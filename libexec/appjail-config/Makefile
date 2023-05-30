CC?=		cc
CFLAGS+=	-Wall -Wextra -Wsign-compare -Wsign-conversion -pedantic -ansi -std=c17
RM?=		rm
STRIP_CMD?=	strip
TARGETS=	tok appjail-config
COMMANDS=	cmd_check.o \
			cmd_edit.o \
			cmd_delAll.o \
			cmd_delColumn.o \
			cmd_del.o \
			cmd_getAll.o \
			cmd_getColumn.o \
			cmd_get.o \
			cmd_help.o \
			cmd_jailConf.o \
			cmd_setColumn.o \
			cmd_set.o \
			cmd_usage.o

all: ${TARGETS}

tok: ${.PREFIX}.c buff.o except.o overflow.o word.o
	${CC} ${CFLAGS} ${.ALLSRC} -o ${.PREFIX}

word.o: word.h worderr.h buff.o except.o

buff.o: buff.h bufferr.h except.o overflow.o

appjail-config: config.c buff.o commands.o cmd.o except.o template.o overflow.o parameters.o util.o word.o ${COMMANDS}
	${CC} ${CFLAGS} ${.ALLSRC} -o ${.PREFIX}

commands.o: commands.h ${COMMANDS}

cmd_check.o: cmd_check.h

cmd_edit.o: cmd_edit.h

cmd_delAll.o: cmd_delAll.h

cmd_delColumn.o: cmd_delColumn.h

cmd_del.o: cmd_del.h

cmd_getAll.o: cmd_getAll.h

cmd_getColumn.o: cmd_getColumn.h

cmd_get.o: cmd_get.h

cmd_help.o: cmd_help.h

cmd_setColumn.o: cmd_setColumn.h

cmd_set.o: cmd_set.h

cmd_usage.o: cmd_usage.h

cmd.o: cmd.h cmderr.h except.o overflow.o

template.o: template.h templateerr.h buff.o except.o parameters.o util.o word.o

parameters.o: parameters.h

util.o: util.h buff.o except.o

except.o: except.h overflow.o

overflow.o: overflow.h

clean:
	${RM} -f *.o

cleanall: clean
	${RM} -f ${TARGETS}

strip: appjail-config tok
.for p in ${TARGETS}
	${STRIP_CMD} ${p}
.endfor
