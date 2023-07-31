#!/bin/bash
#
# This script allows users to switch between different keyboard layout and variant combinations
# using a simple menu interface. The script supports a wide array of keyboard layouts and
# variants, which can be customized as per the user's needs.
#
# The script keeps track of the combinations used by the user and allows the user to quickly
# toggle between them. The user can cycle through the last four used combinations.
#
# Dependencies:
# - dmenu: dmenu is a fast and lightweight dynamic menu for X. It is needed to provide
#   the menu interface.
# - setxkbmap: setxkbmap is a part of the X Window System that changes the keymap of
#   the keyboard to use different layouts.
# - awk: awk is a versatile programming language for working on files.
#   It is used here to process the selected layout and variant.
#
# Directory Structure:
# The script creates and uses a directory at $HOME/.cache/dmenu_utilities to store the
# combinations used by the user. The used combinations are stored in a text file named
# keyboard_used_combinations.txt.
#
# Usage:
# The user will then see a menu with options to select a layout and variant combination,
# select from previously used combinations, or cycle through the last four used combinations.

# Define your layouts and variants here
variants=(",chr" ",euro" ",intl" ",alt-intl" ",colemak" ",dvorak" ",dvorak-intl" ",dvorak-alt-intl" ",dvorak-l" ",dvorak-r" ",dvorak-classic" ",dvp" ",rus" ",mac" ",altgr-intl" ",olpc2" ",hbs" ",workman" ",workman-intl" ",ps" ",uz" ",olpc-ps" ",fa-olpc" ",uz-olpc" ",azerty" ",azerty_digits" ",digits" ",qwerty" ",qwerty_digits" ",buckwalter" ",mac" ",plisi-d1" ",phonetic" ",phonetic-alt" ",eastern" ",western" ",eastern-alt" ",nodeadkeys" ",sundeadkeys" ",mac" ",cyrillic" ",legacy" ",latin" ",oss" ",oss_latin9" ",oss_sundeadkeys" ",iso-alternate" ",nodeadkeys" ",sundeadkeys" ",wang" ",urd-phonetic" ",urd-phonetic3" ",urd-winkeys" ",eng" ",alternatequotes" ",unicode" ",unicodeus" ",us" ",nodeadkeys" ",dvorak" ",nativo" ",nativo-us" ",nativo-epo" ",thinkpad" ",phonetic" ",bas_phonetic" ",ber" ",ar" ",french" ",tifinagh" ",tifinagh-alt" ",tifinagh-alt-phonetic" ",tifinagh-extended" ",tifinagh-phonetic" ",tifinagh-extended-phonetic" ",french" ",qwerty" ",azerty" ",dvorak" ",mmuock" ",fr-dvorak" ",fr-legacy" ",multix" ",multi" ",multi-2gr" ",ike" ",eng" ",tib" ",tib_asciinum" ",ug" ",alternatequotes" ",unicode" ",unicodeus" ",us" ",bksl" ",qwerty" ",qwerty_bksl" ",ucw" ",dvorak-ucw" ",rus" ",nodeadkeys" ",winkeys" ",mac" ",mac_nodeadkeys" ",dvorak" ",sundeadkeys" ",neo" ",mac" ",mac_nodeadkeys" ",dsb" ",dsb_qwertz" ",qwerty" ",tr" ",ru" ",deadtilde" ",simple" ",extended" ",nodeadkeys" ",polytonic" ",standard" ",nodeadkeys" ",qwerty" ",101_qwertz_comma_dead" ",101_qwertz_comma_nodead" ",101_qwertz_dot_dead" ",101_qwertz_dot_nodead" ",101_qwerty_comma_dead" ",101_qwerty_comma_nodead" ",101_qwerty_dot_dead" ",101_qwerty_dot_nodead" ",102_qwertz_comma_dead" ",102_qwertz_comma_nodead" ",102_qwertz_dot_dead" ",102_qwertz_dot_nodead" ",102_qwerty_comma_dead" ",102_qwerty_comma_nodead" ",102_qwerty_dot_dead" ",102_qwerty_dot_nodead" ",Sundeadkeys" ",nodeadkeys" ",mac_legacy" ",mac" ",mac_legacy" ",lyx" ",phonetic" ",biblical" ",nodeadkeys" ",winkeys" ",mac" ",us" ",geo" ",ibm" ",kana" ",kana86" ",OADG109A" ",mac" ",phonetic" ",ruskaz" ",kazrus" ",ext" ",stea" ",nodeadkeys" ",deadtilde" ",sundeadkeys" ",dvorak" ",std" ",us" ",pes_keypad" ",ku" ",ku_f" ",ku_alt" ",ku_ara" ",ku" ",ku_f" ",ku_alt" ",ku_ara" ",nodeadkeys" ",classic" ",nodeadkeys" ",winkeys" ",mac" ",nodeadkeys" ",dvorak" ",rus" ",rus_nodeadkeys" ",smi" ",mac" ",svdvorak" ",swl" ",legacy" ",de_nodeadkeys" ",de_sundeadkeys" ",fr" ",fr_nodeadkeys" ",fr_sundeadkeys" ",fr_mac" ",de_mac" ",syc" ",syc_phonetic" ",ku" ",ku_f" ",ku_alt" ",legacy" ",tam_unicode" ",tam_TAB" ",us" ",tis" ",pat" ",f" ",alt" ",sundeadkeys" ",ku" ",ku_f" ",ku_alt" ",intl" ",crh" ",crh_f" ",crh_alt" ",indigenous" ",saisiyat" ",phonetic" ",typewriter" ",winkeys" ",legacy" ",rstu" ",rstu_ru" ",homophonic" ",extd" ",intl" ",dvorak" ",dvorakukp" ",mac" ",mac_intl" ",colemak" ",latin" ",kr104" ",CloGaelach" ",UnicodeExpert" ",ogam" ",ogam_is434" ",urd-crulp" ",urd-nla" ",ara" ",snd" ",legacy" ",igbo" ",yoruba" ",hausa" ",left_hand" ",right_hand" ",alt" ",fr-oss" ",us-mac" ",us-intl" ",kik" ",qwerty-bay" ",capewell-dvorak" ",capewell-dvorak-bay" ",capewell-qwerf2k6" ",capew")
layouts=("us" "af" "ara" "al" "am" "at" "au" "az" "by" "be" "in" "ba" "br" "bg" "dz" "ma" "cm" "mm" "ca" "cd" "cn" "hr" "cz" "dk" "nl" "bt" "ee" "ir" "iq" "fo" "fi" "fr" "gh" "gn" "ge" "de" "gr" "hu" "is" "il" "it" "jp" "kg" "kh" "kz" "la" "latam" "lt" "lv" "mao" "me" "mk" "mt" "mn" "no" "pl" "pt" "ro" "ru" "rs" "si" "sk" "es" "se" "ch" "sy" "tj" "lk" "th" "tr" "tw" "ua" "gb" "uz" "vn" "kr" "nec_vndr/jp" "ie" "pk" "mv" "za" "epo" "np" "ng" "et" "sn" "brai" "tm" "ml" "tz" "tg" "ke" "bw" "ph" "md" "id" "my" "bn")

# Combine layouts and variants
layout_variants=()
for layout in "${layouts[@]}"; do
    for variant in "${variants[@]}"; do
        layout_variants+=("$layout $variant")
    done
done

# Create directory if not exists
dir="$HOME/.cache/dmenu_utilities"
if [[ ! -d $dir ]]; then
    mkdir -p $dir
fi

# File to store used combinations
used_combinations_file="$dir/keyboard_used_combinations.txt"

# Create file if not exists
if [[ ! -f $used_combinations_file ]]; then
    touch $used_combinations_file
fi

# Read used combinations
used_combinations=()
if [[ -f $used_combinations_file ]]; then
    mapfile -t used_combinations < $used_combinations_file
fi

# Recursive function for main menu
main_menu() {
    # Fetch the current layout and variant
    current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')
    current_variant=$(setxkbmap -query | grep variant | awk '{print $2}')
    current_combination="Current: $current_layout $current_variant"

    # Main menu
    options=("$current_combination" "All Combinations" "Used Combinations" "Cycle Through Used Combinations")
    choice=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'Select an option:')

    # Skip the action if the current combination is selected
    if [[ $choice == $current_combination ]]; then
        main_menu
        return
    fi

    case $choice in
        "All Combinations")
            combination=$(printf '%s\n' "${layout_variants[@]}" | dmenu -i -p 'Select keyboard layout and variant:')
            if [[ -n $combination ]]; then
                # Deduplication: Only add if not already in the list
                if ! grep -Fxq "$combination" $used_combinations_file; then
                    # If there are already 4 used combinations, remove the oldest one
                    if [[ ${#used_combinations[@]} -ge 4 ]]; then
                        sed -i "1d" $used_combinations_file
                    fi
                    # Add the new combination to the list of used combinations
                    echo $combination >> $used_combinations_file
                    # Reload the list of used combinations
                    mapfile -t used_combinations < $used_combinations_file
                fi
                layout=$(echo $combination | awk '{print $1}')
                variant=$(echo $combination | awk '{print $2}')
                setxkbmap -layout $layout -variant $variant
                echo "Keyboard layout and variant changed to $combination"
                sleep 1
                main_menu
            else
                # If no option is selected, recall main menu
                main_menu
            fi
            ;;
        "Used Combinations")
            if [[ ${#used_combinations[@]} -eq 0 ]]; then
                echo "No used combinations. Please select from All Combinations first."
                main_menu
            fi
            combination=$(printf '%s\n' "${used_combinations[@]}" | dmenu -i -p 'Select used keyboard layout and variant:')
            if [[ -n $combination ]]; then
                layout=$(echo $combination | awk '{print $1}')
                variant=$(echo $combination | awk '{print $2}')
                setxkbmap -layout $layout -variant $variant
                echo "Keyboard layout and variant changed to $combination"
                sleep 1
                main_menu
            else
                # If no option is selected, recall main menu
                main_menu
            fi
            ;;
        "Cycle Through Used Combinations")
            if [[ ${#used_combinations[@]} -lt 2 ]]; then
                echo "Not enough used combinations to toggle. Please select from All Combinations first."
                main_menu
            fi
            # Switch to the next used combination
            used_combinations=("${used_combinations[@]:1}" "${used_combinations[0]}")
            # Save the used combinations
            printf "%s\n" "${used_combinations[@]}" > $used_combinations_file

            # Apply the new layout and variant
            combination=${used_combinations[0]}
            layout=$(echo $combination | awk '{print $1}')
            variant=$(echo $combination | awk '{print $2}')
            setxkbmap -layout $layout -variant $variant
            echo "Keyboard layout and variant toggled to $combination"
            sleep 1

            # Recall the main menu
            main_menu
            ;;
        *)
            echo "Invalid option. Exiting..."
            exit 1
            ;;
    esac
}

# Call main menu
main_menu
