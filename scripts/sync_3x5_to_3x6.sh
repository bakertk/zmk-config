#!/bin/bash
# Sync 3x5 Core to 3x6
# 
# This script automatically syncs core keys from generic_3x5.keymap to generic_3x6.keymap
# 
# Mapping:
# - Core 3x5 alpha keys stay the same
# - 3x5 thumbs (2 per side) → 3x6 middle thumbs (outer 2 of 3)
# - Outer columns: Tab/Ctrl/Shift (left), Bspc/'/Shift (right)
# - Extra thumb: Tab (left), GUI (right)
#
# Usage: ./scripts/sync_3x5_to_3x6.sh

set -e

KEYMAP_3X5="config/generic_3x5.keymap"
KEYMAP_3X6="config/generic_3x6.keymap"
TEMP_FILE=$(mktemp)

echo "🔄 Syncing 3x5 core keys to 3x6..."
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
    
    awk "/${layer_name} {/,/>;/" "$keymap_file" | \
        sed -n '/bindings = </,/>;/p' | \
        sed '1d;$d' | \
        sed 's/^[[:space:]]*//'
}

echo "📝 Extracting 3x5 layers..."

# Extract 3x5 layers
BASE_3X5=$(extract_layer "$KEYMAP_3X5" "base_layer")
NUM_3X5=$(extract_layer "$KEYMAP_3X5" "num_layer")
SYM_3X5=$(extract_layer "$KEYMAP_3X5" "sym_layer")
ADJ_3X5=$(extract_layer "$KEYMAP_3X5" "adj_layer")

# Function to convert 3x5 layer to 3x6
# Adds outer columns and expands thumb cluster
convert_to_3x6() {
    local layer_3x5=$1
    local left_outer_1=$2
    local left_outer_2=$3
    local left_outer_3=$4
    local right_outer_1=$5
    local right_outer_2=$6
    local right_outer_3=$7
    local left_thumb_extra=$8
    local right_thumb_extra=$9
    
    # Split into rows
    local row1=$(echo "$layer_3x5" | sed -n '1p')
    local row2=$(echo "$layer_3x5" | sed -n '2p')
    local row3=$(echo "$layer_3x5" | sed -n '3p')
    local row4=$(echo "$layer_3x5" | sed -n '4p')
    
    # Add outer columns to alpha rows
    echo "$left_outer_1  $row1  $right_outer_1"
    echo "$left_outer_2  $row2  $right_outer_2"
    echo "$left_outer_3  $row3  $right_outer_3"
    
    # Expand thumb row: add extra thumb on each side
    # 3x5: [mo 1] [RET]  [SPACE] [mo 2]
    # 3x6: [TAB] [mo 1] [RET]  [SPACE] [mo 2] [GUI]
    echo "                                       $left_thumb_extra  $row4  $right_thumb_extra"
}

echo "📝 Converting layers to 3x6 format..."

# Base layer: Tab/Ctrl/Shift on left, Bspc/'/Shift on right
BASE_3X6=$(convert_to_3x6 "$BASE_3X5" \
    "&kp TAB" "&kp LCTRL" "&kp LSHFT" \
    "&kp BSPC" "&kp SQT" "&kp RSHFT" \
    "&kp TAB" "&kp LGUI")

# Num layer: Esc/F11/F12 on left, Del/Tab/Ins on right
NUM_3X6=$(convert_to_3x6 "$NUM_3X5" \
    "&kp ESC" "&kp F11" "&kp F12" \
    "&kp DEL" "&kp TAB" "&kp INS" \
    "&trans" "&trans")

# Sym layer: Tilde/Shift/Shift on left, Bspc/'/Shift on right
SYM_3X6=$(convert_to_3x6 "$SYM_3X5" \
    "&kp TILDE" "&kp LSHFT" "&kp LSHFT" \
    "&kp BSPC" "&kp SQT" "&kp RSHFT" \
    "&trans" "&trans")

# Adj layer: none/none/Bootloader on left, none/none/none on right
ADJ_3X6=$(convert_to_3x6 "$ADJ_3X5" \
    "&none" "&none" "&bootloader" \
    "&none" "&none" "&none" \
    "&none" "&none")

echo "📝 Updating $KEYMAP_3X6..."

# Create new 3x6 keymap with updated bindings
cat > "$TEMP_FILE" << 'HEADER'
/*
 * Generic 3x6 Keymap
 * 
 * AUTO-SYNCED from generic_3x5.keymap
 * Core keys are synced automatically - outer columns defined here
 * 
 * Edit generic_3x5.keymap, then run: ./scripts/sync_3x5_to_3x6.sh
 */

#include <behaviors.dtsi>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/ext_power.h>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/outputs.h>

/ {
    behaviors {
        esc_q: escape_q {
            compatible = "zmk,behavior-hold-tap";
            #binding-cells = <2>;
            flavor = "tap-preferred";
            tapping-term-ms = <200>;
            quick-tap-ms = <150>;
            bindings = <&kp>, <&kp>;
        };
        
        bspc_p: backspace_p {
            compatible = "zmk,behavior-hold-tap";
            #binding-cells = <2>;
            flavor = "tap-preferred";
            tapping-term-ms = <200>;
            quick-tap-ms = <150>;
            bindings = <&kp>, <&kp>;
        };
    };

    combos {
        compatible = "zmk,combos";

        combo_unlock {
            timeout-ms = <50>;
            key-positions = <0 1>;
            bindings = <&studio_unlock>;
            layers = <0>;
        };

        combo_adj {
            timeout-ms = <200>;
            key-positions = <36 41>;
            bindings = <&mo 3>;
        };
    };

    keymap {
        compatible = "zmk,keymap";

        base_layer {
            display-name = "Base";
            bindings = <
HEADER

echo "$BASE_3X6" >> "$TEMP_FILE"

cat >> "$TEMP_FILE" << 'MID1'
            >;
        };

        num_layer {
            display-name = "Numbers";
            bindings = <
MID1

echo "$NUM_3X6" >> "$TEMP_FILE"

cat >> "$TEMP_FILE" << 'MID2'
            >;
        };

        sym_layer {
            display-name = "Symbols";
            bindings = <
MID2

echo "$SYM_3X6" >> "$TEMP_FILE"

cat >> "$TEMP_FILE" << 'MID3'
            >;
        };

        adj_layer {
            display-name = "Adjust";
            bindings = <
MID3

echo "$ADJ_3X6" >> "$TEMP_FILE"

cat >> "$TEMP_FILE" << 'FOOTER'
            >;
        };
    };
};
FOOTER

# Replace the 3x6 keymap
mv "$TEMP_FILE" "$KEYMAP_3X6"

echo "   ✅ Updated $KEYMAP_3X6"
echo ""
echo "✅ Successfully synced 3x5 → 3x6!"
echo ""
echo "📋 Next steps:"
echo "   1. Review $KEYMAP_3X6 to verify outer columns"
echo "   2. Run: ./scripts/sync_all_generic_layers.sh"
echo "   3. Commit and build!"
