# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Makefile of /kernel/networking/vnic/sriov_dpdk_pft
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


export TEST=/kernel/networking/vnic/sriov_dpdk_pft
export TESTVERSION=1.0

BUILT_FILES=

FILES=$(METADATA) \
	lib \
	common_sriov.py \
	console.py \
	cxgb4_sriov.py \
	env.sh  \
	guest.xml  \
	lib_sriov.py  \
	Makefile  \
	mlx_sriov.py  \
	PURPOSE  \
	rhos-release-13.repo  \
	runtest.sh  \
	sriov.py  \
	tools.py  \
	trex_sport.py \
	rh_sriov_test_main.sh \
	vmsh

.PHONY: all install download clean

run: $(FILES) build
	cp --remove-destination vmsh /usr/local/bin/
	./runtest.sh

update:
	mkdir -p ./lib/
	cp --remove-destination ../../common/lib/lib_nc_sync.sh ./lib/
	cp --remove-destination ../../common/lib/lib_utils.sh ./lib/
	cp --remove-destination ../../common/tools/vmsh ./


build: $(BUILT_FILES)
	test -x runtest.sh || chmod a+x runtest.sh

clean:
	rm -f *~ $(BUILT_FILES)


include /usr/share/rhts/lib/rhts-make.include

$(METADATA): Makefile
	@echo "Owner:           Qijun Ding <qding@redhat.com>" > $(METADATA)
	@echo "Name:            $(TEST)" >> $(METADATA)
	@echo "TestVersion:     $(TESTVERSION)" >> $(METADATA)
	@echo "Path:            $(TEST_DIR)" >> $(METADATA)
	@echo "Description:     SR-IOV DPDK PFT TEST CASE " >> $(METADATA)
	@echo "Type:            Tier1" >> $(METADATA)
	@echo "TestTime:        6h" >> $(METADATA)
	@echo "RunFor:          kernel" >> $(METADATA)
	@echo "Requires:        kernel" >> $(METADATA)
	@echo "RhtsRequires:    kernel-kernel-networking-common" >> $(METADATA)
	@echo "Priority:        Normal" >> $(METADATA)
	@echo "License:         GPLv2" >> $(METADATA)
	@echo "Confidential:    no" >> $(METADATA)
	@echo "Destructive:     no" >> $(METADATA)

	rhts-lint $(METADATA)
