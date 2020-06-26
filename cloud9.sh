#!/bin/bash

read -p "Enter cloud9 port: " PORT 
read -p "Enter password for admin user: " PASSWORD  

apt install build-essential python -y

curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs

curl -L https://npmjs.org/install.sh | sudo sh


git clone https://github.com/c9/core sdk
cd sdk/
./scripts/install-sdk.sh

npm i forever -g

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

chmod 777 /etc/init.d/vpsstart.sh 
update-rc.d vpsstart.sh defaults