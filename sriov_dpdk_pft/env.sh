#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   env.sh of /kernel/networking/vnic/sriov_dpdk_pft
#   Author: Hekai Wang <hewang@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2013 Red Hat, Inc.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CUSTOMER_PFT_TEST="no"

CUSTOMER_PFT_TEST=${CUSTOMER_PFT_TEST:-"yes"}

NIC_DRIVER=${NIC_DRIVER:-"ixgbe"}
SYSTEM_VERSION="RHEL-8.0.0-20190129.1"

TREX_URL='http://netqe-bj.usersys.redhat.com/share/wanghekai/v2.48.tar.gz'
IMAGE_GUEST="http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel${SYSTEM_VERSION:5:3}-vsperf-1Q-viommu.qcow2"

#IMAGE_GUEST="http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel7.6-vsperf-1Q-viommu.qcow2"
#IMAGE_GUEST="http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel8.0-vsperf-1Q-viommu.qcow2"
DRIVERCTL_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/driverctl/0.101/1.el8/noarch/driverctl-0.101-1.el8.noarch.rpm"
#DPDK_URL="http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el7_6/x86_64/dpdk-18.11-2.el7_6.x86_64.rpm"
#DPDK_TOOL_URL="http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el7_6/x86_64/dpdk-tools-18.11-2.el7_6.x86_64.rpm"

DPDK_URL="http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-18.11-2.el8.x86_64.rpm"
DPDK_TOOL_URL="http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-tools-18.11-2.el8.x86_64.rpm"

TRAFFIC_TYPE=trex

#TOPO PORT NAME
#SERVER_PORT_ONE=01.01.05
#SERVER_PORT_TWO=01.01.06
#CLIENT_PORT_ONE=01.01.47
#CLIENT_PORT_TWO=01.01.48

SERVER_NIC1_MAC='b4:96:91:14:b0:14'
SERVER_NIC2_MAC='b4:96:91:14:b0:16'
CLIENT_NIC1_MAC='90:e2:ba:29:bf:14'
CLIENT_NIC2_MAC='90:e2:ba:29:bf:15'

# if [[ $TRAFFIC_TYPE == "trex" ]]
# then
#     TRAFFIC_PORT_ONE=$CLIENT_PORT_ONE
#     TRAFFIC_PORT_TWO=$CLIENT_PORT_TWO
# else
#     TRAFFIC_PORT_ONE=XENA_M7P0
#     TRAFFIC_PORT_TWO=XENA_M7P1
# fi

# SWITCH_PORT_ONE=5010_Eth3
# SWITCH_PORT_TWO=5010_Eth4
# SWITCH_PORT_THREE=5010_Eth5
# SWITCH_PORT_FOUR=5010_Eth6
# SWITCH_NAME=5010
# SWITCH_PORT_NAME='Eth1/3 Eth1/4'
# SWITCH_PORT2_NAME='Eth1/5 Eth1/6'
# SW_PORT_ONE_NAME=`echo $SWITCH_PORT_NAME| awk '{print $1}'`
# SW_PORT_TWO_NAME=`echo $SWITCH_PORT_NAME| awk '{print $2}'`

under_test_machine='dell-per730-54.rhts.eng.pek2.redhat.com,dell-per730-18.rhts.eng.pek2.redhat.com'
temp_machine=`echo ${under_test_machine} | tr -s ',' ' '`
temp_machine_list=($temp_machine)
TREX_SERVER_IP=${temp_machine_list[1]}
TREX_SERVER_PASSWORD=QwAo2U6GRxyNPKiZaOCx

SERVERS=${temp_machine_list[0]}
CLIENTS=${temp_machine_list[1]}


SERVER_VCPUS=${SERVER_VCPUS:-2}
CLIENT_VCPUS=${CLIENT_VCPUS:-2}

DPDK_VERSION=18.11-2
GUEST_DPDK_VERSION=1811-2

manual_test()
{
    set -x
    local temp_machine=`echo ${under_test_machine} | tr -s ',' ' '`
    local temp_machine_list=($temp_machine)

    # systemctl start openvswitch
    # ovs-vsctl --if-exists del-br ovsbrup
	# ovs-vsctl --if-exists del-br ovsbr0    
    # systemctl stop openvswitch

    local hugepage_dir=`mount -l | grep hugetlbfs | awk '{print $3}'`
    rm -rf $hugepage_dir/*

    pkill t-rex-64
    pkill t-rex-64
    pkill _t-rex-64
    pkill _t-rex-64

    virsh destroy guest30032
    virsh undefine guest30032


    if [[ -f /usr/sbin/dpdk-devbind ]] 
    then
            bus_list=`dpdk-devbind -s | grep  -E drv=vfio-pci\|drv=igb | awk '{print $1}'`
            for i in $bus_list
            do
                kernel_driver=`lspci -s $i -v | grep Kernel  | grep modules  | awk '{print $NF}'`
                dpdk-devbind -b $kernel_driver $i
            done        
    fi

    virsh destroy guest30032
    virsh undefine guest30032

    export NAY=yes
    export NIC_DRIVER=${NIC_DRIVER}
    export SYSTEM_VERSION=${SYSTEM_VERSION}
    export IMG_GUEST=${IMAGE_GUEST}
    export DRIVERCTL_URL=${DRIVERCTL_URL}
    export DPDK_URL=${DPDK_URL}
    export DPDK_TOOL_URL=${DPDK_TOOL_URL}
    export DPDK_VERSION=${DPDK_VERSION}
    export GUEST_DPDK_VERSION=${GUEST_DPDK_VERSION}
    export TREX_SERVER_IP=${TREX_SERVER_IP}
    export TREX_SERVER_PASSWORD=${TREX_SERVER_PASSWORD}
    #TOPO PORT NAME
    export SERVER_NIC1_MAC=${SERVER_NIC1_MAC}
    export SERVER_NIC2_MAC=${SERVER_NIC2_MAC}
    export CLIENT_NIC1_MAC=${CLIENT_NIC1_MAC}
    export CLIENT_NIC2_MAC=${CLIENT_NIC2_MAC}

    export SERVERS=${temp_machine_list[0]}
    export CLIENTS=${temp_machine_list[1]}

    export SERVER_VCPUS=${SERVER_VCPUS}
    export CLIENT_VCPUS=${CLIENT_VCPUS}


    export TREX_URL=${TREX_URL}

    set +x
}

#manual_test

func_test()
{
	set -x
    local temp_machine=`echo ${under_test_machine} | tr -s ',' ' '`
    local temp_machine_list=($temp_machine)
    local white_board="sriov dpdk pft case | ${NIC_DRIVER} |"
    white_board=$white_board" $under_test_machine |"
    white_board=$white_board" $version |"
    local dpdk_version=`basename $DPDK_URL`
    white_board=$white_board" $dpdk_version |"
    white_board=$white_board" $IMAGE_GUEST|"

    temp_varient=server
    echo $SYSTEM_VERSION | grep "RHEL-8" && temp_varient=BaseOS
    echo $temp_varient

    lstest | runtest ${SYSTEM_VERSION} --machine=${under_test_machine} --wb="$white_board" \
        --param=NIC_DRIVER=${NIC_DRIVER} \
        --param=SYSTEM_VERSION=${SYSTEM_VERSION} \
        --param=IMG_GUEST=${IMAGE_GUEST} \
        --param=DRIVERCTL_URL=${DRIVERCTL_URL} \
        --param=DPDK_URL=${DPDK_URL} \
        --param=DPDK_TOOL_URL=${DPDK_TOOL_URL} \
        --param=GUEST_DPDK_VERSION=${GUEST_DPDK_VERSION} \
        --param=DPDK_VERSION=${DPDK_VERSION} \
        --param=TRAFFIC_TYPE=${TRAFFIC_TYPE} \
        --param=TREX_SERVER_IP=${TREX_SERVER_IP} \
        --param=TREX_SERVER_PASSWORD=${TREX_SERVER_PASSWORD} \
        --param=SERVER_NIC1_MAC=${SERVER_NIC1_MAC} \
        --param=SERVER_NIC2_MAC=${SERVER_NIC2_MAC} \
        --param=CLIENT_NIC1_MAC=${CLIENT_NIC1_MAC} \
        --param=CLIENT_NIC2_MAC=${CLIENT_NIC2_MAC} \
        --param=SERVERS=${temp_machine_list[0]} \
        --param=CLIENTS=${temp_machine_list[1]} \
        --param=SERVER_VCPUS=${SERVER_VCPUS} \
        --param=CLIENT_VCPUS=${CLIENT_VCPUS} \
        --param=NAY=yes \
        --param=NIC_DRIVER=${NIC_DRIVER} \
        --param=TREX_URL=${TREX_URL} \
        --variant=$temp_varient \
        --systype=Machine \
        --random=true \
        --ks-meta="method=nfs" \
        --kernel-options="kpti" \
        --kernel-options-post="kpti" \
        --kdump \
        --topo=multiHost.1.1 \
    	--noavc
    set +x
}

#func_test