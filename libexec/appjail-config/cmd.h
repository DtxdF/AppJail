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

#ifndef CMD_H
#define CMD_H

#include "except.h"

/* A pointer to a command. */
typedef struct cmd *cmd;
/* Incomplete structure pointing to an instance of `cmdui`. */
typedef struct cmdui *cmdui;

/*
 * Creates a new instance of `cmdui` and assigns it to `cptr`. `trbck` is the trace
 * exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see cmderr.h):
 *   - [CDERRG]: A generic error is returned when `malloc(3)` cannot allocate
 *               bytes in memory.
 *   - [CDERRN]: There are no errors.
 */
int     cmd_init(cmdui *cptr, traceback *trbck);

/*
 * Appends a new command pointed to in `cui`. `i` is the index of the new command.
 * If `i` is `NULL`, no index is set.
 *
 * Returns (see cmderr.h):
 *   - [CDERRM]: No more commands  can be appended.
 *   - [CDERRG]: `malloc(3)` or `realloc(3)` cannot allocate more memory.
 *   - [CDERRN]: There is no errors.
 */
int     cmd_new(cmdui cui, unsigned int *i, traceback *trbck);

/*
 * Gets a command from instance `cui` with index `i`.
 *
 * Returns:
 *   - A pointer to the command or `NULL` if not found.
 */
cmd     cmd_get(cmdui cui, unsigned int i);

/*
 * Search for a command of the `cui` instance using its name in `n`.
 *
 * Returns:
 *   - A pointer to the command or `NULL` if not found.
 */
cmd     cmd_search(cmdui cui, const char *n);

/*
 * Sets the name of the `c` command. `strdup(3)` is used to copy the string `n`.
 * `trbck` is the trace exception that can be set to `NULL` to not use
 * exceptions (see except.h).
 *
 * Returns (see cmderr.h):
 *   - [CDERRG]: If `strdup(3)` fails.
 *   - [CDERRN]: There is no errors.
 */
int     cmd_setname(cmd c, const char *n, traceback *trbck);

/*
 * Sets a function to be executed when `cmd_run()` is called on a matching command.
 * The first argument of `cmdptr` is `argc`, the second `argv` and the third, `argi`
 * which is incremented in each call to `cmd_run()` and can be used in a variable
 * such as `optind` of `getopt(3)` and must be passed in calls to `cmd_run()` for
 * consistency.
 */
void    cmd_setcmd(cmd c, int (*cmdptr)(int, char **, int));

/*
 * Marks `c` as the default command (See `cmd_run()` for more details).
 */
void    cmd_setdefault(cmd c);

/*
 * Gets the command that is marked as the default command.
 *
 * Returns:
 *   - A pointer to the command or `NULL` if not found.
 */
cmd     cmd_getdefault(cmdui cui);

/*
 * Executes a `cui` command specified in `argv[argi]`. If `argv[argi]` is `NULL`,
 * `cmd_run()` will attempt to get the default command using `cmd_getdefault()`.
 * `err` is a pointer to the value returned by the command. `trbck` is the trace
 * exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns:
 *   - [CDERRI]: If `argi` is greater than `argc`. 
 *   - [CDERRC]: If the command is not found.
 *   - [CDERRB]: If the matching command has no callback to execute.
 *   - [CDERRN]: There is no errors.
 */
int     cmd_run(cmdui cui, int argc, char **argv, int argi, int *err, traceback *trbck);

/*
 * Prints a string indicating the error specified with `e` (see `cmd_strerr()`).
 * `s` is a string that will be used to print the concatenated string with a
 * colon and the string error.
 */
void    cmd_perr(const char *s, int e);

/*
 * Gets an error string indicating the error specified with `e`.
 *
 * Returns:
 *   - Returns a pointer to the string. `NULL` is returned when the error is
 *     unknown or `e` is greater or equal to `0`.
 */
const char *    cmd_strerr(int e);

/*
 * Frees an instance pointed to in `cptr`. If the block pointed to in `cptr` is
 * `NULL`, this function does nothing. After executing all operations, `NULL`
 * is set in `cptr`.
 */
void    cmd_free(cmdui *cptr);

#endif
