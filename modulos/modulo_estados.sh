#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# modulo_estados.sh
# Lista/valida UFs cadastradas e resolve destinos ("todos", "SP,RJ" etc.).
# ---------------------------------------------------------------------------

modulo_estados_rodar() {
    modulo_pastas_rodar
    echo "[estados] ${#NEWS_UF_NOME[@]} unidades federativas carregadas: ${NEWS_UFS_ORDENADAS[@]}"
}

NEWS_UFS_ORDENADAS="AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO"

news_existe_uf() {
    [[ -n "${NEWS_UF_NOME[$1]:-}" ]]
}

# Converte "todos" | "sp,rj" | "SP RJ" em lista de UFs válidas (imprime)
news_resolver_ufs() {
    local alvo="${1:-todos}" uf saida=""
    if [[ "$alvo" == "todos" ]]; then
        for uf in $NEWS_UFS_ORDENADAS; do news_existe_uf "$uf" || continue; saida+="$uf "; done
    else
        alvo="${alvo//,/ }"
        for uf in $alvo; do
            uf="${uf^^}"
            if news_existe_uf "$uf"; then
                saida+="$uf "
            else
                echo "[aviso] UF desconhecida: $uf (ignorada)" >&2
            fi
        done
    fi
    printf '%s' "$saida"
}

news_nome_uf_completo() {
    printf '%s' "${NEWS_UF_NOME[$1]:-$1}"
}
