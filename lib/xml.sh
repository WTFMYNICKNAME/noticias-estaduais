#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# lib/xml.sh
# Utilitários para parsing de RSS 2.0 em bash puro (sem dependências extras).
# ---------------------------------------------------------------------------

# Extrai o conteúdo de <tag[ attrs]>...</tag> de um bloco XML (tolera CDATA).
# Imprime nada e sai com código 1 se o campo não existir.
xml_extrai_campo() {
    awk -v bloco="$1" -v tag="$2" 'BEGIN {
        o = "<" tag; c = "</" tag ">";
        i = index(bloco, o);
        if (i == 0) exit 1;
        i += length(o);
        f = index(substr(bloco, i), ">");
        if (f == 0) exit 1;
        i += f;
        j = index(bloco, c);
        if (j <= i) exit 1;
        print substr(bloco, i, j - i);
    }'
}

# Emite, separados por \037 (0x1F), os blocos <item>...</item> do XML por stdin.
# O separador evita quebras porque um bloco pode ter várias linhas.
xml_itens() {
    awk 'BEGIN { RS = "</item>" }
         index($0, "<item") > 0 {
             i = index($0, "<item");
             print substr($0, i) "\037";
         }'
}

# Converte um campo XML (possivelmente com CDATA/HTML) em texto puro legível.
xml_para_texto() {
    sed -e 's/<!\[CDATA\[//g' \
        -e 's/\]\]>//g' \
        -e 's/<[^>]*>/ /g' \
        -e 's/\r/ /g' \
        -e 's/&nbsp;/ /g' \
        -e 's/&quot;/"/g' \
        -e "s/&apos;/'/g" \
        -e "s/&#39;/'/g" \
        -e 's/&lt;/</g' \
        -e 's/&gt;/>/g' \
        -e 's/&amp;/\&/g' \
        -e 's/<[^>]*>/ /g' \
    | tr -s ' \t' ' ' \
    | sed 's/^ //; s/ $//'
}

# Remove frases de navegação/identidade comuns dos portais de notícias.
news_limpar_texto() {
    sed -e '/LEIA MAIS:/d' \
        -e '/^VÍDEOS:/d' \
        -e '/^VÍDEO:/d' \
        -e '/Agora no g1/d' \
        -e '/Clique aqui/d' \
        -e '/Confira a previsão/d' \
        -e '/Se depender de/d'
}

# Gera um resumo curto (até N caracteres, cortando no fim de uma frase).
news_resumir() {
    local maximo="${1:-320}"
    awk -v maximo="$maximo" '
    { txt = txt (txt == "" ? "" : " ") $0 }
    END {
        gsub(/[ \t]+/, " ", txt);
        txt = substr(txt, 1, maximo);
        corte = 0; alvo = int(maximo * 0.6);
        for (i = alvo; i >= 1; i--) {
            c = substr(txt, i, 1);
            if (c == "." || c == "!" || c == "?") { corte = i; break }
        }
        if (corte > 0) txt = substr(txt, 1, corte);
        sub(/[[:space:]]+$/, "", txt);
        print txt;
    }'
}
