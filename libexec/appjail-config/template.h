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

#ifndef TEMPLATE_H
#define TEMPLATE_H

#include <stdbool.h>
#include <limits.h>

#include "except.h"
#include "word.h"

/* Maximum number of parameters in a template that can be appended. */
#define MAX_TEMPLATE    ULLONG_MAX

/* The number of parameters in a template. */
typedef unsigned long long templatelen;
/* The index of a parameter in a template. */
typedef unsigned long long templateindex;

/* Incomplete structure pointing to an instance of `template`. */
typedef struct template *template;

/* Incomplete structure pointing to an instance of `param`. */
typedef struct param *param;

/*
 * Creates a new instance of `template` and assigns it to `tptr`. `trbck` is the
 * trace exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * This function parses the file specfied in `fn` to obtain a template. The template
 * is parsed line by line to get the parameters. A parameter is separated by a key
 * and a value using a colon as a separator. A key starting with an asterisk is a
 * `required parameter` but how the application handles it depends entirely up to the
 * application. A colon starting with a plus sign is an `append parameter` but how
 * the application handles it is entirely up to the application. A key can be a variable
 * based on `sh(1)` (e.g.: `$key` or `${key}`) and it is written as is. A value can be
 * accessed through a string or by columns.
 *
 * Empty lines (see `util.h:test_empty()`) and comments (see `util.h:test_comment()`)
 * are included, but a `garbage` flag is set to `true` and no parse operations are
 * executed on this line.
 *
 * Returns (see templateerr.h):
 *   - [TPERRB]: If `template_create()` fails.
 *   - [TPERRP]: Parsing error.
 *   - [TPERRN]: There are no errors.
 */
int     template_init(const char *fn, template *tptr, traceback *trbck);

/*
 * Allocates memory to a template. This function should only be used when more control
 * is needed, but `template_init()` should be sufficient. `trbck` is the trace
 * exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see templateerr.h):
 *   - [TPERRG]: Memory cannot be allocated.
 *   - [TPERRN]: There are no errors.
 */
int     template_create(template *tptr, traceback *trbck);

/*
 * Allocates memory for a new parameter and assigns it to `t`. The index will be stored
 * in `i` unless it is `NULL`. `trbck` is the trace exception that can be set to `NULL`
 * to not use exceptions (see except.h).
 *
 * Returns (see templateerr.h):
 *   - [TPERRM]: No more parameters can be appended.
 *   - [TPERRG]: Memory cannot be allocated.
 *   - [TPERRN]: There are no errors.
 */
int     template_newparam(template t, templateindex *i, traceback *trbck);

/*
 * This function does the actual parsing work, but only for a string. The parse operation
 * is described in `template_init()`. `p` must be an allocated parameter before using this
 * function. `trbck` is the trace exception that can be set to `NULL` to not use exceptions
 * (see except.h).
 *
 * Returns (see templateerr.h):
 *   - [TPERRG]: Memory cannot be allocated.
 *   - [TPERRB]: A buffer cannot be initialized. 
 *   - [TPERRS]: Syntax error.
 *   - [TPERRO]: Error parsing the value to convert it into columns.
 *   - [TPERRN]: There are no errors.
 */
int     template_setparam(const char *s, param p, traceback *trbck);

/*
 * Checks if `s` is a template-compliant variable (see `template_init()`).
 *
 * Returns:
 *   - `false` if `s` is not a template-compliant variable, otherwise `true`.
 */
bool    template_checkvar(const char *s);

/*
 * Checks if `s` is a valid parameter by comparing it with a list in `parameters.c`.
 *
 * Returns:
 *   - `false` if `s` is not found, otherwise `true`.
 */
bool    template_checkparam(const char *s);

/*
 * This function frees buffers such as to store the key, value and columns in a parameter,
 * and sets the `ignore` flag. If `p` has the `ignore` flag set to `true` this function
 * does nothing.
 */
void    template_setignore(param p);

/*
 * Checks if `p` has the `ignore` flag set to `true`.
 *
 * Returns:
 *   - `true` if `p` has the `ignore` flag set to `true`, otherwise `false`.
 */
bool    template_isignore(param p);

/*
 * Sets `p` as an `append parameter` (see `template_init()`).
 */
void    template_setappend(param p);

/*
 * Unsets the `append parameter` flag.
 */
void    template_setnappend(param p);

/*
 * Checks if `p` has the `append parameter` flag set to `true`.
 *
 * Returns:
 *   - `true` if `p` has the `append parameter` flag set to `true`, otherwise `false`.
 */
bool    template_isappend(param p);

/*
 * Checks if `p` is a variable described in `template_init()`.
 *
 * Returns:
 *   - `true` if `p` is a variable, otherwise `false`.
 */
bool    template_isvar(param p);

/*
 * Gets the key. 
 *
 * Returns:
 *   - Returns a pointer to a string. If the key is not defined, a `NULL` pointer is
 *     returned.
 */
char *  template_getkey(param p);

/*
 * Sets a new key. It also sets the `garbage` and `ignore` flags to `false` and frees
 * the line representing the parameter when it is garbage (see `template_getline()`).
 * `trbck` is the trace exception that can be set to `NULL` to not use exceptions
 * (see except.h).
 *
 * Returns (see templateerr.h):
 *   - [TPERRB]: A buffer cannot be initialized. 
 *   - [TPERRO]: `s` cannot be copy to the buffer.
 *   - [TPERRN]: There are no errors.
 */
int     template_setkey(param p, const char *k, traceback *trbck);

/*
 * Sets a new value and its columns. It also sets the `required parameter` to `false`.
 * `trbck` is the trace exception that can be set to `NULL` to not use exceptions
 * (see except.h).
 *
 * Returns (see templateerr.h)
 *   - [TPERRB]: A buffer cannot be initialized.
 *   - [TPERRO]: Error parsing the value to convert it into columns.
 *   - [TPERRN]: There are no errors.
 */
int     template_setvalue(param p, const char *v, traceback *trbck);

/*
 * Gets the line representing the garbage line.
 *
 * Returns:
 *   - A pointer to a string, otherwise a `NULL` pointer is returned if there is no
 *     garbage line.
 */
char *  template_getline(param p);

/*
 * Gets the value. 
 *
 * Returns:
 *   - Returns a pointer to a string. If the value is not defined, a `NULL` pointer is
 *     returned.
 */
char *  template_getvalue(param p);

/*
 * Gets the total number of columns.
 *
 * Returns:
 *   - Number of columns.
 */
wordlen     template_getcolumns(param p);

/*
 * Gets the string representing the column with index `c`.
 *
 * Returns:
 *   - A pointer to a string or `NULL` if the column is not found.
 */
char *  template_getcolumn(param p, wordindex c);

/*
 * Changes the index string `c` to the string `s`. `trbck` is the trace exception
 * that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see templateerr.h):
 *   - [TPERRO]: Error parsing the value to convert it into columns or an error ocurred
 *               while copying `s` into the buffer.
 *   - [TPERRN]: There no errors.
 */
int     template_setcolumn(param p, wordindex c, const char *s, traceback *trbck);

/*
 * Appends a new column. `trbck` is the trace exception that can be set to `NULL`
 * to not use exceptions (see except.h).
 *
 * Returns (see templateerr.h):
 *   - [TPERRO]: Error parsing the value to convert it into columns or an error ocurred
 *               while copying `s` into the buffer.
 *   - [TPERRN]: There are no errors.
 */
int     template_newcolumn(param p, const char *s, traceback *trbck);

/*
 * Deletes a column with index `c`. `trbck` is the trace exception that can be set to
 * `NULL` to not use exceptions (see except.h).
 *
 * Returns (see worderr.h)
 *   - [TPERRI]: If `c` is greater than the total number of columns.
 *   - [TPERRO]: Error parsing the value to convert it into columns.
 *   - [TPERRN]: There are no errors.
 */
int     template_delcolumn(param p, wordindex c, traceback *trbck);

/*
 * Checks if `p` has the `garbage` flag set to `true`.
 *
 * Returns:
 *   - `true` if `p` has the `garbage` flag set to `true`, otherwise `false`.
 */
bool    template_isgarbage(param p);

/*
 * Sets `p` as a `required parameter` (see `template_init()`).
 */
void    template_setrequire(param p);

/*
 * Unsets the `required parameter` flag.
 */
void    template_setnrequire(param p);

/*
 * Checks if `p` has the `required parameter` flag set to `true`.
 *
 * Returns:
 *   - `true` if `p` has the `required parameter` flag set to `true`, otherwise `false`.
 */
bool    template_isrequire(param p);

/*
 * Gets the parameter with the index `i`.
 *
 * Returns:
 *   - A pointer to the parameter or `NULL` if `i` is greater than the total number
 *     of parameters.
 */
param   template_getparam(template t, templateindex i);

/*
 * Gets the parameter with the key `k` and with the matching row number `r` ignoring
 * parameters that have the `ignore` and `garbage` flags set to `true`.
 *
 * Returns:
 *   - A pointer to the parameter or `NULL` if the parameter is not found.
 */
param   template_getrow(template t, templateindex r, const char *k);

/*
 * Like `template_getrow()` but the function can be called as many times as needed
 * with a custom starting index `s`. `s` is both an input and output argument.
 *
 * Returns:
 *   - A pointer to the parameter or `NULL` if there is no more parameters.
 */
param   template_yieldrow(template t, const char *k, templateindex *s);

/*
 * Gets the total number of rows.
 *
 * Returns:
 *   - Total number of rows.
 */
templatelen   template_getrows(template t);

/*
 * Writes the template to the `stream`. Useful for rewriting a template after a
 * modification.
 *
 * Returns (see templateerr.h):
 *   - [TPERRO]: If `template_printrow()` fails.
 *   - [TPERRN]: There are no errors.
 */
int     template_printrows(template t, FILE *stream, traceback *trbck);

/*
 * Like `template_printrows()` but for a single parameter.
 *
 * Returns (see templateerr.h):
 *   - [TPERRG]: An error related to `printf(3)`.
 *   - [TPERRN]: There are no errors.
 */
int     template_printrow(param p, FILE *stream, traceback *trbck);

/*
 * Prints a string indicating the error specified with `e` (see `template_strerr()`).
 * `s` is a string that will be used to print the concatenated string with a
 * colon and the string error.
 */
void    template_perr(const char *s, int e);

/*
 * Gets an error string indicating the error specified with `e`.
 *
 * Returns:
 *   - Returns a pointer to the string. `NULL` is returned when the error is
 *     unknown or `e` is greater or equal to `0`.
 */
const char *    template_strerr(int e);

/*
 * Frees an instance pointed to in `tptr`. If the block pointed to in `tptr` is
 * `NULL`, this function does nothing. After executing all operations, `NULL`
 * is set in `tptr`.
 */
void    template_free(template *tptr);

/*
 * Frees a parameter and its members. If the block pointed to in `pptr` is `NULL`,
 * this function does nothing. After executing all operations, `NULL` is set in
 * `pptr`.
 */
void    template_freeparam(param *pptr);

#endif
