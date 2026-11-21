#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# wikipedia/missao_sem_fontes.sh — sorteia artigos da Wikipédia PT que
# carecem de fontes (Categoria:!Artigos que carecem de fontes).
#
# Inspirado na mobilização da Esplanada (2012): sorteia um artigo, você
# adiciona ao menos uma referência com nota de rodapé e o resgata.
#
# Uso:
#   ./missao_sem_fontes.sh              sorteia 1 artigo
#   ./missao_sem_fontes.sh 3            sorteia 3 artigos
#   ./missao_sem_fontes.sh --antigos    só os relicários (Sem fontes há ~10 anos)
#   ./missao_sem_fontes.sh --desde 2016 categoria por ano de marcação
#   ./missao_sem_fontes.sh --abrir      sorteia e abre no navegador
#   ./missao_sem_fontes.sh --navegar    imprime link de sorteio aleatório p/ navegador
#   ./missao_sem_fontes.sh --visitados  mostra o registro de âncoras
#   ./missao_sem_fontes.sh --limpar     apaga o registro de âncoras
#
# Sem rede? O link do --navegar (Special:RandomInCategory) funciona no
# navegador sem nenhuma configuração.
# ---------------------------------------------------------------------------
set -u

API="${WIKI_API:-https://pt.wikipedia.org/w/api.php}"
WIKI_BASE="${WIKI_WIKI_BASE:-https://pt.wikipedia.org/wiki/}"
BASE_DADOS="${NEWS_BASE_DIR:-$HOME/.news_npc_system}"
DIR_WIKI="$BASE_DADOS/wikipedia"
VISITADOS="$DIR_WIKI/visitados.tsv"

CAT_PADRAO="!Artigos que carecem de fontes sem indicação de tema"
CAT_ANTIGA="!Sem fontes há 10 anos"
GUIA="https://pt.wikipedia.org/wiki/Wikip%C3%A9dia:Livro_de_estilo/Notas_de_rodap%C3%A9"
ESPLANADA="https://pt.wikipedia.org/wiki/Wikip%C3%A9dia:Projetos/Manuten%C3%A7%C3%A3o"
NAVEGADOR_OK=""

quantidade=1
modo_categoria="$CAT_PADRAO"
flag_abrir=0

wiki_ajuda() {
    cat <<'AJUDA'
missao_sem_fontes.sh — sorteia artigos da Wikipédia PT sem fontes

Uso: missao_sem_fontes.sh [quantidade] [--antigos | --desde ANO] [--abrir]

  quantidade   quantos artigos sortear (padrão: 1)
  --antigos    sorteia só dos relicários ("Sem fontes há 10 anos")
  --desde ANO  sorteia da subcategoria "carecem de fontes desde ANO"
  --abrir      abre o artigo sorteado no navegador padrão
  --navegar    imprime o link de sorteio aleatório (funciona só no navegador,
               sem dependência da API: Special:RandomInCategory)
  --visitados  mostra as âncoras já sorteadas (evita repetir artigo)
  --limpar     apaga o registro de âncoras
  --ajuda      mostra esta ajuda

Cada artigo sorteado é gravado em ~/.news_npc_system/wikipedia/visitados.tsv
(mesma filosofia de âncora do motor de notícias: nunca repetir coleta).
Referência válida vale a quest M-014 do docs/QUADRO_DE_MISSOES.md.
AJUDA
}

wiki_url_encode() {
    local enc="" bytes b ch
    bytes="$(printf '%s' "$1" | od -An -tx1 | tr -s ' \n' ' ')"
    for b in ${bytes}; do
        ch="$(printf "\\x$b")"
        case "$ch" in
            [a-zA-Z0-9_.~,-]) enc+="$ch" ;;
            ' ') enc+="_" ;;
            *) enc+="%${b^^}" ;;
        esac
    done
    printf '%s' "${enc}"
}

wiki_url_artigo() {
    printf '%s%s' "$WIKI_BASE" "$(wiki_url_encode "$1")"
}

wiki_hash_titulo() {
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "${1,,}" | sha256sum | cut -c1-16
    elif command -v shasum >/dev/null 2>&1; then
        printf '%s' "${1,,}" | shasum | cut -c1-16
    else
        printf '%s' "${1,,}" | md5sum | cut -c1-16
    fi
}

wiki_registrado() {
    [[ -s "$VISITADOS" ]] && grep -qxF "$1" <(cut -f2 "$VISITADOS" 2>/dev/null)
}

wiki_marcar_visitado() {
    mkdir -p "$DIR_WIKI"
    printf '%s\t%s\t%s\n' "$(wiki_hash_titulo "$1")" "$1" "$(date +%F_%H:%M)" >> "$VISITADOS"
}

wiki_baixarCategoria() {
    local cat="$1" hex url
    hex="$(printf '%x' $((RANDOM * 256 + RANDOM * 16 + (RANDOM % 16))))"
    url="$API?action=query&format=json&list=categorymembers&cmtype=page"
    url+="&cmtitle=Categoria%3A$(wiki_url_encode "$cat")"
    url+="&cmsort=sortkey&cmstarthexsortkey=$hex&cmlimit=12"
    if [[ -n "${WIKI_TESTE_RESPOSTA:-}" ]]; then
        cat "${WIKI_TESTE_RESPOSTA}"
        return 0
    fi
    curl -fsSL --max-time 25 --retry 1 \
        --user-agent "NewsNPC/1.0 (missao_sem_fontes.sh; +https://github.com/WTFMYNICKNAME/noticias-estaduais)" \
        "$url" 2>/dev/null || true
}

wiki_extrair_titulos() {
    grep -o '"title":[[:space:]]*"[^"]*"' <<< "${1:-}" \
        | sed 's/^"title":[[:space:]]*"//; s/"$//' | sed 's/\\"/"/g'
}

wiki_abrir_navegador() {
    local url="$1"
    if command -v xdg-open >/dev/null 2>&1; then xdg-open "$url" >/dev/null 2>&1 & return 0; fi
    if command -v open >/dev/null 2>&1;     then open "$url" >/dev/null 2>&1 & return 0; fi
    if command -v cygstart >/dev/null 2>&1; then cygstart "$url" >/dev/null 2>&1 & return 0; fi
    return 1
}

wiki_carta_missao() {
    local titulo="$1" xp="${2:-30}" quest="${3:-M-014}"
    local url_editar
    url_editar="$(wiki_url_artigo "$titulo")?action=edit"
    echo "📜 MISSÃO SORTEADA — \"$quest\" ($xp XP)"
    echo "   Artigo: $titulo"
    echo "   Ler:    $(wiki_url_artigo "$titulo")"
    echo "   Editar: $url_editar"
    echo "   Guia:   $GUIA"
}

wiki_linha_visitados() {
    if [[ -s "$VISITADOS" ]]; then
        echo "🗂️  Âncoras registradas: $(wc -l < "$VISITADOS" | tr -d ' ') ($VISITADOS)"
    fi
}

# ------------------- restaurar IFS / parâmetros -------------------
anterior_ifs="$IFS"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --antigos)  modo_categoria="$CAT_ANTIGA"; shift;;
        --desde)    [[ $# -ge 2 ]] || { echo "ERRO: --desde precisa de um ano (ex.: 2016)." >&2; exit 2; }
                    modo_categoria="!Artigos que carecem de fontes desde $2"; shift 2;;
        --abrir)    flag_abrir=1; shift;;
        --navegar)
                    echo "🎲 Sorteio aleatório no navegador (não precisa de API):"
                    echo "   https://pt.wikipedia.org/Special:RandomInCategory/$(wiki_url_encode "$CAT_PADRAO")"
                    echo "   Antigos: https://pt.wikipedia.org/Special:RandomInCategory/$(wiki_url_encode "$CAT_ANTIGA")"
                    echo "   Coordenação: $ESPLANADA"
                    exit 0;;
        --visitados) cat "$VISITADOS" 2>/dev/null || echo "(nenhuma âncora registrada ainda)"; exit 0;;
        --limpar)   rm -f "$VISITADOS"; echo "🧹 Registro de âncoras apagado: $VISITADOS"; exit 0;;
        --ajuda|-h|--help) wiki_ajuda; exit 0;;
        [0-9]*)     quantidade="$1"; shift;;
        *)          echo "Opção desconhecida: $1 (use --ajuda)." >&2; exit 2;;
    esac
done
IFS="$anterior_ifs"

[[ "$quantidade" -ge 1 ]] || { echo "Quantidade deve ser >= 1." >&2; exit 2; }

# ------------------- sorteio -------------------
XP_MODO=30; QUEST_MODO="M-014"
[[ "$modo_categoria" != "$CAT_PADRAO" ]] && { XP_MODO=40; QUEST_MODO="M-015"; }

sorteados=0
tentativas=0
while [[ $sorteados -lt $quantidade && $tentativas -lt 6 ]]; do
    tentativas=$((tentativas + 1))
    resposta="$(wiki_baixarCategoria "$modo_categoria")"
    mapfile -t titulos < <(wiki_extrair_titulos "$resposta")
    novos=0
    for titulo in "${titulos[@]:-}"; do
        [[ -n "$titulo" ]] || continue
        wiki_registrado "$titulo" && continue
        wiki_marcar_visitado "$titulo"
        wiki_carta_missao "$titulo" "$XP_MODO" "$QUEST_MODO"
        echo
        if [[ $flag_abrir -eq 1 ]]; then
            wiki_abrir_navegador "$(wiki_url_artigo "$titulo")" || \
                echo "(não achei navegador — use o link acima ou --navegar)"
        fi
        sorteados=$((sorteados + 1)); novos=$((novos + 1))
        [[ $sorteados -ge $quantidade ]] && break
    done
    (( novos > 0 )) || break
done

if [[ $sorteados -eq 0 ]]; then
    echo "🧭 Nenhum artigo novo veio do sorteio (categoria vazia, rede indisponível ou"
    echo "   tudo já visitado). Alternativas:"
    echo "   • limpar âncoras locais:  $0 --limpar"
    echo "   • sortear no navegador:   $0 --navegar"
else
    wiki_linha_visitados
    echo "Referência adicionada? Marque a quest $QUEST_MODO no docs/QUADRO_DE_MISSOES.md. 📚"
fi

exit $(( sorteados == 0 ))
