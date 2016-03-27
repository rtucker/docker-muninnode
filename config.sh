NAME="MUNIN-SNMP"
TAG="munin-snmp"

HOSTS="
coors|192.168.1.1|-v2c
hap-487f95|172.16.0.100|-v2c
hap-ce2580|172.16.0.101|-v2c
budlight|192.168.1.6|-v1
milwaukees-best|192.168.1.18|-v1
"

gen_hosts_file(){
    for h in ${HOSTS}
    do
        arg1=$(echo $h | cut -d'|' -f1)
        arg2=$(echo $h | cut -d'|' -f2)
        echo "$arg2 $arg1"
    done
}

gen_docker_args(){
    for h in ${HOSTS}
    do
        arg1=$(echo $h | cut -d'|' -f1)
        arg2=$(echo $h | cut -d'|' -f2)
        echo -n "--add-host=${arg1}:${arg2} "
    done
}

get_snmp_ver(){
    for h in ${HOSTS}
    do
        arg1=$(echo $h | cut -d'|' -f1)
        arg3=$(echo $h | cut -d'|' -f3)
        [ "$1" = "$arg1" ] && echo "${arg3}" && return
    done
}

