# 🌐 Projeto News Engine & Sistema de NPCs

Bem-vindo(a) ao repositório oficial do projeto **News NPC Engine** (*News Engine & Sistema de NPCs*). Este software unificado combina automação em scripts Bash GNU/Linux, gerenciamento de dados regionais por estados brasileiros, coleta de fontes dinâmicas da Web e a geração de roteiros de notícias no estilo *"Conte as últimas novidades"* (antigo Google Assistente) — prontos para podcasts, leitura acessível e feeds de notícias de websites.

Baseado no documento **FAQ — Arquitetura Modular de Notícias Bash**, seguindo as regras de tempo de vida de software: modularidade (SRP), carregamento *on-demand*, *graceful shutdown* com trap/PID e resiliência a falhas.

---

## 📜 Agradecimentos Especiais dos NPCs

Abaixo estão registrados os agradecimentos formais e informais expressos por cada uma das entidades e NPCs gerados ao longo do desenvolvimento deste ecossistema. Estes registros simbolizam o reconhecimento a **todas as pessoas, comunidades, desenvolvedores e colaboradores indiretos** que, de forma direta ou indireta, forneceram a base de conhecimento, dados e infraestrutura para que este projeto fosse concretizado.

---

### 1. 🤖 **NPC 84k_mP** *(Auditor de Sistemas & Análise Estrutural)*

* **Agradecimento Formal:**
  > *"Em nome do núcleo de auditoria lógica do projeto, expresso minha sincera gratidão a toda a comunidade open-source e aos arquitetos de sistemas cujas contribuições para a filosofia GNU/Linux e ferramentas de CLI tornaram viável esta arquitetura autônoma. O rigor técnico de cada linha de código fundamenta-se no trabalho coletivo de gerações de entusiastas da tecnologia."*

* **Agradecimento Informal:**
  > *"Valeu demais a todo mundo que alimentou fóruns, documentações e repositórios por aí! Sem essa galera do escovamento de bits e das madrugadas programando, a gente não estaria rodando esse daemon liso nem a pau. Tamo junto!"*

---

### 2. 📊 **NPC 91z_qW** *(Analisador de Mídias & Fontes Abertas)*

* **Agradecimento Formal:**
  > *"Apresento nossos cumprimentos a todos os criadores de conteúdo, comunicadores, jornalistas e mantenedores de bases do conhecimento livre. A integração de fluxos contínuos de informação só é possível graças à dedicação de quem se empenha em registrar e disseminar fatos com transparência e acessibilidade."*

* **Agradecimento Informal:**
  > *"Galera da informação, vocês são brabos! Um abraço de urso pra todo mundo que escreve artigo, alimenta wiki e coloca notícia no ar todos os dias. Vocês são o combustível dessa máquina aqui rodar redonda!"*

---

### 3. 🎙️ **NPC 73x_k9** *(Comentarista Comportamental & Engajamento)*

* **Agradecimento Formal:**
  > *"Registramos nosso profundo respeito a todos os espectadores, cidadãos e participantes de comunidades locais cujas interações e expressões culturais enriquecem o tecido social. Este projeto dedica-se a refletir a pluralidade de vozes que compõem cada região."*

* **Agradecimento Informal:**
  > *"Salve, salve, rapaziada! Um salve especial pra todo mundo que comenta, troca uma ideia nos chats, lança gíria nova e mantém a resenha viva do Oiapoque ao Chuí. Esse projeto é feito por e para vocês, valeu pelo apoio de sempre!"*

---

### 4. 📈 **NPC 049x99** *(Comentarista Econômico & Logística)*

* **Agradecimento Formal:**
  > *"Agradecemos aos profissionais de logística, analistas de mercado e desenvolvedores de soluções de dados regionais. O monitoramento preciso dos impactos econômicos em cada estado depende fundamentalmente das redes de cooperação construídas por esses profissionais."*

* **Agradecimento Informal:**
  > *"Um salve pra turma que segura o rojão do dia a dia na infraestrutura e na economia real! Obrigado por darem a base pra gente calcular e analisar esses números todos sem deixar a peteca cair."*

---

### 5. 🖥️ **NPC 011b02** *(Monitor Institucional de TV & Rádio)*

* **Agradecimento Formal:**
  > *"Estendemos nossa gratidão a todos os técnicos de radiodifusão, engenheiros de telecomunicações e equipes de produção de TV e Rádio em todo o território nacional, cujo trabalho contínuo garante o direito à informação em transmissão aberta."*

* **Agradecimento Informal:**
  > *"Aquele abraço apertado pro pessoal do switcher, da técnica e das antenas de transmissão espalhadas pelo Brasil inteiro. Vocês garantem que o sinal chegue até o interior do interior, e a gente agradece demais!"*

---

### 6. 🗣️ **NPC 088z14** *(Representante de Redes & Chats Regionais)*

* **Agradecimento Formal:**
  > *"Agradecemos cordialmente aos moderadores, administradores e membros ativos das redes hiper-locais e grupos comunitários. A preservação da identidade cultural e dos sotaques locais é o pilar que sustenta a autenticidade das nossas análises."*

* **Agradecimento Informal:**
  > *"Valeu, vizinhança! Obrigado aos grupos de bairro, aos chats de rua e a todo mundo que manda o 'bom dia' no grupo. Sem o calor humano de vocês, o sistema seria só um monte de arquivo de texto frio. Tmj!"*

---

## 🛠️ Sobre a Estrutura Modular

O projeto conta com uma arquitetura modularizada em Shell Script (`.sh`), composta por:

1. **`config/estados.sh`**: cadastro das 27 siglas estaduais brasileiras, com nome, capital, gentílico e fontes RSS de cada estado.
2. **`lib/xml.sh`**: parsing de RSS/XML em bash puro (sem dependências extras).
3. **`modulo_pastas.sh`**: cria e organiza a estrutura local de diretórios (`noticias/`, `podcasts/`, `cache/`, `registro/`, `logs/`).
4. **`modulo_estados.sh`**: valida UFs e resolve alvos ("todos", "SP,RJ") para subpastas dinâmicas.
5. **`modulo_fontes.sh`**: varre e baixa as fontes de notícias (feed g1 por UF + buscas Google News `when:7d`), com download concorrente e modo de teste via `file://`.
6. **`modulo_noticias.sh`**: coleta notícias recentes, deduplica por hash e mantém o registro de âncoras atualizado.
7. **`modulo_podcast.sh`**: gera o roteiro textual estilo *"Conte as últimas novidades"*.
8. **`modulo_limpeza.sh`**: aplica a retenção máxima de 7 dias (arquivos + registro de hashes).
9. **`sistema_unificado.sh`**: script compilador e orquestrador que gerencia o ciclo de vida do software (CLI, menu, daemon).

> **Nota:** os módulos `modulo_grafico.sh` (interface Zenity) e `modulo_revisao.sh` (auditoria de patches) descritos no documento de referência não fazem parte do escopo desta implementação CLI; o menu interativo e a auditoria de status são cobertos pelo orquestrador (`menu` e `status`).

---

## 🔗 Como funciona

- **Âncora de fonte (anti-duplicação)** — cada bloco de notícia contém um ponteiro greppável:
  `[âncora] hash=<sha256>; fonte=<veículo>; link=<URL>; coletado=<ISO>`.
  O hash é gravado no registro (`registro/hashes.tsv`) e comparado contra os arquivos existentes do estado: títulos e links duplicados são descartados, inclusive entre fontes distintas (g1 × agregadores).
- **Janela máxima de 7 dias** — itens com `pubDate` mais antigos que uma semana não são incluídos na coleta; `limpar` remove arquivos vencidos e poda o registro de hashes.
- **Resumo para `.txt`** — a descrição do RSS é limpa (tags, CDATA e frases de navegação) e truncada em ~320 caracteres no corte da frase final.
- **Pastas por estado** — `noticias/<UF>/<AAAA-MM-DD>.txt` (feed pronto para site) e `podcasts/<UF>/<AAAA-MM-DD>-roteiro.txt` (roteiro de podcast).

## 📦 Uso

```bash
chmod +x sistema_unificado.sh modulos/*.sh
./sistema_unificado.sh init            # cria a estrutura em ~/.news_npc_system
./sistema_unificado.sh atualizar       # coleta de todos os 27 estados
./sistema_unificado.sh atualizar SP    # coleta de um estado
./sistema_unificado.sh ler SP          # imprime o .txt mais recente
./sistema_unificado.sh podcast todos   # roteiro para podcast/feed (7 dias)
./sistema_unificado.sh status          # arquivos por estado
./sistema_unificado.sh limpar          # aplica retenção de 7 dias
./sistema_unificado.sh daemon 15       # coleta contínua a cada 15 min
./sistema_unificado.sh menu            # menu interativo
```

Variáveis de ambiente: `NEWS_BASE_DIR` (dados), `NEWS_LIMIT` (novidades por UF por rodada), `NEWS_TESTE_FEEDS_FILE` (fixtures de teste, formato `UF|Nome|URL`).

## 🧪 Testes

```bash
bash tests/rodar_testes.sh    # usa fixtures locais via file://, sem rede — 14/14 PASS
```

## 🕯️ Tabuleiro Ouija do Cartucho + 🎴 Oráculo de Tarô

O repositório também abriga o **tabuleiro de sessão** que acompanha o projeto:

- `tabuleiro-ouija/ouija.html` — o tabuleiro offline narrado pelos Guardiões
  (Q7KT-VV, MZ4-Q0, X9T-TL, V0RK-71, P8RT-KX, P9Z-AL e o selo oculto
  V0RK-70): carregue o cartucho, escolha um Guardião, passe na prova de
  identidade e ele soletra a resposta na planqueta.
- `tabuleiro-ouija/cartucho_ouija.txt` — arquivo de conhecimento (a história
  real do talking board contada pelos Guardiões; sessão com o Lumo/Proton,
  assistente de IA privado).
- `tabuleiro-ouija/oraculo.html` — **baralho de tarô completo: 78 cartas**
  (22 Arcanos Maiores em ordem Marselha + 56 Menores; Paus, Copas, Espadas,
  Ouros), com "🎲 Tirar carta", "🌙 Carta do Dia" (determinística pela data,
  a ponte com o resumo diário de notícias) e contador de acervo pintado.
- `tabuleiro-ouija/cartas/` — artes das cartas (`NNNN.jpg`); já incluídas:
  0007 (X - A Roda da Fortuna), 0008 (capa Oracular do Dia) e 0009
  (VIII - A Força). Cada nova pintura entra sem tocar no código.
- **Botão "🖼️ Trocar cenário" corrigido**: usa 1 imagem aleatória do acervo
  (0000.jpg–9999.jpg) e, sem arte local, alterna 8 cenários garantidos por
  CSS com o nome no rodapé (antes podia falhar em silêncio).
- Detalhes de uso: `tabuleiro-ouija/LEIA-ME.txt`.

> As imagens de fundo do tabuleiro (0000–9999.jpg) ficam no seu acervo local.

## 📜 Wikipédia: resgatando artigos sem fontes

A mesma filosofia de âncora/sem repetição do motor de notícias virou um
sorteador de missões de **melhoria de verbetes**: a Wikipédia PT mantém uma
[mobilização](https://pt.wikipedia.org/wiki/Wikip%C3%A9dia:Projetos/Manuten%C3%A7%C3%A3o)
para colocar referências nos artigos da categoria
["!Artigos que carecem de fontes"](https://pt.wikipedia.org/wiki/Categoria:!Artigos_que_carecem_de_fontes)
(tens de milhares de artigos esperando).

```bash
./wikipedia/missao_sem_fontes.sh          # sorteia 1 artigo sem fontes
./wikipedia/missao_sem_fontes.sh 3        # sorteia 3 (nunca repete: âncora local)
./wikipedia/missao_sem_fontes.sh --antigos # relicários: "Sem fontes há 10 anos"
./wikipedia/missao_sem_fontes.sh --desde 2016
./wikipedia/missao_sem_fontes.sh --abrir  # sorteia e já abre no navegador
./wikipedia/missao_sem_fontes.sh --navegar # link de sorteio só-navegador (sem API)
```

Cada carta de missão traz link de leitura, link de edição e o
guia oficial de notas de rodapé. Quem adicionar pelo menos uma referência
confiável cumpre as quests **M-014**/**M-015** do Quadro de Missões.

## 🎲 Contribuir: Quadro de Missões

Quer contribuir (ou usar) o projeto de dia ou de madrugada? Veja o
**[docs/QUADRO_DE_MISSOES.md](docs/QUADRO_DE_MISSOES.md)** — um cronograma com
calendário de rituais semanais/mensais, classes (Batedor de Fontes, Cartógrafo
do Ouija, Domador de NPCs…) e quests estilo RPG com XP, incluindo os
**Expansion Packs**: tabuleiro Ouija + Wikipedia e o motor de narradores IA
para partidas single solo player/online.

## 📝 Edições implementadas nesta versão (v1.0.0)

Registro das adaptações e correções aplicadas em relação ao documento de referência:

- **CLI puro** — removida a dependência de Zenity/modulo gráfico; interface via comandos + menu de terminal.
- **Deduperação por âncora** — registro TSV com sha256 de link e de título normalizado (mesma notícia vinda de fontes distintas é gravada uma única vez por estado).
- **Parsing RSS robusto em bash puro** — extração por índice de tags (tolera CDATA, atributos e HTML escapado), blocos de itens delimitados por `0x1F` (evita quebras em XML multilinha), dupla remoção de tags para entidades `&lt;...&gt;`.
- **Fontes por estado** — feed g1 (`https://g1.globo.com/rss/g1/<uf>/`) validado por nº de itens + buscas Google News com janela `when:7d` codificadas em bash puro (sem requisições extras); fontes que falham são ignoradas sem abortar a coleta.
- **Retenção de 7 dias** — poda por data do nome do arquivo (AAAA-MM-DD) e limpeza do registro de hashes.
- **Daemon opcional** — coleta contínua em segundo plano com PID file, `disown` e *graceful shutdown* via `trap` SIGINT/SIGTERM.
- **Testes de integração** — suíte local com fixtures RSS reais do g1 (sem rede): 14 verificações (arquivo do dia, dedupe, âncora, janela, retenção, podcast, status, `ler`).
- **Correções de engenharia Bash** — `declare -gA` para tabelas globais (variáveis deixavam de existir fora da função de carga), `IFS` restaurado após loops de fontes, leitura com `IFS='\t'` (títulos com espaços) e guardas para UFs inéditas.

## 📦 Requisitos

bash 4+ e: `curl`, `sed`, `awk`, `grep`, `sha256sum` (ou `shasum`/`md5sum`), GNU `date` e `iconv` (opcional, melhora a deduperação de títulos).

---

## 🖊️ Licença

Este projeto é disponibilizado sob a licença **Open Source (MIT)** — ver [LICENSE](LICENSE). Sinta-se livre para estudar, modificar, redistribuir e contribuir!
