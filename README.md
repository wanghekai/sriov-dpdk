# DPDK In Guest/SR-IOV Host/SR-IOV

DPDK In Guest/SR-IOV Host/SR-IOV

#OVERVIEW

    This project is to create a sriov dpdk host and guest automate case for customer on RHEL7(Extras) and RHEL8(Appstream)

#TOPO DESCRIPTION

    There must be two hosts as DUT devices ,one as server and another as client
    There is a switch between server and client as describe below

    SERVER <------> Tor switch <--------> CLIENT

#REQUIREMENT

#Hardware
    Two linux server with interfaces that support sriov and dpdk feature
#Software
    RHEL7 OR RHEL8 SYSTEM with extras fast data path repo or Appstrem for rhel8

#SETUP 
1. INSTALL SYSTEM ON EACH SERVER AND REGISTER YOUR CUSTOMER ACCOUNTS
2. INSTALL FAST DATA PATH 
3. PREPARE TEST 
There is a scripts for easy install for your test 
Just need config environment follow the readme and run the setup shell for dpdk and sriov feautre enable

#TEST CASE LIST 
1. SRIOV BASIC FUNCTIONAL TEST IN HOST
2. DPDK BASIC FUNCTIONAL TEST IN HOST
3. SRIOV VM FUNCTIONAL TEST IN VM 
4. DPDK VM FUNCTIONAL TEST IN VM 
5. SRIOV DPDK TESTPMD TEST IN HOST
6. SRIOV DPDK TESTPMD TEST IN VM 
7. MIGRATION TEST FOR SRIOV AND DPDK 
8. ETC ..

DETAIL TEST CASE LIST 
NEED FIX ME 