MAKE?=make
TARGETS=appjail-config \
		get_assigned_rulesets \
		find-smallest-missing-number \
		find-number-from-start \
		getservbyname \
		ipcheck \
		network

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
