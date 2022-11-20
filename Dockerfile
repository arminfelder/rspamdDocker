FROM debian:bullseye-slim

RUN	apt-get update && apt-get install -y --no-install-recommends  \
    gnupg \
    dirmngr \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings
RUN	wget -O- https://rspamd.com/apt-stable/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rspamd.gpg > /dev/null

RUN	set -x \
# gpg: key FFA232EDBF21E25E: public key "Rspamd Nightly Builds (Rspamd Nightly Builds) <vsevolod@highsecure.ru>" imported
	&& key='3FA347D5E599BE4595CA2576FFA232EDBF21E25E' \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "FFA232EDBF21E25E" \
	&& apt-key list > /dev/null


RUN	echo "deb http://rspamd.com/apt-stable/ bullseye main" | tee /etc/apt/sources.list.d/rspamd.list

RUN	apt-get update \
	&& apt-get install -y rspamd \
	&& rm -rf /var/lib/apt/lists/*

RUN	echo 'type = "console";' > /etc/rspamd/override.d/logging.inc \
	&& echo 'bind_socket = "*:11334";' > /etc/rspamd/override.d/worker-controller.inc \
	&& echo 'pidfile = false;' > /etc/rspamd/override.d/options.inc

VOLUME	["/etc/rspamd", "/var/lib/rspamd" ]

CMD	[ "/usr/bin/rspamd", "-f", "-u", "_rspamd", "-g", "_rspamd" ]

EXPOSE	11333 11334 11332
