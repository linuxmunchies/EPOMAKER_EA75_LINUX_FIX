Fedora Keyboard Function Key Fix Script
Overview

This repository contains a shell script designed to fix a common issue on Fedora Linux where the function keys (F1-F12) on certain keyboards default to media key actions instead of their standard function. This problem is often caused by the hid_apple kernel module incorrectly identifying the keyboard and applying an "Apple-like" key mapping.

The script, fix_keyboard.sh, automates the process of reconfiguring this module to prioritize standard function key behavior.
Who is this for?

You should use this script if you are:

    Running Fedora Linux.

    Using a keyboard (like certain models from Keychron, Epomaker, etc.) where the F1-F12 keys perform actions like changing volume or screen brightness by default.

    You want the F1-F12 keys to work as standard function keys and use the Fn key modifier to access the media controls.

How it Works

The script performs the following actions safely and interactively:

    Checks for Permissions: It first verifies that it is being run with sudo (root privileges), as it needs to modify system files.

    Verifies Applicability: It checks for the existence of /sys/module/hid_apple/parameters/fnmode. If this file doesn't exist, the script determines that the hid_apple module is not the cause of the issue and exits safely without making changes.

    Applies a Temporary Fix: The script writes the value 2 to the fnmode parameter. This immediately changes the keyboard's behavior for the current session, allowing you to test if the fix works.

    Asks for Confirmation: It then prompts you to confirm whether the temporary fix was successful. If you respond with anything other than 'y', the script reverts the temporary change and exits.

    Makes the Change Permanent: If you confirm the fix worked, the script creates a new configuration file at /etc/modprobe.d/hid_apple.conf. This file contains the line options hid_apple fnmode=2, which tells the system to apply this setting every time it boots.

    Rebuilds the Initramfs: To ensure the setting is loaded early in the boot process, the script rebuilds the initial RAM file system using dracut --force. This is the standard procedure for Fedora.

    Prompts for Reboot: Finally, it informs you that the process is complete and a reboot is required for the permanent changes to take effect.

Usage Instructions

To use the script, follow these steps:

    Save the Script: Save the code to a file named EA75Fix.sh

    Make it Executable: Open a terminal in the directory where you saved the file and run the following command to give it execute permissions:

    chmod +x EA75Fix.sh

    Run with Sudo: Execute the script with sudo:

    sudo ./EA75Fix.sh

    Follow the Prompts: The script will guide you through the testing and confirmation process. After it completes, reboot your computer.

Disclaimer

This script modifies system configuration files. While it is designed to be safe and has checks in place, you should always understand what a script does before running it with root privileges. The author is not responsible for any potential damage to your system.
