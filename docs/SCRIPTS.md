# ZMK Config Scripts

Automation scripts for managing generic keymaps across multiple boards.

## Setup

**Install the pre-commit hook (recommended):**

Mac/Linux:
```bash
./scripts/setup-hooks.sh
```

Windows:
```batch
scripts\setup-hooks.bat
```

This automatically syncs keymaps before each commit!

**Note:** All scripts have both `.sh` (Mac/Linux) and `.bat` (Windows) versions. 

- Windows `.bat` scripts use PowerShell for text processing (included helper `.ps1` files)
- The pre-commit hook works on all platforms via Git Bash

## Scripts

### `setup-hooks` (.sh / .bat)
Installs the pre-commit hook that automatically syncs keymaps.

**Usage:**

Mac/Linux:
```bash
./scripts/setup-hooks.sh
```

Windows:
```batch
scripts\setup-hooks.bat
```

### `pre-commit`
Git pre-commit hook that runs automatically before each commit.

**What it does:**
- Syncs 3x5 → 3x6 keymaps
- Updates .dtsi files
- Adds synced files to commit

**To bypass:**
```bash
git commit --no-verify
```

### `sync_3x5_to_3x6` (.sh / .bat)
Syncs core keys from generic_3x5.keymap to generic_3x6.keymap.

**Usage:**

Mac/Linux:
```bash
./scripts/sync_3x5_to_3x6.sh
```

Windows:
```batch
scripts\sync_3x5_to_3x6.bat
```

**What it does:**
- Extracts core 3x5 alpha keys
- Adds outer columns (Tab/Ctrl/Shift, Bspc/'/Shift)
- Expands 2-thumb to 3-thumb layout
- Updates generic_3x6.keymap

### `sync_all_generic_layers` (.sh / .bat)
Syncs keymap files to .dtsi layer definition files.

**Usage:**

Mac/Linux:
```bash
./scripts/sync_all_generic_layers.sh
```

Windows:
```batch
scripts\sync_all_generic_layers.bat
```

**What it does:**
- Extracts bindings from generic_3x5.keymap → generic_3x5_layers.dtsi
- Extracts bindings from generic_3x6.keymap → generic_3x6_layers.dtsi
- Board keymaps include these .dtsi files automatically

## Workflow

1. **Edit** `config/generic_3x5.keymap` with keymap-editor
2. **Commit** - the pre-commit hook handles the rest!
3. **Push** - GitHub Actions builds firmware for all boards

All boards (a_dux, cradios, corne) stay in sync automatically!
