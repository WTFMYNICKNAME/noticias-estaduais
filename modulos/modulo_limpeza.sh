#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# modulo_limpeza.sh
# Retenção de dados: nada além de 7 dias (ou --dias N <= 7) sobrevive.
# Limpa .txt de notícias/podcasts e poda o registro de hashes.
# ---------------------------------------------------------------------------

modulo_limpeza_rodar() {
    local dias="${NEWS_RETENCAO_DIAS:-$NEWS_DIASES_MAXIMO}"
    (( dias > NEWS_DIASES_MAXIMO )) && dias="$NEWS_DIASES_MAXIMO"
    local corte total_removed=0
    corte="$(date -d "$(date +%F) - ${dias} days" +%F 2>/dev/null || printf '')"

    if [[ -z "$corte" ]]; then
        echo "[limpeza] não foi possível calcular a data de corte; nada removido." >&2
        return 1
    fi

    local arquivo dia uf
    for arquivo in "$NEWS_BASE_DIR"/noticias/*/*.txt "$NEWS_BASE_DIR"/podcasts/*/*.txt; do
        [[ -e "$arquivo" ]] || continue
        dia="$(basename "$arquivo" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')"
        [[ -z "$dia" ]] && continue
        if [[ "$dia" < "$corte" ]]; then
            rm -f "$arquivo"
            total_removed=$(( total_removed + 1 ))
        fi
    done

    if [[ -f "$(news_arquivo_registro)" ]]; then
        local tmp
        tmp="$(mktemp)"
        awk -F'\t' -v corte="$corte" '$3 >= corte' "$(news_arquivo_registro)" > "$tmp" \
            && mv "$tmp" "$(news_arquivo_registro)"
    fi

    echo "[limpeza] retenção de ${dias} dias aplicada (${total_removed} arquivo(s) removidos; corte em ${corte})."
}
