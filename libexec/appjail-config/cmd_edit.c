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
#include <errno.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <sys/wait.h>
#include <unistd.h>

#include "commands.h"
#include "template.h"
#include "templateerr.h"
#include "except.h"
#include "util.h"

#define CMD_EDIT_TRBCK(trbck) \
    do { \
        except_addsf(EX_SOFTWARE, NULL, trbck); \
        return EX_SOFTWARE; \
    } while (0)


static int  edit_file(const char *f);

static inline void  freeall(void);

static void     mutually_exclusive(int c1, int c2);

static void     usage(void);

/* Template */
static char *template_file;

/* Jail name */
static char *jail_name;

int
command_cmd_edit(int argc, char **argv, int argi)
{
    int c;
    bool jflag = false,
         tflag = false;

    optind = argi;

    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    while ((c = getopt(argc, argv, ":j:t:")) != -1) {
        switch (c) {
        case 'j':
            jflag = true;
            jail_name = safe_strdup(optarg);
            break;
        case 't':
            tflag = true;
            template_file = safe_strdup(optarg);
            break;
        default:
            usage();
        }
    }

    /* Mandatory arguments. */
    if (!jflag && !tflag) {
        usage();
    }

    /* Mutually exclusive. */
    if (jflag && tflag) {
        mutually_exclusive('j', 't');
    }

    /* Use jail's template as the template file. */
    if (jflag) {
        /* Check for an invalid jail name. */
        if (!test_jailname(jail_name)) {
            fprintf(stderr, "Invalid jail name: %s\n",
                jail_name);
            return EX_DATAERR;
        }

        template_file = get_jail_template(jail_name);
    }

    return edit_file(template_file);
}

static int
edit_file(const char *f)
{
    int errcode = EXIT_SUCCESS;

    char *e = getenv("EDITOR");
    if (e == NULL)
        e = CMD_EDIT_EDITOR;

    pid_t p;

    switch ((p = fork())) {
    case -1:
        err(EX_OSERR, "fork()");
        break;
    case 0:
        if (execlp(e, e, f, NULL) == -1)
            err(EX_SOFTWARE, "execlp()");
        break;
    default: {
            int stat_val;

            if (wait(&stat_val) == -1)
                err(EX_SOFTWARE, "wait()");

            if (WIFEXITED(stat_val) != 0)
                errcode = WEXITSTATUS(stat_val);
        }
    }

    return errcode;
}

static inline void
freeall(void)
{
    free(jail_name);
    free(template_file);
}

void
command_help_edit(void)
{
    command_usage_edit();

    fprintf(stderr, "\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -j <jail>            -- Use the jail's template..\n");
    fprintf(stderr, "    -t <template>        -- Use the specified template.\n");
}

static void
mutually_exclusive(int c1, int c2)
{
    fprintf(stderr, "Options `-%c` and `-%c` are mutually exclusive.\n",
        c1, c2);
    exit(EX_DATAERR);
}

static void
usage(void)
{
    command_usage_edit();
    exit(EX_USAGE);
}

void
command_usage_edit(void)
{
    fprintf(stderr, "usage: edit [-j <jail>|-t <template>]\n");
}
