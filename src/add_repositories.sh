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
