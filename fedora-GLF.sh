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
# CONTRUBUTORS: Chevek
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

set -e  # wont works with dnf check-update --refresh ? exit code is 100 if there is updates.
export VERBOSE=false
# Colors and text formating
BG_BLUE="$(tput setab 4)"
BG_BLACK="$(tput setab 0)"
BG_GREEN="$(tput setab 2)"
FG_GREEN="$(tput setaf 2)"
FG_WHITE="$(tput setaf 7)"

TEXT_BOLD="$(tput bold)"
TEXT_DIM="$(tput dim)"
TEXT_REV="$(tput rev)"
TEXT_DEFAULT="$(tput sgr0)"

export RESET=$(tput sgr0)
export RED=$(tput setaf 1)
export GREEN=$(tput setaf 2)
export YELLOW=$(tput setaf 3)
export BLUE=$(tput setaf 4)
export PURPLE=$(tput setaf 5)

export LOG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/logfile_Fedora_GLF_$(date "+%Y%m%d-%H%M%S").log"

# log functions from https://github.com/Gaming-Linux-FR/Architect/blob/main/src/cmd.sh
function init_log() {
    touch "$LOG_FILE"
    echo -e "Commit hash: $(git rev-parse HEAD)" >>"$LOG_FILE"
    echo -e "Log file: ${LOG_FILE}\n" >>"$LOG_FILE"
}

function log() {
    local -r comment="$1"
    echo "[$(date "+%Y-%m-%d %H:%M:%S") TXT] $comment" >>"$LOG_FILE"
}

function log_msg() {
    local -r comment="$1"
    echo "$comment"
    log "$comment"
}

function exec_command() {
    local -r command="$1"
		echo "[$(date "+%Y-%m-%d %H:%M:%S") EXE] $command" >>"$LOG_FILE"
    if [[ $VERBOSE == true ]]; then
        eval "$command" 2>&1 | tee -a "$LOG_FILE"
    else
        eval "$command" >>"$LOG_FILE" 2>&1
    fi
}

function exec_log() {
    local -r comment="$1"
		local -r command="$2"
    log_msg "$comment"
    exec_command "$command"
}

################### SCRIPT START HERE!
init_log
# We need an up to date system !
# Enforcement :
log_msg "Vérification de la fraicheur du système :"
dnf check-update --refresh && RC=$? || RC=$? # see line "set -e" of this script... We deal with it right here:
if [ "$RC" -eq 0 ]; then
	log_msg  "Le système est à jour."
else
	echo ""	
	log_msg  "${RED}${TEXT_BOLD}[X]${RESET} Ce script a besoin d'un système à jour. Veuillez faire la mise à jour avec un reboot. Puis relancez le script."
	exit
fi

read -n 1 -s -r -p "Appuyez sur une touche pour continuer."

#===================================================================================
# DNF configuration
# Source : https://linuxtricks.fr/wiki/fedora-script-post-installation
#===================================================================================
log_msg  "*************************"
log_msg  "* Gestion des paquets"
log_msg  "*************************"
# Paramétrage DNF
log_msg  "Optimisation de DNF :"
if ! grep -Fq "fastestmirror=" /etc/dnf/dnf.conf; then
	exec_command "echo 'fastestmirror=true' | sudo tee -a /etc/dnf/dnf.conf"
fi
if ! grep -Fq "max_parallel_downloads=" /etc/dnf/dnf.conf; then
	exec_command "echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf"
fi
# We need more accurate statistics!
if ! grep -Fq "countme=" /etc/dnf/dnf.conf; then
	exec_command "echo 'countme=true' | sudo tee -a /etc/dnf/dnf.conf"
fi

#===================================================================================
# Flathub configuration
#===================================================================================
if [[ ! $(flatpak remotes --columns=name) =~ "flathub" ]]; then
	exec_log "Ajout du dépôt Flathub :" \
	"flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
fi

#===================================================================================
# Firmwares configuration
#===================================================================================
log_msg  "Mise à jour des firmwares :"
# MàJ Firmware si supporté
exec_command "sudo fwupdmgr get-devices" 
exec_command "sudo fwupdmgr refresh --force" 
#FIXME!
sudo fwupdmgr get-updates || RC=$?
#FIXME!
sudo fwupdmgr update || RC=$?

#===================================================================================
# RPM Fusion configuration
# Source : https://rpmfusion.org/Configuration
#===================================================================================
# To enable access to both the free and the nonfree repository from rpmfusion
exec_command "sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# On Fedora, we default to use the openh264 library, so you need the repository to be explicitely enabled:
exec_command "sudo dnf config-manager -y --enable fedora-cisco-openh264"

# RPM Fusion repositories also provide Appstream metadata to enable users to install packages using Gnome Software/KDE Discover. Please note that these are a subset of all packages since the metadata are only generated for GUI packages.
exec_command "sudo dnf groupupdate -y core"

#===================================================================================
# NVIDIA GPU configuration
# Source : https://rpmfusion.org/Howto/NVIDIA
#===================================================================================
GPU_TYPE=$(lspci | grep -E "VGA|3D" | cut -d ":" -f3)
if [[ $GPU_TYPE =~ "NVIDIA" ]]; then
	log_msg  "*************************"
	log_msg  "* Carte graphique NVIDIA"
	log_msg  "*************************"
	log_msg  "Configuration pour les cartes graphiques NVIDIA récentes (2014+) :"
	exec_command "sudo dnf install -y akmod-nvidia" # rhel/centos users can use kmod-nvidia instead
	exec_command "sudo dnf install -y xorg-x11-drv-nvidia-cuda" #optional for cuda/nvdec/nvenc support
#FIXME:	exec_log "Version du pilote NVIDIA installé :" \
	"modinfo -F version nvidia"
	exec_log "Installe Vulkan :" \
	"sudo dnf install -y vulkan"
	
	exec_log "Support de ffmpeg avec NVENC/NVDEC (CUDA) :" \
	"sudo dnf install -y xorg-x11-drv-nvidia-cuda-libs"
	
	exec_log "VDPAU/VAAPI support :" \
	"sudo dnf install -y nvidia-vaapi-driver libva-utils vdpauinfo"
	# sudo dracut --regenerate-all --force
	# sudo depmod -a
	
fi

#===================================================================================
# Multimedia configuration
# Source : https://rpmfusion.org/Howto/Multimedia
#===================================================================================
log_msg  "*************************"
log_msg  "* MULTIMÉDIA"
log_msg  "*************************"

# Switch to full ffmpeg
exec_log "ffmpeg complet :" \
"sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing"
# This will allows the application using the gstreamer framework and other multimedia software, to play others restricted codecs:
# multimedia packages needed by gstreamer enabled applications:
exec_log "Codecs multimdédia pour gstreamer :" \
"sudo dnf groupupdate -y multimedia --setopt='install_weak_deps=False' --exclude=PackageKit-gstreamer-plugin"
# sound-and-video complement packages needed by some applications:
exec_log "Codecs multimédias pour applications" \
"sudo dnf groupupdate -y sound-and-video"

# Hardware Accelerated Codec
log_msg  "Accélération matérielle par le GPU :"
#if [[ $GPU_TYPE =~ "NVIDIA" ]]; then           # if nvidia GPU
	# Déjà fait à l'étape NVIDIA...
	#sudo dnf install nvidia-vaapi-driver
if [[ $GPU_TYPE =~ "AMD" ]]; then            # if AMD GPU
	log_msg  "Carte graphique AMD détectée :"
	log_msg  "Codecs pour Mesa3D :"
	exec_command "sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld"
	exec_command "sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld"
	# i686 compat for Steam
	exec_command "sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686"
	exec_command "sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686"
	# RocM
	exec_log "Installation de ROCm pour le calcul accéléré :" \
	"sudo dnf -y install rocm-opencl rocminfo rocm-clinfo rocm-hip rocm-runtime rocm-smi"
fi
if [[ $GPU_TYPE =~ "INTEL" ]]; then          # If Intel GPU (recent)
	log_msg  "Carte graphique INTEL détectée :"
	exec_log "Codecs pour Mesa3D :" \
	"sudo dnf install -y intel-media-driver"
#elif [[ $GPU_TYPE =~ "VMware" || $GPU_TYPE =~ "QXL" ]]; then          # If virtualisation
fi

# Various firmware. Tainted nonfree is dedicated to non-FLOSS packages without a clear redistribution status by the copyright holder. But is allowed as part of hardware inter-operability between operating systems in some countries :
log_msg  "Firmwares divers (b43, broadcom-bt, dvb, nouveau) :"
exec_command "sudo dnf install -y rpmfusion-nonfree-release-tainted"
exec_command "sudo dnf --repo=rpmfusion-nonfree-tainted install -y '*-firmware'"

#===================================================================================
# Fonts Microsoft
# Source : https://www.linuxcapable.com/install-microsoft-fonts-on-fedora-linux/
#===================================================================================
log_msg  "*************************"
log_msg  "* Compatibilité bureautique"
log_msg  "*************************"
log_msg  "Installation des fonts Microsoft :"
exec_command "sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig"
#FIXME!
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm || RC=$?

#===================================================================================
# Desktop Tools
#===================================================================================
log_msg  "*************************"
log_msg  "* Installation des bases du bureau :"
log_msg  "*************************"
exec_log "GameMode :" \
"sudo dnf install -y gamemode"
# Is GNOME running?
if [[ $(pgrep -c gnome-shell) -gt 0 ]];then
	exec_log "GNOME Tweaks, la gestion des extension de GNOME Shell, du systray, du GameMode et du téléphone portable :" \
	"sudo dnf install -y gnome-tweaks gnome-extensions-app gnome-shell-extension-appindicator gnome-shell-extension-caffeine gnome-shell-extension-gamemode gnome-shell-extension-gsconnect"
	# enable extensions system wide
	if [[ ! -f /etc/dconf/db/local.d/00-extensions ]]; then
		exec_command "cat <<EOF | sudo tee /etc/dconf/db/local.d/00-extensions
[org/gnome/shell]
# List all extensions that you want to have enabled for all users
enabled-extensions=['gsconnect@andyholmes.github.io', 'appindicatorsupport@rgcjonas.gmail.com','gamemode@christian.kellner.me','caffeine@patapon.info']
EOF"
		exec_command "sudo dconf update"
	else
		log_msg "File /etc/dconf/db/local.d/00-extensions already exists!"
	fi
	# enable extensions for the current user
	exec_command "gnome-extensions enable gsconnect@andyholmes.github.io"
	exec_command "gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com"
	exec_command "gnome-extensions enable gamemode@christian.kellner.me"
	exec_command "gnome-extensions enable caffeine@patapon.info"
fi

exec_log "Gestion des droits des flatpaks (Flatseal) :" \
"sudo dnf install -y flatseal"
# Check if the system is using btrfs for the root partition
lsblk -f |
while IFS= read -r line; do
	if [[ "$line" == */ && "$line" =~ "btrfs" ]]; then #root filesystem && it's using btrfs?
		exec_log "btrfs-assistant :" \
		"sudo dnf install -y btrfs-assistant"
	fi
done

exec_log "Outils de compression (7zip, rar, ace, lha) :" \
"sudo dnf install -y p7zip p7zip-plugins unrar unace lha"

exec_log "Fonts (Google Roboto, Mozilla Fira, dejavu, liberation, Google Noto Emoji-sans-serif, Adobe Source, Awesome, Google Droid) :" \
"sudo dnf install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts dejavu-fonts-all liberation-fonts google-noto-emoji-fonts google-noto-color-emoji-fonts google-noto-sans-fonts google-noto-serif-fonts 'adobe-source-code*' adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts fontawesome-fonts-all google-droid-fonts-all"

exec_log "OpenRGB :" \
"sudo dnf install -y openrgb"

exec_log "Fastfetch :" \
"sudo dnf install -y fastfetch"

exec_log "Bloqueur de pub/malwares pour Firefox (uBlock Origin) :" \
"sudo dnf install -y mozilla-ublock-origin"

log_msg  "${GREEN}${TEXT_BOLD}[X]${RESET} Ce script est terminé. Veuillez rebooter."
