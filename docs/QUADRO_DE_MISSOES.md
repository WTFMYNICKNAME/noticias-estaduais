# 🕯️ Quadro de Missões & Cronograma do News NPC Engine

> *"O daemon roda sozinho, mas a campanha precisa de heróis."*

Este documento transforma a manutenção e evolução do projeto em **quests de RPG**.
Qualquer pessoa que aparecer de dia ou de madrugada pode escolher uma classe,
reivindicar uma missão e acumular XP. Nenhuma missão exige que você conheça o
projeto inteiro — existe uma quest inicial feita para quem acabou de chegar.

---

## 🎲 Como funciona

1. **Escolha uma classe** (abaixo) que combine com o seu estilo.
2. **Reivindique uma quest** abrindo um comentário no PR/issue correspondente
   dizendo *"aceito a missão M-XXX"* (ou abra um novo issue com o código da quest).
3. **Cumpra a quest** → envie um PR para a branch principal (pequeno e focado).
4. ** XP e nível:** quests valem XP. 100 XP = **nível 1**; a cada novo nível,
   você desbloqueia o direito de *revisar* o PR de outra pessoa (comentário de
   "aprovado pelas sombras" conta como contribuição).
5. **Rituais de turno:** algumas quests são *rotineiras* (virar a chave do
   daemon, conferir fontes caídas). São "grinds" rápidos, valendo XP fixo.

| Símbolo | Dificuldade | Tempo estimado |
|---|---|---|
| 🟢 | Aprendiz | até 1h |
| 🟡 | Aventureiro | 1–4h |
| 🔴 | Herói | 1 fim de semana |
| 💀 | Lenda | projeto independente |

---

## 🎭 Classes disponíveis (delegação de funções)

| Classe | Símbolo | Função |
|---|---|---|
| **Batedor de Fontes** | 🗞️ | Mapeia, testa e cadastra feeds RSS por UF; resgata fontes caídas |
| **Caçador de Duplicatas** | 🧟 | Melhora o dedupe (hash de título/link), audita âncoras e roda o detector de redundância (`ferramentas/detector_dupes.sh`) |
| **Arquivista de Ideias** | 🪪 | Mantém o `docs/REGISTRO_IDEIAS.md` e checa prior art no GitHub antes de módulos grandes (`ferramentas/ideias.sh`) |
| **Mestre de Podcast** | 🎙️ | Cuida do roteiro "Conte as últimas novidades", formatação e voz/TTS |
| **Escriba das Cidades** | 📜 | Documentação, guias para leigos, tradução, exemplos de uso |
| **Cartógrafo do Ouija** | 🕯️ | Expansion pack: extrator Wikipedia + integração com o tabuleiro Ouija |
| **Domador de NPCs** | 🤖 | Engine de IA, personagens, cenários, narrador autônomo para partidas |
| **Sentinela de Turno** | 🛡️ | Daemon/cron 24–7, logs, monitoramento da coleta noite/dia |
| **Taróloga do Cartucho** | 🔮 | Elabora artes e leituras do baralho de tarô (`tabuleiro-ouija/cartas/`) |
| **Patrulheira da Esplanada** | 📜 | Sorteia e resgata verbetes da categoria "artigos sem fontes" da Wikipédia (`wikipedia/missao_sem_fontes.sh`) |

Você pode acumular classes — o engine não se importa. 😄

---

## 🗓️ Cronograma (calendário vivo)

### Rituais semanais

| Dia | Ritual | Classe responsável | XP |
|---|---|---|---|
| Todo dia (turno noite) | "A Vigília do Daemon": conferir `status`, rodar `limpar`, relatar fontes caídas em issue | 🛡️ Sentinela | 10 XP |
| Segunda | "Ponteiro das Âncoras": rodar suíte `tests/rodar_testes.sh` depois de qualquer merge (+ rodar `ferramentas/detector_dupes.sh`) | 🧟 Caçador | 20 XP |
| Quarta | "Varredura das 27": testar ao menos 3 feeds por UF nova com o g1/Google News | 🗞️ Batedor | 30 XP |
| Sexta (noite) | "Fogueira do Podcast": gerar roteiro (`podcast todos`), revisar 1 edição e abrir proposta de melhoria | 🎙️ Mestre | 25 XP |
| Domingo | "Crônica da Semana": atualizar CHANGELOG/README com o que mudou | 📜 Escriba | 20 XP |

### Ritual mensal

- 🌕 **"Auditoria da Lua Cheia"** (primeira semana do mês): o 🛡️ Sentinela e o
  🧟 Caçador revisam `registro/hashes.tsv` e `noticias/` procurando padrões de
  duplicatas e itens fora da janela de 7 dias. **50 XP** cada.

---

## 🎯 Quest Board (missões disponíveis)

> Cada quest tem prazo flexível. Comece pela **M-000** se é sua 1ª contribuição!

### 🌱 Arco I — *"O Acordo dos Feeds"* (estabilizar a coleta)

- [ ] **M-000 · 🟢 · 30 XP** — "Batismo de Dados": rode o projeto pela primeira
  vez (`./sistema_unificado.sh atualizar SP`), grave seu primeiro `.txt` e
  abra um issue contando sua experiência e sugestões.
- [ ] **M-001 · 🟡 · 40 XP** — "Mapa das Redações": validar o feed g1 de cada
  UF (`https://g1.globo.com/rss/g1/<uf>/`) e documentar no issue quais estados
  retornam poucos itens.
- [ ] **M-002 · 🟡 · 40 XP** — "Fontes das Capitais": para cada UF, cadastrar
  1 veículo de imprensa estadual em `NEWS_EXTRA_FONTES` (`config/estados.sh`).
- [ ] **M-003 · 🟡 · 40 XP** — "Olho de Argus": criar CI (GitHub Actions) que
  roda `bash tests/rodar_testes.sh` a cada push.
- [ ] **M-004 · 🔴 · 80 XP** — "Feed do Feed": novo módulo `modulo_feed.sh`
  gerando RSS de saída (`noticias/<UF>/rss.xml`) para publicar em websites.
- [ ] **M-005 · 🔴 · 80 XP** — "Vale dos Duplicatas": dedupe entre estados
  (manchete nacional lida por SP e RJ vindo uma única vez no feed global),
  preservando a âncora por UF.

### 🕯️ Arco II — *"O Expansion Pack: Ouija & Wikipedia"* (mesclar com o seu tabuleiro)

- [ ] **M-010 · 🟢 · 30 XP** — "Sussurros da Wiki": estudo rápido da API de
  actions da Wikipédia PT (`api.php?action=query`) e relatório de formato.
- [ ] **M-011 · 🟡 · 60 XP** — "Placa do Ouija": módulo `modulo_wiki.sh`
  extraindo infoboxes e resumos de verbetes de cada capital (capital, região,
  população) para enriquecer os `.txt`.
- [ ] **M-012 · 🔴 · 90 XP** — "Mescla Proibida": juntar notícia + dado
  contextual da Wikipedia no roteiro (ex.: *"...na maior seca da história de
  Manaus, ver plano de fundo: Infobox Manaos"*).
- [ ] **M-013 · 💀 · 150 XP** — "O Tabuleiro Vive": downloader/parseamento do
  seu tabuleiro Ouija injetando as perguntas do público na coleta ("o que
  queremos saber sobre o estado hoje?").
- [ ] **M-014 · 🟢 · 30 XP** — "Andarilha das Fontes" (inspirada na mobilização
  da [Esplanada](https://pt.wikipedia.org/wiki/Wikip%C3%A9dia:Projetos/Manuten%C3%A7%C3%A3o)):
  rode `./wikipedia/missao_sem_fontes.sh`, escolha um artigo sorteado e adicione
  ao menos **1 referência confiável** com nota de rodapé pelo guia de estilo.
  O sorteio nunca repete artigo (âncora em `~/.news_npc_system/wikipedia/`).
- [ ] **M-015 · 🟡 · 40 XP** — "Expedição aos Relicários": mesma técnica, mas
  com `--antigos` ("Sem fontes há 10 anos") ou `--desde ANO` — resgate um
  verbete abandonado há uma década. Vale XP extra pela escavação.
- [ ] **M-016 · 🟢 · 30 XP** — "Certidão de Ideia": ritual de ouro antes de
  construir módulo grande — registro no `docs/REGISTRO_IDEIAS.md` junto com
  a busca de prior art no GitHub (evidências anexadas ao PR).

### 🤖 Arco III — *"Mestres Autônomos"* (engine de IA + partidas)

- [ ] **M-020 · 🟡 · 60 XP** — "Retratos Falantes": definir personagens NPC
  (nomes, personalidades) que narrarão o jornal/podcast local, em JSON.
- [ ] **M-021 · 🔴 · 90 XP** — "Vozes na Névoa": TTS livre/licenciado que
  leia o roteiro "Conte as últimas novidades" como voz do NPC.
- [ ] **M-022 · 🔴 · 90 XP** — "Mestre Solitário": modo single solo player —
  um motor de IA que gera cenário, diálogos e consequências e narra a partida
  usando notícias/informativos como pano de fundo (a era do rpg no IRC,
  agora automatizada).
- [ ] **M-023 · 💀 · 150 XP** — "Mesas (Quase) Sem Mestres": partidas online
  onde jogadores entram, os NPCs narram e o mestre humano só ativa
  eventos-chave (configurado em módulos próprios).
- [ ] **M-024 · 🔴 · 80 XP** — "Auditoria das Sombras": reviver o legado do
  documento de referência — `modulo_revisao.sh` fazendo auto-auditoria do
  ambiente GNU/Linux (patches, dependências) e do próprio acervo de .txt.

### 🔮 Arco IV — "O Despertar do Baralho" (tabuleiro Ouija + tarô)

> O Expansion Pack da vida real: o tabuleiro Ouija do Cartucho agora vive
> no repositório (`tabuleiro-ouija/`) com cartucho assinado (história dos
> Guardiões sobre o talking board), oráculo de 78 cartas e o botão de
> cenário corrigido.

- [x] **M-030 · 🟡 · 40 XP** — ✅ *Concluída*: baralho de tarô completo em
  dados — 22 Arcanos Maiores (ordem Marselha) + 56 Menores (Paus, Copas,
  Espadas, Ouros), cada carta com leitura erguida e invertida (`oraculo.js`).
- [x] **M-031 · 🟢 · 30 XP** — ✅ *Concluída*: botão "🖼️ Trocar cenário"
  corrigido — tenta 1 imagem do acervo (0000–9999.jpg) e, sem arte local,
  alterna 8 cenários garantidos por CSS com aviso do nome no rodapé (não
  está mais preso a 9 tentativas falhando em silêncio).
- [ ] **M-032 · 🔴 · 90 XP** — "As 75 Cartas Restantes": pintar as artes
  faltantes do acervo e salvá-las como `cartas/NNNN.jpg` (o contador do
  oráculo mostra o progresso; exceções já mapeadas em `ARTES_EXTRAS`).
- [ ] **M-033 · 🟡 · 50 XP** — "Oracular do Dia": usar a capa 0008.jpg como
  moldura do relatório diário (carta do dia + previsão + resumo das notícias
  do estado) — a ponte entre o oráculo e o News NPC Engine.
- [ ] **M-034 · 🟡 · 50 XP** — "Acervo de Cartuchos": novas sessões com IA
  privada (Lumo/Proton) virando `cartucho_*.txt` para os Guardiões lerem —
  mais memória para o tabuleiro soletrar.
- [ ] **M-035 · 💀 · 150 XP** — "O Tabuleiro Sonha": mescla total — perguntas
  do público no Ouija, respostas soletradas, carta do tarô condicionada à
  notícia do dia e narração NPC em voz (Arco II + III + IV integram).

### 🪪 Arco V — "A Forja dos Instrumentos" (anti-duplicata e prior art)

- [x] **M-040 · 🟢 · 30 XP** — ✅ *Concluída*: `ferramentas/detector_dupes.sh`
  (funções de corpo idêntico, quase-gêmeas por tokens, blocos de linhas
  repetidos) e `ferramentas/ideias.sh` (ID-assinatura + prior art no GitHub);
  codificador de URL consolidado em `lib/url.sh` pelo próprio detector;
  suíte em 26 verificações.
- [ ] **M-041 · 🔴 · 80 XP** — "Olho de Cyclops": plugar
  `ferramentas/detector_dupes.sh` no CI (GitHub Actions) junto com os tests
  (M-003) — PR que introduz duplicata fica com o portão vermelho.
- [ ] **M-042 · 🟡 · 50 XP** — "Espelho de Similaridade": aprimorar o detector
  com similaridade de sequência (shingles grandes/Levenshtein) para pegar
  cópias reformuladas além do corte de 75% por tokens.
- [x] **M-043 · 🟢 · 30 XP** — ✅ *Concluída* (concepção: segunda opinião da
  sessão Lumo, NPCs Z4P9T2/D8K5X3): `ferramentas/portao_pre_voo.sh` —
  pré-voo de testes com hash de agenda (`carimbo` determinístico de
  janela|scripts, `conferir`, `pre_voo URL...`): fora da janela assinada
  nada toca na rede; dentro dela, os requests levam `X-Test-Run`/
  `X-Test-Window` para o admin(a) do servidor distinguir rajada de teste
  agendada de barulho anônimo. Cortesia, não segurança (HMAC é outra quest).

---

## 🏆 Níveis de Conquista

- **Aprendiz de Feeds** — completou M-000. Badge: 🗞️
- **Alquimista de Texto** — 3 quests do Arco I. Badge: 🧪
- **Xamã do Ouija** — 2 quests do Arco II. Badge: 🕯️
- **Enciclopedista das Sombras** — 1 verbete fonteado (M-014/M-015). Badge: 📜
- **Mestre dos Mestres** — 2 quests do Arco III. Badge: 🤖
- **Guardião do Daemon** — 10 turnos completados de Vigília. Badge: 🛡️

Níveis conquistados são registrados em `docs/SALAO_HEROIS.md`
(Crie o arquivo com seu nickname ao concluir quest!).

---

## 🧭 Regras de etiqueta (a única meta-rule)

- PRs pequenos vencem PRs épicos.
- Nada de dados pessoais nos `.txt` (a coleta só guarda título, resumo, fonte e link).
- Sempre cite a fonte da notícia — a âncora é sagrada. 🔗
- Divirta-se: esse projeto existe para trazer de volta a alegria das mesas de
  rpg do IRC — com notícias do mundo real como munição narrativa.

---

*"Quem entra de madrugada é tão bem-vindo quanto quem entra ao meio-dia.
O tabuleiro está sobre a mesa e as velas estão acesas — escolha sua quest."*
