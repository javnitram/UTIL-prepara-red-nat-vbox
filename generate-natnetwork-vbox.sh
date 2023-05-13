#!/bin/bash

# set -e # Provoca que el script termine si un comando acaba con código de error
set -u # Provoca que el script termine si se usa una variable no declarada
set -o pipefail # Una sentencia con pipes acaba con código de error si un comando intermedio falla

# VARIABLES GLOBALES
declare -a LONG_OPTS_LIST=(
    "dhcp"
    )
declare netname
declare network
declare dhcp
declare vm_ip

function error_uso() {
    local nombre
    local red
    local dhcp

    nombre=$(subrayado NOMBRE)
    red=$(subrayado RED)
    dhcp=$(subrayado "--dhcp ON|OFF")

    cat >&2 << EOF
    Uso:
        $0 ${nombre} ${red}
        $0 ${nombre} ${red} ${dhcp}

    Donde:
        ${nombre} es el nombre que se dará de alta en la red NAT de Virtual Box (por ejemplo, NATNetwork)
        ${red} debe ser una dirección de red válida en notación CIDR (por ejemplo, 10.0.2.0/24)
        ${dhcp} es un argumento opcional para que indicar con ON/OFF si VirtualBox gestiona las IPs de esta red por DHCP o no
EOF
}

function subrayado() {
    echo -e "\e[4m$*\e[0m"
}

# Genera una dirección IP aleatoria cambiando el valor del último octeto de la dirección de red
function calc_vm_example_ip() {
    local left
    local right
    # Los tres primeros octetos de la dirección de red
    left=${network%.*}
    # El último octeto de la dirección de red
    right=$(echo "$network" | sed 's/.*\.\([0-9]*\)\/[0-9]*/\1/')
    # Prefijo CIDR, para el cálculo aleatorio de la dirección de host se considerará al menos /24
    netmask=${network##*/}
    netmask=$(( 24 > $netmask ? 24 : $netmask ))
    right=$(( ( RANDOM>>(16-(32-netmask)) ) + right + 1))
    printf "%s.%s" $left $right
}

function check_params() {
    if [[ $# -lt 2 ]]
    then
        error_uso
        exit 1
    fi

    netname="$1"
    network="$2"
    vm_ip=$(calc_vm_example_ip)
    dhcp="on" # default
    shift 2

    if [[ $# -gt 0 ]]
    then
        # read arguments
        local opts
        opts=$(getopt \
        --longoptions "$(printf "%s:," "${LONG_OPTS_LIST[@]}")" \
        --name "$(basename "$0")" \
        --options "" \
        -- "$@"
        )

        eval set -- "${opts}"
        while true; do
            case "$1" in
                --dhcp )
                    dhcp="${2:-on}"
                    if ! es_estado_valido $dhcp
                    then
                        printf 'dhcp tiene un valor inválido %s\n\n' "$dhcp" >&2
                        error_uso
                        exit 2
                    fi
                    shift 2
                    ;;
                -- )
                    shift
                    break
                    ;;
                * )
                    break
                    ;;
            esac
        done
    fi
}

function es_estado_valido() {
    local estado=$1
    local patron="^(on|off|ON|OFF)$"
    [[ $estado =~ $patron ]]
}

function main() {
    check_params "$@"

    cat << EOF
    VBoxManage natnetwork remove --netname "$netname"
    VBoxManage natnetwork add --netname "$netname" --network $network --enable
    VBoxManage natnetwork modify --netname "$netname" --dhcp $dhcp
    VBoxManage natnetwork start --netname "$netname"

    # TO-DO - Reglas de reenvío de puertos
    # se presentan ejemplos válidos para adaptarlos manualmente, cambia la dirección IP de la VM y los puertos
    # VBoxManage natnetwork modify --netname "$netname" --port-forward-4 "ssh:tcp:[]:1022:[$vm_ip]:22"
    # VBoxManage natnetwork modify --netname "$netname" --port-forward-4 "http:tcp:[]:1080:[$vm_ip]:80"
EOF
    exit 0
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    # Están ejecutando directamente este script, no importándolo con source
    main "$@"
fi