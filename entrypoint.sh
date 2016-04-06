#!/bin/bash
set -e

WOWZA_KEY=${WOWZA_KEY:-}

check_and_install_wowza() {
  echo "Checking if Wowza Streaming Engine is installed..."
  if [[ -e /usr/local/WowzaStreamingEngine ]]; then
    echo "Installation found"
    return
  fi

  echo "No installation found"
  echo "Installing Wowza..."

  if [[ ${WOWZA_ACCEPT_LICENSE} != yes ]]; then
    echo "ERROR: "
    echo "  Please accept the Wowza EULA by specifying 'WOWZA_ACCEPT_LICENSE=yes'"
    echo "  Visit https://www.wowza.com/legal to read the Licensing Terms."
    echo "  Aborting..."
    exit 1
  fi

  if [[ -z ${WOWZA_KEY} && ! -f /usr/local/WowzaStreamingEngine/conf/Server.license ]]; then
    echo "ERROR: "
    echo "  Please specify your Wowza Streaming Engine license key using"
    echo "  the WOWZA_KEY environment variable."
    echo "  Cannot continue without a license. Aborting..."
    exit 1
  fi

  # setting up licences
  echo "${WOWZA_KEY}" > /usr/local/WowzaStreamingEngine/conf/Server.license
  sed -i "s/xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxxxxxxxxx/${WOWZA_KEY}/g" /app/interaction.exp

  # install Wowza
  /app/interaction.exp

  # symlink /usr/local/WowzaStreamingEngine/logs -> ${WOWZA_LOG_DIR}/wowza
  rm -rf /usr/local/WowzaStreamingEngine/logs
  ln -sf ${WOWZA_LOG_DIR}/wowza /usr/local/WowzaStreamingEngine/logs

  # symlink /usr/local/WowzaStreamingEngine/manager/logs -> ${WOWZA_LOG_DIR}/manager
  rm -rf /usr/local/WowzaStreamingEngine/manager/logs
  ln -sf ${WOWZA_LOG_DIR}/manager /usr/local/WowzaStreamingEngine/manager/logs
}

rewire_wowza() {
  echo "Preparing Wowza..."
  rm -rf /usr/local/WowzaStreamingEngine/conf
  ln -sf ${WOWZA_DATA_DIR}/conf/wowza /usr/local/WowzaStreamingEngine/conf

  rm -rf /usr/local/WowzaStreamingEngine/manager/conf
  ln -sf ${WOWZA_DATA_DIR}/conf/manager /usr/local/WowzaStreamingEngine/manager/conf

  rm -rf /usr/local/WowzaStreamingEngine/transcoder
  ln -sf ${WOWZA_DATA_DIR}/transcoder /usr/local/WowzaStreamingEngine/transcoder

  rm -rf /usr/local/WowzaStreamingEngine/content
  ln -sf ${WOWZA_DATA_DIR}/content /usr/local/WowzaStreamingEngine/content

  rm -rf /usr/local/WowzaStreamingEngine/backup
  ln -sf ${WOWZA_DATA_DIR}/backup /usr/local/WowzaStreamingEngine/backup

  rm -rf /usr/local/WowzaStreamingEngine/applications
  ln -sf ${WOWZA_DATA_DIR}/applications /usr/local/WowzaStreamingEngine/applications

  rm -rf /usr/local/WowzaStreamingEngine/stats
  ln -sf ${WOWZA_DATA_DIR}/stats /usr/local/WowzaStreamingEngine/stats
}

initialize_data_dir() {
  mkdir -p ${WOWZA_DATA_DIR}
  chmod 0755 ${WOWZA_DATA_DIR}
  chown -R root:root ${WOWZA_DATA_DIR}

  if [[ ! -f ${WOWZA_DATA_DIR}/.firstrun ]]; then
    echo "Initializing data volume..."
    mkdir -p ${WOWZA_DATA_DIR}/conf
    [[ ! -d ${WOWZA_DATA_DIR}/conf/wowza ]]   && cp -a /usr/local/WowzaStreamingEngine/conf ${WOWZA_DATA_DIR}/conf/wowza
    [[ ! -d ${WOWZA_DATA_DIR}/conf/manager ]] && cp -a /usr/local/WowzaStreamingEngine/manager/conf ${WOWZA_DATA_DIR}/conf/manager
    [[ ! -d ${WOWZA_DATA_DIR}/transcoder ]]   && cp -a /usr/local/WowzaStreamingEngine/transcoder ${WOWZA_DATA_DIR}/transcoder
    [[ ! -d ${WOWZA_DATA_DIR}/content ]]      && cp -a /usr/local/WowzaStreamingEngine/content ${WOWZA_DATA_DIR}/content
    [[ ! -d ${WOWZA_DATA_DIR}/backup ]]       && cp -a /usr/local/WowzaStreamingEngine/backup ${WOWZA_DATA_DIR}/backup
    [[ ! -d ${WOWZA_DATA_DIR}/applications ]] && cp -a /usr/local/WowzaStreamingEngine/applications ${WOWZA_DATA_DIR}/applications
    [[ ! -d ${WOWZA_DATA_DIR}/stats ]]        && mkdir -p ${WOWZA_DATA_DIR}/stats
    touch ${WOWZA_DATA_DIR}/.firstrun
  fi
}

initialize_log_dir() {
  mkdir -p ${WOWZA_LOG_DIR}/supervisor
  chmod 0755 ${WOWZA_LOG_DIR}/supervisor
  chown -R root:root ${WOWZA_LOG_DIR}/supervisor

  mkdir -p ${WOWZA_LOG_DIR}/wowza
  chmod 0755 ${WOWZA_LOG_DIR}/wowza
  chown -R root:root ${WOWZA_LOG_DIR}/wowza

  mkdir -p ${WOWZA_LOG_DIR}/manager
  chmod 0755 ${WOWZA_LOG_DIR}/manager
  chown -R root:root ${WOWZA_LOG_DIR}/manager
}

check_and_install_wowza
initialize_data_dir
initialize_log_dir
rewire_wowza

if [[ -z ${1} ]]; then
  exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
else
  exec "$@"
fi
