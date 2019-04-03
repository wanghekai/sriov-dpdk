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


CUSTOMER_PFT_TEST=${CUSTOMER_PFT_TEST:-"no"}

#HOST NAME CONFIG , INPUT YOUR HOSTNAME FOR TEST
#SERVERS AS DUT SERVER
#CLIENTS AS TREX TRAFFIC GENERATOR
SERVERS=${SERVERS:-"dell-per730-54.rhts.eng.pek2.redhat.com"}
CLIENTS=${CLIENTS:-"dell-per730-18.rhts.eng.pek2.redhat.com"}

#CONFIG THE MAC ADDRESS OF INTERFACE BY TESTED
SERVER_NIC1_MAC=${SERVER_NIC1_MAC:-'b4:96:91:14:b0:14'}
SERVER_NIC2_MAC=${SERVER_NIC2_MAC:-'b4:96:91:14:b0:16'}
CLIENT_NIC1_MAC=${CLIENT_NIC1_MAC:-'90:e2:ba:29:bf:14'}
CLIENT_NIC2_MAC=${CLIENT_NIC2_MAC:-'90:e2:ba:29:bf:15'}

#CONFIG DUT SERVER NIC DRIVER
NIC_DRIVER=${NIC_DRIVER:-"ixgbe"}
#CONFIG RHEL VERSION 
SYSTEM_VERSION=${SYSTEM_VERSION:-"RHEL-8.0.0-20190129.1"}

TREX_SERVER_IP=${TREX_SERVER_IP:-$CLIENTS}
#CONFIG YOUR TREX HOST PASSWORD
TREX_SERVER_PASSWORD=${TREX_SERVER_PASSWORD:QwAo2U6GRxyNPKiZaOCx}

#TREX TAR PACKAGE 
#HERE IS OFFICAL URL LINK https://trex-tgn.cisco.com/trex/release/
TREX_URL=${TREX_URL:-'http://netqe-bj.usersys.redhat.com/share/wanghekai/v2.48.tar.gz'}
#GUEST IMAGE FILE
IMAGE_GUEST=${IMAGE_GUEST:-"http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel${SYSTEM_VERSION:5:3}-vsperf-1Q-viommu.qcow2"}


DRIVERCTL_URL=${DRIVERCTL_URL:-"http://download-node-02.eng.bos.redhat.com/brewroot/packages/driverctl/0.101/1.el8/noarch/driverctl-0.101-1.el8.noarch.rpm"}
DPDK_URL=${DPDK_URL:-"http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-18.11-2.el8.x86_64.rpm"}
DPDK_TOOL_URL=${DPDK_TOOL_URL:-"http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-tools-18.11-2.el8.x86_64.rpm"}
DPDK_VERSION=${DPDK_VERSION:-18.11-2}


#################################################################
#PLEASE DO NOT CHANGE BELOW CONFIG
SERVER_VCPUS=${SERVER_VCPUS:-2}
CLIENT_VCPUS=${CLIENT_VCPUS:-2}


manual_test()
{
    set -x

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
    export TREX_SERVER_IP=${TREX_SERVER_IP}
    export TREX_SERVER_PASSWORD=${TREX_SERVER_PASSWORD}
    #TOPO PORT NAME
    export SERVER_NIC1_MAC=${SERVER_NIC1_MAC}
    export SERVER_NIC2_MAC=${SERVER_NIC2_MAC}
    export CLIENT_NIC1_MAC=${CLIENT_NIC1_MAC}
    export CLIENT_NIC2_MAC=${CLIENT_NIC2_MAC}
    export SERVERS=${SERVERS}
    export CLIENTS=${CLIENTS}
    export SERVER_VCPUS=${SERVER_VCPUS}
    export CLIENT_VCPUS=${CLIENT_VCPUS}
    export TREX_URL=${TREX_URL}

    set +x
}

#manual_test
func_test()
{
	set -x
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
        --param=DPDK_VERSION=${DPDK_VERSION} \
        --param=TRAFFIC_TYPE=${TRAFFIC_TYPE} \
        --param=TREX_SERVER_IP=${TREX_SERVER_IP} \
        --param=TREX_SERVER_PASSWORD=${TREX_SERVER_PASSWORD} \
        --param=SERVER_NIC1_MAC=${SERVER_NIC1_MAC} \
        --param=SERVER_NIC2_MAC=${SERVER_NIC2_MAC} \
        --param=CLIENT_NIC1_MAC=${CLIENT_NIC1_MAC} \
        --param=CLIENT_NIC2_MAC=${CLIENT_NIC2_MAC} \
        --param=SERVERS=${SERVERS} \
        --param=CLIENTS=${CLIENTS} \
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