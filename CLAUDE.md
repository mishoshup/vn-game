# Cereka VN Engine — Dev Notes

## Philosophy
Cereka is to visual novels what Waybar is to status bars: the engine provides the runtime,
game developers script everything else. No recompile needed to change story, UI, or theme —
just edit `.crka` files. The engine stays minimal; expressiveness lives in the script layer.

## Repo layout
- `engine/cereka/` — git submodule → github.com/mishoshup/Cereka
- `assets/`        — current test game project (bg, characters, fonts, sounds, scripts)
- `game.cfg`       — test game config (`entry = assets/scripts/test.crka`)
- `build/`         — cmake build dir (binaries: CerekaGame, CerekaLauncher)

Upstream repo (canonical source): `~/personal/dev/visual-novel-engine`

## Workflow (IMPORTANT — never commit engine changes only in the submodule)
1. Edit engine source in `engine/cereka/` (submodule working copy)
2. Copy changed files to `~/personal/dev/visual-novel-engine/`
3. Commit upstream
4. Sync submodule without SSH:
   ```bash
   cd engine/cereka
   git remote add local-upstream ~/personal/dev/visual-novel-engine
   git fetch local-upstream
   git checkout <new-hash>
   git remote remove local-upstream
   ```
5. Bump pointer: `cd ../.. && git add engine/cereka && git commit -m "update: bump cereka submodule (...)"`
6. Push both when SSH available: upstream first, then vn-with-lua

## Build
```bash
cd engine/cereka/build
cmake .. -DCMAKE_BUILD_TYPE=Debug && cmake --build . -j$(nproc)
# Targets: CerekaGame  CerekaLauncher  Cereka (static lib)
# Note: changing compiler.lua triggers automatic re-embed + recompile (no cmake re-run needed)
```

## Engine architecture
```
src/
├── engine_impl.hpp        — CerekaImpl class declaration (private pimpl, shared by all engine .cpp)
├── ui_config.hpp          — Dim + UiConfig structs (all theme-able UI values with defaults)
├── Cereka.cpp             — init, shutdown, SDL helpers, public CerekaEngine wrapper
├── script_vm.cpp          — TickScript, Update (typewriter + fade), Load, Reset, HandleEvent
├── draw.cpp               — Draw(): all per-frame rendering using UiConfig
├── audio.cpp              — PlayBGM, StopBGM, PlaySFX
├── ui_config.cpp          — ApplyUiSet (processes `ui` blocks at runtime), LoadFont
├── video.hpp/.cpp         — SDL window/display init
├── text_renderer.hpp/.cpp — TTF init
└── compiler/
    ├── vn_instruction.hpp  — Instruction struct, Op enum
    ├── vn_instruction.cpp  — CompileVNScript: Lua compiler + INCLUDE/CALL resolution
    └── embed_lua.cmake     — build-time rule: compiler.lua change → re-embed → recompile
```
- `scripts/compiler.lua` — Lua compiler: parses .crka text → instruction list
- `runner/main.cpp`      — loads game.cfg, compiles entry script, runs 60fps game loop
- `launcher/main.cpp`    — ImGui project manager; writes full tutorial project on "Create Game"

## .crka script command reference
```
; ---------- flow ----------
label <name>           jump <label>              end
include <file>         call <file>               ; include = inline, call = subroutine (returns)

; ---------- scene ----------
bg <file>              bg <file> fade <secs>
bgm <file>             sfx <file>                stop_bgm
char <id> [left|center|right] <file>             hide char <id>
say <id> "text"        narrate "text"

; ---------- logic ----------
set <var> <value>
if <var> == <val>  ...  endif
if <var> != <val>  ...  endif

; ---------- menu ----------
menu
    bg <file>                          ; optional background swap
    button "text" goto <label>
    button "text" exit

; ---------- UI theming ----------
ui textbox
    color 0 0 0 160        ; r g b a
    y     75%              ; % = screen-relative, plain number = pixels
    h     25%
    text_margin_x 80
    text_color 255 255 255 255
    image assets/ui/textbox.png   ; optional: overrides solid color

ui namebox
    color 30 30 100 255
    x 50   y_offset -65   w 260   h 52
    text_color 255 220 120 255
    image assets/ui/namebox.png

ui button
    color 20 80 120 255
    w 560   h 72
    text_color 255 255 255 255
    image assets/ui/button.png
    hover_image assets/ui/button_hover.png

ui font
    size 36
```
Assets resolved from project root: `assets/bg/` `assets/characters/` `assets/sounds/` `assets/fonts/` `assets/ui/`

## Multi-file scripts
- `include <file>` — compile-time inline. Target file's instructions are pasted in place; its `end` is stripped.
  Good for: UI themes, shared label banks, config.
- `call <file>` — runtime subroutine. Pushes return address, jumps to file, resumes on `end`.
  Good for: self-contained scenes, reusable sequences.
- Paths are relative to the including file's directory (so `include ui.crka` from `assets/scripts/main.crka` finds `assets/scripts/ui.crka`).
- Max include/call depth: 32 (prevents infinite loops).

## UI theming
All UI properties have defaults. Override only what you need in a `ui` block.
- Image beats solid color: if `image` is set, the engine draws it instead of `color`.
- `font.size` reloads the font immediately (safe to call before any dialogue).
- Put `include ui.crka` at the top of your entry script to apply a theme before any scene runs.
- Template project ships with `assets/ui/` directory ready for custom sprites.

## Launcher template project
Written to disk on "Create Game":
```
assets/scripts/main.crka      — full tutorial (every command with comments)
assets/scripts/ui.crka        — starter UI theme (ready to customise)
assets/scripts/scene_two.crka — example of a called scene
assets/bg/placeholder_bg.png  — dark gradient
assets/characters/placeholder_char.png — teal silhouette
assets/sounds/placeholder_{bgm,sfx}.wav
assets/fonts/Montserrat-Medium.ttf
assets/ui/                    — empty, ready for custom UI sprites
game.cfg
```

## Roadmap (priority order)
1. ~~Character positions — `char Alice left|center|right <file>`~~ ✓ done
2. ~~Fade/dissolve transitions — `bg <file> fade 0.5`~~ ✓ done
3. ~~Multi-file scripts — `include` / `call`~~ ✓ done
4. ~~UI theming via `.crka` — `ui textbox`, `ui button`, etc.~~ ✓ done
5. Save/load system — serialize pc + variables to disk
6. Typed variables + expressions — `if money > 100`, `set money money+50`
7. Named character definitions — `define char Alice "Alice Liddell" alice_normal.png`
8. Rollback — history stack of execution snapshots
