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

#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "except.h"
#include "overflow.h"

const char *except_deffmt = " %l [ret:%r, errno:%e] <%m> (line:%L, file:%f, func:%F) %E";
const char *except_deferrfmt = "ERROR [ret:%r, errno:%e] <%m> %E";

struct except {
    int err;
    int ret;
    char *msg;
    long long line;
    char *file;
    char *func;
};

struct traceback {
    size_t n;
    except *excs;
};

struct traceback_levels {
    size_t l;
    size_t n;
};

static int  new_except(int ret, const char *msg, long long line, const char *file, const char *func, traceback t);

static char *   copystr(const char *s);

static void     print_traceback(const char *fmt, except e, struct traceback_levels *tl);
static void     print_traceback_flag(char f, except e, struct traceback_levels *tl);

static void     print_multichar(int n, int c);

void
except_addfsf(int ret, const char *msg, long long line, const char *file, const char *func, traceback *tptr)
{
    if (except_addf(ret, msg, line, file, func, tptr) != 0) {
        perror("except_addf()");
        exit(errno);
    }
}

int
except_addf(int ret, const char *msg, long long line, const char *file, const char *func, traceback *tptr)
{
    if (*tptr == NULL)
        return 0;

    if (new_except(ret, msg, line, file, func, *tptr) != 0)
        return -1;

    return 0;
}

traceback
except_newtrbck(void)
{
    traceback t;
    if ((t = (traceback)malloc(sizeof(struct traceback))) == NULL)
        return NULL;

    t->n = 0;
    t->excs = NULL;

    return t;
}

static int
new_except(int ret, const char *msg, long long line, const char *file, const char *func, traceback t)
{
    size_t n = ++t->n;
    if (n >= SIZE_MAX)
        return -2;

    size_t s;
    if (test_swrap_mul(n, sizeof(except), &s) == -1)
        return -2;

    t->excs = (except *)realloc(t->excs, s);
    if (t->excs == NULL)
        return -1;

    size_t i = n - 1;

    t->excs[i] = (except)malloc(sizeof(struct except));

    except e = t->excs[i];
    if (e == NULL) {
        free(t->excs);
        return -1;
    }

    e->ret = ret;
    e->err = errno;
    e->msg = copystr(msg);
    e->line = line;
    e->file = copystr(file);
    e->func = copystr(func);

    return 0;
}

static char *
copystr(const char *s)
{
    return s == NULL ? NULL : strdup(s);
}

void
except_printerrf(const char *fmt, traceback t)
{
    if (t == NULL || t->n == 0) {
        return;
    }

    print_traceback(fmt, t->excs[0],
        (struct traceback_levels[]){ { .n = t->n, .l = 0 } });
}

void
except_tracebackf(const char *fmt, traceback *tptr)
{
    traceback t = *tptr;
    if (t == NULL) {
        return;
    } else if (t->n == 0) {
        except_free(tptr);
        return;
    }

    fprintf(stderr, "Traceback exception (depth:%zd):\n", t->n);
    for (size_t n = t->n, l = 0; n > 0; n--, l++) {
        print_traceback(fmt, t->excs[n - 1],
            (struct traceback_levels[]){ { .n = n, .l = l } });
    }

    except_free(tptr);
}

static void
print_traceback(const char *fmt, except e, struct traceback_levels *tl)
{
    bool doexit = false;
    char c;
    while (!doexit && (c = *fmt++) != '\0') {
        switch (c) {
        case '%':
            if ((c = *fmt++) == '\0')
                doexit = true;
            else
                print_traceback_flag(c, e, tl);
            break;
        default:
            putc(c, stderr);
        }
    }

    fprintf(stderr, "\n");
}

static void
print_traceback_flag(char f, except e, struct traceback_levels *tl)
{
        switch (f) {
        case 'E':
            if (errno != 0)
                fprintf(stderr, "%s", strerror(errno));
            break;
        case 'e':
            fprintf(stderr, "%d", errno);
            break;
        case 'F':
            if (e->func != NULL)
                fprintf(stderr, "%s", e->func);
            break;
        case 'f':
            if (e->file != NULL)
                fprintf(stderr, "%s", e->file);
            break;
        case 'L':
            if (e->line > 0)
                fprintf(stderr, "%lld", e->line);
            break;
        case 'l':
            print_multichar(tl->n, '-');
            print_multichar(tl->l, ' ');
            break;
        case 'm':
            if (e->msg != NULL)
                fprintf(stderr, "%s", e->msg);
            break;
        case 'r':
            fprintf(stderr, "%d", e->ret);
            break;
        case '%':
            putc('%', stderr);
            break;
        default:
            break;
        }
}

static void
print_multichar(int n, int c)
{
    while (n-- > 0)
        fprintf(stderr, "%c", (unsigned char)c);
}

size_t
except_gettotal(traceback t)
{
    return t->n;
}

void
except_free(traceback *tptr)
{
    traceback t = *tptr;

    if (t == NULL)
        return;

    except e;
    while (t->n-- > 0) {
        e = t->excs[t->n];
        if (e == NULL)
            continue;

        free(e->msg);
        free(e->file);
        free(e->func);
        free(e);
    }

    free(t->excs);
    free(t);

    *tptr = NULL;
}
