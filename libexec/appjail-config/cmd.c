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

#include <limits.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "cmd.h"
#include "cmderr.h"
#include "except.h"
#include "overflow.h"

#define CMD_TRBCK(ret) except_addsf(ret, cmd_strerr(ret), trbck)

struct cmd {
    bool dflt;
    char *name;
    int (*cmd)(int, char **, int);
};

struct cmdui {
    unsigned int n;
    cmd *cmds;
};

int
cmd_init(cmdui *cptr, traceback *trbck)
{
    cmdui cui;
    if ((cui = (cmdui)malloc(sizeof(struct cmdui))) == NULL) {
        CMD_TRBCK(CDERRG);
        return CDERRG;
    }

    cui->n = 0;
    cui->cmds = NULL;

    *cptr = cui;

    return CDERRN;
}

int
cmd_new(cmdui cui, unsigned int *i, traceback *trbck)
{
    unsigned int n = cui->n + 1;
    if (n >= UINT_MAX) {
        CMD_TRBCK(CDERRM);
        return CDERRM;
    }

    unsigned int s;
    if (test_uiwrap_mul(n, sizeof(cmd), &s) == -1) {
        CMD_TRBCK(CDERRM);
        return CDERRM;
    }

    if ((cui->cmds = (cmd *)realloc(cui->cmds, s)) == NULL) {
        CMD_TRBCK(CDERRG);
        return CDERRG;
    }

    cui->n = n;

    cmd c;
    if ((c = cui->cmds[n - 1] = (cmd)malloc(sizeof(struct cmd))) == NULL) {
        CMD_TRBCK(CDERRG);
        return CDERRG;
    }

    c->name = NULL;
    c->cmd = NULL;
    c->dflt = false;
    if (i != NULL)
        *i = n;
    
    return CDERRN;
}

cmd
cmd_get(cmdui cui, unsigned int i)
{
    if (i >= cui->n)
        return NULL;
    return cui->cmds[i];
}

cmd
cmd_search(cmdui cui, const char *n)
{
    for (unsigned int i = 0; i < cui->n; i++) {
        cmd c = cui->cmds[i];

        if (c->name == NULL)
            continue;

        if (strcmp(c->name, n) == 0)
            return c;
    }

    return NULL;
}

int
cmd_setname(cmd c, const char *n, traceback *trbck)
{
    c->name = strdup(n);
    if (c->name == NULL) {
        CMD_TRBCK(CDERRG);
        return CDERRG;
    }

    return CDERRN;
}

void
cmd_setcmd(cmd c, int (*cmdptr)(int, char **, int))
{
    c->cmd = cmdptr;
}

void
cmd_setdefault(cmd c)
{
    c->dflt = true;
}

cmd
cmd_getdefault(cmdui cui)
{
    for (unsigned int i = 0; i < cui->n; i++) {
        cmd c = cui->cmds[i];

        if (c->dflt)
            return c;
    }

    return NULL;
}

int
cmd_run(cmdui cui, int argc, char **argv, int argi, int *err, traceback *trbck)
{
    if (argi > argc)
        return CDERRI;

    cmd c;
    char *cmd_name = argv[argi];

    if (cmd_name == NULL)
        c = cmd_getdefault(cui);
    else
        c = cmd_search(cui, cmd_name);

    if (c == NULL) {
        CMD_TRBCK(CDERRC);
        return CDERRC;
    }

    if (c->cmd == NULL) {
        CMD_TRBCK(CDERRB);
        return CDERRB;
    }

    *err = c->cmd(argc, argv, argi + 1);

    return CDERRN;
}

void
cmd_perr(const char *s, int e)
{
    fprintf(stderr, "%s: %s\n", s, cmd_strerr(e));
}

const char *
cmd_strerr(int e)
{
    if (e > 0)
        return NULL;
    else
        e = -e;

    static const char *estr[] = {
        "No error (CDERRN).",
        "Generic error (CDERRG).",
        "No more commands can be added (CDERRM).",
        "Command not found (CDERRC).",
        "No callback has been added (CDERRB).",
        "Invalid argument (CDERRI).",
    };

    size_t etot = sizeof(estr) / sizeof(estr[0]);

    if ((size_t)e >= etot)
        return NULL;

    return estr[e];
}

void
cmd_free(cmdui *cptr)
{
    cmdui cui = *cptr;
    if (cui == NULL)
        return;

    while (cui->n-- > 0) {
        cmd c = cui->cmds[cui->n];
        if (c == NULL)
            continue;

        free(c->name);
        free(c);
    }

    free(cui->cmds);
    free(cui);

    *cptr = NULL;
}
