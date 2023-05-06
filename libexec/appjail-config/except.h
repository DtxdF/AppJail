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

#ifndef EXCEPT_H
#define EXCEPT_H

/*
 * macro-function to call `except_add` with the current line, the current source
 * and the current function.
 */
#define except_add(ret, msg, tptr) (except_addf((ret), (msg), __LINE__, __FILE__, __func__, (tptr)))

/*
 * macro-function to call `except_addsf` with the current line, the current source
 * and the current function.
 */
#define except_addsf(ret, msg, tptr) (except_addfsf((ret), (msg), __LINE__, __FILE__, __func__, (tptr)))

/*
 * macro-function to call `except_printerrf` with the default format
 * (see `except_deferrfmt`).
 */
#define except_printerr(trbck) (except_printerrf(except_deferrfmt, (trbck)))

/*
 * macro-function to call `except_tracebackf()` with the default format
 * (see `except_deffmt`).
 */
#define except_traceback(tptr) (except_tracebackf(except_deffmt, (tptr)))

/* Incomplete structure pointing to an instance of `except`. */
typedef struct except *except;

/* Incomplete structure pointing to an instance of `traceback`. */
typedef struct traceback *traceback;

/* Default format used by `except_printerr()` and can be used by `except_printerrf()`
 * and `except_tracebackf()` */
extern const char *except_deferrfmt;
/* Default format used by `except_traceback()` and can be used by `except_printerrf()`
 * and `except_tracebackf()` */
extern const char *except_deffmt;

/*
 * Creates a new instance of `traceback`.
 *
 * Returns:
 *   - If successful, a new instance of `traceback` is returned, otherwise a `NULL`
 *     pointer is returned.
 */
traceback     except_newtrbck(void);

/*
 * Appends a new exception pointed to in `tptr`. `ret` is the return value, `msg` a
 * message to describe this exception, `file` is the current source, `func` is the
 * current function calling `except_addf()`. The current `èrrno` will be saved for
 * use by `except_printerrf()` or `except_tracebackf()`.
 *
 * `msg`, `file` and `func` can be set to `NULL` so as not to print them in a call
 * to `except_printerrf()` or `except_printerrf()`.
 *
 * `tptr` can point to `NULL` to do nothing.
 *
 * Returns:
 *   - -1: No more memory can be allocated.
 *   - -2: No more exceptions can be appended.
 *   - 0: There is no errors.
 */
int     except_addf(int ret, const char *msg, long long line, const char *file, const char *func, traceback *tptr);

/*
 * Same as `except_addf()` but if it returns an error, the program will exit.
 */
void    except_addfsf(int ret, const char *msg, long long line, const char *file, const char *func, traceback *tptr);

/*
 * Prints the first error in the trace.
 *
 * `fmt` is the format for customizing the output, and can accept the following specifiers:
 *   - %E: Prints the string returned by `strerror(3)` when `errno` is not equal to `0`.
 *   - %e: Prints `errno`.
 *   - %F: Prints the function when it is not `NULL`.
 *   - %f: Prints the source when it is not `NULL`.
 *   - %L: Prints the line when it is greater than `0`. 
 *   - %l: Prints `-` as many times as the number of levels with spaces to align the output.
 *   - %m: Prints the message when it is not `NULL`.
 *   - %r: Prints the return value.
 *   - %%: Prints `%`.
 *   - any other: Prints the literal meaning.
 */
void    except_printerrf(const char *fmt, traceback t);

/*
 * The function behaves like `except_printerrf()` but prints all exceptions, after
 * which `except_free()` will be called.
 */
void    except_tracebackf(const char *fmt, traceback *tptr);

/*
 * Gets the total number of exceptions.
 */
size_t     except_gettotal(traceback t);

/*
 * Frees an instance pointed to in `tptr`. If the block pointed to in `tptr` is
 * `NULL`, this function does nothing. After executing all operations, `NULL`
 * is set in `tptr`.
 */
void    except_free(traceback *tptr);

#endif
