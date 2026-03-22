EAPI=8

DESCRIPTION="A silent and clean SDDM theme (Qt6)"
HOMEPAGE="https://github.com/uiriansan/SilentSDDM"
SRC_URI="https://github.com/uiriansan/SilentSDDM/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
    >=x11-misc/sddm-0.21
    >=dev-qt/qtbase-6.5:6[gui,widgets]
    dev-qt/qtdeclarative:6
    dev-qt/qtmultimedia:6[qml]
    dev-qt/qtsvg:6
    dev-qt/qtvirtualkeyboard:6
"

S="${WORKDIR}/SilentSDDM-${PV}"

src_install() {
    insinto /usr/share/sddm/themes/silent
    doins -r *

    if [[ -d "fonts" ]]; then
        insinto /usr/share/fonts/silentsddm
        doins fonts/*
    fi
}

pkg_postinst() {
    # Refresh the font cache so the theme can use its custom fonts immediately
    einfo "Updating font cache..."
    fc-cache -f /usr/share/fonts/silentsddm

    # Configuration instructions
    elog "To enable SilentSDDM, create or edit /etc/sddm.conf.d/theme.conf:"
    elog ""
    elog "[General]"
    elog "InputMethod=qtvirtualkeyboard"
    elog "GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard"
    elog ""
    elog "[Theme]"
    elog "Current=silent"
}