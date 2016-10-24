#!/bin/bash

# Copyright 2015 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function ose_hack() {
	export USER_ID=$(id -u)
	export GROUP_ID=$(id -g)
	envsubst < /opt/cpm/conf/passwd.template > /tmp/passwd
	export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
	export NSS_WRAPPER_PASSWD=/tmp/passwd
	export NSS_WRAPPER_GROUP=/etc/group
}

ose_hack

rm -rf /tmp/pgbouncer.pid

BINDIR=/opt/cpm/bin
CONFDIR=/pgconf

if [ -f $CONFDIR/users.txt ]; then
	echo "users.txt found in " $CONFDIR
	CONFDIR=/pgconf
else
	echo "users.txt NOT found in " $CONFDIR
fi

if [ -f $CONFDIR/pgbouncer.ini ]; then
	echo "pgbouncer.ini found in " $CONFDIR
	CONFDIR=/pgconf
else
	echo "pgbouncer.ini NOT found in " $CONFDIR
	echo "will use default config files out of /tmp"
	CONFDIR=/tmp
fi

if [ -v FAILOVER ]; then
	echo "FAILOVER is set and a watch will be started on the master"
	/opt/cpm/bin/pgbouncer-watch.sh &
fi

pgbouncer $CONFDIR/pgbouncer.ini -u pgbouncer

while true; do
	echo "main sleeping..."
	sleep 100
done
