#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# config/estados.sh
# Cadastro das 27 unidades federativas do Brasil e das principais fontes de
# notícias estaduais usadas pelo News NPC Engine.
#
# Fontes por UF:
#   - Feed RSS do g1 do estado (https://g1.globo.com/rss/g1/<uf>/)
#   - Feeds de busca no Google News (prefixo "@BUSCA:") com janela when:7d
#
# A variável NEWS_EXTRA_FONTES[também por UF] pode receber URLs RSS diretas
# adicionais separadas por "|". Feeds que falharem são ignorados sem abortar.
#
# janela máxima de novidades: 7 dias (see modulo_limpeza.sh)
# ---------------------------------------------------------------------------

NEWS_DIASES_MAXIMO=7

declare -gA NEWS_UF_NOME
declare -gA NEWS_UF_CAPITAL
declare -gA NEWS_UF_GENTILICO
declare -gA NEWS_UF_FONTES
declare -gA NEWS_EXTRA_FONTES

news_registrar_uf() {
    local uf="$1" nome="$2" capital="$3" gentilico="$4"
    NEWS_UF_NOME["${uf}"]="$nome"
    NEWS_UF_CAPITAL["${uf}"]="$capital"
    NEWS_UF_GENTILICO["${uf}"]="$gentilico"
    NEWS_UF_FONTES["${uf}"]="G1::https://g1.globo.com/rss/g1/${uf,,}/"
    NEWS_UF_FONTES["${uf}"]+="|BUSCA::notícias ${nome}"
    NEWS_UF_FONTES["${uf}"]+="|BUSCA::${capital}"
}

# ------------------------- TABELA DE ESTADOS -------------------------
# UF|Nome|Capital|Gentílico
while IFS='|' read -r _uf _nome _capital _gentilico; do
    [ -z "${_uf}" ] && continue
    case "${_uf}" in \#*) continue ;; esac
    news_registrar_uf "${_uf}" "${_nome}" "${_capital}" "${_gentilico}"
done <<'TABELA_UFS'
AC|Acre|Rio Branco|acriano
AL|Alagoas|Maceió|alagoano
AP|Amapá|Macapá|amapaense
AM|Amazonas|Manaus|amazonense
BA|Bahia|Salvador|baiano
CE|Ceará|Fortaleza|cearense
DF|Distrito Federal|Brasília|brasiliense
ES|Espírito Santo|Vitória|espírito-santense
GO|Goiás|Goiânia|goiano
MA|Maranhão|São Luís|maranhense
MT|Mato Grosso|Cuiabá|mato-grossense
MS|Mato Grosso do Sul|Campo Grande|sul-mato-grossense
MG|Minas Gerais|Belo Horizonte|mineiro
PA|Pará|Belém|paraense
PB|Paraíba|João Pessoa|paraibano
PR|Paraná|Curitiba|paranaense
PE|Pernambuco|Recife|pernambucano
PI|Piauí|Teresina|piauiense
RJ|Rio de Janeiro|Rio de Janeiro|fluminense
RN|Rio Grande do Norte|Natal|potiguar
RS|Rio Grande do Sul|Porto Alegre|gaúcho
RO|Rondônia|Porto Velho|rondoniense
RR|Roraima|Boa Vista|roraimense
SC|Santa Catarina|Florianópolis|catarinense
SP|São Paulo|São Paulo|paulista
SE|Sergipe|Aracaju|sergipano
TO|Tocantins|Palmas|tocantinense
TABELA_UFS

# ------------------------- FONTES DIRETAS EXTRAS -------------------------
# Coloque aqui links RSS diretos dos principais veículos de cada estado.
# Ex.: NEWS_EXTRA_FONTES["RJ"]="https://rss.uol.com.br/...|https://extra.globo.com/rss/"

# Converte "BUSCA::termo" na URL do feed de busca do Google News (janela de 7 dias).
news_url_busca_google() {
    local enc bytes
    bytes="$(printf '%s' "${1} when:7d" | od -An -tx1 | tr -s ' \n' ' ')"
    for b in ${bytes}; do enc+="%${b^^}"; done
    printf 'https://news.google.com/rss/search?q=%s&hl=pt-BR&gl=BR&ceid=BR%%3Apt-419\n' "${enc}"
}
