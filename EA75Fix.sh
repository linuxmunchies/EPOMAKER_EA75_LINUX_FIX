#!/bin/bash

# ==============================================================================
# Fedora Keyboard Function Key Fix
# ------------------------------------------------------------------------------
# This script corrects an issue where function keys (F1-F12) on certain
# keyboards are incorrectly treated as media keys by default. It targets the
# `hid_apple` kernel module, which is a common cause of this behavior on Linux.
#
# The script first applies a temporary fix and asks for confirmation. If the
# temporary fix works, it proceeds to make the change permanent.
#
# Adapted for Fedora, which uses 'dracut' to manage the initramfs.
#
# USAGE:
# 1. Save this script as 'fix_keyboard.sh'
# 2. Make it executable: chmod +x fix_keyboard.sh
# 3. Run with sudo: sudo ./fix_keyboard.sh
# ==============================================================================

fix_keyboard_fn_keys() {
    # Define the path to the hid_apple fnmode parameter
    local fnmode_path="/sys/module/hid_apple/parameters/fnmode"

    echo "--- Keyboard Function Key Fixer for Fedora ---"

    # Step 1: Check for root privileges
    if [[ $EUID -ne 0 ]]; then
       echo "ERROR: This script must be run as root. Please use 'sudo'."
       exit 1
    fi

    # Step 2: Check if the target module parameter exists
    if [ ! -f "$fnmode_path" ]; then
        echo "ERROR: The kernel module parameter was not found at:"
        echo "  $fnmode_path"
        echo "This likely means the 'hid_apple' module is not in use or your"
        echo "system is configured differently. Aborting."
        exit 1
    fi

    # Step 3: Apply the fix temporarily to test it
    echo
    echo "Attempting a temporary fix..."
    if echo 2 > "$fnmode_path"; then
        echo "Temporary fix applied successfully."
        echo "=> Please test your F1-F12 keys now. They should act as standard function keys."
    else
        echo "ERROR: Failed to apply the temporary fix."
        exit 1
    fi

    # Step 4: Ask the user to confirm if the temporary fix worked
    echo
    read -p "Did the temporary fix work correctly? (y/n) " -n 1 -r
    echo # Move to a new line

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting. Reverting temporary change. No permanent changes were made."
        # Revert to the default value (usually 1)
        echo 1 > "$fnmode_path"
        exit 0
    fi

    # Step 5: Make the change permanent
    echo
    echo "Great! Making the change permanent..."

    # Create the modprobe configuration file to set the option on boot
    local conf_file="/etc/modprobe.d/hid_apple.conf"
    echo "Creating configuration file: $conf_file"
    if echo "options hid_apple fnmode=2" > "$conf_file"; then
        echo "Configuration file created."
    else
        echo "ERROR: Failed to create configuration file."
        exit 1
    fi

    # Rebuild the initramfs using dracut for Fedora
    echo "Rebuilding the initramfs with 'dracut'. This may take a few moments..."
    if dracut --force; then
        echo "Initramfs rebuilt successfully."
    else
        echo "ERROR: Failed to rebuild initramfs with dracut."
        exit 1
    fi

    echo
    echo "--- SUCCESS ---"
    echo "The configuration has been saved permanently."
    echo "Please reboot your computer for the changes to take full effect."
}

# Execute the function
fix_keyboard_fn_keys
