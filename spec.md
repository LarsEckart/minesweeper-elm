# Minesweeper in Elm – Specification

## 1. Overview

Re‑create Microsoft Windows **Minesweeper** in **Elm 0.19**, compiled to JavaScript. The game delivers a **modern flat design** with the **Vibrant Sunset** palette and runs responsively on **desktop** and **mobile** web browsers. Deployment is a static build hosted on **Netlify**.

---

## 2. Visual Style

* **Palette** – Vibrant Sunset:

  * Navy `#0D1B2A`, Indigo `#1B263B`, Slate `#415A77`, Sunset Orange `#E85D04`, Sunset Gold `#FFBA08`
* **Cells** – bordered squares, subtle drop‑shadow on hover/press.
* **Numbers** – classic color‑coding:

  * `1` blue, `2` green, `3` red, `4` navy, `5` maroon, `6` turquoise, `7` black, `8` gray.
* **Mine icon** – 💣 emoji.
* **Flag icon** – 🚩 emoji.
* **Reset button** – smiley emoji that changes state:

  * 🙂 idle/reset
  * 😮 mouse‑down press
  * 😵 loss
  * 😎 win
* **Audio** – silent (no sounds).
* **Animations** – none; instant state changes.
* **Accessibility** – no color‑blind mode or help modal in v1.

---

## 3. Gameplay Requirements

| Difficulty   | Grid    | Mines |
| ------------ | ------- | ----- |
| Beginner     | 9 × 9   | 10    |
| Intermediate | 16 × 16 | 40    |
| Expert       | 30 × 16 | 99    |

* Player selects difficulty at game start.
* **First click is always safe** and flood‑fills contiguous zero cells.
* **Binary flag/unflag** (no question‑mark state).
* **Long‑press** ≥ 500 ms on mobile to flag/unflag.
* **Win** – all non‑mine cells revealed.
* **Loss** – mine clicked.
* On loss: reveal all mines and highlight incorrect flags.
* After win or loss, the board **ignores further clicks** until reset.
* Reset always generates a **new random board** (unless a `seed` query param is supplied for testing).

---

## 4. UI & UX

* **Header bar** (desktop & mobile):

  * Mine counter (remaining mines).
  * Game timer (seconds, plain digits).
  * Smiley reset button.
* **Landing modal** – difficulty selection buttons.
* **Responsive board** – board auto‑scales to fit viewport width on mobile; no horizontal scroll.
* **Leaderboard modal** – trophy icon opens modal showing best times per difficulty and a “Clear Records” button.
* **Win dialog** – after victory, modal shows `Your time XX s — Best YY s` with a “Play Again” button.

---

## 5. Technical Requirements

* Elm 0.19 compiled to JS; no external JS frameworks.
* **Modules**:

  * `Main.elm` – root `init`, `update`, `view`, subscriptions.
  * `Types.elm` – shared type aliases & custom types.
  * `Board.elm` – board generation, mine placement, flood‑fill, win/loss logic.
  * `Cell.elm` – per‑cell view helpers.
  * `Timer.elm` – timer state & formatting.
  * `LeaderBoard.elm` – localStorage interface & modal view.
  * `Style.elm` – palette constants & style helpers.
* **Ports** – minimal JS (<50 LOC) for localStorage get/set of best times.
* **Seeded boards for tests** – optional `?seed=<int>` query param; hidden from UI.
* Board scaling via CSS Grid/Flexbox; mobile auto‑fit.
* Timer starts on **first reveal**; stops on win or loss.

---

## 6. Leaderboard

* **Storage** – best (fastest) time per difficulty in `localStorage`.
* **Win dialog** shows current vs. best time.
* **Modal** lists best times and offers “Clear Records”.

---

## 7. Testing & QA

* **elm-test** unit tests from day 1:

  * Mine placement (count & seed reproducibility).
  * First‑click safety.
  * Flood‑fill reveal logic.
  * Win/loss detection.
  * Timer start/stop.
  * Leaderboard read/write ports.
* **CI** – GitHub Actions runs `scripts/check.sh` on push:

  * `elm-format --validate` (format check)
  * `elm-review` (lint)
  * `elm-test` (unit tests)

---

## 8. Build & Tooling

* **scripts/check.sh** – convenience script shorthanding lint + format + test.
* **Build** – `elm make src/Main.elm --optimize --output=dist/elm.js`.

---

## 9. Deployment

* **Host** – Netlify static site. (setup already)
* Publish directory: `/dist` (plus index.html & styles).
* Automatic deploys from `main` branch.

---
