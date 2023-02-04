CP?=cp
INSTALL?=install
MKDIR?=mkdir
RM?=rm
SED?=sed
PREFIX?=/usr/local

all: install

install: utils-strip
	${MKDIR} -p "${DESTDIR}${PREFIX}/bin"
	${MKDIR} -p "${DESTDIR}${PREFIX}/share/appjail"
	${INSTALL} -d -m 750 "${DESTDIR}${PREFIX}/appjail"
	${MKDIR} -p "${DESTDIR}${PREFIX}/etc"
	${INSTALL} -d -m 750 "${DESTDIR}${PREFIX}/etc/appjail"
	${MKDIR} -p "${DESTDIR}${PREFIX}/etc/rc.d"
.for rc_script in appjail appjail-natnet
	${INSTALL} -m 555 etc/rc.d/${rc_script}.sh "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
	${SED} -i '' -e 's|%%PREFIX%%|${DESTDIR}${PREFIX}|' "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
.endfor
	${INSTALL} -m 555 appjail.sh "${DESTDIR}${PREFIX}/bin/appjail"
	${INSTALL} -m 555 share/appjail/scripts/dns.sh "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${SED} -i '' -e '/^APPJAIL_PROGRAM=/s|=.*|=\"${DESTDIR}${PREFIX}/bin/appjail\"|' "${DESTDIR}${PREFIX}/bin/appjail"
	${SED} -i '' -e '/^CONFIG=/s|=.*|=\"${DESTDIR}${PREFIX}/etc/appjail/appjail.conf\"|' "${DESTDIR}${PREFIX}/bin/appjail"
	${INSTALL} -m 640 etc/appjail/appjail.conf "${DESTDIR}${PREFIX}/etc/appjail/appjail.conf.sample"
	${SED} -i '' -e '/^PREFIX=/s|=.*|=\"${DESTDIR}${PREFIX}\"|' "${DESTDIR}${PREFIX}/etc/appjail/appjail.conf.sample"
.for folder in cmd files lib makejail scripts
	${CP} -R share/appjail/${folder} "${DESTDIR}${PREFIX}/share/appjail"
.endfor
	${CP} -R share/examples "${DESTDIR}${PREFIX}/share"
.for util in getservbyname ipcheck network
	${MKDIR} -p "${DESTDIR}${PREFIX}/share/appjail/util/${util}"
	${CP} share/appjail/util/${util}/${util} "${DESTDIR}${PREFIX}/share/appjail/util/${util}/${util}"
.endfor

utils-strip:
	@${MAKE} -C share/appjail/util strip

uninstall:
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-natnet"
	${RM} -f "${DESTDIR}${PREFIX}/etc/appjail/appjail.conf.sample"
	${RM} -rf "${DESTDIR}${PREFIX}/share/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/share/examples/appjail"
