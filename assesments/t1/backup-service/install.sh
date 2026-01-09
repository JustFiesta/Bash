#!/usr/bin/env bash
# -----------------
# Backup Tool Installation Script

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
BACKUP_DIR="/var/backup-tool/archives"
SYSTEMD_DIR="/etc/systemd/system"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Backup Tool Installation Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 
   echo "Please run: sudo $0"
   exit 1
fi

echo -e "${YELLOW}[1/8] Checking dependencies...${NC}"
missing_deps=()
required_commands=("tar" "date" "find" "basename" "dirname" "du" "mkdir" "mv" "rm" "systemctl")

for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        missing_deps+=("$cmd")
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo -e "${RED}Error: Missing required commands: ${missing_deps[*]}${NC}"
    exit 1
fi
echo -e "${GREEN}✓ All dependencies satisfied${NC}"

echo ""
echo -e "${YELLOW}[2/8] Installing main script...${NC}"
if [[ ! -f "backup.sh" ]]; then
    echo -e "${RED}Error: backup.sh not found in current directory${NC}"
    exit 1
fi

cp backup.sh "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo -e "${GREEN}✓ Script installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"

echo ""
echo -e "${YELLOW}[3/8] Creating directories...${NC}"
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✓ Directories created:${NC}"
echo "  - $CONFIG_DIR"
echo "  - $LOG_DIR"
echo "  - $BACKUP_DIR"

echo ""
echo -e "${YELLOW}[4/8] Installing configuration file...${NC}"
if [[ -f "$CONFIG_DIR/backup.conf" ]]; then
    echo -e "${YELLOW}⚠ Configuration file already exists at $CONFIG_DIR/backup.conf${NC}"
    read -p "Do you want to backup the existing config? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$CONFIG_DIR/backup.conf" "$CONFIG_DIR/backup.conf.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✓ Existing config backed up${NC}"
    fi
else
    if [[ -f "backup.conf.example" ]]; then
        cp backup.conf.example "$CONFIG_DIR/backup.conf"
        echo -e "${GREEN}✓ Configuration file installed to $CONFIG_DIR/backup.conf${NC}"
    else
        echo -e "${YELLOW}⚠ backup.conf.example not found, creating minimal config${NC}"
        cat > "$CONFIG_DIR/backup.conf" << 'CONFEOF'
SOURCE_DIR=/var/www/html
DEST_DIR=/var/backup-tool/archives
RETENTION_DAYS=7
LOG_FILE=/var/log/backup-tool/backup.log
EMAIL_TO_ALERT=
LOCK_FILE=/var/run/backup-tool.lock
CONFEOF
        echo -e "${GREEN}✓ Minimal configuration file created${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}[5/8] Would you like to edit the configuration now? (y/n)${NC}"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ${EDITOR:-nano} "$CONFIG_DIR/backup.conf"
fi

echo ""
echo -e "${YELLOW}[6/8] Installing SystemD service and timer...${NC}"
if [[ -f "backup-tool.service" ]] && [[ -f "backup-tool.timer" ]]; then
    cp backup-tool.service "$SYSTEMD_DIR/"
    cp backup-tool.timer "$SYSTEMD_DIR/"
    systemctl daemon-reload
    echo -e "${GREEN}✓ SystemD service and timer installed${NC}"
else
    echo -e "${RED}Error: SystemD files not found${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[7/8] Do you want to enable automatic backups? (y/n)${NC}"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl enable backup-tool.timer
    systemctl start backup-tool.timer
    echo -e "${GREEN}✓ Automatic backups enabled (daily at midnight)${NC}"
else
    echo -e "${YELLOW}⚠ Automatic backups not enabled${NC}"
    echo "  You can enable them later with: systemctl enable backup-tool.timer"
fi

echo ""
echo -e "${YELLOW}[8/8] Checking mail utility for notifications...${NC}"
if command -v mail &>/dev/null; then
    echo -e "${GREEN}✓ Mail utility is installed${NC}"
else
    echo -e "${YELLOW}⚠ Mail utility not found${NC}"
    echo "  Email notifications will not work until you install mailutils:"
    echo "  sudo apt install mailutils"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Edit configuration: sudo nano $CONFIG_DIR/backup.conf"
echo "2. Test backup manually: sudo $INSTALL_DIR/$SCRIPT_NAME"
echo "3. Check timer status: systemctl status backup-tool.timer"
echo "4. View logs: sudo tail -f $LOG_DIR/backup.log"
echo ""
echo -e "${GREEN}Useful commands:${NC}"
echo "  Start backup now:     sudo systemctl start backup-tool.service"
echo "  Check timer:          systemctl list-timers backup-tool.timer"
echo "  View service logs:    sudo journalctl -u backup-tool.service"
echo "  Disable auto backup:  sudo systemctl disable backup-tool.timer"
echo ""
echo -e "${YELLOW}⚠ Important:${NC} Remember to configure SOURCE_DIR in $CONFIG_DIR/backup.conf"
echo ""
