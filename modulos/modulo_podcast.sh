#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# modulo_podcast.sh
# Gera roteiro textual estilo "Conte as últimas novidades" (Google Assistente)
# a partir dos arquivos .txt já deduplicados de cada UF.
# ---------------------------------------------------------------------------

modulo_podcast_gerar() {
    local uf="$1" dias="${2:-$NEWS_DIASES_MAXIMO}"
    local hoje destino blocos
    hoje="$(date +%F)"
    destino="$(news_arquivo_podcast "$uf" "$hoje")"

    [[ -z "$(news_ler_blocos_uf "$uf" "$dias" | grep '^\[âncora\]' || true)" ]] && return 1

    local nome="$(news_nome_uf_completo "$uf")"
    {
        printf 'ROTEIRO DE PODCAST — "Conte as últimas novidades" — %s (%s)\n' "$nome" "$uf"
        printf 'Janela: últimos %s dias | Gerado em: %s\n' "$dias" "$(date '+%F %H:%M %Z')"
        printf '%s\n' "$(printf '=%.0s' {1..70})"
        printf '\n[LOCUTOR]\n'
        printf 'Olá! Aqui está o resumo das últimas novidades de %s, direto das principais fontes de notícias do estado.\n' "$nome"
    } > "$destino"

    local n=0 linha hash fonte link titulo resumo
    local pendente=0
    while IFS= read -r linha; do
        if [[ "$linha" == "[âncora]"* ]]; then
            hash="$(printf '%s' "$linha" | sed -n 's/.*hash=\([^;]*\);.*/\1/p')"
            fonte="$(printf '%s' "$linha" | sed -n 's/.*fonte=\([^;]*\);.*/\1/p')"
            link="$(printf '%s' "$linha" | sed -n 's/.*link=\([^;]*\);.*/\1/p')"
            pendente=1
        elif [[ "$linha" == "Título: "* ]]; then
            titulo="${linha#Título: }"
        elif [[ "$linha" == "Resumo: "* ]]; then
            resumo="${linha#Resumo: }"
            if [[ "$pendente" -eq 1 && -n "${titulo:-}" ]]; then
                n=$(( n + 1 ))
                {
                    printf '\nNotícia %s — %s\n' "$n" "$titulo"
                    printf '%s\n' "${resumo:-}"
                    printf '(Fonte: %s — %s | âncora: hash=%s)\n' "$fonte" "$link" "$hash"
                } >> "$destino"
                pendente=0 titulo="" resumo=""
            fi
        fi
    done <<< "$(news_ler_blocos_uf "$uf" "$dias")"

    {
        printf '\n[LOCUTOR]\n'
        printf 'Era isso! Para ler as matérias completas, confira os links das fontes em cada bloco.\n'
        printf 'Total de notícias nesta edição: %s\n' "$n"
    } >> "$destino"

    printf '%s' "$destino"
}
