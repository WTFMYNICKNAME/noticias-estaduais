# ---------------------------------------------------------------------------
# lib/url.sh — utilidades de codificação de URL (bash puro, sem curl extra)
# Fonte única do codificador: config/estados.sh e wikipedia/ compartilham aqui.
# ---------------------------------------------------------------------------

# url_encode "texto" → texto percent-encodado (espaço = %20).
# Caracteres seguros mantidos cru: A-Z a-z 0-9 . _ ~ , -
url_encode() {
    local enc="" bytes b ch
    bytes="$(printf '%s' "$1" | od -An -tx1 | tr -s ' \n' ' ')"
    for b in ${bytes}; do
        ch="$(printf "\\x$b")"
        case "$ch" in
            [a-zA-Z0-9_.~,-]) enc+="$ch" ;;
            ' ') enc+="%20" ;;
            *) enc+="%${b^^}" ;;
        esac
    done
    printf '%s' "${enc}"
}

# url_encode_caminho "título" → igual url_encode, mas espaço vira "_"
# (convenção dos caminhos de artigo da Wikipédia: /wiki/Chula_(Rio_Grande_do_Sul))
url_encode_caminho() {
    local enc
    enc="$(url_encode "$1")"
    printf '%s' "${enc//%20/_}"
}
