#!/usr/bin/env bash
# -------------------
# Backup Tool Installation Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
SCRIPT_NAME="backup-tool.sh"
SERVICE_NAME="backup-tool.service"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/backup-tool"
LOG_DIR="/var/log/backup-tool"
BACKUP_DIR="/var/backup-tool/archives"
CRON_FILE="/etc/cron.d/backup-tool"
SERVICE_FILE="/etc/systemd/system/backup-tool.service"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Backup Tool Installer${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: Run as root${NC}" 
   echo "Usage: sudo $0"
   exit 1
fi

# Check if required files exist
if [[ ! -f "backup.sh" ]]; then
    echo -e "${RED}Error: backup.sh not found${NC}"
    exit 1
fi

if [[ ! -f "$SERVICE_NAME" ]]; then
    echo -e "${RED}Error: $SERVICE_NAME not found${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/6] Installing script...${NC}"
cp backup.sh "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo -e "${GREEN} Installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"

echo ""
echo -e "${YELLOW}[2/6] Creating directories...${NC}"
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN} Created:${NC}"
echo "  $CONFIG_DIR"
echo "  $LOG_DIR"
echo "  $BACKUP_DIR"

echo ""
echo -e "${YELLOW}[3/6] Creating configuration file...${NC}"
if [[ -f "$CONFIG_DIR/backup.conf" ]]; then
    echo -e "${YELLOW}! Config exists, backing up...${NC}"
    cp "$CONFIG_DIR/backup.conf" "$CONFIG_DIR/backup.conf.bak.$(date +%Y%m%d_%H%M%S)"
fi

cat > "$CONFIG_DIR/backup.conf" << EOF
# Backup Tool Configuration

# Source directory to backup (CHANGE THIS!)
SOURCE_DIR=/var/www/html

# Destination for backups
DEST_DIR=/var/backup-tool/archives

# Retention period in days
RETENTION_DAYS=7

# Log file path
LOG_FILE=/var/log/backup-tool/backup.log

# Email for notifications (leave empty to disable)
EMAIL_TO_ALERT=""

# Lock file path
LOCK_FILE="/var/run/backup-tool.lock"
EOF

echo -e "${GREEN} Config created: $CONFIG_DIR/backup.conf${NC}"

echo ""
echo -e "${YELLOW}[4/6] Installing systemd service...${NC}"
cp "$SERVICE_NAME" "$SERVICE_FILE"
chmod 644 "$SERVICE_FILE"
systemctl daemon-reload
echo -e "${GREEN} Service installed ${NC}"

echo ""
echo -e "${YELLOW}[5/6] Setting up cron job...${NC}"
cat > "$CRON_FILE" << 'CRON'
# Backup Tool - Daily at midnight
0 0 * * * root systemctl start backup-tool.service
CRON

chmod 644 "$CRON_FILE"
echo -e "${GREEN} Cron job installed (daily at 00:00)${NC}"

echo ""
echo -e "${YELLOW}[6/6] Checking dependencies...${NC}"
missing=()
for cmd in tar date find basename dirname du mkdir mv rm; do
    if ! command -v "$cmd" &>/dev/null; then
        missing+=("$cmd")
    fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${RED}✗ Missing: ${missing[*]}${NC}"
    exit 1
fi

if ! command -v mail &>/dev/null; then
    echo -e "${YELLOW}! 'mail' not found (email disabled)${NC}"
    echo "  Install: apt install mailutils"
else
    echo -e "${GREEN} All dependencies OK${NC}"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}! IMPORTANT: Edit config file!${NC}"
echo "  sudo nano $CONFIG_DIR/backup.conf"
echo ""
echo -e "${GREEN}Usage:${NC}"
echo "  Test backup:  sudo $INSTALL_DIR/$SCRIPT_NAME"
echo "  View logs:    sudo tail -f $LOG_DIR/backup.log"
echo "  Edit config:  sudo nano $CONFIG_DIR/backup.conf"
echo "  Edit cron:    sudo nano $CRON_FILE"
echo ""
