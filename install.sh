#!/bin/bash

# OpenNebula Latch addon.
# Copyright (C) 2015  Carlos Martin Sanchez
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

usage() {
 echo
 echo "Usage: install.sh [-u install_user] [-g install_group] [-d ONE_LOCATION] [-h]"
 echo
 echo "-u: user that will run opennebula, defaults to user executing install.sh"
 echo "-g: group of the user that will run opennebula, defaults to user"
 echo "    executing install.sh"
 echo "-d: target installation directory, if not defined it'd be root. Must be"
 echo "    an absolute path."
 echo "-h: prints this help"
}
#-------------------------------------------------------------------------------

PARAMETERS="hu:g:d:"

if [ $(getopt --version | tr -d " ") = "--" ]; then
    TEMP_OPT=`getopt $PARAMETERS "$@"`
else
    TEMP_OPT=`getopt -o $PARAMETERS -n 'install.sh' -- "$@"`
fi

if [ $? != 0 ] ; then
    usage
    exit 1
fi

eval set -- "$TEMP_OPT"

ONEADMIN_USER=`id -u`
ONEADMIN_GROUP=`id -g`
SRC_DIR=$PWD

while true ; do
    case "$1" in
        -h) usage; exit 0;;
        -u) ONEADMIN_USER="$2" ; shift 2;;
        -g) ONEADMIN_GROUP="$2"; shift 2;;
        -d) ROOT="$2" ; shift 2 ;;
        --) shift ; break ;;
        *)  usage; exit 1 ;;
    esac
done

#-------------------------------------------------------------------------------
# Definition of locations
#-------------------------------------------------------------------------------

if [ -z "$ROOT" ] ; then
    BIN_LOCATION="/usr/bin"
    LIB_LOCATION="/usr/lib/one"
    ETC_LOCATION="/etc/one"
    VAR_LOCATION="/var/lib/one"
else
    BIN_LOCATION="$ROOT/bin"
    LIB_LOCATION="$ROOT/lib"
    ETC_LOCATION="$ROOT/etc"
    VAR_LOCATION="$ROOT/var"
fi


mkdir $VAR_LOCATION/remotes/auth/latch

cp $SRC_DIR/auth/authenticate $VAR_LOCATION/remotes/auth/latch
cp $SRC_DIR/cli/onelatch $BIN_LOCATION
cp $SRC_DIR/etc/latch_auth.conf $ETC_LOCATION/auth
cp -r $SRC_DIR/latch-sdk-ruby $LIB_LOCATION/ruby/vendors
cp $SRC_DIR/lib/one_latch.rb $LIB_LOCATION/ruby
cp $SRC_DIR/sunstone/latch.rb $LIB_LOCATION/sunstone/routes/latch.rb
cp $SRC_DIR/sunstone/latch-tab.js $LIB_LOCATION/sunstone/public/js/plugins/latch-tab.js

chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $VAR_LOCATION/remotes/auth/latch
chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $BIN_LOCATION
chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $ETC_LOCATION/auth
chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $LIB_LOCATION/ruby/vendors
chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $LIB_LOCATION/ruby
chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $LIB_LOCATION/sunstone/routes/latch.rb
chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $LIB_LOCATION/sunstone/public/js/plugins/latch-tab.js