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

#ifndef WORD_H
#define WORD_H

#include <limits.h>

#include "buff.h"
#include "except.h"

/* Maximum number of words that can be appended. */
#define MAX_WORD    ULLONG_MAX

/* The number of words. */
typedef unsigned long long wordlen;
/* The index of a word. */
typedef unsigned long long wordindex;

/* Incomplete structure pointing to an instance of `word`. */
typedef struct word *word;

/*
 * Creates a new instance of `word` and assigns it to `wptr`. `trbck` is the trace
 * exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * This function parses `s` to get words. One or more words are separated by spaces.
 * To use spaces in words, the word can be enclosed in single or double quotes.
 * Single and double quotes can be escaped using an escape character. An escape
 * character followed by a character other than the quotation mark (depending on
 * whether it is single or double) will write without escaping.
 *
 * Examples:
 *   - "Hello world!" "Escaping \""
 *     ```
 *     Hello world!
 *     Escaping "
 *     ```
 *   - 'Hello :D' '\"':
 *     ```
 *     Hello :D
 *     \"
 *     ```
 *
 * Returns (see worderr.h):
 *   - [WDERRB]: If `wrdcreat()` fails.
 *   - [WDERRW]: No more words can be allocated.
 *   - [WDERRS]: Syntax error.
 *   - [WDERRO]: No more words can be allocated or no more characters can be added
 *               when parsing.
 *   - [WDERRN]: There are no errors.
 */
int     wrdinit(const char *s, word *wptr, traceback *trbck);

/*
 * Like `wrdinit()` but does not parse a string for words. This function should only
 * be used when there is a need for more control, but `wrdinit()` can do the job
 * much more easily. `trbck` is the trace exception that can be set to `NULL` to not
 * use exceptions (see except.h).
 *
 * Returns (see worderr.h):
 *   - [WDERRG]: Memory cannot be allocated.
 *   - [WDERRN]: There are no errors.
 */
int     wrdcreat(word *wptr, traceback *trbck);

/*
 * Allocates a buffer and assigns it to a new word. `trbck` is the trace
 * exception that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see worderr.h):
 *   - [WDERRM]: No more words can be appended.
 *   - [WDERRG]: Memory cannot be allocated.
 *   - [WDERRO]: Error when creating the buffer.
 *   - [WDERRN]: There are no errors.
 */
int     wrdnew(word w, traceback *trbck);

/*
 * Deletes a word with index `i`. `trbck` is the trace exception that can be set to
 * `NULL` to not use exceptions (see except.h).
 *
 * Returns (see worderr.h)
 *   - [WDERRI]: If `i` is greater than the total number of words.
 *   - [WDERRG]: Memory cannot be allocated.
 *   - [WDERRN]: There are no errors.
 */
int     wrddel(word w, wordindex i, traceback *trbck);

/*
 * Gets the total number of words.
 *
 * Returns:
 *   - Number of words.
 */
wordlen     wrdtot(word w);

/*
 * Gets the string representing the word with index `i`.
 *
 * Returns:
 *   - A pointer to a string or `NULL` if the word is not found.
 */
char *  wrdget(word w, wordlen i);

/*
 * Sets the word with index `i` to the string `s`. `trbck` is the trace exception
 * that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see worderr.h):
 *   - [WDERRI]: If `i` is greater than the total number of words.
 *   - [WDERRG]: Memory cannot be allocated.
 *   - [WDERRN]: There are no errors.
 */
int     wrdset(word w, wordlen i, const char *s, traceback *trbck);

/*
 * Append a new word with the string `s`. `trbck` is the trace exception
 * that can be set to `NULL` to not use exceptions (see except.h).
 *
 * Returns (see worderr.h):
 *   - [WDERRG]: Memory cannot be allocated.
 *   - [WDERRO]: Error when creating the buffer.
 *   - [WDERRN]: There are no errors.
 */
int     wrdadd(word w, const char *s, traceback *trbck);

/*
 * Prints a string indicating the error specified with `e` (see `wrderr()`).
 * `s` is a string that will be used to print the concatenated string with a
 * colon and the string error.
 */
void    wrdperr(const char *s, int e);

/*
 * Gets an error string indicating the error specified with `e`.
 *
 * Returns:
 *   - Returns a pointer to the string. `NULL` is returned when the error is
 *     unknown or `e` is greater or equal to `0`.
 */
const char *    wrderr(int e);

/*
 * Frees an instance pointed to in `wptr`. If the block pointed to in `wptr` is
 * `NULL`, this function does nothing. After executing all operations, `NULL`
 * is set in `wptr`.
 */
void    wrdfree(word *wptr);

#endif
