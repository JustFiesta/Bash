# Backup Tool

Automated backup service that creates compressed tar.gz archives with automatic retention management.

## What it does

When executed, the script:

1. Creates a compressed tar.gz archive of SOURCE_DIR
2. Stores it in DEST_DIR with timestamp (backup_YYYYMMDD_HHMMSS.tar.gz)
3. Removes archives older than RETENTION_DAYS
4. Logs all operations to LOG_FILE
5. Sends email notifications on success/failure (optional)

## Requirements

- Bash 4.0+
- tar, date, find, basename, dirname, du, mkdir, mv, rm
- mail command (optional, for email notifications)

## Installation

```bash
sudo ./install.sh
```

This will:

- Install script to /usr/local/bin/backup-tool.sh
- Create configuration in /etc/backup-tool/backup.conf
- Create directories: /var/backup-tool/archives, /var/log/backup-tool
- Install cron job for daily execution at midnight

## Configuration

Edit /etc/backup-tool/backup.conf:

```bash
SOURCE_DIR=/var/www/html              # Directory to backup
DEST_DIR=/var/backup-tool/archives    # Where to store archives
RETENTION_DAYS=7                      # Days to keep old backups
LOG_FILE=/var/log/backup-tool/backup.log
EMAIL_TO_ALERT=admin@example.com      # Optional email
LOCK_FILE=/var/run/backup-tool.lock
```

## Usage

Run backup manually:

```bash
sudo backup-tool.sh
```

With custom config:

```bash
sudo backup-tool.sh -c /path/to/config
```

With debug logging:

```bash
sudo backup-tool.sh -v 2
```

Show help:

```bash
backup-tool.sh -h
```

## Automatic Execution

The installer sets up a cron job at /etc/cron.d/backup-tool that runs daily at midnight.

To change schedule, edit the cron file:

```bash
sudo nano /etc/cron.d/backup-tool
```

## SystemD Service (Optional)

You can also run the backup via systemd:

```bash
# Copy service file
sudo cp backup-tool.service /etc/systemd/system/
sudo systemctl daemon-reload

# Run manually
sudo systemctl start backup-tool.service

# Check status
sudo systemctl status backup-tool.service

# View logs
sudo journalctl -u backup-tool.service
```

## Logging

The script logs to the file specified in LOG_FILE with three verbosity levels:

- Level 0: Errors only
- Level 1: Info + Errors (default)
- Level 2: Debug + Info + Errors

View logs:

```bash
sudo tail -f /var/log/backup-tool/backup.log
```

View cron logs:

```bash
sudo tail -f /var/log/backup-tool/cron.log
```

## Email Notifications

To enable email notifications:

1. Install mailutils:

    ```bash
    sudo apt install mailutils
    ```

2. Set EMAIL_TO_ALERT in /etc/backup-tool/backup.conf

3. Configure your mail server (postfix, etc.)

The script sends emails on:

- Backup success
- Backup failure

## Security Features

- Single instance locking (prevents concurrent runs)
- PID-based lock file with stale lock detection
- Config file validation
- Dependency checking before execution

## Directory Structure

```
/usr/local/bin/backup-tool.sh           - Main script
/etc/backup-tool/backup.conf            - Configuration
/var/backup-tool/archives/              - Backup archives
  └── backup_20260109_123456.tar.gz
/var/log/backup-tool/backup.log         - Script logs
/var/log/backup-tool/cron.log           - Cron execution logs
/var/run/backup-tool.lock               - Lock file (temporary)
/etc/cron.d/backup-tool                 - Cron job
```

## Uninstallation

```bash
sudo ./uninstall.sh
```

This will remove the script, cron job, and optionally configuration/logs/backups.
