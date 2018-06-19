# https://github.com/elastic/kibana-docker
FROM docker.elastic.co/kibana/kibana:6.3.0

RUN mv /usr/share/kibana/config/kibana.yml /usr/share/kibana/config/kibana_backup
# References:
# https://github.com/Cyb3rWard0g/HELK/blob/master/helk-kibana

# *********** Adding HELK scripts, config files and dashboards to container ***************
ADD dashboards /usr/share/kibana/dashboards
ADD scripts/kibana-entrypoint.sh /usr/share/kibana/kibana-entrypoint.sh
ADD scripts/kibana-setup.sh /usr/share/kibana/kibana-setup.sh

# *********** RUN HELK Kibana ***************
WORKDIR "/usr/share/kibana/"
ENTRYPOINT ["sh", "./kibana-entrypoint.sh"]
