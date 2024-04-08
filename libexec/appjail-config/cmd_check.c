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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>

#include "commands.h"
#include "template.h"
#include "templateerr.h"
#include "except.h"
#include "util.h"

static inline void  freeall(void);

static void     mutually_exclusive(int c1, int c2);

static void     usage(void);

/* Traceback exception */
static traceback trbck;

/* Template */
static template t;
static char *template_file;

/* Jail name */
static char *jail_name;

int
command_cmd_check(int argc, char **argv, int argi)
{
    int c;
    bool qflag = false,
         jflag = false,
         tflag = false,
         Vflag = false;

    optind = argi;

    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    while ((c = getopt(argc, argv, ":qVj:t:")) != -1) {
        switch (c) {
        case 'q':
            qflag = true;
            break;
        case 'V':
            Vflag = true;
            break;
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
    
    /* Traceback exception. */
    trbck = except_newtrbck();
    if (trbck == NULL)
        err(EX_OSERR, "except_newtrbck()");

    /* Template. */
    int tperr;
    if ((tperr = template_init(template_file, &t, &trbck)) != TPERRN) {
        /* We are interested only in the syntax, but probably when the template
         * file does not exist, it is worth showing the error.
         */
        if (!qflag && tperr != TPERRS) {
            except_printerr(trbck);
        }
        /* Free `trbck` blocks using except_free() to avoid printing 
         * the traceback.
         */
        except_free(&trbck);
        return EX_SOFTWARE;
    }

    /* template_init() will evaluate the syntax and other related issues,
     * so no further work is necessary.
     */
    if (Vflag)
        return EXIT_SUCCESS;

    templateindex l, i;
    param p = NULL;
    char *k = NULL;
    bool invalid = false;

    for (l = template_getrows(t), i = 0; !invalid && i < l; i++) {
        p = template_getparam(t, i);

        if (template_isgarbage(p))
            continue;

        if (template_isvar(p))
            continue;

        k = template_getkey(p);
        if (!template_checkparam(k))
            invalid = true;
    }

    if (invalid) {
        if (!qflag) {
            fprintf(stderr, "Invalid parameter `%s` in `%s:%llu`\n",
                k, template_file, i);
        }
        return EX_DATAERR;
    } else {
        return EXIT_SUCCESS;
    }
}

static inline void
freeall(void)
{
    template_free(&t);
    free(jail_name);
    free(template_file);
    except_traceback(&trbck);
}

void
command_help_check(void)
{
    command_usage_check();

    fprintf(stderr, "\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -q                   -- If there is an error, a non-zero value is returned.\n");
    fprintf(stderr, "    -V                   -- Do not validate if the template's parameters are valid\n");
    fprintf(stderr, "                            against a list extracted from jail(8).\n");
    fprintf(stderr, "    -j <jail>            -- Use the jail's template.\n");
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
    command_usage_check();
    exit(EX_USAGE);
}

void
command_usage_check(void)
{
    fprintf(stderr, "usage: check [-qV] [-j <jail>|-t <template>]\n");
}
