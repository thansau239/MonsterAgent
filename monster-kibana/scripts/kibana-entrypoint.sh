#!/bin/sh

# References:
# https://github.com/Cyb3rWard0g/HELK/blob/master/helk-kibana

# *********** Start Kibana services ***************
echo "[MONSTER-DOCKER-INSTALLATION-INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s mstr-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[MONSTER-DOCKER-INSTALLATION-INFO] Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[MONSTER-DOCKER-INSTALLATION-INFO] Running helk_kibana_setup.sh script..."
./kibana-setup.sh

tail -f /dev/null
