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
