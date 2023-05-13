# UTIL-prepara-red-nat-vbox
Scripts bash y cmd para crear red NAT con nombre específico y redirección de puertos para Virtual Box

## Script *generate-natnetwork-vbox.sh*
```
    Uso:
        ./generate-natnetwork-vbox.sh NOMBRE RED
        ./generate-natnetwork-vbox.sh NOMBRE RED --dhcp ON|OFF

    Donde:
        NOMBRE es el nombre que se dará de alta en la red NAT de Virtual Box (por ejemplo, NATNetwork)
        RED debe ser una dirección de red válida en notación CIDR (por ejemplo, 10.0.2.0/24)
        --dhcp ON|OFF es un argumento opcional para que indicar con ON/OFF si VirtualBox gestiona las IPs de esta red por DHCP o no
```


### Ejemplo 1

Orden:

```
./generate-natnetwork-vbox.sh ejemplo_1 192.168.1.252/30 --dhcp off
```

Salida:
```
    VBoxManage natnetwork remove --netname "ejemplo_1"
    VBoxManage natnetwork add --netname "ejemplo_1" --network 192.168.1.252/30 --enable
    VBoxManage natnetwork modify --netname "ejemplo_1" --dhcp off
    VBoxManage natnetwork start --netname "ejemplo_1"

    # TO-DO - Reglas de reenvío de puertos
    # se presentan ejemplos válidos para adaptarlos manualmente, cambia la dirección IP de la VM y los puertos
    # VBoxManage natnetwork modify --netname "ejemplo_1" --port-forward-4 "ssh:tcp:[]:1022:[192.168.1.254]:22"
    # VBoxManage natnetwork modify --netname "ejemplo_1" --port-forward-4 "http:tcp:[]:1080:[192.168.1.254]:80"
```

### Ejemplo 2

Orden:
```
./generate-natnetwork-vbox.sh ejemplo_2 10.10.128.0./17
```

Salida:
```
    VBoxManage natnetwork remove --netname "ejemplo_2"
    VBoxManage natnetwork add --netname "ejemplo_2" --network 10.10.128.0./17 --enable
    VBoxManage natnetwork modify --netname "ejemplo_2" --dhcp on
    VBoxManage natnetwork start --netname "ejemplo_2"

    # TO-DO - Reglas de reenvío de puertos
    # se presentan ejemplos válidos para adaptarlos manualmente, cambia la dirección IP de la VM y los puertos
    # VBoxManage natnetwork modify --netname "ejemplo_2" --port-forward-4 "ssh:tcp:[]:1022:[10.10.128.0.59]:22"
    # VBoxManage natnetwork modify --netname "ejemplo_2" --port-forward-4 "http:tcp:[]:1080:[10.10.128.0.59]:80"
```

## Script *prepara-taller-clonacion.sh*

Se trata de un ejemplo que crea una red NAT de VirtualBox llamada "NAT_MME" con dirección 192.168.123.0/24, deshabilitando la función de servidor DHCP. A continuación, importa dos máquinas virtuales a partir de dos ficheros ova (que deben estar en el directorio de trabajo) y guarda una instantánea de cada una. Las máquinas virtuales pueden estar ya configuradas con el nombre de la red NAT en la propia ova o deberían configurarse vía GUI o CLI (comando *VBoxManage modifyvm*).

## Script *prepara-taller-clonacion.bat*

Equivalente para entornos Windows, donde la ruta del ejecutable *VBoxManage* puede no estar configurado por defecto en la variable de entorno *PATH*.