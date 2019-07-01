# Red Hat DPDK In Guest/SR-IOV Host/SR-IOV Qualification

The goal of this document is to guide you step by step through the process of 
qualifying a NIC card with SR-IOV functionality. This includes both the Linux 
Kernel driver and the DPDK PMD driver.

## OVERVIEW
This project uses a script to run 10 tests to validate the NIC’s Hardware Support 
for SR-IOV. The script runs on two systems. One side is setup as a client and 
the other side is the server. Cisco T-Rex is used on the client side to generate 
and monitor the test traffic.


The performance based tests use an upstream project called TREX from Cisco to
test performance using very basic flows rules and parameters. This is broken
into two scripts, the first script will execute on the Client Side (The Trex Side) 
and the Test Script will execute on the Server side.


The functional test script runs a plethora of tests to verify NICs pass
functional requirements.


This testing require two systems.
One server will have TREX installed, the other will be a clean install system
running RHEL 7.4 or greater. The servers should be wired back to back from the
test NICs to the output NICs of the T-Rex server. These tests use two NIC ports
on the DUT and two ports on the T-Rex which are connected as shown below.
The two NIC ports on the DUT must be the brand and type of NICs which are to be
qualified. The first set of performance tests use a topology as seen below.


```                                                          _

       +---------------------------------------------------+  |
       |                                                   |  |
       |   +-------------------------------------------+   |  |
       |   |                 TESTPMD/forward           |   |  |
       |   +-------------------------------------------+   |  |
       |       ^                                  ^        |  |
       |       |                                  |        |  |  DUT Server
       |       v                                  v        |  |
       |   +---------------+           +---------------+   |  |
       |   | PF/VF port 0  |           |   PF/VF port 1|   |  |
       +---+---------------+-----------+---------------+---+ _|
               ^                                  ^
               |                                  |
               v                                  v         
           +---------------+          +---------------+  
           | NIC port 0    |          | NIC     port 1|     
           +---------------+          +---------------+     
               ^                                  ^         
               |                                  |          
               v                                  v         _
       +--------------------------------------------------+  |   
       |   +--------------+            +--------------+   |  |
       |   |   phy port   |  vSwitch   |   phy port   |   |  |
       |   +--------------+            +--------------+   |  |
       |        ^                              :          |  |
       |        |                              |          |  |   Client
       |        v                              v          |  |
       +--------------------------------------------------+  |
       |                                                  |  |
       |                traffic generator  (T-REX)        |  |
       |                                                  |  |
       +--------------------------------------------------+  |
                                                            _|

```


All traffic on these tests are bi-directional and the results are calculated as a total of the
sum of both ports in frames per second.


###Hardware
Two interfaces that support sriov and dpdk feature and at least with two ports on each linux server

###Software
RHEL7 OR RHEL8 SYSTEM with extras fast data path repo or Appstrem for rhel8
dpdk and dpdk-tools packeage must installed.

## Setup the TRex traffic generator
One of the two machines we will use for the TRex traffic generator. 


Please check out the [TRex Installation Manual](https://trex-tgn.cisco.com/trex/doc/trex_manual.html#_download_and_installation)
for the minimal system requirements to run TRex. For example having a Haswell
or newer CPU. Also, do not forget to enable VT-d in the BIOS



### Register Red Hat Enterprise Linux
We continue here right after installing Red Hat Enterprise Linux. First need to
register the system, so we can download all the packages we need:

```
# subscription-manager register
Registering to: subscription.rhsm.redhat.com:443/subscription
Username: user@domain.com
Password:
The system has been registered with ID: xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxxxx

# subscription-manager attach --pool=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Successfully attached a subscription for: xxxxxxxxxxxxxxxxxx
```


### Install the packages we need
We need _"Red Hat Enterprise Linux Fast Datapath 7"_ for the DPDK package.
If you do not have access to these repositories, please contact your Red Had
representative.

```
subscription-manager repos --enable=rhel-7-fast-datapath-rpms
```


Add the epel repository for some of the python packages:

```
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```

Add the extras channel for the dpdk-tools package:

```
subscription-manager repos --enable rhel-7-server-extras-rpms
```

Now we can install the packages we need:

```
yum -y clean all
yum -y update
yum -y install dpdk dpdk-tools emacs gcc git lshw pciutils python-devel \
               python-setuptools python-pip tmux \
               tuned-profiles-cpu-partitioning wget
```


### Tweak the kernel
Rather than using the default 2M huge pages we configure 32 1G pages. You can
adjust this to your system's specifications. In this step we also enable iommu
needed by some of the DPDK PMD drivers used by TRex:

```
sed -i -e 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="default_hugepagesz=1G hugepagesz=1G hugepages=32 iommu=pt intel_iommu=on /'  /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
```

##Setup the TRex host to run the actual Client script
Mount the Git Repository for the Test Package
```
cd ~
git clone https://github.com/wanghekai/sriov-dpdk.git
```

###Configure the Client script
Modify the file /root/sriov-dpdk/sriov_dpdk_pft/rh_sriov_test_main.sh
Set the Host names for the Client and Server System. The Server is the DUT and the Client the T-Rex
```
#HOST NAME CONFIG , INPUT YOUR HOSTNAME FOR TEST
#SERVERS AS DUT SERVER
#CLIENTS AS TREX TRAFFIC GENERATOR
SERVERS="boston.redhat.com"
CLIENTS="london.redhat.com"
```
###Identify the interface MAC address for the script will be using.

```
#CONFIG THE MAC ADDRESS OF INTERFACE BY TESTED
SERVER_NIC1_MAC='a0:36:9f:65:ee:b4'
SERVER_NIC2_MAC='a0:36:9f:65:ee:b6'
CLIENT_NIC1_MAC='90:e2:ba:cb:ab:28'
CLIENT_NIC2_MAC='90:e2:ba:cb:ab:29'
```
###Set the other test parameters as you have configured.
```
#CONFIG DUT SERVER NIC DRIVER
NIC_DRIVER="ixgbe"
#CONFIG RHEL VERSION 
SYSTEM_VERSION="RHEL-7.7-20190514"

TREX_SERVER_IP=$CLIENTS
#CONFIG YOUR TREX HOST PASSWORD
TREX_SERVER_PASSWORD='redhat'

#TREX TAR PACKAGE 
#HERE IS OFFICAL URL LINK https://trex-tgn.cisco.com/trex/release/
TREX_URL='https://trex-tgn.cisco.com/trex/release/v2.46.tar.gz’'
#GUEST IMAGE FILE
IMAGE_GUEST="http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel${SYSTEM_VERSION:5:3}-vsperf-1Q-viommu.qcow2"
```
###Identify URL locations for Drivers for testing.
```
DRIVERCTL_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/driverctl/0.108/1.el7_6/noarch/driverctl-0.108-1.el7_6.noarch.rpm"
DPDK_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/4.el7_6/x86_64/dpdk-18.11-4.el7_6.x86_64.rpm"
DPDK_TOOL_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/4.el7_6/x86_64/dpdk-tools-18.11-4.el7_6.x86_64.rpm"
DPDK_VERSION=18.11-4

```
### Install Packages needed to T-Rex
Running the Script will identify missing pacakages and install T-rex. You will still need to stop the script 
if you have not completed the T-Rex setup and reboot for Huge pages to be enabled.
```
cd /root/sriov-dpdk/sriov_dpdk_pft
./rh_sriov_test_main.sh
```



###Next step is to configure TRex:

```
# cd /root/sriov-dpdk/sriov_dpdk_pft/v2.49
# ./dpdk_setup_ports.py -i
By default, IP based configuration file will be created. Do you want to use MAC based config? (y/N)y
+----+------+---------+-------------------+------------------------------------------------+-----------+-----------+----------+
| ID | NUMA |   PCI   |        MAC        |                      Name                      |  Driver   | Linux IF  |  Active  |
+====+======+=========+===================+================================================+===========+===========+==========+
| 0  | 0    | 01:00.0 | 24:6e:96:3c:4b:c0 | 82599ES 10-Gigabit SFI/SFP+ Network Connection | ixgbe     | em1       |          |
+----+------+---------+-------------------+------------------------------------------------+-----------+-----------+----------+
| 1  | 0    | 01:00.1 | 24:6e:96:3c:4b:c2 | 82599ES 10-Gigabit SFI/SFP+ Network Connection | ixgbe     | em2       |          |
+----+------+---------+-------------------+------------------------------------------------+-----------+-----------+----------+
| 2  | 0    | 07:00.0 | 24:6e:96:3c:4b:c4 | I350 Gigabit Network Connection                | igb       | em3       | *Active* |
+----+------+---------+-------------------+------------------------------------------------+-----------+-----------+----------+
| 3  | 0    | 07:00.1 | 24:6e:96:3c:4b:c5 | I350 Gigabit Network Connection                | igb       | em4       |          |
+----+------+---------+-------------------+------------------------------------------------+-----------+-----------+----------+
Please choose even number of interfaces from the list above, either by ID , PCI or Linux IF
Stateful will use order of interfaces: Client1 Server1 Client2 Server2 etc. for flows.
Stateless can be in any order.
Enter list of interfaces separated by space (for example: 1 3) : 0 1

For interface 0, assuming loopback to it's dual interface 1.
Destination MAC is 24:6e:96:3c:4b:c2. Change it to MAC of DUT? (y/N).
For interface 1, assuming loopback to it's dual interface 0.
Destination MAC is 24:6e:96:3c:4b:c0. Change it to MAC of DUT? (y/N).
Print preview of generated config? (Y/n)y
### Config file generated by dpdk_setup_ports.py ###

- port_limit: 2
  version: 2
  interfaces: ['01:00.0', '01:00.1']
  port_info:
      - dest_mac: 24:6e:96:3c:4b:c2 # MAC OF LOOPBACK TO IT'S DUAL INTERFACE
        src_mac:  24:6e:96:3c:4b:c0
      - dest_mac: 24:6e:96:3c:4b:c0 # MAC OF LOOPBACK TO IT'S DUAL INTERFACE
        src_mac:  24:6e:96:3c:4b:c2

  platform:
      master_thread_id: 0
      latency_thread_id: 27
      dual_if:
        - socket: 0
          threads: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]


Save the config to file? (Y/n)y
Default filename is /etc/trex_cfg.yaml
Press ENTER to confirm or enter new file:
Saved to /etc/trex_cfg.yaml.
```

As we would like to run the performance script on this machine, we decided
to not dedicate all CPUs to TRex. Below you see what we changed in the
/etc/trex_cfg.yaml file to exclude threads 1-3:

```
    threads: [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]
```


### Tweak the system for TRex usage
We know which threads will be used by TRex, let's dedicate them to this task.
We do this by applying the cpu-partitioning profile and configure the isolated
core mask:

```
systemctl enable tuned
systemctl start tuned
echo isolated_cores=4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26 >> /etc/tuned/cpu-partitioning-variables.conf
tuned-adm profile cpu-partitioning
```

Now it's time to reboot the machine to active the isolated cores and use the
configured 1G huge pages:

```
# reboot
```


### Start the Client Script
Now we're ready to start the TRex server in a tmux session, so we can look at
the console if we want to:

```
cd /root/sriov-dpdk/sriov_dpdk_pft
./rh_sriov_test_main.sh
```



## Setup the Device Under Test (DUT), Client Device


### Register Red Hat Enterprise Linux
As with the TRex system we first need to register the system:

```
# subscription-manager register
Registering to: subscription.rhsm.redhat.com:443/subscription
Username: user@domain.com
Password:
The system has been registered with ID: xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxxxx

# subscription-manager attach --pool=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Successfully attached a subscription for: xxxxxxxxxxxxxxxxxx
```


### Add the packages we need
We need _"Red Hat Enterprise Linux Fast Datapath 7"_ for Open vSwitch,
_"RHEL Extras"_ for dpdk rpms, and _"Red Hat Virtualization 4"_
for Qemu. If you do not have access to these repositories, please contact
your Red Had representative.

```
subscription-manager repos --enable=rhel-7-fast-datapath-rpms
subscription-manager repos --enable=rhel-7-server-rhv-4-mgmt-agent-rpms
subscription-manager repos --enable rhel-7-server-extras-rpms
subscription-manager repos --enable rhel-7-server-optional-rpms
```


Add the epel repository for sshpass and others:

```
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```


###Now we can install the packages we need:

```
yum -y clean all
yum -y update
yum -y install aspell aspell-en autoconf automake bc checkpolicy \
               desktop-file-utils dpdk dpdk-tools driverctl emacs gcc \
               gcc-c++ gdb git graphviz groff hwloc intltool kernel-devel \
               libcap-ng libcap-ng-devel libguestfs libguestfs-tools-c libtool \
               libvirt lshw openssl openssl-devel openvswitch procps-ng python \
               python-six python-twisted-core python-zope-interface \
               qemu-kvm-rhev rpm-build selinux-policy-devel sshpass sysstat \
               systemd-units tcpdump time tmux tuned-profiles-cpu-partitioning \
               virt-install virt-manager wget
```



### Tweak the system for OVS-DPDK and Qemu usage
There is work in progress for Open vSwitch DPDK to play nicely with SELinux,
but for now, the easiest way is to disable it:

```
sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
setenforce permissive
```


Rather than using the default 2M huge pages we configure 32 1G pages. You can
adjust this to your system's specifications. In this step we also enable iommu
needed by the DPDK PMD driver:

```
sed -i -e 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="default_hugepagesz=1G hugepagesz=1G hugepages=32 iommu=pt intel_iommu=on/'  /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
```


Our system is a single NUMA node using Hyper-Threading and we would like to
use the first Hyper-Threading pair for system usage. The remaining threads
we would like dedicate to Qemu and Open vSwitch.


__NOTE__ that if you have a multi-NUMA system the cores you assign to both Open
vSwitch and Qemu need to be one same NUMA node as the network card. For some
more background information on this see the [OVS-DPDK Parameters: Dealing with
multi-NUMA](https://developers.redhat.com/blog/2017/06/28/ovs-dpdk-parameters-dealing-with-multi-numa/)
blog post.


To figure out the numbers of threads, and the first thread pair we execute
the following:

```
# lscpu |grep -E "^CPU\(s\)|On-line|Thread\(s\) per core"
CPU(s):                28
On-line CPU(s) list:   0-27
Thread(s) per core:    2

# lstopo-no-graphics
Machine (126GB)
  Package L#0 + L3 L#0 (35MB)
    L2 L#0 (256KB) + L1d L#0 (32KB) + L1i L#0 (32KB) + Core L#0
      PU L#0 (P#0)
      PU L#1 (P#14)
    L2 L#1 (256KB) + L1d L#1 (32KB) + L1i L#1 (32KB) + Core L#1
      PU L#2 (P#1)
      PU L#3 (P#15)
    L2 L#2 (256KB) + L1d L#2 (32KB) + L1i L#2 (32KB) + Core L#2
      ...
      ...
```


Now we apply the cpu-partitioning profile, and configure the isolated
core mask:

```
systemctl enable tuned
systemctl start tuned
echo isolated_cores=1-13,15-27 >> /etc/tuned/cpu-partitioning-variables.conf
tuned-adm profile cpu-partitioning
```
<a name="isolcpus"/>

In addition, we would also like to remove these CPUs from the  SMP balancing
and scheduler algroithms. With the tuned cpu-partitioning starting with version
2.9.0-1 this can be done with the no_balance_cores= option. As this is not yet
available to us, we have to do this using the isolcpus option on the kernel
command line. This can be done as follows:

```
sed -i -e 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="isolcpus=1-13,15-27 /'  /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
```


Now it's time to reboot the machine to active the isolated cores, and use the
configured 1G huge pages:

```
# reboot
...
# cat /proc/cmdline
BOOT_IMAGE=/vmlinuz-3.10.0-693.1.1.el7.x86_64 root=/dev/mapper/rhel_wsfd--netdev67-root ro default_hugepagesz=1G hugepagesz=1G hugepages=4 crashkernel=auto rd.lvm.lv=rhel_wsfd-netdev67/root rd.lvm.lv=rhel_wsfd-netdev67/swap console=ttyS1,115200 nohz=on nohz_full=1-13,15-27 rcu_nocbs=1-13,15-27 tuned.non_isolcpus=00004001 intel_pstate=disable nosoftlockup
```


###Configure the Server script
Mount the Git Repository for the Test Package
```
cd ~
git clone https://github.com/wanghekai/sriov-dpdk.git
```

###Modify the file /root/sriov-dpdk/sriov_dpdk_pft/rh_sriov_test_main.sh

Set the Host names for the Client and Server System. The Server is the DUT and the Client the T-Rex
```
#HOST NAME CONFIG , INPUT YOUR HOSTNAME FOR TEST
#SERVERS AS DUT SERVER
#CLIENTS AS TREX TRAFFIC GENERATOR
SERVERS="boston.redhat.com"
CLIENTS="london.redhat.com"
```
###Identify the interface MAC address for the script will be using.
```

#CONFIG THE MAC ADDRESS OF INTERFACE BY TESTED
SERVER_NIC1_MAC='a0:36:9f:65:ee:b4'
SERVER_NIC2_MAC='a0:36:9f:65:ee:b6'
CLIENT_NIC1_MAC='90:e2:ba:cb:ab:28'
CLIENT_NIC2_MAC='90:e2:ba:cb:ab:29'
```
###Set the other test parameters as you have configured.
```
#CONFIG DUT SERVER NIC DRIVER
NIC_DRIVER="ixgbe"
#CONFIG RHEL VERSION 
SYSTEM_VERSION="RHEL-7.7-20190514.0"

TREX_SERVER_IP=$CLIENTS
#CONFIG YOUR TREX HOST PASSWORD
TREX_SERVER_PASSWORD='redhat'

#TREX TAR PACKAGE 
#HERE IS OFFICAL URL LINK https://trex-tgn.cisco.com/trex/release/
TREX_URL='https://trex-tgn.cisco.com/trex/release/v2.46.tar.gz’'
#GUEST IMAGE FILE
IMAGE_GUEST="http://netqe-bj.usersys.redhat.com/share/tli/vsperf_img/rhel${SYSTEM_VERSION:5:3}-vsperf-1Q-viommu.qcow2"
```
###Identify URL locations for Drivers for testing.
```
DRIVERCTL_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/driverctl/0.108/1.el7_6/noarch/driverctl-0.108-1.el7_6.noarch.rpm"
DPDK_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/4.el7_6/x86_64/dpdk-18.11-4.el7_6.x86_64.rpm"
DPDK_TOOL_URL="http://download-node-02.eng.bos.redhat.com/brewroot/packages/dpdk/18.11/4.el7_6/x86_64/dpdk-tools-18.11-4.el7_6.x86_64.rpm"
DPDK_VERSION=18.11-4
```




##Run the Test Script

###Start the T-Rex client script on the client system
```
/root/sriov-dpdk/sriov_dpdk_pft/rh_sriov_test_main.sh
```

###Start the Server side script on the server system
```
/root/sriov-dpdk/sriov_dpdk_pft/rh_sriov_test_main.sh
```

The default settings will run all the tests and place a log file with the results in ~/RHEL_NIC_QUAL_LOGS

##Analyzing The Results

```
::   RESULT: PASS (SRIOV DPDK PFT ENV INIT START)
::   RESULT: PASS (sriov test testpmd loopback mode)
::   RESULT: PASS (sriov_test_pf_remote)
::   RESULT: PASS (sriov_test_vf_remote)
::   RESULT: PASS (sriov_test_vmvf_remote)
::   RESULT: PASS (SRIOV DPDK PFT ENV INIT START)
::   RESULT: PASS (sriov test testpmd loopback mode)
::   RESULT: PASS (sriov_test_pf_remote)
::   RESULT: PASS (sriov_test_vf_remote)
::   RESULT: PASS (sriov_test_vmvf_remote)
::   OVERALL RESULT: PASS 
```
