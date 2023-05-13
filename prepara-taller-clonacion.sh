#!/bin/bash
VBoxManage natnetwork remove --netname "NAT_MME"
VBoxManage natnetwork add --netname "NAT_MME" --network 192.168.123.0/24 --enable
VBoxManage natnetwork modify --netname "NAT_MME" --dhcp off
VBoxManage natnetwork start --netname "NAT_MME"

VBoxManage import MME_Clonacion.ova --vsys 0 --group "/MME - Talleres Clonacion"
VBoxManage snapshot MME_Clonacion take Base

VBoxManage import MME_Server.ova --vsys 0 --group "/MME - Talleres Clonacion"
VBoxManage snapshot MME_Server take Base

