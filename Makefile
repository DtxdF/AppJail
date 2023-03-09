CP?=cp
INSTALL?=install
MKDIR?=mkdir
RM?=rm
SED?=sed
PREFIX?=/usr/local

all: install

install: utils-strip
	# Directories.
	${MKDIR} -p "${DESTDIR}${PREFIX}/bin"
	${MKDIR} -p "${DESTDIR}${PREFIX}/share/appjail"
	${MKDIR} -p "${DESTDIR}${PREFIX}/etc"
	${MKDIR} -p "${DESTDIR}${PREFIX}/etc/rc.d"
	
	# rc scripts.
.for rc_script in appjail appjail-natnet
	${INSTALL} -m 555 etc/rc.d/${rc_script}.sh "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
.endfor

	# Scripts.
	${INSTALL} -m 555 appjail.sh "${DESTDIR}${PREFIX}/bin/appjail"
	${INSTALL} -m 555 share/appjail/scripts/dns.sh "${DESTDIR}${PREFIX}/bin/appjail-dns"

	# Files.
.for folder in cmd files lib makejail scripts
	${CP} -R share/appjail/${folder} "${DESTDIR}${PREFIX}/share/appjail"
.endfor
	
	# Prefix.
.for f in bin/appjail share/appjail/files/config.conf share/appjail/files/default.conf 
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/${f}"
.endfor

	# Examples.
	${CP} -R share/examples "${DESTDIR}${PREFIX}/share"

	# Utils.
.for util in getservbyname ipcheck network
	${MKDIR} -p "${DESTDIR}${PREFIX}/libexec/appjail/${util}"
	${CP} libexec/${util}/${util} "${DESTDIR}${PREFIX}/libexec/appjail/${util}/${util}"
.endfor

utils-strip:
	@${MAKE} -C libexec strip

uninstall:
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-natnet"
	${RM} -rf "${DESTDIR}${PREFIX}/share/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/share/examples/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/libexec/appjail"
