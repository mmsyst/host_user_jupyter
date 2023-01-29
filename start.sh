#!/bin/bash
cd `dirname $0`
set -euxo pipefail

export TMP_UID=$(id -u $USER)
export TMP_USER=$(whoami)
export TMP_GROUPS=$(id -Gn $USER)
export TMP_GIDS=$(id -G $USER)
# user password
export TMP_USER_PASS=$(openssl rand -base64 12)
mkdir -p ./tmp
cat << _EOT_ | tee ./tmp/entrypoint.sh
#!/bin/bash
D_USER=jovyan
D_UID=1000
D_GROUP=users
D_GID=100
TMP_GID=11111
groupadd -g \${TMP_GID} tmpgrp
usermod -g tmpgrp \${D_USER}
groupdel \${D_GROUP}
HOST_USER=${TMP_USER}
HOST_UID=${TMP_UID}
HOST_GROUPS=(${TMP_GROUPS})
HOST_GIDS=(${TMP_GIDS})
PASSWORD=${TMP_USER_PASS}
adduser \${HOST_USER} --uid \${HOST_UID} --disabled-password --gecos "" -gid \${TMP_GID}
for ((i = 0; i < \${#HOST_GROUPS[@]}; i++)) {
    groupadd -g \${HOST_GIDS[i]} \${HOST_GROUPS[i]}
    usermod -aG \${HOST_GROUPS[i]} \${HOST_USER}
}

#cp /home/jovyan/.profile /home/\${HOST_USER}/.profile 
#chown \${HOST_USER} /home/\${HOST_USER}/.profile
chpasswd <<<"\${HOST_USER}:\${PASSWORD}"
chown \${HOST_USER} /tmp/run.sh
chmod 777 /tmp/run.sh
chown \${HOST_USER} /opt/pycharm/bin/idea.properties
su \${HOST_USER} -c /tmp/run.sh
exec "\$@"
_EOT_
chmod 0777 ./tmp/entrypoint.sh
DOCKER_BUILDKIT=1 docker build --no-cache -t custom-notebook:latest -f ./Dockerfile .
docker-compose up