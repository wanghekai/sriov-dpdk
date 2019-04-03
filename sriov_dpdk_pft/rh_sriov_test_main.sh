#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   rh_sriov_test_main.sh of /kernel/networking/vnic/sriov_dpdk_pft
#   Author: Hekai Wang <hewang@redhat.com>
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2013 Red Hat, Inc.
#   Author : hewang@redhat.com
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
#####################################
# root directory for the test suite ,may be set manually
CASE_PATH=${CASE_PATH:-"$(dirname $(readlink -f $0))"}

#Physical Topo
#SRIOV DPDK PFT TOPO
#
#                                   +---------------------------------------+
#                                   |DUT Server                             |
#                                   |                                       |
#                                   |                                       |
#+---------------+                  |                                       |
#|               |-----NIC PORT1----|---PF/VF--+                            |
#|Traffic Trex   |                  |          |-TESTPMD                    |
#|   Host        |                  |          | forward                    |
#|               |-----NIC PORT2----|---PF/VF--+                            |
#+---------------+                  |                                       |
#                                   +---------------------------------------+
#
#


CUSTOMER_PFT_TEST="yes"

#HOST NAME CONFIG , INPUT YOUR HOSTNAME FOR TEST
#SERVERS AS DUT SERVER
#CLIENTS AS TREX TRAFFIC GENERATOR
SERVERS="dell-per730-54.rhts.eng.pek2.redhat.com"
CLIENTS="dell-per730-18.rhts.eng.pek2.redhat.com"

#CONFIG THE MAC ADDRESS OF INTERFACE BY TESTED
SERVER_NIC1_MAC='b4:96:91:14:b0:14'
SERVER_NIC2_MAC='b4:96:91:14:b0:16'
CLIENT_NIC1_MAC='90:e2:ba:29:bf:14'
CLIENT_NIC2_MAC='90:e2:ba:29:bf:15'

#CONFIG DUT SERVER NIC DRIVER
NIC_DRIVER="ixgbe"
#CONFIG RHEL VERSION 
SYSTEM_VERSION="RHEL-8.0.0-20190129.1"

TREX_SERVER_IP=$CLIENTS
#CONFIG YOUR TREX HOST PASSWORD
TREX_SERVER_PASSWORD='QwAo2U6GRxyNPKiZaOCx'

#TREX TAR PACKAGE 
#HERE IS OFFICAL URL LINK https://trex-tgn.cisco.com/trex/release/
TREX_URL='http://netqe-bj.usersys.redhat.com/share/wanghekai/v2.49.tar.gz'
#GUEST IMAGE FILE
IMAGE_GUEST="http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel${SYSTEM_VERSION:5:3}-vsperf-1Q-viommu.qcow2"


DRIVERCTL_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/driverctl/0.101/1.el8/noarch/driverctl-0.101-1.el8.noarch.rpm"
DPDK_URL="http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-18.11-2.el8.x86_64.rpm"
DPDK_TOOL_URL="http://download.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-tools-18.11-2.el8.x86_64.rpm"
DPDK_VERSION=18.11-2

###############################################################
# NO NEED TO CHANGE BELOW THIS LINE
#
# Run test automatically from here

source $CASE_PATH/lib/lib_nc_sync.sh
source $CASE_PATH/lib/lib_utils.sh
export PATH=$PATH:$CASE_PATH

time_stamp=$(date +%Y-%m-%d-%T)
NIC_LOG_FOLDER="/root/RHEL_NIC_QUAL_LOGS/${time_stamp}"
mkdir -p ${NIC_LOG_FOLDER}

if hostname | grep $CLIENTS &>/dev/null
then
        test_log=${NIC_LOG_FOLDER}/client.log
else
        test_log=${NIC_LOG_FOLDER}/server.log
fi

if ! [[ -f $test_log ]];then
        touch ${test_log}
fi

echo $CUSTOMER_PFT_TEST | tee -a ${test_log}
echo $SERVERS | tee -a ${test_log}
echo $CLIENTS | tee -a ${test_log}

echo $SERVER_NIC1_MAC | tee -a ${test_log}
echo $SERVER_NIC2_MAC | tee -a ${test_log}
echo $CLIENT_NIC1_MAC | tee -a ${test_log}
echo $CLIENT_NIC2_MAC | tee -a ${test_log}

echo $NIC_DRIVER | tee -a ${test_log}
echo $SYSTEM_VERSION | tee -a ${test_log}

echo $TREX_SERVER_IP | tee -a ${test_log}
echo $TREX_SERVER_PASSWORD | tee -a ${test_log}

echo $TREX_URL | tee -a ${test_log}
echo $IMAGE_GUEST | tee -a ${test_log}

echo $DRIVERCTL_URL | tee -a ${test_log}
echo $DPDK_URL | tee -a ${test_log}
echo $DPDK_TOOL_URL | tee -a ${test_log}
echo $DPDK_VERSION | tee -a ${test_log}

. runtest.sh |& tee -a ${test_log}
