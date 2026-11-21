#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# tests/rodar_testes.sh — testes de integração usando fixtures locais (file://)
# Roda fora do repo: bash tests/rodar_testes.sh
# ---------------------------------------------------------------------------
set -u
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export NEWS_BASE_DIR="$(mktemp -d)"
TESTE_FEEDS="$(mktemp)"
export NEWS_TESTE_FEEDS_FILE="$TESTE_FEEDS"

passou=0; falhou=0
ok()   { echo "PASS: $1"; passou=$((passou+1)); }
falha(){ echo "FAIL: $1"; falhou=$((falhou+1)); }
checa() {
    if eval "${2}"; then ok "$1"; else falha "$1 (condição: $2)"; fi
    if ! eval "${2}"; then return 1; fi
    return 0
}

# fixtures apontando para os arquivos locais
cat > "$TESTE_FEEDS" <<EOF
SP|G1 Sao Paulo|file://$RAIZ/tests/fixtures/g1_sp.xml
SP|Agregador Teste|file://$RAIZ/tests/fixtures/google_news_sp.xml
EOF

# roda a coleta com o orquestrador completo
SAIDA="$("$RAIZ/sistema_unificado.sh" atualizar SP 2>&1)"
HOJE="$(date +%F)"
ARQ="$NEWS_BASE_DIR/noticias/SP/$HOJE.txt"

checa "arquivo do dia criado" "[[ -s '$ARQ' ]]"

BLOCOS="$(grep -c '^\[âncora\]' "$ARQ" || true)"
checa "dedupe: 4 blocos esperados (2 duplicados + 1 antigo excluídos), obtidos \$BLOCOS" "[[ \$BLOCOS -eq 4 ]]"

checa "âncora contém hash"   "grep -q 'hash=[a-f0-9]\{8,\}; fonte=' '$ARQ'"
checa "âncora contém fonte"  "grep -q 'fonte=Jornal Agregador SP' '$ARQ'"
checa "âncora contém link"   "grep -q 'link=https://g1.globo.com' '$ARQ'"
checa "resumo curto gravado" "grep -q '^Resumo: ' '$ARQ'"

# segunda colocação: tudo vira duplicado
NOVAS_2="$("$RAIZ/sistema_unificado.sh" atualizar SP 2>&1 | grep -oE '[0-9]+ nova\(s\)' | grep -oE '^[0-9]+')"
checa "dedupe em segunda execução (zero novas)" "[[ '${NOVAS_2:-0}' -eq 0 ]]"

# podcast
"$RAIZ/sistema_unificado.sh" podcast SP >/dev/null 2>&1
POD="$NEWS_BASE_DIR/podcasts/SP/$HOJE-roteiro.txt"
checa "roteiro de podcast gerado" "[[ -s '$POD' ]]"
checa "roteiro estilo 'Conte as últimas novidades'" "grep -q 'últimas novidades' '$POD'"
checa "roteiro contém fontes áncoradas" "grep -q '(Fonte: G1 Sao Paulo' '$POD'"

# retenção: fabrica arquivo de 10 dias atrás e depois limpa
VELHA="$NEWS_BASE_DIR/noticias/SP/$(date -d "$(date +%F) - 10 days" +%F).txt"
{ echo "arquivo velho de teste"; } > "$VELHA"
"$RAIZ/sistema_unificado.sh" limpar >/dev/null 2>&1
checa "arquivo mais velho que 7 dias removido" "[[ ! -f '$VELHA' ]]"
checa "arquivos atuais preservados" "[[ -s '$ARQ' ]]"

# status/ler
checa "comando status executa" "'$RAIZ/sistema_unificado.sh' status >/dev/null 2>&1"
SAIDA_LER="$("$RAIZ/sistema_unificado.sh" ler SP 2>&1)"
checa "comando ler imprime .txt com âncora" "grep -q '^\[âncora\]' <<< \"\$SAIDA_LER\""


# ---------------------------------------------------------------
# wikipedia/missao_sem_fontes.sh — sorteio de artigos sem fontes
# ---------------------------------------------------------------
WIKI_FIXTURE="$RAIZ/tests/fixtures/wiki_api.json"
SAIDA_W1="$(WIKI_TESTE_RESPOSTA="$WIKI_FIXTURE" NEWS_BASE_DIR="$NEWS_BASE_DIR" "$RAIZ/wikipedia/missao_sem_fontes.sh" 2 2>&1)"
checa "wikipedia: missão impressa com link do artigo" "grep -q 'https://pt.wikipedia.org/wiki/' <<< \"$SAIDA_W1\""
checa "wikipedia: sorteou exatamente 2" "[[ \$(grep -c 'MISSÃO SORTEADA' <<< \"$SAIDA_W1\") -eq 2 ]]"
checa "wikipedia: âncoras registradas (2 linhas)" "[[ \$(wc -l < '$NEWS_BASE_DIR/wikipedia/visitados.tsv') -eq 2 ]]"
checa "wikipedia: carta aponta a quest M-014" "grep -q 'M-014' <<< \"$SAIDA_W1\""

SAIDA_W2="$(WIKI_TESTE_RESPOSTA="$WIKI_FIXTURE" NEWS_BASE_DIR="$NEWS_BASE_DIR" "$RAIZ/wikipedia/missao_sem_fontes.sh" 99 2>&1)"
checa "wikipedia: dedupe — sorteia só as não visitadas (3)" "[[ \$(grep -c 'MISSÃO SORTEADA' <<< \"$SAIDA_W2\") -eq 3 ]]"
checa "wikipedia: mostra total de âncoras (5)" "grep -q 'Âncoras registradas: 5' <<< \"$SAIDA_W2\""

SAIDA_W3="$(WIKI_TESTE_RESPOSTA="$WIKI_FIXTURE" NEWS_BASE_DIR="$NEWS_BASE_DIR" "$RAIZ/wikipedia/missao_sem_fontes.sh" 2>&1; true)"
checa "wikipedia: tudo visitado → orienta --navegar/--limpar" "grep -q '\--navegar' <<< \"$SAIDA_W3\""

"$RAIZ/wikipedia/missao_sem_fontes.sh" --limpar >/dev/null 2>&1 || true


echo
echo "-----------------------------------------"
echo "RESULTADO: $passou passou / $falhou falhou"
echo "Dados de teste em: $NEWS_BASE_DIR"
echo "-----------------------------------------"
rm -rf "$NEWS_BASE_DIR" "$TESTE_FEEDS"
(( falhou == 0 )) || exit 1
