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

#ifndef UTIL_H
#define UTIL_H

#include <stdbool.h>
#include <stdio.h>

/* See `get_jaildir()`. */
#define UTIL_JAILDIR    "/usr/local/appjail/jails"

/* See `get_tparam()`. */
struct tparam {
    char *parameter;
    char *value;
};

/* Incomplete structure pointing to an instance of `buff`. */
typedef struct tparam *tparam;

/*
 * Strip whitespace from the beginning of a string. However, this function does not
 * create a new string or modify `s`, it only returns the string.
 *
 * Returns:
 *   - An stripped string.
 */
char *    ltrim(const char *s);

/*
 * Creates a new string escaping `"` and `\`. The string is quoted with `"`. After
 * this function returns a string, `free(3)` must be called when the string is no
 * longer needed.
 *
 * Returns:
 *   - If successful, an escaped string is returned, otherwise `NULL` is returned.
 */
char *  escape_word(const char *s, traceback *trbck);

/*
 * Gets a copy of `s` without the newline character.
 *
 * Returns:
 *   - A pointer to string without the newline character.
 */
char *  get_line(const char *s);

/*
 * Separates `s` using the `=` character as a separator to get the parameter and its value.
 *
 * Returns:
 *   - A pointer to a `tparam` structure.
 */
tparam  get_tparam(const char *s);

/*
 * Frees an instance pointed to in `tptr`. If the block pointed to in `tptr` is
 * `NULL`, this function does nothing. After executing all operations, `NULL`
 * is set in `tptr`.
 */
void    free_tparam(tparam *tptr);

/*
 * Calls `get_jaildir()` to get the jail directory from `jail` to concatenate with
 * `conf/template.conf`.
 *
 * Returns:
 *   - A pointer to a string such as `<jail directory>/conf/template.conf`.
 */
char *  get_jail_template(const char *jail);

/*
 * Gets the jail directory from the `APPJAIL_CONFIG_JAILDIR` environment variable
 * and concatenates it with `jail`. If `APPJAIL_CONFIG_JAILDIR` is not defined,
 * the `UTIL_JAILDIR` macro is used.
 *
 * Returns:
 *   - A pointer to a string such as `<jails directory>/<jail>`.
 */
char *  get_jaildir(const char *jail);

/*
 * Checks if `jail` is `^[a-zA-Z0-9_][a-zA-Z0-9_-]*$`.
 *
 * Returns:
 *   - `false` if the test false, otherwise `true`.
 */
bool    test_jailname(const char *jail);

/*
 * Checks if `s` does not contain characters other than blanks.
 *
 * Returns:
 *   - `false` if the test false, otherwise `true`.
 */
bool    test_empty(const char *s);

/*
 * Checks if the first character of `s` is `#` in a stripped string. It is
 * not necessary to strip the string before calling this function.
 *
 * Returns:
 *   - `false` if the stripped version of `s` does not contain `#`, otherwise
 *     `true`.
 */
bool    test_comment(const char *s);

/*
 * Checks if `c` is `-`, `.` or alphanumeric
 *
 * Returns:
 *   - `false` if the test fails, otherwise `true`.
 */
bool    test_param(int c);

/*
 * Prints `c` as many times as `n` in the `s` stream.
 */
void    print_multichar(int n, int c, FILE *s);

/*
 * Calls `strtoull(3)` and if it fails, the program will exit.
 *
 * Returns:
 *   - An `unsigned long long` integer.
 */
unsigned long long  safe_strtoull(const char *s);

/*
 * Checks whether `s` is `1` or `0`, otherwise the program will exit.
 *
 * Returns:
 *   - `false` If `s` is `0`, otherwise `true`.
 */
bool    safe_strtob(const char *s);

/*
 * Calls `strdup(3)` and if it fails, the program will exit.
 *
 * Returns:
 *   - A pointer to the copied string.
 */
char *  safe_strdup(const char *s);

#endif
