# Install compression tools
compression_tools() {
    log_msg "Installing compression tools (7zip, rar, ace, lha):"
    exec_command "sudo dnf install -y p7zip p7zip-plugins unrar unace lha"
}


#===================================================================================
# Desktop Tools
#===================================================================================
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
