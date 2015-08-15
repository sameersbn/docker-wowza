#!/bin/bash
set -e

WOWZA_KEY=${WOWZA_KEY:-}

# create configuration directory
mkdir -p /data/conf

# setup container for first run
if [ ! -f "/data/.firstrun" ]; then
  echo "Configuring container for first run..."
  if [ ! -d "/data/conf/wowza" ]; then
    cp -a /usr/local/WowzaStreamingEngine/conf /data/conf/wowza
  fi
  if [ ! -d "/data/conf/manager" ]; then
    cp -a /usr/local/WowzaStreamingEngine/manager/conf /data/conf/manager
  fi
  if [ ! -d "/data/transcoder" ]; then
    cp -a /usr/local/WowzaStreamingEngine/transcoder /data/transcoder
  fi
  if [ ! -d "/data/content" ]; then
    cp -a /usr/local/WowzaStreamingEngine/content /data/content
  fi
  if [ ! -d "/data/backup" ]; then
    cp -a /usr/local/WowzaStreamingEngine/backup /data/backup
  fi
  if [ ! -d "/data/stats" ]; then
    mkdir -p /data/stats
  fi
  touch "/data/.firstrun"
fi

# setup symlinks
rm -rf /usr/local/WowzaStreamingEngine/conf
ln -sf /data/conf/wowza /usr/local/WowzaStreamingEngine/conf

rm -rf /usr/local/WowzaStreamingEngine/manager/conf
ln -sf /data/conf/manager /usr/local/WowzaStreamingEngine/manager/conf

rm -rf /usr/local/WowzaStreamingEngine/transcoder
ln -sf /data/transcoder /usr/local/WowzaStreamingEngine/transcoder

rm -rf /usr/local/WowzaStreamingEngine/content
ln -sf /data/content /usr/local/WowzaStreamingEngine/content

rm -rf /usr/local/WowzaStreamingEngine/backup
ln -sf /data/backup /usr/local/WowzaStreamingEngine/backup

rm -rf /usr/local/WowzaStreamingEngine/stats
ln -sf /data/stats /usr/local/WowzaStreamingEngine/stats

# populate /var/log/wowza
mkdir -m 0755 -p /var/log/wowza/supervisor   && chown -R root:root /var/log/wowza/supervisor
mkdir -m 0755 -p /var/log/wowza/wowza        && chown -R root:root /var/log/wowza/wowza
mkdir -m 0755 -p /var/log/wowza/manager      && chown -R root:root /var/log/wowza/manager

#
if [ -z "${WOWZA_KEY}" -a ! -f "/usr/local/WowzaStreamingEngine/conf/Server.license" ]; then
  echo "ERROR: "
  echo "  Please specify your Wowza Streaming Engine license key using"
  echo "  the WOWZA_KEY environment variable."
  echo "  Cannot continue without a license. Aborting..."
  exit 1
fi

# install wowza license
if [ -n "${WOWZA_KEY}" ]; then
  echo "Installing Wowza Streaming Engine license..."
  echo "${WOWZA_KEY}" > /usr/local/WowzaStreamingEngine/conf/Server.license
fi

start () {
  # start supervisord
  exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

help () {
  echo "Available options:"
  echo " start      - Starts the wowza server (default)"
  echo " help       - Displays the help"
  echo " [command]  - Execute the specified linux command eg. bash."
}

case "$1" in
  start)
    start
    ;;
  help)
    help
    ;;
  *)
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "${prog}" ] ; then
        shift 1
        $prog $@
      else
        help
      fi
    fi
    ;;
esac

exit 0
