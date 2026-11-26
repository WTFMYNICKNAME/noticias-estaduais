# 👐🚫 Política "Feito à Mão" — recusa de conteúdo gerado por I.A.

> *"Aqui o Rune nasce da mão de quem joga, não da máquina que responde."*

Este documento institui a regra central pedida pelo mantenedor: **este projeto não
aceita nenhum conteúdo gerado por I.A.** (texto, código, arte, tradução, resumo,
roteiro ou qualquer trecho substantivo produzido por modelo de linguagem,
chatbot, copiloto de código, gerador de imagens ou ferramenta equivalente).

## ⚖️ Transparência fundadora

O código inicial do repositório (sessões S-001/S-002 do registro) foi construído
**em sessões assistidas por I.A., sob comando explícito e decisão do dono** do
projeto — e está registrado como tal. Esta política vale **a partir da sua
publicação** para contribuições de terceiros e para a rotina do projeto. O dono
pode, a qualquer momento, mandar reescrever à mão qualquer parte herdada (isso é
uma quest de "purificação", ver Quadro de Missões).

## 📜 As regras

1. **Humanos só.** Toda contribuição aceita (PR, issue, comentário, documentação,
   código, arte, pinturas do baralho, roteiros) precisa ter sido **produzida por
   uma pessoa**, sem geração por I.A.
2. **Definição de "gerado por I.A."** — qualquer trecho substantivo escrito,
   completo, parafraseado, traduzido ou ilustrado por uma ferramenta de I.A.
   generativa, mesmo que a pessoa tenha revisado.
3. **Ferramentas determinísticas são permitidas** — corretores ortográficos
   clássicos (sem geração de texto), `grep`/`sed`/`awk` (o próprio projeto é
   feito deles), validadores, linters sem sugestão de escrita por modelo,
   busca na web para *ler*. O que é proibido é **gerar conteúdo**, não usar
   computador.
4. **Dever de declaração.** Toda contribuição deve trazer a **Declaração Feito à
   Mão** (modelo abaixo) assinada pelo autor. Sem a declaração, o PR fica
   parado até que alguém a inclua.
5. **Auditoria.** O mantenedor (ou o agente auditor configurado conforme
   `docs/GUIA_CONFIG_MISTRAL.md`) pode pedir comprovação do processo de trabalho
   (histórico, rascunhos, gravação de tela). Recusa injustificada = contribuição
   recusada.
6. **Punhado de sanções.** 1ª vez: PR/issue fechado com apontamento da política.
   Reincidência comprovada: bloqueio de participação nas quests.
7. **Denúncia.** Qualquer pessoa pode marcar um conteúdo suspeito comentando
   "👀 regra 1". Cabe ao mantenedor auditar.
8. **Exceção formal.** Casos específicos (ex.: dados públicos já indexados que
   só possam ser obtidos via API) exigem decisão **aberta e registrada** do
   mantenedor em issue — nunca engessada em silêncio.

## 📋 Modelo da Declaração Feito à Mão

```
DECLARAÇÃO FEITO À MÃO
Eu, <nome/usuário>, declaro que este PR é de minha autoria humana:
o conteúdo substantivo (código/texto/arte) foi escrito/desenhado por mim,
sem geração por ferramentas de I.A., conforme docs/POLITICA_SEM_IA.md.
Assinatura: <usuário> — <data>
```

## 🔧 Bloco pronto para colar nas configurações (o "conjunto de regras")

Copie o bloco abaixo para as instruções do seu assistente (Le Chat, agente do
Mistral Studio ou início de sessão do Vibe Code) — o passo a passo detalhado
está em [docs/GUIA_CONFIG_MISTRAL.md](GUIA_CONFIG_MISTRAL.md):

```
POLÍTICA DO USUÁRIO — PROJETO "FEITO À MÃO" (obrigatória, não negociável)

1. NUNCA gere, complete, parafraseie, traduza ou ilustre conteúdo para as
   contribuições do projeto noticias-estaduais. Sua função é AUDITOR, não autora.
2. Se eu colar um texto/código/dif para avaliar: analise e aponte SOMENTE
   (a) verossimilhança de origem automatizada (estilo genérico, redundância,
   erros típicos de LLM), (b) se atende às 8 regras de docs/POLITICA_SEM_IA.md,
   (c) o que o autor precisaria mudar para estar em conformidade.
3. Não reescreva trechos dos autores: mostre onde está o problema e deixe a
   correção com o autor humano.
4. Toda contribuição sem a "Declaração Feito à Mão" deve ser apontada como
   não conforme (regra 4), com o modelo de declaração de volta ao autor.
5. Ao me ajudar a configurar a política, explique os passos por extenso; ao
   me ajudar a codificar o MEU próprio trabalho, seja também auditor: gere
   somente o mínimo solicitado e identifique claramente o que foi gerado.
6. Registre cada auditoria no padrão do projeto (data, alvo, resultado,
   regra aplicada) ao final da resposta.
```

> **Nota honesta:** este bloco foi redigido num momento fundador assistido por
> I.A., por comando do dono, e é o único texto "de escritório" do projeto
> derivado de máquina. A partir daqui, edições nestas regras devem ser feitas à
> mão pelo dono (ou por quem declarar e cumprir a política).
