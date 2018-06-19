# References:
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_98.html
# https://github.com/spujadas/elk-docker/blob/master/Dockerfile
# https://github.com/Cyb3rWard0g/HELK/blob/master/helk-nginx/Dockerfile

FROM cyb3rward0g/helk-base:0.0.1
ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN echo "[INFO] Updating Ubuntu base image.." \
    && apt-get update -qq

RUN apt-get -qy clean \
    autoremove

# *********** Adding HELK scripts and files to Container ***************
ADD scripts/nginx-entrypoint.sh /opt/helk/scripts/
RUN chmod +x /opt/helk/scripts/nginx-entrypoint.sh

# *********** Installing Nginx ***************
RUN apt-get install -qqy nginx \
    && mv /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default
ADD default /etc/nginx/sites-available/
RUN apt-get update -qq

# *********** RUN HELK ***************
EXPOSE 80
WORKDIR "/opt/helk/scripts/"
ENTRYPOINT ["./nginx-entrypoint.sh"]
