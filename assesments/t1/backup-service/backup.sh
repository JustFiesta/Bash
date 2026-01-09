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
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_filename="backup_${timestamp}.tar.gz"
    local temp_backup="/tmp/${backup_filename}"

    log_message "INFO" "Starting backup creation"
    log_message "DEBUG" "Source directory: $SOURCE_DIR"
    log_message "DEBUG" "Temporary backup file: $temp_backup"

    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_message "ERROR" "Source directory does not exist: $SOURCE_DIR"
        return 1
    fi

    if [[ ! -r "$SOURCE_DIR" ]]; then
        log_message "ERROR" "Source directory is not readable: $SOURCE_DIR"
        return 1
    fi

    log_message "INFO" "Creating compressed archive: $backup_filename"

    tar -czf "$temp_backup" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>&1 | while IFS= read -r line; do
        log_message "DEBUG" "tar: $line"
    done

    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        log_message "ERROR" "Failed to create backup archive"
        rm -f "$temp_backup"
        return 1
    fi

    if [[ ! -f "$temp_backup" ]]; then
        log_message "ERROR" "Backup file was not created: $temp_backup"
        return 1
    fi

    local backup_size
    backup_size=$(du -h "$temp_backup" | cut -f1)
    log_message "INFO" "Backup created successfully: $backup_filename (size: $backup_size)"

    echo "$temp_backup"
    return 0
}


move_backup_to_destination(){
    local backup_file="$1"

    if [[ -z "$backup_file" ]]; then
        log_message "ERROR" "No backup file specified for moving"
        return 1
    fi

    if [[ ! -f "$backup_file" ]]; then
        log_message "ERROR" "Backup file does not exist: $backup_file"
        return 1
    fi

    log_message "INFO" "Moving backup to destination: $DEST_DIR"
    log_message "DEBUG" "Source: $backup_file"

    if [[ ! -d "$DEST_DIR" ]]; then
        log_message "INFO" "Destination directory does not exist, creating: $DEST_DIR"
        mkdir -p "$DEST_DIR" || {
            log_message "ERROR" "Failed to create destination directory: $DEST_DIR"
            return 1
        }
    fi

    if [[ ! -w "$DEST_DIR" ]]; then
        log_message "ERROR" "Destination directory is not writable: $DEST_DIR"
        return 1
    fi

    local filename
    filename=$(basename "$backup_file")
    local destination="$DEST_DIR/$filename"

    mv "$backup_file" "$destination" || {
        log_message "ERROR" "Failed to move backup to destination"
        return 1
    }

    log_message "INFO" "Backup moved successfully to: $destination"
    return 0
}


remove_backups_older_than(){
    local retention_days="$1"

    if [[ -z "$retention_days" ]]; then
        log_message "ERROR" "No retention days specified"
        return 1
    fi

    if ! [[ "$retention_days" =~ ^[0-9]+$ ]]; then
        log_message "ERROR" "Invalid retention days value: $retention_days"
        return 1
    fi

    log_message "INFO" "Removing backups older than $retention_days days from: $DEST_DIR"

    if [[ ! -d "$DEST_DIR" ]]; then
        log_message "INFO" "Destination directory does not exist, nothing to remove"
        return 0
    fi

    local removed_count=0
    while IFS= read -r -d '' file; do
        local filename
        filename=$(basename "$file")
        log_message "DEBUG" "Removing old backup: $filename"

        rm -f "$file" || {
            log_message "ERROR" "Failed to remove backup: $filename"
            continue
        }

        ((removed_count++))
        log_message "INFO" "Removed old backup: $filename"
    done < <(find "$DEST_DIR" -name "backup_*.tar.gz" -type f -mtime "+$retention_days" -print0)

    if [[ $removed_count -eq 0 ]]; then
        log_message "INFO" "No old backups found to remove"
    else
        log_message "INFO" "Removed $removed_count old backup(s)"
    fi

    return 0
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
    log_message "INFO" "Loading default configuration"

    SOURCE_DIR="${SOURCE_DIR:-/var/data}"
    DEST_DIR="${DEST_DIR:-/var/backups}"
    RETENTION_DAYS="${RETENTION_DAYS:-7}"
    LOG_FILE="${LOG_FILE:-/var/log/backup.log}"
    EMAIL_TO_ALERT="${EMAIL_TO_ALERT:-}"

    log_message "DEBUG" "Default config: SOURCE_DIR=$SOURCE_DIR, DEST_DIR=$DEST_DIR, RETENTION_DAYS=$RETENTION_DAYS"
    log_message "INFO" "Default configuration loaded"

    return 0
}

send_mail_alert() {
    local subject="$1"
    local body="$2"
    echo "$body" | mail -s "$subject" "$EMAIL_TO_ALERT"
}

lock_instance(){
    local lock_file="/var/lock/backup.lock"

    log_message "DEBUG" "Attempting to acquire lock: $lock_file"

    if [[ -f "$lock_file" ]]; then
        local pid
        pid=$(cat "$lock_file" 2>/dev/null)

        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log_message "ERROR" "Another instance is already running (PID: $pid)"
            return 1
        else
            log_message "INFO" "Stale lock file found, removing"
            rm -f "$lock_file"
        fi
    fi

    echo $$ > "$lock_file" || {
        log_message "ERROR" "Failed to create lock file: $lock_file"
        return 1
    }

    log_message "INFO" "Lock acquired (PID: $$)"
    return 0
}

unlock_instance(){
    local lock_file="/var/lock/backup.lock"

    log_message "DEBUG" "Releasing lock: $lock_file"

    if [[ -f "$lock_file" ]]; then
        rm -f "$lock_file"
        log_message "INFO" "Lock released"
    fi

    return 0
}

kill_instance(){
    log_message "INFO" "Backup process terminated"
    unlock_instance
    exit "${1:-1}"
}

# runtime
main(){
    # TODO: implement main function with getopts parsing
    true
}

main "$@"