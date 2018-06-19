#!/bin/sh

# Start graceful termination of HELK services that might be running before running the entrypoint script.
_term() {
  echo "Terminating Nginx Services"
  service nginx stop
  exit 0
}
trap _term SIGTERM

until curl -s mstr-elasticsearch:9200 -o /dev/null; do
    sleep 1
done

echo "[MONSTER-DOCKER-INSTALLATION-INFO] Starting remaining services.."
service nginx restart

echo "[MONSTER-DOCKER-INSTALLATION-INFO] Pushing Nginx Logs to console.."
tail -f /var/log/nginx/*.log
