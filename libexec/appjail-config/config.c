/*
 * Copyright (c) 2022-2023, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <err.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>

#include "commands.h"
#include "cmd.h"
#include "cmderr.h"
#include "except.h"

#define CONFIG_TRBCK(trbck) except_addsf(EX_SOFTWARE, NULL, trbck)

/* Traceback exception */
traceback trbck; 

/* Commands */
cmdui cui;

static void     freeall(void);

int
main(int argc, char **argv)
{
    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    trbck = except_newtrbck();
    if (trbck == NULL)
        err(EX_OSERR, "except_newtrbck()");

    if (cmd_init(&cui, &trbck) != CDERRN) {
        CONFIG_TRBCK(&trbck);
        return EX_SOFTWARE;
    }

    for (size_t i = 0; i < command_total; i++) {
        unsigned int cmd_index = 0;
        if (cmd_new(cui, &cmd_index, &trbck) != CDERRN) {
            CONFIG_TRBCK(&trbck);
            return EX_SOFTWARE;
        }

        cmd c = cmd_get(cui, cmd_index - 1);

        if (cmd_setname(c, commands[i].name, &trbck) != CDERRN) {
            CONFIG_TRBCK(&trbck);
            return EX_SOFTWARE;
        }

        if (commands[i].isdefault)
            cmd_setdefault(c);

        cmd_setcmd(c, commands[i].cmd);
    }

    int errcode = EXIT_SUCCESS;
    if (cmd_run(cui, argc, argv, 1, &errcode, &trbck) != CDERRN) {
        CONFIG_TRBCK(&trbck);
        return EXIT_FAILURE;
    }

    return errcode;
}

static void
freeall(void)
{
    except_traceback(&trbck);
    cmd_free(&cui);
}
