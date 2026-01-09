#!/usr/bin/env bash
# -----------------
# Backup Tool Uninstallation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_NAME="backup-tool.sh"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/backup-tool"
LOG_DIR="/var/log/backup-tool"
BACKUP_DIR="/var/backup-tool"
SYSTEMD_DIR="/etc/systemd/system"
CRON_FILE="/etc/cron.d/backup-tool"

echo -e "${RED}========================================${NC}"
echo -e "${RED}  Backup Tool Uninstallation Script${NC}"
echo -e "${RED}========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 
   echo "Please run: sudo $0"
   exit 1
fi

echo -e "${YELLOW}WARNING: This will remove the Backup Tool from your system.${NC}"
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/6] Stopping and disabling SystemD services...${NC}"
if systemctl is-active --quiet backup-tool.timer; then
    systemctl stop backup-tool.timer
    echo -e "${GREEN}✓ Timer stopped${NC}"
fi

if systemctl is-enabled --quiet backup-tool.timer 2>/dev/null; then
    systemctl disable backup-tool.timer
    echo -e "${GREEN}✓ Timer disabled${NC}"
fi

if systemctl is-active --quiet backup-tool.service; then
    systemctl stop backup-tool.service
    echo -e "${GREEN}✓ Service stopped${NC}"
fi

echo ""
echo -e "${YELLOW}[2/6] Removing SystemD files...${NC}"
rm -f "$SYSTEMD_DIR/backup-tool.service"
rm -f "$SYSTEMD_DIR/backup-tool.timer"
systemctl daemon-reload
echo -e "${GREEN}✓ SystemD files removed${NC}"

echo ""
echo -e "${YELLOW}[3/6] Removing main script...${NC}"
rm -f "$INSTALL_DIR/$SCRIPT_NAME"
echo -e "${GREEN}✓ Script removed from $INSTALL_DIR${NC}"

echo ""
echo -e "${YELLOW}[4/6] Removing cron job (if exists)...${NC}"
if [[ -f "$CRON_FILE" ]]; then
    rm -f "$CRON_FILE"
    echo -e "${GREEN}✓ Cron job removed${NC}"
else
    echo -e "${YELLOW}⚠ No cron job found${NC}"
fi

echo ""
echo -e "${YELLOW}[5/6] Removing lock file (if exists)...${NC}"
rm -f /var/run/backup-tool.lock
echo -e "${GREEN}✓ Lock file removed${NC}"

echo ""
echo -e "${YELLOW}[6/6] Do you want to remove configuration, logs, and backups?${NC}"
echo -e "${RED}WARNING: This will permanently delete:${NC}"
echo "  - Configuration: $CONFIG_DIR"
echo "  - Logs: $LOG_DIR"
echo "  - Backups: $BACKUP_DIR"
echo ""
read -p "Remove all data? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    rm -rf "$LOG_DIR"
    rm -rf "$BACKUP_DIR"
    echo -e "${GREEN}✓ All data removed${NC}"
else
    echo -e "${YELLOW}⚠ Data preserved:${NC}"
    echo "  - Configuration: $CONFIG_DIR"
    echo "  - Logs: $LOG_DIR"
    echo "  - Backups: $BACKUP_DIR"
    echo ""
    echo "  You can manually remove them later with:"
    echo "  sudo rm -rf $CONFIG_DIR $LOG_DIR $BACKUP_DIR"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Uninstallation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
