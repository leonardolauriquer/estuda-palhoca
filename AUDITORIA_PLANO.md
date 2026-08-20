# Plano de Auditoria Completa — App de Estudos Concurso Câmara de Palhoça/SC 01/2026

**App:** `index.html` único (115 KB, 14 views, 10 matérias, 190 flashcards, ~88 resumos, 10 exercícios, leis comentadas, TTS)
**Deploy:** GitHub Pages `https://leonardolauriquer.github.io/estuda-palhoca/` (v33)
**Objetivo:** Confrontar informações e métodos de estudo, auditar todo o app com agentes especializados e entregar correções.

---

## 1. Escopo da Auditoria (4 domínios)

| # | Domínio | O que se mede | Agente |
|---|---------|---------------|--------|
| A | **Veracidade do Conteúdo** | Resumos/cards/leis batem com edital real (e1/e2)? Matérias fantasma? Erros factuais? | leaf |
| B | **Funcionalidade / JS** | `node --check`, runtime, navegação, localStorage, version-busting, TTS, resíduos A/B | leaf |
| C | **UX / Design / Acessibilidade** | Contraste, responsivo, legibilidade, fluxo intuitivo, bots TTS | leaf |
| D | **Pedagogia / Métodos** | Leitner real? Gamificação? Cronograma coerente? Contas dos exercícios? Lacunas | leaf |

## 2. Fontes de Verdade
- `e1_utf8.txt` — Edital Original 05/06 (Nível Superior, 5 cargos)
- `e2_utf8.txt` — Edital Retificado 19/08 (Superior + Médio + IA)
- `index.html` — app sob teste (v33 local)

## 3. Metodologia (cada agente)
1. Ler editais + `index.html` (e objetos `DADOS`, `CONTEUDO`/`CONTEUDO_EST`, `LEIS`/`LEIS_ART`, `EXERCICIOS`).
2. Produzir achados com evidência (trecho edital vs trecho app / linha de código).
3. Classificar severidade: 🔴 crítico · 🟡 médio · 🟢 leve.
4. Sugerir correção concreta.

## 4. Critérios de Aceite (definition of done)
- [ ] Todo tópico de matéria do edital está representado no app.
- [ ] Zero erro factual em resumos/cards/leis.
- [ ] `node --check` passa; zero resíduo A/B; TTS/localStorage/version-busting funcionam.
- [ ] Contraste AA em todas as telas; layout responsivo validado.
- [ ] Leitner, gamificação e cronograma coerentes e pedagógicos.
- [ ] Exercícios com contas conferidas manualmente.

## 5. Entregáveis
1. Relatório consolidado de achados (por domínio + severidade).
2. Plano de correções (PRs/patches) priorizado.
3. App corrigido em nova versão (v34+) com re-teste.

## 6. Cronograma (estimado)
- T0: disparo dos 4 agentes (paralelo, batch de 3 + 1)
- T+~5min: consolidação dos relatórios
- T+~10min: aplicação de correções críticas/médias
- T+~15min: re-test (node --check + browser) e deploy

## 7. Riscos conhecidos (do histórico)
- Visão do Hermes falha (400) → auditoria de UX via `getComputedStyle`, não imagem.
- Edições manuais corrompem o `index.html` → corrigir via `git checkout` + reaplicar em etapas.
- `localStorage` do usuário esconde o landing → instruir aba anônima.
