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
