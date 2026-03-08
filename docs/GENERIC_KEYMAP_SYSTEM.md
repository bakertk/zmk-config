# Generic Keymap System

This ZMK config uses a shared keymap system to keep multiple boards in sync.

## Architecture

### Core Files

1. **generic_3x5.keymap** - The master keymap (edit this with keymap-editor)
2. **generic_3x5_behaviors.dtsi** - Shared behaviors and macros
3. **generic_3x5_layers.dtsi** - Layer definitions (auto-generated)
4. **generic_3x6.keymap** - 3x6 version (auto-synced from 3x5)
5. **generic_3x6_layers.dtsi** - 3x6 layer definitions (auto-generated)

### How It Works

```
generic_3x5.keymap (edit this)
       ↓
   [sync scripts]
       ↓
   ┌───┴────┐
   ↓        ↓
3x5_layers  3x6.keymap
   ↓            ↓
   ↓        [sync scripts]
   ↓            ↓
   ↓        3x6_layers
   ↓            ↓
   └────┬───────┘
        ↓
   Board keymaps include these
```

## Board Keymap Structure

Each board keymap should follow this pattern:

```c
#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>
// ... other includes

// Include shared behaviors FIRST
#include "generic_3x5_behaviors.dtsi"

// Include shared layers
#include "generic_3x5_layers.dtsi"

/ {
    // Board-specific combos, settings, etc.
    
    keymap {
        compatible = "zmk,keymap";
        
        base_layer {
            bindings = < BASE_LAYER >;
        };
        
        num_layer {
            bindings = < NUM_LAYER >;
        };
        
        sym_layer {
            bindings = < SYM_LAYER >;
        };
        
        fnc_layer {
            bindings = < FNC_LAYER >;
        };
    };
};
```

## What's Shared

### Behaviors (generic_3x5_behaviors.dtsi)
- `esc_q` - Tap Q, hold Esc
- `bspc_p` - Tap P, hold Backspace
- `lmt` - Left hand homerow mods (Ctrl, Alt, GUI)
- `rmt` - Right hand homerow mods (GUI, Alt, Ctrl)
- `lst` - Left shift with tap-preferred
- `rst` - Right shift with tap-preferred

### Macros (generic_3x5_behaviors.dtsi)
- `vim_q` - Types `:q!` for Vim
- `vim_s` - Types `:x` for Vim
- `dir_up` - Types `../` for navigation

### Layers (generic_3x5_layers.dtsi)
- `BASE_LAYER` - QWERTY with homerow mods
- `NUM_LAYER` - Numbers, F-keys, navigation
- `SYM_LAYER` - Symbols and brackets
- `FNC_LAYER` - Bluetooth, system, media controls

## Workflow

### 1. Edit the Master Keymap
```bash
# Edit with keymap-editor or manually
code config/generic_3x5.keymap
```

### 2. Sync to Other Formats
```bash
# Windows
scripts\sync_3x5_to_3x6.bat
scripts\sync_all_generic_layers.bat

# Linux/Mac
./scripts/sync_3x5_to_3x6.sh
./scripts/sync_all_generic_layers.sh
```

### 3. Commit and Build
```bash
git add .
git commit -m "Update keymap"
git push
```

Or install the pre-commit hook to automate step 2:
```bash
scripts\setup-hooks.bat  # Windows
./scripts/setup-hooks.sh # Linux/Mac
```

## Adding a New Board

1. Create `config/yourboard.keymap`
2. Include the shared files:
   ```c
   #include "generic_3x5_behaviors.dtsi"
   #include "generic_3x5_layers.dtsi"
   ```
3. Use the layer macros in your keymap
4. Add board-specific combos/settings as needed
5. Add to `build.yaml`

## Customizing Per Board

If a board needs different behaviors:

1. Don't include `generic_3x5_behaviors.dtsi`
2. Define your own behaviors in the board keymap
3. Still include `generic_3x5_layers.dtsi` for the layers

If a board needs different layers:

1. Don't use the layer macros
2. Define layers directly in the board keymap
3. Or create board-specific layer files

## Benefits

✅ Edit once, update all boards
✅ Consistent behavior across keyboards
✅ Easy to maintain and test
✅ Keymap-editor compatible
✅ No code duplication

## Current Boards Using This System

- **a_dux** - 3x5 + 2 thumbs (34 keys)
- More boards can be added easily!
