#!/bin/bash

# Apply munin-node allowed hosts
if [ ! -z ${ALLOWED_HOSTS+x} ]; then
	sed -i -e 's@^cidr_allow.*@cidr_allow '"$ALLOWED_HOSTS"'@' /etc/munin/munin-node.conf
fi

# Apply user defined server name from ENV
if [ ! -z ${HOSTNAME+x} ]; then
	sed -ie 's@localhost.localdomain@'"$HOSTNAME"'@g' /etc/munin/munin.conf
fi

# Set timezone if supplied ENV{TZ} is valid
if [ -f "/usr/share/zoneinfo/$TZ" ]; then
	rm /etc/localtime
	ln -s "/usr/share/zoneinfo/$TZ" /etc/localtime
fi

# Create holding page if no stats are available
if [ ! -e /var/cache/munin/www/index.html ]; then
	echo "NEW INSTALLATION: Charts will be available within 5 minutes, thank you for waiting..." > /var/cache/munin/www/index.htm
fi

munin-node-configure --remove --shell | sh
ln -s /usr/share/munin/plugins/hddtemp_smartctl   /etc/munin/plugins/hddtemp_smartctl
ln -s /usr/share/munin/plugins/iostat   /etc/munin/plugins/iostat 
ln -s /usr/share/munin/plugins/meminfo   /etc/munin/plugins/meminfo 
printf '[docker_*]\nuser root\n' > /etc/munin/plugin-conf.d/docker

service cron start
a2enmod cgid
service apache2 start
exec /usr/sbin/munin-node --config /etc/munin/munin-node.conf
