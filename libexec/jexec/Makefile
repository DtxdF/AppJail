TARGET=jexec
CFLAGS+=-fno-common -fPIE -std=gnu99 -Wno-format-zero-length -fstack-protector-strong -Wsystem-headers -Werror -Wall -Wno-format-y2k -W -Wno-unused-parameter -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith -Wreturn-type -Wcast-qual -Wwrite-strings -Wswitch -Wshadow -Wunused-parameter -Wcast-align -Wchar-subscripts -Wnested-externs -Wold-style-definition -Wno-pointer-sign -Wdate-time -Wmissing-variable-declarations -Wthread-safety -Wno-empty-body -Wno-string-plus-int -Wno-unused-const-variable -Wno-error=unused-but-set-parameter -Qunused-arguments -Wl,-zrelro -pie
LDFLAGS+=-ljail -lutil
RM?=rm
STRIP_CMD?=strip

all: ${TARGET}

${TARGET}: ${TARGET}.c
	${CC} ${CFLAGS} ${LDFLAGS} -o ${TARGET} ${.ALLSRC}

clean:

cleanall: clean
	${RM} -f ${TARGET}

strip: ${TARGET}
	${STRIP_CMD} ${TARGET}
