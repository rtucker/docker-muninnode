#!/bin/bash

. config.sh

IFINDEXOID=".1.3.6.1.2.1.2.2.1.1"   # IF-MIB::ifIndex
IFTYPEOID=".1.3.6.1.2.1.2.2.1.3"    # IF-MIB::ifType

ifindexes(){
    local h=$1
    [ -z "$h" ] && return 1
    local ver=$(get_snmp_ver $h)
    [ -z "$ver" ] && return 2

    snmpwalk -OE -Oq $ver -c public $h $IFINDEXOID | cut -d' ' -f2 | xargs
}

iftype(){
    local h=$1
    [ -z "$h" ] && return 1
    local idx=$2
    [ -z "$idx" ] && return 1

    local ver=$(get_snmp_ver $h)
    [ -z "$ver" ] && return 2

    snmpget -OE -Oq $ver -c public $h ${IFTYPEOID}.${idx} | cut -d' ' -f2
}

echo "Configuring temporary DNS..."
gen_hosts_file >> /etc/hosts

echo "Fetching plugins..."

cd /usr/src
git clone https://github.com/rtucker/munin-plugins.git

echo -n "Deploying interface plugins..."
for host in budlight coors hap-487f95 hap-ce2580 milwaukees-best
do
    echo -n " ${host}"
    for n in $(ifindexes $host)
    do
        # filter out l2vlan because it doesn't work right with munin
        if [ "$(iftype $host $n)" -ne "135" ]
        then
            ln -s /usr/share/munin/plugins/snmp__if_            /etc/munin/plugins/snmp_${host}_if_${n}
            ln -s /usr/share/munin/plugins/snmp__if_err_        /etc/munin/plugins/snmp_${host}_if_err_${n}
        fi
    done

    ln -s /usr/share/munin/plugins/snmp__if_multi       /etc/munin/plugins/snmp_${host}_if_multi
    ln -s /usr/share/munin/plugins/snmp__netstat        /etc/munin/plugins/snmp_${host}_netstat
    ln -s /usr/share/munin/plugins/snmp__uptime         /etc/munin/plugins/snmp_${host}_uptime
done

echo ""

echo -n "Deploying Mikrotik plugins..."

for host in coors hap-487f95 hap-ce2580
do
    echo -n " ${host}"
    ln -s /munin-plugins/mikrotikcpu_                   /etc/munin/plugins/mikrotikcpu_${host}
    ln -s /munin-plugins/mikrotikdiskspace_             /etc/munin/plugins/mikrotikdiskspace_${host}
    ln -s /munin-plugins/mikrotikmemory_                /etc/munin/plugins/mikrotikmemory_${host}
    ln -s /munin-plugins/mikrotiktemperature_           /etc/munin/plugins/mikrotiktemperature_${host}
    ln -s /munin-plugins/mikrotikvoltage_               /etc/munin/plugins/mikrotikvoltage_${host}
done

echo ""

echo "Installing remaining plugins..."
ln -s /munin-plugins/mikrotikcapsman_               /etc/munin/plugins/mikrotikcapsman_coors
ln -s /usr/share/munin/plugins/snmp__print_pages    /etc/munin/plugins/snmp_milwaukees-best_print_pages

echo "Done!"

