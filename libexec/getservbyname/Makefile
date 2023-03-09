TARGET=getservbyname
RM?=rm
STRIP_CMD?=strip

all: ${TARGET}

${TARGET}: ${TARGET}.c
	${CC} ${CFLAGS} -o ${TARGET} ${.ALLSRC}

clean:
	${RM} -f ${TARGET}

strip: ${TARGET}
	${STRIP_CMD} ${TARGET}
