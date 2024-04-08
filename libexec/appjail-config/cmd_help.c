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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>

#include "cmd_help.h"
#include "commands.h"
#include "util.h"

#define PAD_SIZE     10

int
command_cmd_help(int argc, char **argv, int argi)
{
    char *help_cmd = NULL;

    if (argc >= argi)
        help_cmd = argv[argi];

    if (help_cmd == NULL) {
        command_help_help();
        return EXIT_SUCCESS;
    }

    for (size_t i = 0; i < command_total; i++) {
        if (strcmp(commands[i].name, help_cmd) == 0) {
            commands[i].help_cmd();
            return EXIT_SUCCESS;
        }
    }

    fprintf(stderr, "Command \"%s\" does not exist.\n", help_cmd);

    return EX_NOINPUT;
}

void
command_help_help(void)
{
    /* Calculate the longest command name. */
    size_t l, m = 0;
    for (size_t j = 0; j < command_total; j++) {
        if ((l = strlen(commands[j].name)) > m)
            m = l;
    }

    fprintf(stderr, "Commands:\n");
    for (size_t i = 0; i < command_total; i++) {
        fprintf(stderr, "  %s", commands[i].name);
        print_multichar(l - strlen(commands[i].name) + PAD_SIZE, ' ', stderr);
        fprintf(stderr, "%s\n", commands[i].desc);
    }
    fprintf(stderr, "\n");
    fprintf(stderr, "Use `help <command>` to display the help information for that command.\n");
}

void
command_usage_help(void)
{
    fprintf(stderr, "usage: help [command]\n");
}
