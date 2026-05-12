# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Guardiões do Bairro" — a 2D Godot 4.6 game built as a UNIFOR coursework deliverable (the SGDD doc and `Aula 2.1` PDF in the repo root are the game's design document and assignment brief). Theme: side‑scrolling waste‑collection / recycling game. Identifiers, comments, and UI strings are in **Brazilian Portuguese** — match that language when editing existing code, signals, and exported variables.

The Godot project root is `guardioes-do-bairro/` (open this folder, not the repo root, in the Godot editor).

## Running

- Open `guardioes-do-bairro/project.godot` in Godot 4.6 (Forward+ renderer, Jolt 3D physics — though the game itself is 2D).
- Main scene is `res://prefabs/tittle_screen.tscn` (note the spelling — "tittle", not "title"; keep it as-is to avoid breaking `project.godot` and existing `change_scene_to_file` calls).
- No build system, package manager, or test runner — Godot handles the build. `.godot/` and `/android/` are gitignored.

## Architecture

### Scene flow

`tittle_screen` → `start_screen` (menu) → `instruction_screen` → `street.tscn` (the only gameplay scene) → `win_screen` or `lose_screen` → back to `start_screen` / `street`. Transitions use `get_tree().change_scene_to_file(...)` with hardcoded `res://` paths; if you move or rename a scene, grep all `.gd` files for the path.

### `GameState` autoload (`autoload/game_state.gd`)

The **only** singleton. Used solely to ferry `tempo_final` and `pontos_finais` from `street.gd` into `win_screen.gd` / `lose_screen.gd` across the scene change. Reset via `GameState.resetar()` at the start of each gameplay run. Don't grow this into a general-purpose service locator — per-scene state stays in the scene's controller.

### `street.gd` is the level controller

`scenes/street.gd` owns the gameplay loop and is the **mediator** between Player and HUD — they never reference each other directly. Pattern:

- `Player` emits domain signals: `vida_alterada`, `lixo_coletado`, `descarte_feito`, `morreu`.
- `street.gd._ready()` wires those signals to local `_on_*` handlers which then call methods on the HUD (`atualizar_vidas`, `atualizar_pontuacao`, `atualizar_inventario`, `remover_inventario`, `atualizar_cronometro`).
- Collectibles are auto-wired in `_ready()` by iterating `$Coletaveis` children and connecting their `coletado` signal to `player.adicionar_lixo`.
- HUD calls are guarded with `has_method(...)` — keep that pattern when adding new HUD hooks so a missing node doesn't crash the level.

When adding gameplay state (score multipliers, combos, new pickups), follow this flow: emit from the entity → handle in `street.gd` → push to HUD. Don't have entities reach into the HUD directly.

### Auto-scrolling camera + `DamageArea`

`street.gd._process` advances `camera.position.x` at `VELOCIDADE_CAMERA` and pins `$DamageArea` to follow it. The damage area is what kills players who fall off-screen left. Reaching `FIM_DA_FASE_X` triggers `_terminar_fase(true)`. If you add parallax, new hazards, or extra cameras, account for this: the camera is moved by code, not a Camera2D `limit_*`, and `$DamageArea` must stay glued to `camera.position.x`.

### Trash type ↔ bin color coupling

Two enums **must stay in sync**:

- `scenes/collectible.gd` defines `TipoLixo { PAPEL, METAL, PLASTICO, VIDRO, ORGANICO }` (ints 0–4).
- `scenes/trash_bin.gd` defines `CorLixeira { AZUL, AMARELA, VERMELHA, VERDE, MARROM }` and a `COR_PARA_TIPO` constant mapping each color to the matching `TipoLixo` int.
- `scenes/hud.gd` indexes `contagem_inventario` by the same 0–4 ordering (`# 0=PAPEL, 1=METAL, ...`).

When you add a new trash type you must update **all three** plus the HUD's `$Control/Inventario` children (one slot per type, in order) and the `COR_PARA_TIPO` dict.

### Player invulnerability

`Player.receber_dano` starts a 1s `$InvulnerabilidadeTimer` and sets `invulneravel = true`. Jumping (`_pular`) also briefly sets `invulneravel = true` — that's intentional (jump-dodge). `_fim_pulo` and `_fim_invulnerabilidade` each only clear `invulneravel` if the *other* state isn't active, so don't simplify either to a blanket `invulneravel = false`.

### Empty `_on_*` stubs on Player

`player.gd` has unused empty `_on_descarte_feito`, `_on_morreu`, `_on_lixo_coletado`, `_on_vida_alterada` methods. These are Godot editor auto-generated stubs from signal connections that don't do anything yet — safe to ignore, but don't delete them without checking the `.tscn` file for signal connections that target them.

## Conventions

- GDScript with explicit type hints (`@onready var x: Type = ...`, typed signal args, typed locals via `:=`). Match this style.
- `@export` for tunables (`vidas_max`, `dano`, `intervalo`, `tipo`, `cor`, `textura`) so designers can adjust per-instance in the editor — prefer `@export` over hardcoded scene values.
- Signal-based communication; avoid `get_node` paths reaching across the scene tree at runtime — wire connections in `_ready()` on the parent that owns both nodes (the `street.gd` pattern).
- Brazilian Portuguese for identifiers and user-facing strings.
