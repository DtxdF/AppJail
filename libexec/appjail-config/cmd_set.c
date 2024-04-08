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

#define CMD_SET_DEFROW  ((templateindex)0)

#define CMD_SET_TRBCK(trbck) \
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
static FILE *template_stream;
static char *template_file;

/* Jail name */
static char *jail_name;

int
command_cmd_set(int argc, char **argv, int argi)
{
    templateindex row = CMD_SET_DEFROW;
    int c;
    bool Aflag = false, Aopt,
         Iflag = false,
         jflag = false,
         Rflag = false, Ropt,
         tflag = false,
         Vflag = false;

    optind = argi;

    if (atexit(freeall) == -1)
        err(EX_OSERR, "atexit()");

    while ((c = getopt(argc, argv, ":IVA:j:R:r:t:")) != -1) {
        switch (c) {
        case 'I':
            Iflag = true;
            break;
        case 'V':
            Vflag = true;
            break;
        case 'A':
            Aflag = true;
            Aopt = safe_strtob(optarg);
            break;
        case 'j':
            jflag = true;
            jail_name = safe_strdup(optarg);
            break;
        case 'R':
            Rflag = true;
            Ropt = safe_strtob(optarg);
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
        CMD_SET_TRBCK(&trbck);

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

    /*
     * If a previous parameter exists, it is necessary to force the append
     * flag so that it does not overwrite the value when the template is
     * converted to a jail.conf(5) file unless the user says otherwise.
     */
    bool append = false;
    if (Iflag || (!Aflag && row > 0)) {
        append = template_yieldrow(t, tp->parameter, (templateindex []){ 0 }) != NULL;
    }

    param p = NULL;

    if (Iflag || (p = template_getrow(t, row, tp->parameter)) == NULL) {
        if (template_newparam(t, &row, &trbck) != TPERRN)
            CMD_SET_TRBCK(&trbck);

        p = template_getparam(t, row);

        if (template_setkey(p, tp->parameter, &trbck) != TPERRN)
            CMD_SET_TRBCK(&trbck);

        if (append)
            template_setappend(p);
    }

    /* Mark/Unmark as required. */
    if (Rflag) {
        if (Ropt)
            template_setrequire(p);
        else
            template_setnrequire(p);
    }

    /* Mark/Unmark as append. */
    if (Aflag || append) {
        if (Aopt || append)
            template_setappend(p);
        else
            template_setnappend(p);
    }

    if (tp->value != NULL && template_setvalue(p, tp->value, &trbck) != TPERRN) {
        CMD_SET_TRBCK(&trbck);
    }

    if ((template_stream = fopen(template_file, "w")) == NULL)
        CMD_SET_TRBCK(&trbck);
    else
        setlinebuf(template_stream);

    if (template_printrows(t, template_stream, &trbck) != TPERRN)
        CMD_SET_TRBCK(&trbck);

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
command_help_set(void)
{
    command_usage_set();

    fprintf(stderr, "\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "    -I                   -- Insert parameter as a new row ignoring the -r parameter.\n");
    fprintf(stderr, "    -V                   -- Do not validate if parameter is valid against a list\n");
    fprintf(stderr, "                            extracted from jail(8) nor validate if parameter is a\n");
    fprintf(stderr, "                            correct variable.\n");
    fprintf(stderr, "    -A [0|1]             -- If 1, mark parameter as an append parameter (+:), otherwise\n");
    fprintf(stderr, "                            parameter is unmarked.\n");
    fprintf(stderr, "    -j <jail>            -- Use the jail's template.\n");
    fprintf(stderr, "    -R [0|1]             -- If 1, mark parameter as a required parameter, otherwise\n");
    fprintf(stderr, "                            parameter is unmarked.\n");
    fprintf(stderr, "    -r <row>             -- Limit matching with row.\n");
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
    command_usage_set();
    exit(EX_USAGE);
}

void
command_usage_set(void)
{
	fprintf(stderr, "usage: set [-IV] [-A [0|1]] [-R [0|1]] [-r <row>]\n");
	fprintf(stderr, "               [-j <jail>|-t <template>] <parameter>[=<value>]\n");
}
