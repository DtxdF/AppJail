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
#include <sysexits.h>
#include <unistd.h>

#include "commands.h"
#include "template.h"
#include "templateerr.h"
#include "except.h"
#include "util.h"

#define CMD_SETCOLUMN_DEFROW  ((templateindex)0)
#define CMD_SETCOLUMN_DEFCOL  ((templateindex)0)

#define CMD_SETCOLUMN_TRBCK(trbck) \
    do { \
        except_addsf(EX_SOFTWARE, NULL, trbck); \
        return EX_SOFTWARE; \
    } while (0)

static inline void  freeall(void);

static void     mutually_exclusive(int c1, int c2);

static void     usage(void);

/* Traceback exception */
static traceback trbck;

/* Parameter & value */
static tparam tp;

/* Template */
static template t;
static char *template_file;
static FILE *template_stream;

/* Jail name */
static char *jail_name;

int
command_cmd_setColumn(int argc, char **argv, int argi)
{
    templateindex column = CMD_SETCOLUMN_DEFCOL,
                  row = CMD_SETCOLUMN_DEFROW;
    int c;
    bool Aflag = false,
         jflag = false,
         tflag = false,
         Vflag = false;

    optind = argi;

    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    while ((c = getopt(argc, argv, ":AVc:j:r:t:")) != -1) {
        switch (c) {
        case 'A':
            Aflag = true;
            break;
        case 'V':
            Vflag = true;
            break;
        case 'c':
            column = safe_strtoull(optarg);
            break;
        case 'j':
            jflag = true;
            jail_name = safe_strdup(optarg);
            break;
        case 'r':
            row = safe_strtoull(optarg);
            break;
        case 't':
            tflag = true;
            template_file = safe_strdup(optarg);
            break;
        default:
            usage();
        }
    }

    char *parameter = argv[optind++];

    /* Mandatory arguments. */
    if ((!jflag && !tflag) \
        || parameter == NULL) {
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

    if ((tp = get_tparam(parameter)) == NULL)
        CMD_SETCOLUMN_TRBCK(&trbck);

    /* Check for an invalid parameter. */
    if (!Vflag \
        && !template_checkvar(tp->parameter) \
        && !template_checkparam(tp->parameter)) {
        fprintf(stderr, "Invalid parameter `%s`\n",
            tp->parameter);
        return EX_DATAERR;
    }

    if (template_init(template_file, &t, &trbck) != TPERRN) {
        except_printerr(trbck);
        /* Free `trbck` blocks using except_free() to avoid printing 
         * the traceback.
         */
        except_free(&trbck);
        return EX_SOFTWARE;
    }

    param p;
    if ((p = template_getrow(t, row, tp->parameter)) == NULL) {
        fprintf(stderr, "Unknown parameter -- %s:%llu:%llu\n",
            tp->parameter, row, column);
        return EX_NOINPUT;
    }

    if (Aflag) {
        if (template_newcolumn(p, tp->value, &trbck) != TPERRN)
            CMD_SETCOLUMN_TRBCK(&trbck);
    } else {
        if (column >= template_getcolumns(p)) {
            fprintf(stderr, "Column out of range (%llu >= %llu)\n",
                column, template_getcolumns(p));
            return EX_NOINPUT;
        }

        if (template_setcolumn(p, column, tp->value, &trbck) != TPERRN)
            CMD_SETCOLUMN_TRBCK(&trbck);
    }

    if ((template_stream = fopen(template_file, "w")) == NULL)
        CMD_SETCOLUMN_TRBCK(&trbck);
    else
        setlinebuf(template_stream);

    if (template_printrows(t, template_stream, &trbck) != TPERRN)
        CMD_SETCOLUMN_TRBCK(&trbck);

    return EXIT_SUCCESS;
}

static inline void
freeall(void)
{
    if (template_stream != NULL)
        fclose(template_stream);
    free_tparam(&tp);
    template_free(&t);
    free(jail_name);
    free(template_file);
    except_traceback(&trbck);
}

void
command_help_setColumn(void)
{
    command_usage_setColumn();

    fprintf(stderr, "\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -A                 -- Append `value` as a new column in `parameter` with row\n");
    fprintf(stderr, "                          `row`.\n");
    fprintf(stderr, "                          The `-c` parameter is ignored.\n");
    fprintf(stderr, "    -V                 -- Do not validate if `parameter` is valid against a list\n");
    fprintf(stderr, "                          extracted from `jail(8)` nor validate if `parameter` is\n");
    fprintf(stderr, "                          a correct variable.\n");
    fprintf(stderr, "    -j jail            -- Use jail's template as the template file.\n");
    fprintf(stderr, "    -c column          -- Edit the column in the `column` position.\n");
    fprintf(stderr, "    -r row             -- Edit columns in the `row` position.\n");
    fprintf(stderr, "    -t template        -- Use `template` as the template file.\n");
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
    command_usage_setColumn();
    exit(EX_USAGE);
}

void
command_usage_setColumn(void)
{
    fprintf(stderr, "usage: setColumn [-AV] [-c column] [-r row] [-j jail | -t template] parameter[=value]\n");
}
