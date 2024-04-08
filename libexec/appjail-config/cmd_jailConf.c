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
#include <stdbool.h>
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

#define CMD_JAILCONF_STREAM         stdout

#define CMD_JAILCONF_TRBCK(trbck) \
    do { \
        except_addsf(EX_SOFTWARE, NULL, trbck); \
        return EX_SOFTWARE; \
    } while (0)

static inline void  freeall(void);

static void     mutually_exclusive(int c1, int c2);

static void     usage(void);

/* Traceback exception */
static traceback trbck;

/* Template */
static template t;
static char *template_file;

/* Output */
static char *output_file;
static FILE *output_stream;

/* Jail name */
static char *name;
static char *jail_name;

int
command_cmd_jailConf(int argc, char **argv, int argi)
{
    int c;
    bool jflag = false,
         nflag = false,
         tflag = false;

    optind = argi;

    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    while ((c = getopt(argc, argv, ":j:n:o:t:")) != -1) {
        switch (c) {
        case 'j':
            jflag = true;
            jail_name = safe_strdup(optarg);
            break;
        case 'n':
            nflag = true;
            name = safe_strdup(optarg);
            break;
        case 'o':
            if (strcmp(optarg, "-") == 0)
                break; /* Use CMD_JAILCONF_STREAM. */
            output_file = safe_strdup(optarg);
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
    if ((!jflag && !tflag) \
        || (tflag && !nflag)) {
        usage();
    }

    /* Mutually exclusive. */
    if (jflag && tflag) {
        mutually_exclusive('j', 't');
    }

    if (!nflag)
        name = strdup(jail_name);

    /* Check for an invalid jail name used in the template. */
    if (!test_jailname(name)) {
        fprintf(stderr, "Invalid jail name: %s\n",
            name);
        return EX_DATAERR;
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

    if (template_init(template_file, &t, &trbck) != TPERRN) {
        except_printerr(trbck);
        /* Free `trbck` blocks using except_free() to avoid printing 
         * the traceback.
         */
        except_free(&trbck);
        return EX_SOFTWARE;
    }

    output_stream = CMD_JAILCONF_STREAM;
    if (output_file != NULL && (output_stream = fopen(output_file, "w")) == NULL) {
        CMD_JAILCONF_TRBCK(&trbck);
    }

    /* Line buffering. */
    if (output_stream != CMD_JAILCONF_STREAM)
        setlinebuf(output_stream);

    /* Start */
    fprintf(output_stream, "%s {\n", name);

    for (templatelen l = template_getrows(t), i = 0; i < l; i++) {
        param p = template_getparam(t, i);

        if (template_isgarbage(p))
            continue;

        if (template_isrequire(p)) {
            fprintf(stderr, "Cannot continue because `%s` is a required parameter.\n",
                template_getkey(p));
            return EX_DATAERR;
        }

        fprintf(output_stream, "    %s", template_getkey(p));

        wordlen l = template_getcolumns(p);
        if (l > 0) {
            fprintf(output_stream, " ");
            if (template_isappend(p))
                fprintf(output_stream, "+");
            fprintf(output_stream, "= ");

            for (wordindex c = 0; c < l; c++) {
                char *e;
                if ((e = escape_word(template_getcolumn(p, c), &trbck)) == NULL)
                    CMD_JAILCONF_TRBCK(&trbck);

                fprintf(output_stream, "%s", e);

                if (l > 1 && c < (l - 1))
                    fprintf(output_stream, ", ");

                free(e);
            }
        }

        fprintf(output_stream, ";\n");
    }

    /* End */
    fprintf(output_stream, "}\n");

    return EXIT_SUCCESS;
}

static inline void
freeall(void)
{
    if (output_stream != NULL \
        && output_stream != CMD_JAILCONF_STREAM) {
        fclose(output_stream);
    }
    template_free(&t);
    free(jail_name);
    free(name);
    free(output_file);
    free(template_file);
    except_traceback(&trbck);
}

void
command_help_jailConf(void)
{
    command_usage_jailConf();

    fprintf(stderr, "\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -j <jail>            -- Use the jail's template.\n");
    fprintf(stderr, "    -n <name>            -- Jail name.\n");
    fprintf(stderr, "    -o <output>          -- Output file. stdout (default) is used if output is `-`.\n");
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
    command_usage_jailConf();
    exit(EX_USAGE);
}

void
command_usage_jailConf(void)
{
    fprintf(stderr, "usage: jailConf [-n <name>] [-o <output>] -j <jail>\n");
    fprintf(stderr, "       jailConf [-o <output>] -n <name> -t <template>\n");
}
