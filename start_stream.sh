#/bin/bash
echo "stopping all first..."
killall icecast

sleep 2

icecast -c /usr/local/etc/icecast.xml &
echo "icecast started"
