#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# modulo_noticias.sh
# Parseia o cache RSS, deduplica por hash (âncora de fonte) e grava os .txt
# por estado, respeitando a janela máxima de 7 dias.
#
# O registro anti-duplicação fica em $NEWS_BASE_DIR/registro/hashes.tsv:
#   <hash>\t<UF>\t<AAAA-MM-DDTHH:MM:SS>\t<link>
#
# Bloco gravado em noticias/<UF>/<AAAA-MM-DD>.txt:
#   [âncora] hash=<...>; fonte=<...>; link=<...>; coletado=<ISO>
#   Título: ...
#   Resumo: ...
# ---------------------------------------------------------------------------

news_normalizar_titulo() {
    local t
    t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
    t="$(printf '%s' "$t" | iconv -f UTF-8 -t ASCII//TRANSLIT//IGNORE 2>/dev/null || printf '%s' "$t")"
    printf '%s' "$t" | tr -cd 'a-z0-9' | _news_hash
}

news_hash_do_link() {
    printf '%s' "$1" | _news_hash
}

news_hash_conhecido() {
    local hash="$1" uf="$2"
    grep -qF "$(printf '%s\t%s\t' "$hash" "$uf")" "$(news_arquivo_registro)" 2>/dev/null
}

news_hash_conhecido_arquivo() {
    local hash="$1" uf="$2" arquivo
    shopt -s nullglob
    for arquivo in "$(news_dir_noticias "$uf")"/*.txt; do
        grep -q "hash=${hash};" "$arquivo" 2>/dev/null && return 0
    done
    shopt -u nullglob
    return 1
}

news_registrar_hash() {
    local hash="$1" uf="$2" quando="$3" link="$4"
    printf '%s\t%s\t%s\t%s\n' "$hash" "$uf" "$quando" "$link" >> "$(news_arquivo_registro)"
}

# "Título - Nome do Agregador" -> "Título<TAB>Agregador"
news_separar_fonte_do_titulo() {
    local titulo="$1" provedor
    provedor="${titulo##* - }"
    if [[ "$provedor" != "$titulo" && ${#provedor} -le 40 ]]; then
        printf '%s\t%s\n' "${titulo% - *}" "$provedor"
    else
        printf '%s\t%s\n' "$titulo" ""
    fi
}

news_data_para_epoch() {
    date -d "$1" +%s 2>/dev/null || echo ""
}

news_data_iso_agora() {
    date +%Y-%m-%dT%H:%M:%S
}

news_data_hoje() {
    date +%Y-%m-%d
}

# Processa uma UF: baixa fontes, deduplica e grava os .txt. Imprime nº novos.
noticias_processar_uf() {
    local uf="$1" limite="${2:-12}" dias="$NEWS_DIASES_MAXIMO"
    local hoje agora epoch_limite epoch_item total=0
    local xml bloco titulo_crudo titulo fonte_crudo link pubdate resumo
    local h_titulo h_link

    agora="$(news_data_iso_agora)"
    hoje="$(news_data_hoje)"
    epoch_limite="$(news_data_para_epoch "$hoje - ${dias} days")"
    news_atualizar_cache_uf "$uf"

    shopt -s nullglob
    for xml in "$(news_dir_cache "$uf")"/*.xml; do
        [[ -s "$xml" ]] || continue
        nome_fonte="$(news_nome_fonte_legivel "$(basename "$xml" .xml)")"
        while IFS= read -r -d $'\037' bloco; do
            [[ -z "$bloco" ]] && continue

            titulo_crudo="$(xml_extrai_campo "$bloco" title | xml_para_texto)"
            link="$(xml_extrai_campo "$bloco" link | xml_para_texto)"
            pubdate="$(xml_extrai_campo "$bloco" pubDate | xml_para_texto)"
            [[ -z "$titulo_crudo" || -z "$link" ]] && continue

            epoch_item="$(news_data_para_epoch "$pubdate")"
            if [[ -n "$epoch_item" && -n "$epoch_limite" && "$epoch_item" -lt "$epoch_limite" ]]; then
                continue
            fi

            printf -v linha '%s' "$titulo_crudo"
            IFS=$'\t' read -r titulo fonte_crudo <<< "$(news_separar_fonte_do_titulo "$linha")"
            [[ -z "$fonte_crudo" ]] && fonte_crudo="$nome_fonte"

            h_titulo="$(news_normalizar_titulo "$titulo")"
            h_link="$(news_hash_do_link "$link")"

            if news_hash_conhecido "$h_link" "$uf" || news_hash_conhecido "$h_titulo" "$uf" \
               || news_hash_conhecido_arquivo "$h_link" "$uf" || news_hash_conhecido_arquivo "$h_titulo" "$uf"; then
                continue
            fi

            resumo="$(xml_extrai_campo "$bloco" description | xml_para_texto | news_limpar_texto | news_resumir 320)"
            if [[ "$resumo" == "$titulo"* || ${#resumo} -lt 40 ]]; then
                resumo="(Ver matéria completa na fonte.)"
            fi

            noticias_gravar_bloco "$uf" "$hoje" "$h_link" "$fonte_crudo" "$link" "$agora" "$titulo" "$resumo"
            news_registrar_hash "$h_link" "$uf" "$agora" "$link"
            news_registrar_hash "$h_titulo" "$uf" "$agora" "$titulo"
            total=$(( total + 1 ))
            (( total >= limite )) && break 2
        done < <(xml_itens < "$xml")
    done
    shopt -u nullglob

    printf '%s' "$total"
}

news_nome_fonte_legivel() {
    printf '%s' "$1" | sed 's/_xml$//; s/_/ /g'
}

# Grava um bloco de notícia no arquivo do dia da UF.
noticias_gravar_bloco() {
    local uf="$1" hoje="$2" hash="$3" fonte="$4" link="$5" agora="$6" titulo="$7" resumo="$8"
    local arquivo
    arquivo="$(news_arquivo_dia "$uf" "$hoje")"
    [[ -s "$arquivo" ]] || {
        {
            printf 'NOTÍCIAS ESTADUAIS — %s (%s) — %s\n' "$(news_nome_uf_completo "$uf")" "$uf" "$hoje"
            printf 'Janela máxima: %s dias | Gerado em: %s\n' "$NEWS_DIASES_MAXIMO" "$agora"
            printf '\n'
        } >> "$arquivo"
    }
    {
        printf '[âncora] hash=%s; fonte=%s; link=%s; coletado=%s\n' "$hash" "$fonte" "$link" "$agora"
        printf 'Título: %s\n' "$titulo"
        printf 'Resumo: %s\n' "$resumo"
        printf '\n'
    } >> "$arquivo"
}

# Lê blocos das notícias dentro da janela de dias da UF (usado pelo podcast).
news_ler_blocos_uf() {
    local uf="$1" dias="${2:-$NEWS_DIASES_MAXIMO}"
    local corte arquivo dia
    corte="$(date -d "$(date +%F) - ${dias} days" +%F 2>/dev/null || printf '')"
    shopt -s nullglob
    for arquivo in "$(news_dir_noticias "$uf")"/*.txt; do
        dia="$(basename "$arquivo" .txt)"
        [[ -n "$corte" && "$dia" < "$corte" ]] && continue
        cat "$arquivo"
    done
    shopt -u nullglob
}

# Lê blocos das notícias em janela de dias (usado pelo módulo de podcast).
news_ler_blocos_uf_direto() { news_ler_blocos_uf "$@"; }
