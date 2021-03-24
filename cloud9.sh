#!/bin/bash

cd /root/

ip=$(ip addr|grep 'inet '|grep global|head -n1|awk '{print $2}'|cut -f1 -d/)
PORT=8181
PASSWORD=$(date +%s | sha256sum | base64 | head -c 32)

apt install build-essential python -y

curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs

curl -L https://npmjs.org/install.sh | sudo sh

rm /root/.c9/ -rf
rm /root/sdk/ -rf

git clone https://github.com/c9/core sdk
cd sdk/
git fetch origin; git reset origin/master --hard
./scripts/install-sdk.sh
npm i optimist amd-loader architect

npm i forever -g

forever stop /root/sdk/server.js

cat << EOF > /etc/init.d/vpsstart.sh

#!/bin/bash

### BEGIN INIT INFO
# Provides:          	vps
# Required-Start:     	\$all
# Required-Stop:      	\$all
# Default-Start:     	2 3 4 5
# Default-Stop:      	0 1 6
# Short-Description:    vpsstart
# Description:       	Enable service provided by daemon.
### END INIT INFO

su -c "cd /home/ & forever start /root/sdk/server.js -w / -p $PORT -l 0.0.0.0  -a admin:$PASSWORD --collab" root;

EOF

ufw allow $PORT

chmod 777 /etc/init.d/vpsstart.sh 
update-rc.d vpsstart.sh defaults

/etc/init.d/vpsstart.sh

forever list

cat << EOF > /root/cloud9_password.txt

Congratulations, you have just successfully installed cloud9
http://$ip:$PORT
username: admin
password: $PASSWORD

EOF

cat /root/cloud9_password.txt

