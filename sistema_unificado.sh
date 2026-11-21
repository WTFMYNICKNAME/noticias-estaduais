#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# sistema_unificado.sh — News NPC Engine
# Orquestrador modular (CLI) de notícias estaduais em .txt, seguindo as regras
# de tempo de vida de software do documento "Arquitetura Modular de Notícias":
#   1. Modularidade (SRP)      — cada módulo cuida de uma única tarefa
#   2. On-demand/Lazy loading  — coleta pesada só sob demanda ou no daemon
#   3. Graceful shutdown       — trap SIGINT/SIGTERM + PID file
#   4. Resiliência             — fonte que falha não aborta a coleta
#
# Uso:
#   ./sistema_unificado.sh                          # menu interativo
#   ./sistema_unificado.sh init                     # cria a estrutura de pastas
#   ./sistema_unificado.sh atualizar [UF|todos]     # coleta notícias (txt)
#   ./sistema_unificado.sh podcast  [UF|todos]      # roteiro "Conte as últimas"
#   ./sistema_unificado.sh ler      <UF>            # imprime o .txt mais recente
#   ./sistema_unificado.sh limpar                   # aplica retenção de 7 dias
#   ./sistema_unificado.sh status                   # resumo por estado
#   ./sistema_unificado.sh daemon [min]             # coleta em segundo plano
# ---------------------------------------------------------------------------

PROJECT_NAME="News_NPC_Engine"
VERSION="1.0.0"
LICENSE="MIT (Open Source)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NEWS_BASE_DIR="${NEWS_BASE_DIR:-$HOME/.news_npc_system}"
NEWS_PID_FILE="$NEWS_BASE_DIR/news_daemon.pid"
NEWS_LIMIT="${NEWS_LIMIT:-12}"
NEWS_RETENCAO_DIAS=7

BLUE='\033[34m'; GREEN='\033[32m'; RED='\033[31m'; YELLOW='\033[33m'; NC='\033[0m'

verificar_dependencias() {
    local deps=("curl" "bash" "sed" "awk" "grep" "date") dep faltou=0
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo -e "${RED}[ERRO] Ferramenta '$dep' não encontrada. Instale-a para continuar.${NC}"
            faltou=1
        fi
    done
    (( faltou )) && exit 1
    echo -e "${GREEN}[OK] Dependências encontradas.${NC}"
}

carregar_modulos() {
    source "$SCRIPT_DIR/lib/xml.sh"
    source "$SCRIPT_DIR/config/estados.sh"
    source "$SCRIPT_DIR/modulos/modulo_pastas.sh"
    source "$SCRIPT_DIR/modulos/modulo_estados.sh"
    source "$SCRIPT_DIR/modulos/modulo_fontes.sh"
    source "$SCRIPT_DIR/modulos/modulo_noticias.sh"
    source "$SCRIPT_DIR/modulos/modulo_podcast.sh"
    source "$SCRIPT_DIR/modulos/modulo_limpeza.sh"
    news_ferramenta_hash
}

# ---------------------------------------------------------------------------
# FASE 2: coleta (Burst Mode)
# ---------------------------------------------------------------------------
cmd_atualizar() {
    local alvo="${1:-todos}" ufs uf novas_total=0 novas
    ufs="$(news_resolver_ufs "$alvo")"
    [[ -z "$ufs" ]] && { echo -e "${RED}[ERRO] Nenhuma UF válida.${NC}"; return 1; }
    modulo_pastas_rodar
    for uf in $ufs; do
        echo -e "${BLUE}[*] Coletando notícias de ${NEWS_UF_NOME[$uf]} ($uf)...${NC}"
        novas="$(noticias_processar_uf "$uf" "$NEWS_LIMIT")"
        novas="${novas//[^0-9]/}"
        : "${novas:=0}"
        novas_total=$(( novas_total + novas ))
        if (( novas > 0 )); then
            echo -e "${GREEN}[OK] ${novas} nova(s) notícia(s) gravada(s).${NC} → $NEWS_BASE_DIR/noticias/$uf/"
        else
            echo -e "${YELLOW}[NADA NOVO] Nenhuma notícia inédita nesta rodada.${NC}"
        fi
    done
    echo -e "${GREEN}[OK] Coleta concluída: $novas_total novidade(s) no total.${NC}"
}

cmd_podcast() {
    local alvo="${1:-todos}" ufs uf destino
    ufs="$(news_resolver_ufs "$alvo")"
    [[ -z "$ufs" ]] && return 1
    for uf in $ufs; do
        if destino="$(modulo_podcast_gerar "$uf")"; then
            echo -e "${GREEN}[OK] Roteiro gerado → $destino${NC}"
        else
            echo -e "${YELLOW}[SEM DADOS] Sem notícias recentes para $uf; rode 'atualizar' primeiro.${NC}"
        fi
    done
}

cmd_ler() {
    local uf="${1^^}"
    news_existe_uf "$uf" || { echo -e "${RED}[ERRO] UF inválida: $1${NC}"; return 1; }
    local arquivo
    arquivo="$(ls -1 "$(news_dir_noticias "$uf")"/*.txt 2>/dev/null | sort | tail -n 1)"
    [[ -z "$arquivo" ]] && { echo "${YELLOW}[VAZIO] Sem arquivos para $uf ainda; rode 'atualizar $uf'.${NC}"; return 1; }
    cat "$arquivo"
}

cmd_status() {
    local uf qtd ultimo
    printf '%-4s %-22s %-8s %s\n' "UF" "Estado" "Arquivos" "Mais recente"
    for uf in $NEWS_UFS_ORDENADAS; do
        qtd="$(find "$(news_dir_noticias "$uf")" -name '*.txt' 2>/dev/null | wc -l)"
        ultimo="$(ls -1 "$(news_dir_noticias "$uf")"/*.txt 2>/dev/null | sort | tail -n 1)"
        [[ -n "$ultimo" ]] && ultimo="$(basename "$ultimo" .txt)"
        printf '%-4s %-22s %-8s %s\n' "$uf" "${NEWS_UF_NOME[$uf]}" "$qtd" "${ultimo:-(vazio)}"
    done
}

# ---------------------------------------------------------------------------
# FASE 3: daemon em background (coleta contínua, sleep configurável)
# ---------------------------------------------------------------------------
cmd_daemon() {
    local intervalo="${1:-15}"   # minutos
    if [[ -f "$NEWS_PID_FILE" ]] && kill -0 "$(cat "$NEWS_PID_FILE")" 2>/dev/null; then
        echo -e "${YELLOW}[DAEMON] Já ativo (PID $(cat "$NEWS_PID_FILE")).${NC}"; return 0
    fi
    (
        echo $$ > "$NEWS_PID_FILE"
        while true; do
            cmd_atualizar todos > "$NEWS_BASE_DIR/logs/daemon.log" 2>&1
            sleep $(( intervalo * 60 ))
        done
    ) &
    disown
    echo -e "${GREEN}[DAEMON] Coleta em segundo plano iniciada (a cada ${intervalo} min; PID salvo em $NEWS_PID_FILE).${NC}"
}

encerrar_sistema() {
    if [[ -f "$NEWS_PID_FILE" ]]; then
        local daemon_pid
        daemon_pid="$(cat "$NEWS_PID_FILE")"
        if kill -0 "$daemon_pid" 2>/dev/null; then
            kill "$daemon_pid" 2>/dev/null
            echo -e "${GREEN}[OK] Daemon (PID $daemon_pid) encerrado.${NC}"
        fi
        rm -f "$NEWS_PID_FILE"
    fi
}

# ---------------------------------------------------------------------------
# FASE 4: interface (menu interativo / disposição de comandos)
# ---------------------------------------------------------------------------
menu_terminal_principal() {
    clear
    echo "=============================================================="
    echo " $PROJECT_NAME - v$VERSION ($LICENSE)"
    echo " Dados: $NEWS_BASE_DIR"
    echo "=============================================================="
    echo " 1) Atualizar notícias (todos os estados)"
    echo " 2) Atualizar um estado específico"
    echo " 3) Gerar roteiro de podcast (últimos 7 dias)"
    echo " 4) Ler notícias de um estado"
    echo " 5) Status dos arquivos por estado"
    echo " 6) Aplicar retenção (limpeza de antigos)"
    echo " 7) Sair"
    echo "=============================================================="
    read -r -p "Escolha uma opção [1-7]: " opcao
    case "$opcao" in
        1) cmd_atualizar todos ;;
        2) read -r -p "UF (ex.: SP): " uf_uf; cmd_atualizar "$uf_uf" ;;
        3) read -r -p "UF ou 'todos': " uf_uf; cmd_podcast "${uf_uf:-todos}" ;;
        4) read -r -p "UF (ex.: SP): " uf_uf; cmd_ler "${uf_uf:-SP}" ;;
        5) cmd_status ;;
        6) modulo_limpeza_rodar ;;
        7) encerrar_sistema; echo -e "${GREEN}[OK] Encerrando. ${NC}"; exit 0 ;;
        *) echo -e "${RED}Opção inválida.${NC}"; sleep 1 ;;
    esac
    read -r -p "Pressione ENTER para voltar ao menu..." _
}

cmd_ajuda() {
    cat <<AJUDA
$PROJECT_NAME v$VERSION — notícias estaduais do Brasil em .txt

Uso: $0 <comando> [alvo] [opções]

Comandos:
  init                      cria a estrutura de pastas
  atualizar [UF|todos]      consulta as fontes e grava os .txt com âncora de fonte
  podcast   [UF|todos]      gera roteiro "Conte as últimas novidades" (7 dias)
  ler       <UF>            imprime o arquivo .txt mais recente do estado
  status                    resumo de arquivos por estado
  limpar                    aplica retenção máxima de 7 dias
  daemon    [minutos]       coleta contínua em segundo plano (padrão 15 min)
  menu                      menu interativo
  ajuda                     esta ajuda

Variáveis (export): NEWS_BASE_DIR (diretório de dados), NEWS_LIMIT (novidades/UF por rodada),
                    NEWS_TESTE_FEEDS_FILE (arquivo de fixture no formato UF|Nome|URL)
AJUDA
}

main() {
    verificar_dependencias
    carregar_modulos
    modulo_pastas_rodar >/dev/null
    trap encerrar_sistema SIGINT SIGTERM

    local comando="${1:-menu}"
    case "$comando" in
        init)      modulo_pastas_rodar; echo -e "${GREEN}[OK] Estrutura criada em $NEWS_BASE_DIR${NC}" ;;
        atualizar) shift || true; cmd_atualizar "${1:-todos}" ;;
        podcast)   shift || true; cmd_podcast "${1:-todos}" ;;
        ler)       shift || true; cmd_ler "${1:-}" ;;
        status)    cmd_status ;;
        limpar)    modulo_limpeza_rodar ;;
        daemon)    shift || true; cmd_daemon "${1:-15}" ;;
        menu|-i)   while true; do menu_terminal_principal; done ;;
        ajuda|help|-h) cmd_ajuda ;;
        *)         cmd_ajuda ;;
    esac
    encerrar_sistema
}

main "$@"
