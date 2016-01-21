#!/bin/bash
set -e

WOWZA_INSTALLER_URL="https://www.wowza.com/downloads/WowzaStreamingEngine-${WOWZA_VERSION//./-}/WowzaStreamingEngine-${WOWZA_VERSION}-linux-x64-installer.run"
WOWZA_INSTALLER_FILE="WowzaStreamingEngine.run"

cd /app

# download wowza installer
wget "${WOWZA_INSTALLER_URL}" -O "${WOWZA_INSTALLER_FILE}"
chmod +x "${WOWZA_INSTALLER_FILE}"

# move supervisord.log file to ${WOWZA_LOG_DIR}/supervisor/
sed 's|^logfile=.*|logfile='"${WOWZA_LOG_DIR}"'/supervisor/supervisord.log ;|' -i /etc/supervisor/supervisord.conf

# configure supervisord to start wowza streaming engine
cat > /etc/supervisor/conf.d/wowza.conf <<EOF
[program:wowza]
priority=10
directory=/usr/local/WowzaStreamingEngine/bin
command=/usr/local/WowzaStreamingEngine/bin/startup.sh
user=root
autostart=true
autorestart=true
stdout_logfile=${WOWZA_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${WOWZA_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord to start wowza streaming engine manager
cat > /etc/supervisor/conf.d/wowzamgr.conf <<EOF
[program:wowzamgr]
priority=20
directory=/usr/local/WowzaStreamingEngine/manager/bin
command=/usr/local/WowzaStreamingEngine/manager/bin/startmgr.sh
user=root
autostart=true
autorestart=true
stdout_logfile=${WOWZA_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${WOWZA_LOG_DIR}/supervisor/%(program_name)s.log
EOF
