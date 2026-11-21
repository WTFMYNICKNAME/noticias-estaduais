#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# modulo_fontes.sh
# Baixa (ou lê, em modo teste) os RSS das fontes de cada UF para o cache.
# ---------------------------------------------------------------------------

NEWS_TESTE_FEEDS_FILE="${NEWS_TESTE_FEEDS_FILE:-}"
NEWS_CURL_UA="NewsNPC/1.0 (open source; bash)"

# Resolve função de hash disponível no sistema (sha256 -> shasum -> md5).
news_ferramenta_hash() {
    if command -v sha256sum >/dev/null 2>&1; then
        _news_hash() { sha256sum | cut -d' ' -f1; }
    elif command -v shasum >/dev/null 2>&1; then
        _news_hash() { shasum -a 256 | cut -d' ' -f1; }
    else
        _news_hash() { md5sum | cut -d' ' -f1; }
    fi
}

# Imprime "NOME<TAB>URL" para cada fonte da UF informada.
news_listar_fontes_uf() {
    local uf="$1" item nome url extras ifs_salvo="$IFS"
    [[ -z "${NEWS_UF_FONTES[$uf]:-}" ]] && return 0
    if [[ -n "$NEWS_TESTE_FEEDS_FILE" ]]; then
        grep -E "^${uf}\|" "$NEWS_TESTE_FEEDS_FILE" 2>/dev/null \
            | while IFS='|' read -r _uf nome url; do
                [[ -n "$url" ]] && printf '%s\t%s\n' "$nome" "$url"
              done
        return 0
    fi
    IFS='|'
    for item in ${NEWS_UF_FONTES[$uf]}; do
        nome="${item%%::*}"
        url="${item#*::}"
        [[ "$item" == *'::'* ]] || continue
        if [[ "$nome" == "BUSCA" ]]; then
            url="$(news_url_busca_google "$url")"
        fi
        [[ -n "$url" ]] && printf '%s\t%s\n' "$nome ($uf)" "$url"
    done
    IFS="$ifs_salvo"
    extras="${NEWS_EXTRA_FONTES[$uf]:-}"
    [[ -z "$extras" ]] && return 0
    for url in $extras; do
        nome="$(printf '%s' "$url" | sed -E 's#https?://([^/]+).*#\1#')"
        printf '%s\t%s\n' "$nome ($uf)" "$url"
    done
}

news_baixar_fonte() {
    local nome="$1" url="$2" destino="$3"
    if [[ "$url" == file://* ]]; then
        cat "${url#file://}" > "$destino" 2>/dev/null
        return 0
    fi
    curl -fsSL --max-time 25 --retry 1 --retry-delay 2 \
         --user-agent "$NEWS_CURL_UA" \
         -o "$destino" "$url" 2>/dev/null
}

news_filesafe() {
    printf '%s' "${1//[^a-zA-Z0-9._-]/_}"
}

# Baixa todas as fontes de uma UF (com pequena concorrência).
news_atualizar_cache_uf() {
    local uf="$1" tasks=0 nome url destino
    while IFS=$'\t' read -r nome url; do
        [[ -z "$url" ]] && continue
        destino="$(news_dir_cache "$uf")/$(news_filesafe "$nome").xml"
        (( tasks >= NEWS_TAMANHO_LOTE )) && wait
        ( news_baixar_fonte "$nome" "$url" "$destino" ) &
        tasks=$(( tasks + 1 ))
    done < <(news_listar_fontes_uf "$uf")
    wait
    return 0
}
