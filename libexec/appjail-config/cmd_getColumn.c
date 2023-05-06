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
#include <unistd.h>

#include "commands.h"
#include "template.h"
#include "templateerr.h"
#include "except.h"
#include "util.h"

#define CMD_GETCOLUMN_DEFROW    ((templateindex)0)
#define CMD_GETCOLUMN_DEFCOL    ((templateindex)0)

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
command_cmd_getColumn(int argc, char **argv, int argi)
{
    templateindex row = CMD_GETCOLUMN_DEFROW,
                  column = CMD_GETCOLUMN_DEFCOL;
    int c;
    bool Cflag = false,
         iflag = false,
         jflag = false,
         Pflag = false,
         pflag = false,
         tflag = false,
         Vflag = false;

    optind = argi;

    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    while ((c = getopt(argc, argv, ":CiPpVc:j:r:t:")) != -1) {
        switch (c) {
        case 'C':
            Cflag = true;
            break;
        case 'i':
            iflag = true;
            break;
        case 'P':
            Pflag = true;
            break;
        case 'p':
            pflag = true;
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

    /* Check for an invalid parameter. */
    if (!Vflag \
        && !template_checkvar(parameter) \
        && !template_checkparam(parameter)) {
        fprintf(stderr, "Invalid parameter `%s`\n",
            parameter);
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
    if (trbck == NULL) {
        err(EX_OSERR, "except_newtrbck()");
    }

    if (template_init(template_file, &t, &trbck) != TPERRN) {
        except_printerr(trbck);
        /* Free `trbck` blocks using except_free() to avoid printing 
         * the traceback.
         */
        except_free(&trbck);
        return EX_SOFTWARE;
    }

    /* Used when Pflag is true. */
    templateindex start = 0;
    bool unknown = true;

    for (;;) {
        param p;
        
        if (Pflag)
            p = template_yieldrow(t, parameter, &start);
        else
            p = template_getrow(t, row, parameter);

        if (p == NULL)
            break;

        char *column_str;
        if (pflag) {
            wordlen c = 0;

            while ((column_str = template_getcolumn(p, c++)) != NULL) {
                unknown = false;
                
                if (Cflag)
                    break;

                printf("%s\n", column_str);
            }
        } else {
            column_str = template_getcolumn(p, column);

            if (column_str != NULL) {
                unknown = false;

                if (!Cflag)
                    printf("%s\n", column_str);
            }
        }

        if (unknown || Cflag || !Pflag)
            break;
    }

    if (unknown) {
        if (!Cflag && !iflag) {
            fprintf(stderr, "Unknown parameter -- %s",
                parameter);
            if (!Pflag)
                fprintf(stderr, ":%llu", row);
            if (!pflag)
                fprintf(stderr, ":%llu", column);
            fprintf(stderr, "\n");
        }
        return EX_DATAERR;
    }

    return EXIT_SUCCESS;
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
command_help_getColumn(void)
{
    command_usage_getColumn();

    fprintf(stderr, "\n");
    fprintf(stderr, "Options\n");
    fprintf(stderr, "    -c                 -- Returns `0` if `parameter` and `column` exists,\n");
    fprintf(stderr, "                          otherwise, a non-zero value is returned.\n");
    fprintf(stderr, "    -i                 -- Ignore unknown parameters, as well as columns.\n");
    fprintf(stderr, "    -P                 -- Dump all matching rows, not just one. The `-r`\n");
    fprintf(stderr, "                          parameter is ignored.\n");
    fprintf(stderr, "    -p                 -- Dump all matching columns, not just one. The `-c`\n");
    fprintf(stderr, "                          parameter is ignored.\n");
    fprintf(stderr, "    -V                 -- Do not validate if `parameter` is valid against a list\n");
    fprintf(stderr, "                          extracted from `jail(8)` nor validate if `parameter` is\n");
    fprintf(stderr, "                          a correct variable.\n");
    fprintf(stderr, "    -c column          -- Dump the given column. Use `0` to dump all columns. Default: %llu\n",
        CMD_GETCOLUMN_DEFCOL);
    fprintf(stderr, "    -j jail            -- Use jail's template as the template file.\n");
    fprintf(stderr, "    -r row             -- Dump columns with the row `row`. Default: %llu.\n",
        CMD_GETCOLUMN_DEFROW);
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
    command_usage_getColumn();
    exit(EX_USAGE);
}

void
command_usage_getColumn(void)
{
    fprintf(stderr, "usage: getColumn [-cilPV] [-c column] [-r row] [-j jail | -t template] parameter\n");
}
