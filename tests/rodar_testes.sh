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


# ---------------------------------------------------------------
# ferramentas/detector_dupes.sh + ferramentas/ideias.sh
# ---------------------------------------------------------------
"$RAIZ/ferramentas/detector_dupes.sh" >/dev/null 2>&1
checa "detector: repositório limpo de duplicatas exatas" "[[ $? -eq 0 ]]"

PASTA_DUP="$(mktemp -d)"
cat > "$PASTA_DUP/a.sh" <<'FIXA'
coisa() {
    echo "linha um aqui"
    echo "linha dois aqui"
    echo "linha tres aqui"
}
FIXA
cp "$PASTA_DUP/a.sh" "$PASTA_DUP/b.sh"
"$RAIZ/ferramentas/detector_dupes.sh" "$PASTA_DUP" >/dev/null 2>&1
checa "detector: flag duplicata exata em fixture" "[[ $? -eq 1 ]]"
rm -rf "$PASTA_DUP"

REGISTRO_TESTE="$(mktemp)"
IDEIAS_ARQUIVO="$REGISTRO_TESTE" "$RAIZ/ferramentas/ideias.sh" registrar "Ideia de Teste" "uma descrição qualquer" >/dev/null
checa "ideias: ideia registrada com ID" "grep -q 'IDEIA-[0-9a-f]\{8\}' '$REGISTRO_TESTE'"
IDEIAS_ARQUIVO="$REGISTRO_TESTE" "$RAIZ/ferramentas/ideias.sh" registrar "Ideia de Teste" "uma descrição qualquer" >/dev/null 2>&1
checa "ideias: duplicata recusada (1 registro só)" "[[ \$(grep -c 'IDEIA-' '$REGISTRO_TESTE') -eq 1 ]]"
IDEIAS_ARQUIVO="$REGISTRO_TESTE" "$RAIZ/ferramentas/ideias.sh" registrar "Outra Ideia" "descrição diferente" >/dev/null
checa "ideias: segunda ideia registrada" "[[ \$(grep -c 'IDEIA-' '$REGISTRO_TESTE') -eq 2 ]]"
rm -f "$REGISTRO_TESTE"


# ---------------------------------------------------------------
# ferramentas/portao_pre_voo.sh — gate de testes com hash de agenda
# ---------------------------------------------------------------
PORTAO="$RAIZ/ferramentas/portao_pre_voo.sh"
JANELA="2026-11-22T09:00/2026-11-28T16:00"
CARIMBO1="$("$PORTAO" carimbo "$JANELA" "sistema_unificado.sh,lib/url.sh")"
CARIMBO2="$("$PORTAO" carimbo "$JANELA" "sistema_unificado.sh,lib/url.sh")"
checa "portao: carimbo determinístico (16 hex)" "[[ '$CARIMBO1' == '$CARIMBO2' && \${#CARIMBO1} -eq 16 ]]"
checa "portao: dentro da janela com agora congelado: 2026-11-25T10:00" "PORTAO_TESTE_NOW='2026-11-25T10:00' '$PORTAO' conferir '$JANELA' >/dev/null 2>&1"
checa "portao: fora da janela recusa (exit 1)" "! PORTAO_TESTE_NOW='2026-12-01T23:59' '$PORTAO' conferir '$JANELA' >/dev/null 2>&1"
checa "portao: janela estragada recusa (exit 2)" "! PORTAO_TESTE_NOW='2026-11-25T10:00' '$PORTAO' conferir 'janela-offline' >/dev/null 2>&1"
STUB_CURL="$(mktemp)"
printf '#!/usr/bin/env bash\necho "STUB args: $*"\n' > "$STUB_CURL"; chmod +x "$STUB_CURL"
SAIDA_PV="$(PORTAO_TESTE_NOW='2026-11-25T10:00' PORTAO_TESTE_CURL="$STUB_CURL" "$PORTAO" pre_voo "$JANELA" "lista" 'https://exemplo.teste/feed.xml' 2>&1)"
checa "portao: pre_voo in-window dispara com carimbo" "grep -q 'X-Test-Run:' <<< \"$SAIDA_PV\""
SAIDA_PV_FORA="$(PORTAO_TESTE_NOW='2026-12-01T23:59' PORTAO_TESTE_CURL="$STUB_CURL" "$PORTAO" pre_voo "$JANELA" "lista" 'https://exemplo.teste/feed.xml' 2>&1; true)"
checa "portao: pre_voo fora da janela aborta sem rede" "grep -q 'nada disparado' <<< \"$SAIDA_PV_FORA\""
rm -f "$STUB_CURL"




echo
echo "-----------------------------------------"
echo "RESULTADO: $passou passou / $falhou falhou"
echo "Dados de teste em: $NEWS_BASE_DIR"
echo "-----------------------------------------"
rm -rf "$NEWS_BASE_DIR" "$TESTE_FEEDS"
(( falhou == 0 )) || exit 1
