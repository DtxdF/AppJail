MAKE?=make
TARGETS=appjail-config getservbyname ipcheck network

all:
.for target in ${TARGETS}
	@${MAKE} -C ${target}
.endfor

strip:
.for target in ${TARGETS}
	@${MAKE} -C ${target} strip
.endfor

clean:
.for target in ${TARGETS}
	@${MAKE} -C ${target} clean
.endfor

cleanall:
.for target in ${TARGETS}
	@${MAKE} -C ${target} cleanall
.endfor
