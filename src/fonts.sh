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
