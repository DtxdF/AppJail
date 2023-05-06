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

#ifndef BUFF_H
#define BUFF_H

#include <stddef.h>

#include "except.h"

/* A convenient macro to use in `bufinit()`. */
#define BUFF_MINBUF 64

/* Incomplete structure pointing to an instance of `buff`. */
typedef struct buff *buff;

/*
 * Creates a new instance of `buff` and assigns it to `bptr`. `l` is the minimum
 * size of this buffer (see `buffadd()`). `trbck` is the trace
 * exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see buferr.h):
 *   - [BFERRI]: An invalid argument error is returned when `l` is less than or
 *               equal to `1`.
 *   - [BFERRG]: A generic error is returned when `malloc(3)` cannot allocate
 *               more memory.
 *   - [BFERRN]: There are no errors.
 */
int     bufinit(size_t l, buff *bptr, traceback *trbck);

/*
 * Copies character by character the characters of the string `s`. `b` is an
 * instance of `b` that must be initialized using `bufinit()`. `trbck` is
 * the trace exception that can be set to `NULL` to not use exceptions
 * (see except.h).
 *
 * Returns (see buferr.h):
 *   - [BFERRO]: When `bufadd()` fails.
 *   - [BFERRN]: There are no errors.
 */
int     bufcopy(const char *s, buff b, traceback *trbck);

/*
 * Append the `c` as a new character in `b`. A modulo operation is used against
 * the minimum size and the total number of characters to know when to reserve
 * more memory. `trbck` is the trace exception that can be set to `NULL` to not
 * use exceptions (see except.h).
 *
 * Returns (see buferr.h):
 *   - [BFERRM]: When no more characters can be appended.
 *   - [BFERRG]: A generic is returned when `realloc(3)` cannot allocate
 *               bytes in memory.
 *   - [BFERRN]: There no errors.
 */
int     bufadd(char c, buff b, traceback *trbck);

/*
 * Gets the characters appended when calling `bufadd()` as a string.
 *
 * Returns:
 *   - Returns a pointer to the string. `NULL` is returned if no character has
 *     been appended.
 */
char *  bufget(buff b);

/*
 * Gets the total number of characters.
 */
size_t  buflen(buff b);

/*
 * Prints a string indicating the error specified with `e` (see `buferr()`).
 * `s` is a string that will be used to print the concatenated string with a
 * colon and the string error.
 */
void    bufperr(const char *s, int e);

/*
 * Gets an error string indicating the error specified with `e`.
 *
 * Returns:
 *   - Returns a pointer to the string. `NULL` is returned when the error is
 *     unknown or `e` is greater or equal to `0`.
 */
const char *    buferr(int e);

/*
 * Frees an instance pointed to in `bptr`. If the block pointed to in `bptr` is
 * `NULL`, this function does nothing. After executing all operations, `NULL`
 * is set in `bptr`.
 */
void    buffree(buff *bptr);

#endif
