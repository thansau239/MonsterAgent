#!/bin/sh

# References:
# https://github.com/Cyb3rWard0g/HELK/blob/master/helk-kibana

# *********** Start Kibana services ***************
echo "[INFO] Waiting for elasticsearch URI to be accessible.."
until curl -s mstr-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[INFO] Starting Kibana service.."
exec /usr/local/bin/kibana-docker &

# *********** Creating Kibana Dashboards, visualizations and index-patterns ***************
echo "[INFO] Running helk_kibana_setup.sh script..."
./kibana-setup.sh

tail -f /dev/null
