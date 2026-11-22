#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# ferramentas/portao_pre_voo.sh — pré-voo de testes com hash de agenda.
# Concepção: segunda opinião (sessão Lumo — NPCs Z4P9T2 e D8K5X3).
#
# O hash não valida o servidor, valida a *janela*: SHA-256 de
# "janela|lista-de-scripts" viaja em headers de diagnóstico (X-Test-Run,
# X-Test-Window) em qualquer request de teste. Nos access logs do servidor
# testado, rajada + janela legível + hash estável = teste agendado, e não
# tentativa de intrusão. E o portão local recusa disparar QUALQUER request
# fora da janela assinada — fora dela nada toca na rede.
#
# Honradez técnica (herdada da segunda opinião): headers customizados não são
# validados pelo servidor e são triviais de falsificar — isto é cortesia e
# rastreabilidade, não segurança (isso exigiria HMAC com chave só do admin).
#
# Uso:
#   ./portao_pre_voo.sh carimbo "JANELA" "script1,script2"   → hash (16 hex)
#   ./portao_pre_voo.sh conferir "JANELA"                    → 0 dentro, 1 fora
#   ./portao_pre_voo.sh pre_voo "JANELA" "lista" URL...      → gate + curls
#
# Janela no formato AAAA-MM-DDTHH:MM/AAAA-MM-DDTHH:MM
#   ex.: "2026-11-22T09:00/2026-11-28T16:00"
# Ambiente (para testes): PORTAO_TESTE_NOW congela o "agora";
# PORTAO_TESTE_CURL substitui o binário curl (stub sem rede).
# ---------------------------------------------------------------------------
set -u

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UA_TESTE="NewsNPC-Teste/1.0"

portao_ajuda() {
    cat <<'AJUDA'
portao_pre_voo.sh — pré-voo de testes com hash de agenda

Uso:
  portao_pre_voo.sh carimbo "JANELA" "lista-de-scripts"   → hash + headers
  portao_pre_voo.sh conferir "JANELA"                     → 0 dentro / 1 fora
  portao_pre_voo.sh pre_voo "JANELA" "lista" URL...       → gate + request

Janela: "AAAA-MM-DDTHH:MM/AAAA-MM-DDTHH:MM" (ISOString local, comparação
alfabética = cronológica). O carimbo é determinístico: mesmos insumos,
mesmo hash — o admin(a) pode agrupar o access_log por X-Test-Run.

Exemplo de validação em rajada ANTES de cadastrar fontes novas:
  ./portao_pre_voo.sh pre_voo \
      "2026-11-22T09:00/2026-11-28T16:00" \
      "sistema_unificado.sh,lib/url.sh" \
      "https://g1.globo.com/rss/g1/sp/" \
      "https://g1.globo.com/rss/g1/ac/"
AJUDA
}

portao_agora() {
    printf '%s' "${PORTAO_TESTE_NOW:-$(date +%F'T'%R)}"
}

# comparação por STRING: ISO normalizado ordena igual agenda (o mesmo truque
# da segunda opinião — sem dependência de GNU date)
portao_dentro_da_janela() {
    local janela="${1:-}" agora fim inicio
    [[ "$janela" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}$ ]] || return 2
    inicio="${janela%%/*}"
    fim="${janela##*/}"
    agora="$(portao_agora)"
    if [[ "$agora" < "$inicio" || "$agora" > "$fim" ]]; then return 1; fi
    return 0
}

portao_carimbo() {
    local janela="${1:-}" lista="${2:-}"
    [[ -n "$janela" && -n "$lista" ]] || return 2
    printf '%s\n' "$(printf '%s|%s' "$janela" "$lista" | sha256sum | cut -c1-16)"
}

portao_pre_voo() {
    local janela="${1:-}" lista="${2:-}"; shift 2 2>/dev/null || true
    [[ -n "$janela" && -n "$lista" ]] || { portao_ajuda; return 2; }
    local hash="$(portao_carimbo "$janela" "$lista")"
    if ! portao_dentro_da_janela "$janela"; then
        echo "[PORTÃO] fora da janela autorizada ($janela) — teste abortado, nada disparado" >&2
        return 3
    fi
    echo "[PORTÃO] dentro da janela — carimbo $hash"
    local url saida
    for url in "$@"; do
        if [[ "${PORTAO_TESTE_CURL:-}" != "" ]]; then
            saida="$("$PORTAO_TESTE_CURL" "$url" \
                -H "User-Agent: $UA_TESTE (agenda=$janela)" \
                -H "X-Test-Run: $hash" \
                -H "X-Test-Window: $janela")"
        else
            saida="$(curl -sS --max-time 25 --retry 1 -o /dev/null -w '%{http_code} %{time_total}' \
                "$url" \
                -H "User-Agent: $UA_TESTE (agenda=$janela)" \
                -H "X-Test-Run: $hash" \
                -H "X-Test-Window: $janela" 2>&1)"
        fi
        printf '%-50s %s\n' "$url" "$saida"
    done
    return 0
}

case "${1:-ajuda}" in
    carimbo)  shift; portao_carimbo "${1:-}" "${2:-}" \
                  || { echo "Uso: portao_pre_voo.sh carimbo \"JANELA\" \"lista\"" >&2; exit 2; };;
    conferir) shift
              portao_dentro_da_janela "${1:-}"; resposta=$?
              case $resposta in
                  0) echo "✅ dentro da janela ($(portao_agora))"; exit 0;;
                  1) echo "⛔ fora da janela ($(portao_agora) vs ${1:-})"; exit 1;;
                  *) echo "Janela inválida (use AAAA-MM-DDTHH:MM/AAAA-MM-DDTHH:MM)" >&2; exit 2;;
              esac;;
    pre_voo)  shift; portao_pre_voo "$@";;
    ajuda|-h|--help) portao_ajuda; exit 0;;
    *)        echo "Comando desconhecido: $1" >&2; portao_ajuda; exit 2;;
esac
