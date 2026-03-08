#!/bin/bash
# Sync All Generic Layers
# 
# This script:
# 1. Syncs generic_3x5.keymap → generic_3x5_layers.dtsi
# 2. Extracts core 3x5 keys and injects into generic_3x6_layers.dtsi
# 3. Syncs generic_3x6.keymap → generic_3x6_layers.dtsi (for outer columns)
#
# Usage: ./scripts/sync_all_generic_layers.sh

set -e

KEYMAP_3X5="config/generic_3x5.keymap"
KEYMAP_3X6="config/generic_3x6.keymap"
DTSI_3X5="config/generic_3x5_layers.dtsi"
DTSI_3X6="config/generic_3x6_layers.dtsi"

echo "🔄 Syncing all generic layers..."
echo ""

# Check if files exist
for file in "$KEYMAP_3X5" "$KEYMAP_3X6"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: $file not found"
        exit 1
    fi
done

# Function to extract bindings for a layer
extract_layer() {
    local keymap_file=$1
    local layer_name=$2
    local start_pattern="${layer_name} {"
    local end_pattern=">;$"
    
    awk "/$start_pattern/,/$end_pattern/" "$keymap_file" | \
        sed -n '/bindings = </,/>;/p' | \
        sed '1d;$d' | \
        sed 's/^[[:space:]]*//'
}

# Function to extract core 3x5 keys from a row (removes first and last key)
extract_core_3x5_row() {
    local row=$1
    # Remove leading/trailing whitespace, split by whitespace, remove first and last
    echo "$row" | awk '{for(i=2;i<NF;i++) printf "%s ", $i; if(NF>1) print $NF}'
}

echo "📝 Step 1: Syncing 3x5 layers from $KEYMAP_3X5..."

# Extract 3x5 layers
BASE_3X5=$(extract_layer "$KEYMAP_3X5" "base_layer")
NUM_3X5=$(extract_layer "$KEYMAP_3X5" "num_layer")
SYM_3X5=$(extract_layer "$KEYMAP_3X5" "sym_layer")
ADJ_3X5=$(extract_layer "$KEYMAP_3X5" "adj_layer")

# Create 3x5 .dtsi file
cat > "$DTSI_3X5" << 'EOF'
/*
 * Generic 3x5 Layer Definitions
 * 
 * This file is auto-generated from generic_3x5.keymap
 * Edit generic_3x5.keymap with keymap-editor, then run: ./scripts/sync_all_generic_layers.sh
 * 
 * Include this file in your board's keymap to use the shared layout
 */

// Base Layer - QWERTY with hold-tap on Q (Esc) and P (Backspace)
#define BASE_LAYER \
EOF

echo "$BASE_3X5" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X5"

cat >> "$DTSI_3X5" << 'EOF'

// Numbers Layer - Numbers, F-keys, Navigation
#define NUM_LAYER \
EOF

echo "$NUM_3X5" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X5"

cat >> "$DTSI_3X5" << 'EOF'

// Symbols Layer - All symbols and brackets
#define SYM_LAYER \
EOF

echo "$SYM_3X5" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X5"

cat >> "$DTSI_3X5" << 'EOF'

// Adjust Layer - Bluetooth, system controls, media
#define ADJ_LAYER \
EOF

echo "$ADJ_3X5" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X5"

echo "   ✅ Created $DTSI_3X5"
echo ""

echo "📝 Step 2: Extracting 3x6 layers from $KEYMAP_3X6..."

# Extract 3x6 layers (these have the outer columns defined)
BASE_3X6=$(extract_layer "$KEYMAP_3X6" "base_layer")
NUM_3X6=$(extract_layer "$KEYMAP_3X6" "num_layer")
SYM_3X6=$(extract_layer "$KEYMAP_3X6" "sym_layer")
ADJ_3X6=$(extract_layer "$KEYMAP_3X6" "adj_layer")

# Create 3x6 .dtsi file
cat > "$DTSI_3X6" << 'EOF'
/*
 * Generic 3x6 Layer Definitions
 * 
 * This file is auto-generated from generic_3x6.keymap
 * Edit generic_3x6.keymap with keymap-editor, then run: ./scripts/sync_all_generic_layers.sh
 * 
 * Uses the same macro names as 3x5 for consistency
 * 
 * Layout: 3 rows of 6 keys per side + 3 thumb keys per side = 42 keys
 */

// Base Layer - QWERTY with outer columns
#define BASE_LAYER \
EOF

echo "$BASE_3X6" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X6"

cat >> "$DTSI_3X6" << 'EOF'

// Numbers Layer - Numbers, F-keys, Navigation
#define NUM_LAYER \
EOF

echo "$NUM_3X6" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X6"

cat >> "$DTSI_3X6" << 'EOF'

// Symbols Layer - All symbols and brackets
#define SYM_LAYER \
EOF

echo "$SYM_3X6" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X6"

cat >> "$DTSI_3X6" << 'EOF'

// Adjust Layer - Bluetooth, system controls, media
#define ADJ_LAYER \
EOF

echo "$ADJ_3X6" | sed 's/$/  \\/' | sed '$ s/ \\$//' >> "$DTSI_3X6"

echo "   ✅ Created $DTSI_3X6"
echo ""

echo "✅ Successfully synced all generic layers!"
echo ""
echo "📋 Summary:"
echo "   3x5 Layers:"
echo "      - BASE_LAYER"
echo "      - NUM_LAYER"
echo "      - SYM_LAYER"
echo "      - ADJ_LAYER"
echo ""
echo "   3x6 Layers (same names as 3x5):"
echo "      - BASE_LAYER"
echo "      - NUM_LAYER"
echo "      - SYM_LAYER"
echo "      - ADJ_LAYER"
echo ""
echo "🚀 All boards using these .dtsi files will get the changes on next build!"
echo ""
echo "💡 Tip: To keep 3x5 and 3x6 core keys in sync, edit the core keys"
echo "   in generic_3x5.keymap, then manually update generic_3x6.keymap"
echo "   to match (keeping the outer columns as desired)."
