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
