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


#===================================================================================
# Log Setup and configuration
# Source : https://github.com/Gaming-Linux-FR/Architect/blob/main/src/cmd.sh
#===================================================================================

# Set default configuration
VERBOSE=false
LOG_FILE="$(dirname "$(realpath "$0")")/logfile_Fedora_GLF_$(date "+%Y%m%d-%H%M%S").log"

# Function to log messages
log() {
    local level=$1
    local message=$2
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $level: $message" >> "$LOG_FILE"
}

# Function to display and log messages
log_msg() {
    local message=$1
    echo "$message"
    log INFO "$message"
}

# Function to execute and log commands
exec_command() {
    local command="$1"
    local log_command="Executing: $command"
    if [ "$VERBOSE" = true ]; then
        log_command+=" (Verbose)"
    fi
    log INFO "$log_command"
    if [ "$VERBOSE" = true ]; then
        eval "$command" 2>&1 | tee -a "$LOG_FILE" || { log ERROR "Failed command: $command"; return 1; }
    else
        eval "$command" >> "$LOG_FILE" 2>&1 || { log ERROR "Failed command: $command"; return 1; }
    fi
}

# Function to initialize log file
init_log() {
    touch "$LOG_FILE" || { log ERROR "Failed to create log file"; exit 1; }
    local git_hash=$(git rev-parse HEAD 2>/dev/null || echo "Git not available")
    echo -e "Commit hash: $git_hash" >> "$LOG_FILE"
    echo -e "Log file: $LOG_FILE\n" >> "$LOG_FILE"
}

# Function to set up logging
log_setup() {
    init_log
}

#===================================================================================
# Check for system updates
# Source : https://docs.fedoraproject.org/en-US/fedora/latest/system-administrators-guide/package-management/DNF/#sec-Checking_For_and_Updating_Packages
#===================================================================================
# We need an up to date system !
updates() {
    log_msg "Checking for system updates:"
    if dnf check-update --refresh; then
        log_msg "System is up to date."
    else
        local errmsg=$(color_text 1 "[X] The script requires an updated system. Please update and reboot, then rerun the script.")
        log_msg "$errmsg"
        exit 1
    fi
}


#===================================================================================
# DNF configuration
# Source : https://linuxtricks.fr/wiki/fedora-script-post-installation
#===================================================================================
dnf() {
    log_msg "Optimizing DNF:"
    {
        grep -Fq "fastestmirror=" /etc/dnf/dnf.conf || echo 'fastestmirror=true' | sudo tee -a /etc/dnf/dnf.conf
        grep -Fq "max_parallel_downloads=" /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
        grep -Fq "countme=" /etc/dnf/dnf.conf || echo 'countme=true' | sudo tee -a /etc/dnf/dnf.conf
    } || { log ERROR "Failed to configure DNF"; exit 1; }
}


#===================================================================================
# Firmwares configuration
# Source : https://github.com/fwupd/fwupd#basic-usage-flow-command-line
#===================================================================================
firmwares() {
    log_msg "Firmwares update:"
    exec_command "sudo fwupdmgr get-devices"
    exec_command "sudo fwupdmgr refresh --force"
    RC=0
    sudo fwupdmgr get-updates || RC=$?
    sudo fwupdmgr update || RC=$?
    if [[ $RC -eq 0 ]]; then
        log_msg "Firmware updated successfully."
    elif [[ $RC -eq 1 ]]; then
        log_msg "No firmware updates available."
    else
        log_msg "Failed to update firmware."
    fi
}

system_setup() {
updates
dnf
firmwares
}

#===================================================================================
# RPM Fusion configuration
# Source : https://rpmfusion.org/Configuration
#===================================================================================
rpmfusion() {
    log_msg "Setting up RPM Fusion repositories:"
    exec_command "sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    exec_command "sudo dnf config-manager -y --enable fedora-cisco-openh264"
    exec_command "sudo dnf install -y rpmfusion-nonfree-release-tainted"

}

#===================================================================================
# Flathub configuration
# Source : https://flatpak.org/setup/Fedora
#===================================================================================
flatpak() {
    log_msg "Adding Flathub repository:"
    exec_command "sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"

}

add_repositories() {
rpmfusion
flatpak
}

#===================================================================================
# NVIDIA GPU configuration
# Source : https://rpmfusion.org/Howto/NVIDIA
#===================================================================================
nvidia() {
    GPU_TYPE=$(lspci | grep -E "VGA|3D" | cut -d ":" -f3)
    if [[ $GPU_TYPE =~ "NVIDIA" ]]; then
        log_msg "Configuring for NVIDIA GPUs (2014+):"
        exec_command "sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda"
        exec_command "sudo dnf install -y xorg-x11-drv-nvidia-cuda-libs nvidia-vaapi-driver libva-utils vdpauinfo"
    else
        log_msg "No NVIDIA GPU detected, skipping NVIDIA driver installation."
    fi
}
#===================================================================================
# Hardware acceleration
# Sources : https://rpmfusion.org/Howto/Multimedia
#===================================================================================
hardware_acceleration() {
    log_msg "GPU hardware acceleration :"
    if [[ $GPU_TYPE =~ "NVIDIA" ]]; then
        log_msg "Déjà configuré pour les GPU NVIDIA."
        # Note: NVIDIA driver configuration is already handled in the NVIDIA GPU configuration function.
        # sudo dnf install nvidia-vaapi-driver
    elif [[ $GPU_TYPE =~ "AMD" ]]; then
        log_msg "AMD GPU detected :"
        log_msg "Codecs for Mesa3D :"
        exec_command "sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld"
        exec_command "sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld"
        # i686 compat for Steam
        exec_command "sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686"
        exec_command "sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686"
        # RocM
        log_msg "Install ROCm :" \
        "sudo dnf -y install rocm-opencl rocminfo rocm-clinfo rocm-hip rocm-runtime rocm-smi"
    elif [[ $GPU_TYPE =~ "INTEL" ]]; then
        log_msg "INTEL GPU detected :"
        log_msg "Codecs for Mesa3D :"
        exec_command "sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld"
        exec_command "sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld"
        # i686 compat for Steam
        exec_command "sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686"
        exec_command "sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686"
        exec_command "sudo dnf install -y intel-media-driver"
    fi
}

gpu() {
nvidia
hardware_acceleration
}

#===================================================================================
# Fonts Microsoft
# Source : https://www.linuxcapable.com/install-microsoft-fonts-on-fedora-linux/
#===================================================================================
microsoft_fonts() {
    log_msg "Install Microsoft fonts :"
    exec_command "sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig"
    RC=0
    sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm || RC=$?
    if [[ $RC -eq 0 ]]; then
        log_msg "Microsoft fonts installed successfully."
    else
        log_msg "Failed to install Microsoft fonts."
    fi
}

# Install various fonts
various_fonts() {
    log_msg "Installing fonts (Google Roboto, Mozilla Fira, dejavu, liberation, Google Noto Emoji-sans-serif, Adobe Source, Awesome, Google Droid):"
    exec_command "sudo dnf install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts dejavu-fonts-all liberation-fonts google-noto-emoji-fonts google-noto-color-emoji-fonts google-noto-sans-fonts google-noto-serif-fonts 'adobe-source-code*' adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts fontawesome-fonts-all google-droid-fonts-all"
}

fonts() {
microsoft_fonts
various_fonts
}

# Install compression tools
compression_tools() {
    log_msg "Installing compression tools (7zip, rar, ace, lha):"
    exec_command "sudo dnf install -y p7zip p7zip-plugins unrar unace lha"
}

# Desktop Tools
various-softwares() {
    log_msg "Installing OpenRGB, Fastfetch, gamemode, flatseal and uBlock Origin for Firefox:"
    exec_command "sudo dnf install -y openrgb gamemode fastfetch mozilla-ublock-origin"
    exec_command "flatpak install -y flatseal"
}

#===================================================================================
# Multimedia configuration
# Source : https://rpmfusion.org/Howto/Multimedia
#===================================================================================
setup_multimedia() {
    log_msg "Setting up multimedia support:"
    exec_command "sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing"
    exec_command "sudo dnf groupupdate -y multimedia --setopt='install_weak_deps=False' --exclude=PackageKit-gstreamer-plugin"
    exec_command "sudo dnf groupupdate -y sound-and-video"
}

# Various firmware. Tainted nonfree is dedicated to non-FLOSS packages without a clear redistribution status by the copyright holder. But is allowed as part of hardware inter-operability between operating systems in some countries :
nonfree_firmware() {
    log_msg "Installing various non-free firmware packages (b43, broadcom-bt, dvb, nouveau):"
    exec_command "sudo dnf --repo=rpmfusion-nonfree-tainted install -y '*-firmware'"
}

utilities() {
compression_tools
various-softwares
setup_multimedia
nonfree_firmware
}

# Configure GNOME desktop
gnome() {
    if [[ $(pgrep -c gnome-shell) -gt 0 ]]; then
        log_msg "Installing GNOME Tweaks and essential GNOME Shell extensions:"
        exec_command "sudo dnf install -y gnome-tweaks gnome-extensions-app gnome-shell-extension-appindicator gnome-shell-extension-caffeine gnome-shell-extension-gamemode gnome-shell-extension-gsconnect"

        if [[ ! -f /etc/dconf/db/local.d/00-extensions ]]; then
            echo "Setting up system-wide GNOME extensions."
            sudo tee /etc/dconf/db/local.d/00-extensions > /dev/null <<EOF
[org/gnome/shell]
enabled-extensions=['gsconnect@andyholmes.github.io', 'appindicatorsupport@rgcjonas.gmail.com', 'gamemode@christian.kellner.me', 'caffeine@patapon.info']
EOF
            sudo dconf update
        else
            log_msg "System-wide GNOME extensions configuration already exists."
        fi
    fi
}

desktop_environment() {
gnome
}

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
