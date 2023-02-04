MAKE?=make
TARGETS=getservbyname ipcheck network

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
