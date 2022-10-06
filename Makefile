CHMOD?=chmod
CP?=cp
INSTALL?=install
CHOWN?=chown
MKDIR?=mkdir
SED?=sed
RM?=rm
PW?=pw
PREFIX?=/usr/local
APPJAIL_USER?=appjail
APPJAIL_GROUP?=appjail

all: install

install:
	${MKDIR} -p "${DESTDIR}${PREFIX}/bin"
	${MKDIR} -p "${DESTDIR}${PREFIX}/share"
	${INSTALL} -d -g ${APPJAIL_GROUP} -o ${APPJAIL_USER} -m 770 "${DESTDIR}${PREFIX}/appjail"
	${MKDIR} -p "${DESTDIR}${PREFIX}/etc"
	${INSTALL} -d -g ${APPJAIL_GROUP} -o ${APPJAIL_USER} -m 770 "${DESTDIR}${PREFIX}/etc/appjail"
	${INSTALL} -d -g ${APPJAIL_GROUP} -o ${APPJAIL_USER} -m 770 "${DESTDIR}${PREFIX}/etc/appjail/templates"
	${INSTALL} -g ${APPJAIL_GROUP} -o ${APPJAIL_USER} -m 755 appjail.sh "${DESTDIR}${PREFIX}/bin/appjail"
	${SED} -i '' -e '/^CONFIG=/s|=.*|=\"${DESTDIR}${PREFIX}/etc/appjail/appjail.conf\"|' "${DESTDIR}${PREFIX}/bin/appjail"
	${INSTALL} -g ${APPJAIL_GROUP} -o ${APPJAIL_USER} -m 660 etc/appjail/appjail.conf "${DESTDIR}${PREFIX}/etc/appjail/appjail.conf.sample"
	${SED} -i '' -e '/^PREFIX=/s|=.*|=\"${DESTDIR}${PREFIX}\"|' "${DESTDIR}${PREFIX}/etc/appjail/appjail.conf.sample"
	${CP} -a share/* "${DESTDIR}${PREFIX}/share"
	${CHOWN} -R ${APPJAIL_USER}:${APPJAIL_GROUP} "${DESTDIR}${PREFIX}/share/appjail"
	${CHOWN} -R ${APPJAIL_USER}:${APPJAIL_GROUP} "${DESTDIR}${PREFIX}/share/examples/appjail"

uninstall:
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/share/appjail"

create_user:
	${PW} groupadd -n ${APPJAIL_GROUP}
	${PW} useradd -n ${APPJAIL_USER} -c "Simple and easy-to-use tool for creating portable jails" -d /nonexistent -g ${APPJAIL_GROUP} -s /usr/sbin/nologin
