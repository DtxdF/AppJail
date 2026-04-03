/*-
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2003 Mike Barcroft <mike@FreeBSD.org>
 * Copyright (c) 2008 Bjoern A. Zeeb <bz@FreeBSD.org>
 * Copyright (c) 2026 Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/param.h>
#include <sys/jail.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <arpa/inet.h>
#include <netinet/in.h>

#include <err.h>
#include <errno.h>
#include <jail.h>
#include <limits.h>
#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern char **environ;

static void usage(void);

int
main(int argc, char *argv[])
{
    int jid;
    int ch, clean;
    int env_argc = argc;
    char **env_argv = argv;
    char *cleanenv;
    char *user, *group;
    char *endptr;
    const char *shell, *term;
    const char *workdir;
    const char *jexec_args = "d:e:l";
    long luid, lgid;
    uid_t uid;
    gid_t gid;

    ch = clean = 0;
    user = NULL;
    workdir = "/";

    while ((ch = getopt(argc, argv, jexec_args)) != -1) {
        switch (ch) {
        case 'd':
            workdir = optarg;
            break;
        case 'e':
            /* Used later. */
            if (strchr(optarg, '=') == NULL)
                errx(1, "%s: Invalid environment variable.", optarg);
            break;
        case 'l':
            clean = 1;
            break;
        default:
            usage();
        }
    }
    argc -= optind;
    argv += optind;
    if (argc < 2)
        usage();

    user = argv[0];

    if (user[0] == '\0')
        usage();

    group = strchr(user, ':');
    if (group != NULL)
        *group++ = '\0';

    errno = 0;

    luid = strtol(user, &endptr, 10);

    if (errno != 0 || endptr == user || *endptr != '\0' || luid < 0 || luid >= (uid_t)-1)
        errx(1, "bad user id");

    if (group != NULL) {
        errno = 0;

        lgid = strtol(group, &endptr, 10);

        if (errno != 0 || endptr == group || *endptr != '\0' || lgid < 0 || lgid >= (gid_t)-1)
            errx(1, "bad group id");
    } else {
        lgid = luid;
    }

    uid = (uid_t)luid;
    gid = (gid_t)lgid;

    /* Attach to the jail */
    jid = jail_getid(argv[1]);
    if (jid < 0)
        errx(1, "%s", jail_errmsg);
    if (jail_attach(jid) == -1)
        err(1, "jail_attach(%d)", jid);
    if (chdir(workdir) == -1)
        err(1, "chdir(): %s", workdir);

    /* Set up user environment */
    if (clean) {
        term = getenv("TERM");
        cleanenv = NULL;
        environ = &cleanenv;
        setenv("PATH", "/bin:/usr/bin", 1);
        if (term != NULL)
            setenv("TERM", term, 1);
    }

    if (setgroups(0, NULL) != 0)
        err(1, "setgroups");
    if (setgid(gid) != 0)
        err(1, "setgid");
    if (setuid(uid) != 0)
        err(1, "setuid");

    optreset = 1;
    optind = 1;

    /* Custom environment */
    while ((ch = getopt(env_argc, env_argv, jexec_args)) != -1) {
        switch (ch) {
        case 'e':
            if (putenv(optarg) == -1)
                err(1, "putenv");
            break;
        }
    }

    /* Run the specified command, or the shell */
    if (argc > 2) {
        if (execvp(argv[2], argv + 2) < 0)
            err(1, "execvp: %s", argv[2]);
    } else {
        if (!(shell = getenv("SHELL")))
            shell = _PATH_BSHELL;
        if (execlp(shell, shell, "-i", NULL) < 0)
            err(1, "execlp: %s", shell);
    }
    exit(0);
}

static void
usage(void)
{

    fprintf(stderr, "%s\n",
        "usage: juexec [-l] [-d working-directory] [[-e name=value] ...] uid[:gid] jail\n"
        "       [command ...]");
    exit(1);
}
