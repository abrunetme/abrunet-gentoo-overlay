EAPI=8

# linux-mod-r1 : handles out-of-tree kernel modules
# udev         : handles device rules and permissions
inherit linux-mod-r1 udev

DESCRIPTION="Kernel module for MSI Embedded Controller driver"
HOMEPAGE="https://github.com/abrunetme/msi-ec"
SHA="17bd0d9604503eac22cd76bce42165a37886ea7f"
SRC_URI="https://github.com/abrunetme/msi-ec/archive/${SHA}.tar.gz -> ${P}-${SHA:0:7}.tar.gz"
S="${WORKDIR}/${PN}-${SHA}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+debugfs +udev"

# Dependencies
DEPEND="virtual/linux-sources"
RDEPEND="
	${DEPEND}
	udev? ( virtual/udev )
"

src_compile() {
	# Setup module list for compilation
	local modlist=( msi-ec=misc )
	local modargs=( KDIR="${KERNEL_DIR}" )

	linux-mod-r1_src_compile
}

src_install() {
	# 1. Install the kernel module (.ko)
	linux-mod-r1_src_install

	# 2. Configure Debug interface and module options
	if use debugfs; then
		insinto /etc/modprobe.d
		newins - msi-ec-debug.conf <<-EOF
			# Enable register access via /sys/devices/platform/msi-ec/debug/
			options msi-ec debug=1
		EOF
	fi

	# 3. Blacklist msi-wmi to prevent control conflicts
	insinto /etc/modprobe.d
	newins - msi-ec-blacklist.conf <<-EOF
		# Conflict with msi-ec regarding fan and LED control
		blacklist msi-wmi
	EOF

	# 4. UDEV rule for non-root access
	if use udev; then
		# Install udev rule to allow 'wheel' group to write to EC registers
		# This allows running fan scripts without sudo
		insinto "$(get_udevdir)"/rules.d
		newins - 99-msi-ec.rules << 'EOF'
# Allow wheel group to modify EC registers (Fixing Directory Traversing)
ACTION=="add|change", SUBSYSTEM=="platform", DRIVER=="msi-ec", \
  RUN+="/bin/chgrp -R wheel /sys/devices/platform/msi-ec/", \
  RUN+="/usr/bin/find /sys/devices/platform/msi-ec/ -type d -exec /bin/chmod 775 {} +", \
  RUN+="/usr/bin/find /sys/devices/platform/msi-ec/ -type f -exec /bin/chmod 664 {} +"
EOF
	fi

	# 5. Load module automatically at boot
	insinto /etc/modules-load.d
	newins - msi-ec.conf <<-EOF
		msi-ec
	EOF
}

pkg_postinst() {
	# Reload udev rules if flag is active
	if use udev; then
		udev_reload

		ubegin "Triggering udev rules for msi-ec"
        udevadm trigger --subsystem-match=platform --attr-match=driver=msi-ec
        eend $?
	fi
	
	linux-mod-r1_pkg_postinst
	
	einfo "The msi-wmi module has been blacklisted to prevent conflicts."
	einfo "If 'debug' USE flag is active, registers are accessible at:"
	einfo "/sys/devices/platform/msi-ec/debug/"
}

pkg_postrm() {
	if use udev; then
		udev_reload
	fi
}