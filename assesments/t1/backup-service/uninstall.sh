#!/bin/bash
# Backup Tool Uninstallation Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
SCRIPT_NAME="backup-tool.sh"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/backup-tool"
LOG_DIR="/var/log/backup-tool"
BACKUP_DIR="/var/backup-tool"
CRON_FILE="/etc/cron.d/backup-tool"
LOCK_FILE="/var/run/backup-tool.lock"

echo -e "${RED}================================${NC}"
echo -e "${RED}  Backup Tool Uninstaller${NC}"
echo -e "${RED}================================${NC}"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Run as root${NC}" 
   echo "Usage: sudo $0"
   exit 1
fi

echo -e "${YELLOW}WARNING: This will remove Backup Tool${NC}"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/4] Removing script...${NC}"
if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
    rm -f "$INSTALL_DIR/$SCRIPT_NAME"
    echo -e "${GREEN} Removed $INSTALL_DIR/$SCRIPT_NAME${NC}"
else
    echo -e "${YELLOW}! Script not found${NC}"
fi

echo ""
echo -e "${YELLOW}[2/4] Removing cron job...${NC}"
if [[ -f "$CRON_FILE" ]]; then
    rm -f "$CRON_FILE"
    echo -e "${GREEN} Removed cron job${NC}"
else
    echo -e "${YELLOW}! Cron job not found${NC}"
fi

echo ""
echo -e "${YELLOW}[3/4] Removing lock file...${NC}"
if [[ -f "$LOCK_FILE" ]]; then
    rm -f "$LOCK_FILE"
    echo -e "${GREEN} Removed lock file${NC}"
else
    echo -e "${YELLOW}! Lock file not found${NC}"
fi

echo ""
echo -e "${YELLOW}[4/4] Remove data? (config/logs/backups)${NC}"
echo -e "${RED}WARNING: This deletes:${NC}"
echo "  $CONFIG_DIR"
echo "  $LOG_DIR"
echo "  $BACKUP_DIR"
echo ""
read -p "Delete all data? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    rm -rf "$LOG_DIR"
    rm -rf "$BACKUP_DIR"
    echo -e "${GREEN} All data removed${NC}"
else
    echo -e "${YELLOW}! Data preserved:${NC}"
    echo "  $CONFIG_DIR"
    echo "  $LOG_DIR"
    echo "  $BACKUP_DIR"
    echo ""
    echo "Remove manually: sudo rm -rf $CONFIG_DIR $LOG_DIR $BACKUP_DIR"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Uninstall Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
