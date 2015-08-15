#!/bin/bash
set -e

WOWZA_INSTALLER_URL="http://www.wowza.com/downloads/WowzaStreamingEngine-4-1-2/WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin"

# download wowza installer
wget "${WOWZA_INSTALLER_URL}" -O WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin

# disable user interaction during install
sed 's/^more <<"EOF"$/cat <<"EOF"/'                               -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
sed 's/^agreed=$/agreed=1/'                                       -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
sed 's/^ADMINUSER=$/ADMINUSER=admin/'                             -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
sed 's/\$ADMINUSER  \$ADMINPASS1 admin/\$ADMINUSER  admin admin/' -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
sed 's/^PWMATCH=$/PWMATCH=1/'                                     -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
sed 's/^VALIDLICKEY=$/VALIDLICKEY=1/'                             -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
sed 's/STARTSERVICES=$/STARTSERVICES=0/'                          -i WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin

# install wowza streaming engine
chmod +x WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin
./WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin

# remove installer
rm -rf WowzaStreamingEngine-${WOWZA_VERSION}.deb.bin WowzaStreamingEngine-${WOWZA_VERSION}.deb

# move supervisord.log file to ${WOWZA_LOG_DIR}/supervisor/
sed 's|^logfile=.*|logfile='"${WOWZA_LOG_DIR}"'/supervisor/supervisord.log ;|' -i /etc/supervisor/supervisord.conf

# symlink /usr/local/WowzaStreamingEngine/logs -> ${WOWZA_LOG_DIR}/wowza
rm -rf /usr/local/WowzaStreamingEngine/logs
ln -sf ${WOWZA_LOG_DIR}/wowza /usr/local/WowzaStreamingEngine/logs

# symlink /usr/local/WowzaStreamingEngine/manager/logs -> ${WOWZA_LOG_DIR}/manager
rm -rf /usr/local/WowzaStreamingEngine/manager/logs
ln -sf ${WOWZA_LOG_DIR}/manager /usr/local/WowzaStreamingEngine/manager/logs

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

# configure supervisord to start crond
cat > /etc/supervisor/conf.d/cron.conf <<EOF
[program:cron]
priority=30
directory=/tmp
command=/usr/sbin/cron -f
user=root
autostart=true
autorestart=true
stdout_logfile=${WOWZA_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${WOWZA_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord log rotation
cat > /etc/logrotate.d/supervisord <<EOF
${WOWZA_LOG_DIR}/supervisor/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF

# configure wowza log rotation
cat > /etc/logrotate.d/wowza <<EOF
${WOWZA_LOG_DIR}/wowza/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF

# configure manager log rotation
cat > /etc/logrotate.d/wowza <<EOF
${WOWZA_LOG_DIR}/manager/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF
