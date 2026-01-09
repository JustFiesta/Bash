#!/usr/share/env bash
# -------------------
# Tool used to create and manage compressed archives of given directory, can be configured as service
# -------------------
# Features:
# - Stores archives in a specified backup location with timestamped filenames
# - Removes archives older than a specified number of days
# - Logs of operations to a log file with timestamps, levels and verbosity 
# - Configured via config file (source, destination, retention days, log file)
# - Alerts to email on completion/errors during backup process
# - Only one instance runs at a time (using lock file)

# vars
CONFIG_FILE="/etc/backup.conf"
LOG_FILE=""
SOURCE_DIR=""
DEST_DIR=""
RETENTION_DAYS=""
EMAIL_TO_ALERT=""

VERBOSITY_LEVEL=1  # 0 = errors only, 1 = info, 2 = debug

# functions
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Backup service - creates compressed archives and manages retention.

OPTIONS:
    -c CONFIG_FILE    Path to configuration file (default: /etc/backup.conf)
    -v LEVEL          Verbosity level: 0=errors only, 1=info, 2=debug (default: 1)
    -h                Show this help message

EXAMPLE:
    $0 -c /path/to/backup.conf -v 2

CONFIG FILE FORMAT:
    SOURCE_DIR=/path/to/source
    DEST_DIR=/path/to/destination
    RETENTION_DAYS=7
    LOG_FILE=/var/log/backup.log
    EMAIL_TO_ALERT=admin@example.com

EOF
    exit 0
}

create_backup(){
    # TODO: implement backup creation logic
    true
}

move_backup_to_destination(){
    # TODO: implement backup moving logic
    true
}

remove_backups_older_than(){
    # TODO: implement old backup removal logic
    true
}

log_message() {
    local level="$1"
    local message="$2"
    local log_line="$(date '+%Y-%m-%d %H:%M:%S') [$level] $message"

    # Map log levels to verbosity requirements
    # ERROR: always logged (verbosity >= 0)
    # INFO: logged when verbosity >= 1
    # DEBUG: logged when verbosity >= 2
    local required_verbosity=0
    case "$level" in
        ERROR) required_verbosity=0 ;;
        INFO)  required_verbosity=1 ;;
        DEBUG) required_verbosity=2 ;;
        *) required_verbosity=1 ;;
    esac

    # Only log if current verbosity level is sufficient
    if [[ $VERBOSITY_LEVEL -ge $required_verbosity ]]; then
        # Check if LOG_FILE is set, otherwise log to stderr
        if [[ -n "$LOG_FILE" ]]; then
            echo "$log_line" >> "$LOG_FILE"
        else
            echo "$log_line" >&2
        fi
    fi
}

set_verbosity() {
    local level="$1"
    VERBOSITY_LEVEL="$level"
}

try_to_load_config(){
    local config_file="$1"

    log_message "DEBUG" "Attempting to load config file: $config_file"

    if [[ ! -f "$config_file" ]]; then
        log_message "ERROR" "Config file not found: $config_file"
        return 1
    fi

    if [[ ! -r "$config_file" ]]; then
        log_message "ERROR" "Config file not readable: $config_file"
        return 1
    fi

    # Load config file safely
    # shellcheck disable=SC1090
    source "$config_file" || {
        log_message "ERROR" "Failed to source config file: $config_file"
        return 1
    }

    log_message "DEBUG" "Config file sourced successfully"

    # Validate required variables
    local required_vars=("SOURCE_DIR" "DEST_DIR" "RETENTION_DAYS" "LOG_FILE")
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_message "ERROR" "Missing required variables in config: ${missing_vars[*]}"
        return 1
    fi

    log_message "INFO" "Config loaded successfully from: $config_file"
    log_message "DEBUG" "SOURCE_DIR=$SOURCE_DIR, DEST_DIR=$DEST_DIR, RETENTION_DAYS=$RETENTION_DAYS"

    return 0
}

load_default_config(){
    # TODO: implement default config loading logic
    true
}

send_mail_alert() {
    local subject="$1"
    local body="$2"
    echo "$body" | mail -s "$subject" "$EMAIL_TO_ALERT"
}

lock_instance(){
    # TODO: implement instance locking logic
    true
}

unlock_instance(){
    # TODO: implement instance unlocking logic
    true
}

kill_instance(){
    # TODO: implement instance exiting script/killing logic
    true
}

# runtime
main(){
    # TODO: implement main function with getopts parsing
    true
}

main "$@"