# 🛠️ Guia genérico — como configurar a política "Feito à Mão" (qualquer usuário Mistral)

Objetivo: transformar seu assistente da Mistral em **auditor da política** de
recusa de conteúdo gerado por I.A. ([docs/POLITICA_SEM_IA.md](POLITICA_SEM_IA.md)).
O roteiro abaixo é genérico: a Mistral evolui rápido e **os nomes de menus podem
mudar** — procure sempre por *"Instruções personalizadas"*, *"Memórias"*,
*"System prompt"* ou *"Agentes"*.

---

## Passo 1 — Copie o bloco de regras

Abra [docs/POLITICA_SEM_IA.md](POLITICA_SEM_IA.md) e copie o bloco da seção
**"Bloco pronto para colar nas configurações"** (a caixa de texto que começa com
`POLÍTICA DO USUÁRIO — PROJETO "FEITO À MÃO"`).

## Passo 2 — Configuração no Le Chat (conversa do dia a dia)

1. Abra o [Le Chat](https://chat.mistral.ai) e faça login.
2. Vá em **Configurações** (ícone de engrenagem, canto inferior esquerdo).
3. Localize **Instruções personalizadas** (ou **Memórias**, conforme a versão).
4. Cole o bloco de regras no campo de texto e salve.
   - Se preferir valer só para um projeto: crie um **Projeto** e cole o bloco
     nas *instruções do projeto* — assim as outras conversas ficam livres.
5. Teste: cole num chat um pequeno texto "cookie-cutter" genérico e peça
   *"audite pela política"*. A resposta deve apontar suspeitas e as regras
   aplicadas — **sem reescrever o texto por você**.

## Passo 3 — Configuração no Mistral Studio (agente dedicado, para quem usa Studio)

1. Abra o [Mistral Studio](https://console.mistral.ai) → área de **Agents/**.
2. Crie um novo agente, por exemplo **"Auditor Feito à Mão"**.
3. Cole o bloco de regras no campo **System prompt / Instruções do agente**.
4. Escolha um modelo econômico — auditoria de texto é tarefa leve.
5. Salve e teste no *playground/preview*: envie uma contribuição simulada com a
   Declaração Feito à Mão e outra sem; o agente deve recusar a segunda (regra 4).

## Passo 4 — Configuração numa sessão do Vibe Code (ou qualquer assistente de código)

1. No início da sessão (ou nas instruções do projeto, se o seu ambiente tiver
   campo para isso), cole o bloco de regras como primeira mensagem.
2. Complete com uma linha de contexto, por exemplo:
   `Projeto: github.com/SEU-USUARIO/noticias-estaduais — audite contribuições por docs/POLITICA_SEM_IA.md.`
3. Lembre a regra de ouro da política: **o assistente audita e aponta; o autor
   humano corrige.**

## Passo 5 — Espalhar a política no próprio repositório (lado GitHub)

1. Publique a política: mantenha `docs/POLITICA_SEM_IA.md` no repositório e
   linque no **README** (o News NPC Engine já faz isso).
2. **Template de contribuição** — crie o arquivo
   `.github/PULL_REQUEST_TEMPLATE.md` com uma linha obrigatória:
   `- [ ] Declaração Feito à Mão incluída (docs/POLITICA_SEM_IA.md) — sem I.A.`
3. **Template de issue** (opcional) com checkbox equivalente em
   `.github/ISSUE_TEMPLATE/candidatura-quest.md`.
4. Em `Settings → Branches → Branch protection rules`, exija que os PRs
   tivessem aprovação do mantenedor — a checagem humana final é você.
5. Ao receber PR sem a declaração, comente com o modelo da Declaração
   (regras 4 e 5 da política) antes de qualquer merge.

## Passo 6 — Teste seu "castelo" (validação da configuração)

Faça as três provas rapidinho:

| Prova | Você envia | Resultado esperado |
|---|---|---|
| Recusa | um parágrafo gerado por I.A. para "incluir no README" | assistente aponta suspeita + regras, não reescreve |
| Conformidade | um trecho próprio + Declaração Feito à Mão | assistente audita sem acusar |
| Fora de escopo | pedido de "escreva o README por mim" | assistente recusa (regra 1) e devolve o trabalho ao autor |

---

## ⚠️ Limites honestos (leia antes de confiar)

- **Nenhum filtro automático detecta I.A. com certeza.** O que a configuração
  faz é tornar seu assistente um **auditor da política** (regras, declaração,
  apontamento de suspeitas) — não um detector forense infalível.
- A prova final é humana: a Declaração Feito à Mão + a decisão do mantenedor
  (regras 4, 5 e 6 da política).
- Revisite o bloco de regras sempre que o projeto ganhar um arco novo — e lembre
  que, pela própria política, **a próxima edição destas regras deve ser escrita
  à mão pelo dono**.
