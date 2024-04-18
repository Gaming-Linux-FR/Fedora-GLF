#!/usr/bin/env bash
#===================================================================================
#
# FILE : fedora-GLF.sh
#
# USAGE : ./fedora-GLF.sh
#
# DESCRIPTION : Post installation script for Fedora Linux as a gaming/content creator station.
#
# BUGS: 
# GameMode Gnome Shell Extension is broken on Fedora 39 https://bugzilla.redhat.com/show_bug.cgi?id=2259979
# gamemode-1.8.1 is available https://bugzilla.redhat.com/show_bug.cgi?id=2253403
# NOTES: ---
# CONTRUBUTORS: Chevek, Cardiac
# CREATED: april 2024
# REVISION: april 13th 2024
#
# LICENCE:
# Copyright (C) 2024 Yannick Defais aka Chevek
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#===================================================================================

#===================================================================================
# TODO:
# - Add secure boot support for NVIDIA ( https://rpmfusion.org/Howto/Secure%20Boot )
# - Add Xbox Gamepad support (xpadneo ?)
# - Add translation support (gettext)
# - Add options to the script (VERBOSE...)
# - add GUI
# - Add ZLUDA support ( https://github.com/vosen/ZLUDA ), if still relevant...

# Set shell options
set -e

# Color and Formatting Definitions
color_text() {
    local color_code=$1
    local text=$2
    echo "$(tput setaf $color_code)$text$(tput sgr0)"
}

check_network_connection() {
    if ! ping -c 1 google.com &> /dev/null; then
        echo "No network connection. Please check your internet connection and try again."
        exit 1
    fi
}

# Get the directory of the script
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Initialize logging by defining and setup a log file
source $BASE_DIR/src/log_setup.sh

# Perform system updates, optimizes DNF configuration, and manages firmware updates
source $BASE_DIR/src/system_setup.sh

# Set up RPM Fusion repositories and configures Flatpak with the Flathub repository
source $BASE_DIR/src/add_repositories.sh

# Install NVIDIA GPU drivers if an NVIDIA GPU is detected and sets up hardware acceleration for NVIDIA, AMD, and Intel graphics cards.
source $BASE_DIR/src/gpu.sh

# Install Microsoft fonts and various other popular fonts
source $BASE_DIR/src/fonts.sh

# Install a variety of softwares and utilities including compression tools and miscellaneous applications like OpenRGB and Fastfetch
source $BASE_DIR/src/utilities.sh

# Configure the desktop environment
source $BASE_DIR/src/desktop_environment.sh

# Main function to run all tasks
main() {
    log_setup
    check_network_connection
    system_setup
    add_repositories
    gpu
    fonts
    utilities
    desktop_environment
    log_msg "$(color_text 2 "[X] Script completed. Please reboot.")"
}

# Run the script
main
