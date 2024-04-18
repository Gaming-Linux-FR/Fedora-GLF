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
