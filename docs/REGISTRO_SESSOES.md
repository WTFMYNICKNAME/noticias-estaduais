# 📓 Registro de Sessões — continuidade do projeto

> *"Toda aba morre, mas o registro sobrevive."*

Este arquivo existe pelo pedido central do projeto: **de tempo em tempo, fazer um
arquivo e iniciar uma nova aba**. Cada sessão de trabalho (humana ou assistente de
IA) termina registrando aqui o que fez, onde parou e qual é a próxima quest.
Assim qualquer pessoa — ou qualquer aba nova — abre este arquivo e retoma o
trabalho exatamente do ponto em que parou, sem retrabalho nem duplicata de ideias
(regra de ouro: rode `ferramentas/ideias.sh buscar` antes de começar algo novo).

## 🧭 Ritual de retomada (leia antes de codificar)

1. Leia a **última entrada** abaixo (fim do arquivo).
2. Abra `docs/QUADRO_DE_MISSOES.md` e escolha uma quest **aberta** (sem `[x]`).
3. Rode `bash tests/rodar_testes.sh` — a suíte precisa estar verde **antes** de você mexer.
4. Trabalhe na branch do PR #1 (**não** abra PR concorrente): PR pequeno e focado.
5. Ao encerrar: registre sua sessão aqui, atualize o Quadro e o README se algo mudou para o usuário.

### Modelo de entrada

```
## S-00X — <data> — <quem/sessão>
**Feito:** …
**Verificação:** … (comando + resultado)
**Próximo passo:** quest M-XXX / tarefa apontada.
```

---

## S-001 — 21/11 — Sessão original (Mistral Studio)

- **Feito:** News NPC Engine completo — orquestrador `sistema_unificado.sh`
  (atualizar, ler, podcast, status, limpar, daemon, menu), `config/estados.sh`
  (27 UFs), `lib/xml.sh` (parser RSS em bash puro), 6 módulos, fixtures do g1 e
  suíte de testes; PR #1 aberto (branch `vibe/scripts-noticias-estaduais-a6248d`).
- **Depois:** `docs/QUADRO_DE_MISSOES.md` (quests/classes/XP), tabuleiro Ouija +
  Oráculo de tarô (78 cartas), Quest Wikipédia `wikipedia/missao_sem_fontes.sh`,
  anti-duplicata (`ferramentas/detector_dupes.sh` + `ferramentas/ideias.sh`) e
  portão pré-voo (`ferramentas/portao_pre_voo.sh`, PDF da sessão Lumo).
- **Estado deixado:** suíte 32/32 PASS; detector sobre o repo: 0 duplicatas;
  quests abertas: M-012 a M-024, M-032 a M-035, M-041 em diante.

## S-002 — 26/11 — Aba de continuação (Vibe Code)

- **Feito:** retomada a partir do arquivo de sessão enviado pelo usuário;
  CI instalado em `.github/workflows/ci.yml` concluindo as quests **M-003**
  ("Olho de Argus" — suíte a cada push) e **M-041** ("Olho de Cyclops" —
  detector de duplicatas como portão de PR); criado este registro de sessões.
- **Verificação:** `bash tests/rodar_testes.sh` → 32/32 PASS;
  `bash ferramentas/detector_dupes.sh` → limpo (exit 0).
- **Próximo passo:** sugestões fáceis — **M-042** (Espelho de Similaridade:
  shingles/Levenshtein no detector) ou **M-004** (`modulo_feed.sh`, RSS de
  saída). Grandes quests (M-023, M-035) pedem decisão de escopo do dono.
