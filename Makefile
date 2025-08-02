CP?=cp
FIND?=find
INSTALL?=install
MKDIR?=mkdir
RM?=rm
SED?=sed
PREFIX?=/usr/local
MANDIR?=${PREFIX}/share/man
MANPAGES=man1/appjail.1 \
	 man1/appjail-cpuset.1 \
	 man1/appjail-login.1 \
	 man1/appjail-version.1 \
	 man1/appjail-usage.1 \
	 man1/appjail-help.1 \
	 man7/appjail-tutorial.7 \
	 man1/appjail-zfs.1 \
	 man5/appjail.conf.5 \
	 man1/appjail-apply.1 \
	 man1/appjail-service.1 \
	 man1/appjail-sysrc.1 \
	 man1/appjail-pkg.1 \
	 man1/appjail-status.1 \
	 man1/appjail-cmd.1 \
	 man1/appjail-rstop.1 \
	 man1/appjail-startup.1 \
	 man1/appjail-restart.1 \
	 man8/appjail-user.8 \
	 man5/appjail-initscript.5 \
	 man1/appjail-start.1 \
	 man1/appjail-stop.1 \
	 man1/appjail-run.1 \
	 man1/appjail-checkOld.1 \
	 man1/appjail-deleteOld.1 \
	 man1/appjail-enable.1 \
	 man1/appjail-enabled.1 \
	 man1/appjail-disable.1 \
	 man1/appjail-etcupdate.1 \
	 man5/appjail-template.5 \
	 man5/appjail-ajspec.5 \
	 man1/appjail-logs.1 \
	 man8/appjail-dns.8 \
	 man1/appjail-quick.1 \
	 man1/appjail-jail.1 \
	 man1/appjail-volume.1 \
	 man1/appjail-expose.1 \
	 man1/appjail-limits.1 \
	 man1/appjail-config.1 \
	 man1/appjail-makejail.1 \
	 man1/appjail-image.1 \
	 man1/appjail-fstab.1 \
	 man1/appjail-fetch.1 \
	 man1/appjail-update.1 \
	 man1/appjail-upgrade.1 \
	 man7/appjail-ephemeral.7 \
	 man1/appjail-healthcheck.1 \
	 man1/appjail-devfs.1 \
	 man1/appjail-network.1 \
	 man1/appjail-nat.1 \
	 man5/appjail-makejail.5 \
	 man1/appjail-label.1 \
	 man1/appjail-oci.1

APPJAIL_VERSION?=4.2.0

all: install

install: utils-strip
	# Directories.
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/bin"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/etc"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/etc/rc.d"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/etc/bash_completion.d"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}"
	# Sections used by manual pages.
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man1"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man5"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man7"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man8"

	# man pages.
.for manpage in ${MANPAGES}
	${INSTALL} -m 444 share/man/${manpage} "${DESTDIR}${MANDIR}/${manpage}"
.endfor
	
	# rc scripts.
.for rc_script in appjail appjail-dns appjail-health appjail-natnet
	${INSTALL} -m 555 etc/rc.d/${rc_script}.sh "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
.endfor

	# completion scripts.
	${INSTALL} -m 555 share/appjail/scripts/appjail-completion.bash "${DESTDIR}${PREFIX}/etc/bash_completion.d/_appjail.bash"

	# Main script.
	${INSTALL} -m 555 appjail.sh "${DESTDIR}${PREFIX}/bin/appjail"

	# Wrappers & misc.
	${INSTALL} -m 555 share/appjail/scripts/dns.sh "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${INSTALL} -m 555 share/appjail/scripts/ajconf.sh "${DESTDIR}${PREFIX}/bin/appjail-config"
	${INSTALL} -m 555 share/appjail/scripts/ajuser.sh "${DESTDIR}${PREFIX}/bin/appjail-user"
	${INSTALL} -m 555 share/appjail/scripts/ajconf-user.sh "${DESTDIR}${PREFIX}/bin/appjail-config-user"

	# cmd
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/cmd"
	${FIND} share/appjail/cmd -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# files
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/files"
	${FIND} share/appjail/files -mindepth 1 -exec ${INSTALL} -m 444 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# lib
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/lib"
	${FIND} share/appjail/lib -mindepth 1 -exec ${INSTALL} -m 444 {} "${DESTDIR}${PREFIX}/{}" \;

	# version
	${SED} -i '' -e 's|%%VERSION%%|${APPJAIL_VERSION}|' "${DESTDIR}${PREFIX}/share/appjail/lib/version"
	
	# makejail
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/cmd"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/write"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/cmd/all"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/cmd/build"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/write/all"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/write/build"

	${FIND} share/appjail/makejail/cmd/all -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${FIND} share/appjail/makejail/cmd/build -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${FIND} share/appjail/makejail/write/all -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${FIND} share/appjail/makejail/write/build -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# scripts
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/scripts"
	${FIND} share/appjail/scripts -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# Prefix.
.for f in bin/appjail bin/appjail-config bin/appjail-config-user bin/appjail-user share/appjail/files/config.conf share/appjail/files/default.conf share/appjail/scripts/runas.sh share/appjail/scripts/ajuser.sh share/man/man7/appjail-tutorial.7 share/man/man5/appjail.conf.5 share/man/man8/appjail-dns.8
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/${f}"
.endfor

	# examples
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/examples/appjail"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/examples/appjail/templates"
	${FIND} share/examples/appjail/templates -mindepth 1 -exec ${INSTALL} -m 444 {} "${DESTDIR}${PREFIX}/{}" \;
	${INSTALL} -m 444 share/examples/appjail/appjail.conf "${DESTDIR}${PREFIX}/share/examples/appjail/appjail.conf"

	# utils
.for util in get_assigned_rulesets find-number-from-start find-smallest-missing-number getservbyname ipcheck network jexec
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/libexec/appjail/${util}"
	${INSTALL} -m 555 libexec/${util}/${util} "${DESTDIR}${PREFIX}/libexec/appjail/${util}/${util}"
.endfor
	# appjail-config & tok
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/libexec/appjail/appjail-config"
	${INSTALL} -m 555 libexec/appjail-config/appjail-config "${DESTDIR}${PREFIX}/libexec/appjail/appjail-config/appjail-config"
	${INSTALL} -m 555 libexec/appjail-config/tok "${DESTDIR}${PREFIX}/libexec/appjail/appjail-config/tok"

utils-strip:
	@${MAKE} -C libexec strip

utils-clean:
	@${MAKE} -C libexec clean

utils-cleanall:
	@${MAKE} -C libexec cleanall

clean: utils-clean

cleanall: utils-cleanall

uninstall:
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-config"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-config-user"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-user"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-dns"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-health"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-natnet"
	${RM} -rf "${DESTDIR}${PREFIX}/share/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/share/examples/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/libexec/appjail"
.for manpage in ${MANPAGES}
	${RM} -f "${DESTDIR}${MANDIR}/${manpage}"
.endfor
