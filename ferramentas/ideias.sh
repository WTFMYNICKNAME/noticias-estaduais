#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# ferramentas/ideias.sh — registro de ideias + busca de prior art no GitHub.
# Motivação (a meta-regra do projeto): antes de construir algo grande, conferir
# se ninguém já construiu; e dar a cada ideia um ID assinado com data — para
# nunca mais descobrir tarde demais que alguém fizera a mesma coisa em paralelo.
#
# Uso:
#   ./ideias.sh registrar "Título" "Descrição do que pretende construir"
#   ./ideias.sh buscar "termos de busca"       (gh CLI; sem gh, gera link de busca)
#   ./ideias.sh listar
#   ./ideias.sh ajuda
#
# O registro vive em docs/REGISTRO_IDEIAS.md e cada ideia recebe um ID
# IDEIA-<hash> calculado do texto (mesmo texto = mesmo ID = recusa deuplicata).
# ---------------------------------------------------------------------------
set -u

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$RAIZ/lib/url.sh" ]] && source "$RAIZ/lib/url.sh"
ARQUIVO="${IDEIAS_ARQUIVO:-$RAIZ/docs/REGISTRO_IDEIAS.md}"
MARCA_IDEIAS="<!-- ideias:início -->"
MARCA_BUSCAS="<!-- checagens:início -->"

ideia_ajuda() {
    cat <<'AJUDA'
ideias.sh — registro de ideias + prior art

Uso:
  ideias.sh registrar "Título" "Descrição"   — assina a ideia (ID + data)
  ideias.sh buscar TERMOS...                 — procura projetos parecidos no GitHub
  ideias.sh listar                           — mostra as ideias registradas
  ideias.sh ajuda                            — mostra esta ajuda

buscar usa `gh search repos` se o GitHub CLI estiver autenticado; sem gh,
imprime um link pronto de busca para o navegador. Toda checagem fica
registrada com data e resultado — prova de que a originalidade foi
verificada antes de investir horas.
AJUDA
}

ideia_hash() {
    local normalizado
    normalizado="$(printf '%s' "${1,,}" | tr -s '[:space:]' ' ')"
    printf '%s' "$normalizado" | sha256sum | cut -c1-8
}

ideia_inicializar() {
    [[ -f "$ARQUIVO" ]] && return 0
    mkdir -p "$(dirname "$ARQUIVO")"
    cat > "$ARQUIVO" <<'CABECA'
# 🪪 Registro de Ideias

> Ideias assinadas com ID e data; checagens de originalidade documentadas.
> Gerado por `ferramentas/ideias.sh` — não edite linhas de ID à mão.
CABECA
}

ideia_registrar() {
    local titulo="${1:-}" descricao="${2:-}"
    [[ -n "$titulo" && -n "$descricao" ]] || { echo "Uso: ideias.sh registrar \"Título\" \"Descrição\"" >&2; return 2; }
    local id
    id="$(ideia_hash "$titulo|$descricao")"
    if [[ -f "$ARQUIVO" ]] && grep -qF "IDEIA-$id" "$ARQUIVO"; then
        echo "♻️  Ideia já registrada (IDEIA-$id) — nada a fazer:"
        grep -F "IDEIA-$id" "$ARQUIVO"
        return 1
    fi
    ideia_inicializar
    grep -qF "$MARCA_IDEIAS" "$ARQUIVO" || \
        printf '\n## 🪪 Ideias assinadas\n%s\n' "$MARCA_IDEIAS" >> "$ARQUIVO"
    printf '%s\n' "- **IDEIA-$id** ($(date +%F)) — **$titulo** — $descricao" >> "$ARQUIVO"
    echo "🪪 Registrada: IDEIA-$id — $titulo ($ARQUIVO)"
}

ideia_buscar() {
    [[ $# -gt 0 ]] || { echo "Uso: ideias.sh buscar TERMOS..." >&2; return 2; }
    local termos="$*" resultado resumo
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        echo "🔎 Buscando projetos parecidos no GitHub: \"$termos\""
        resultado="$(gh search repos "$termos" --limit 6 \
            --json fullName,description,stargazersCount \
            --template '{{range .}}{{.fullName}}  ⭐{{.stargazersCount}}  {{.description}}{{"\n"}}{{end}}' 2>/dev/null)" || resultado=""
        if [[ -n "$resultado" ]]; then
            printf '%s\n' "$resultado"
            resumo="$(printf '%s\n' "$resultado" | wc -l | tr -d ' ') achados: $(printf '%s' "$resultado" | head -3 | tr '\n' ' ¦ ')"
        else
            echo "   (nada encontrado — território livre para construir!)"
            resumo="nenhum resultado no GitHub"
        fi
    else
        local link="https://github.com/search?q=$(url_encode "$termos")&type=repositories"
        echo "GitHub CLI indisponível — checagem manual:"
        echo "   $link"
        resumo="checagem manual pendente: $link"
    fi
    if ! grep -qF "$MARCA_BUSCAS" "$ARQUIVO"; then
        printf '\n%s\n%s\n' "## 🔎 Checagens de originalidade" "$MARCA_BUSCAS" >> "$ARQUIVO"
    fi
    printf '%s\n' "- $(date +%F) — buscar \"$termos\" → $resumo" >> "$ARQUIVO"
    echo "📝 Checagem registrada em $ARQUIVO"
}

case "${1:-ajuda}" in
    registrar) shift; ideia_registrar "${1:-}" "${2:-}";;
    buscar)    shift; ideia_buscar "$@";;
    listar)    cat "$ARQUIVO" 2>/dev/null || echo "(nenhuma ideia registrada ainda)";;
    ajuda|-h|--help) ideia_ajuda; exit 0;;
    *)         echo "Comando desconhecido: $1" >&2; ideia_ajuda; exit 2;;
esac
