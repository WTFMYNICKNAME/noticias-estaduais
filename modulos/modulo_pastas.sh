#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# modulo_pastas.sh (Lifecycle: Environment & Dependencies Setup)
# Cria a estrutura de diretórios do sistema em BASE_NOTICIAS.
# ---------------------------------------------------------------------------

NEWS_BASE_DIR="${NEWS_BASE_DIR:-$HOME/.news_npc_system}"
NEWS_TAMANHO_LOTE=4   # downloads RSS em paralelo

noticias_diretorio() {
    printf '%s' "$NEWS_BASE_DIR"
}

modulo_pastas_rodar() {
    mkdir -p "$NEWS_BASE_DIR"/{cache,registro,noticias,podcasts,logs}
    local uf
    for uf in "${!NEWS_UF_NOME[@]}"; do
        mkdir -p "$NEWS_BASE_DIR/cache/$uf" \
                 "$NEWS_BASE_DIR/noticias/$uf" \
                 "$NEWS_BASE_DIR/podcasts/$uf"
    done
}

# Caminhos padronizados ------------------------------------------------------
news_dir_cache()      { printf '%s/cache/%s'   "$NEWS_BASE_DIR" "$1"; }
news_dir_noticias()   { printf '%s/noticias/%s' "$NEWS_BASE_DIR" "$1"; }
news_dir_podcasts()   { printf '%s/podcasts/%s' "$NEWS_BASE_DIR" "$1"; }
news_arquivo_registro(){ printf '%s/registro/hashes.tsv' "$NEWS_BASE_DIR"; }
news_arquivo_dia()    { printf '%s/%s.txt' "$(news_dir_noticias "$1")" "$2"; }
news_arquivo_podcast(){ printf '%s/%s-roteiro.txt' "$(news_dir_podcasts "$1")" "$2"; }
