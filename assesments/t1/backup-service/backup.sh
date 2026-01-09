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
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}

set_verbosity() {
    local level="$1"
    VERBOSITY_LEVEL="$level"
}

try_to_load_config(){
    # TODO: implement config loading logic
    true
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