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

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "buff.h"
#include "bufferr.h"
#include "except.h"
#include "word.h"
#include "worderr.h"

#define WORD_CDQUOTE    '"'
#define WORD_CSQUOTE    '\''
#define WORD_CESCAPE    '\\'
#define WORD_CSPACE     ' '
#define WORD_CNULL      '\0'

#define NULL_DELIM  -1

#define WORD_TRBCK(ret) except_addsf(ret, wrderr(ret), trbck)

enum states {
    WRITE, ESCAPE, NEW_WORD, WORD_WITH_WRITE, IGNORE, END
};

struct word {
    wordlen n;
    buff *b;
};

static int  prv_test_wlwrap_mul(wordlen a, wordlen b, wordlen *r);

int
wrdinit(const char *s, word *wptr, bool quotes, traceback *trbck)
{
    word w = NULL;
    int c, d = NULL_DELIM;
    enum states st;
    int err = WDERRN;

    if (wrdcreat(&w, trbck) != WDERRN) {
        WORD_TRBCK(WDERRB);
        return WDERRB;
    }

    if (wrdnew(w, trbck) != WDERRN) {
        WORD_TRBCK(WDERRW);
        wrdfree(&w);
        return WDERRW;
    }

    for (;;) {
        switch ((c = *s++)) {
        case WORD_CDQUOTE:
        case WORD_CSQUOTE:
            if (d == NULL_DELIM) {
                d = c;
                if (quotes)
                    st = WRITE;
                else
                    st = IGNORE;
            } else if (d == c) {
                d = NULL_DELIM;
                if (quotes)
                    st = WORD_WITH_WRITE;
                else
                    st = NEW_WORD;
            } else {
                st = WRITE;
            }
            break;
        case WORD_CESCAPE:
            if ((c = *s++) == WORD_CNULL) {
                err = WDERRS;
                st = END;
            } else if (c == d || c == WORD_CESCAPE) {
                if (quotes)
                    st = ESCAPE;
                else
                    st = WRITE;
            } else {
                st = ESCAPE;
            }
            break;
        case WORD_CSPACE:
            if (d == NULL_DELIM)
                st = NEW_WORD;
            else
                st = WRITE;
            break;
        case WORD_CNULL:
            if (d != NULL_DELIM)
                err = WDERRS;
            st = END;
            break;
        default:
            st = WRITE;
        }

        switch (st) {
        case ESCAPE:
            if (bufadd(WORD_CESCAPE, w->b[w->n - 1], trbck) != BFERRN) {
                err = WDERRO;
                goto end;
            }
        case WORD_WITH_WRITE:
        case WRITE:
            if (bufadd(c, w->b[w->n - 1], trbck) != BFERRN) {
                err = WDERRO;
                goto end;
            }

            if (st != WORD_WITH_WRITE)
                break;
        case NEW_WORD:
            if (buflen(w->b[w->n - 1]) == 0)
                continue;
            if (wrdnew(w, trbck) != WDERRN) {
                err = WDERRW;
                goto end;
            }
            break;
        case IGNORE:
            break;
        case END:
            goto end;
            break;
        }
    }

end:;

    if (err == WDERRN) {
        if (buflen(w->b[w->n - 1]) == 0) {
            if (wrddel(w, w->n - 1, trbck) != WDERRN) {
                WORD_TRBCK(WDERRO);
                wrdfree(&w);
                return WDERRO;
            }
        }

        *wptr = w;
    } else {
        WORD_TRBCK(err);
        wrdfree(&w);
    }

    return err;
}

int
wrdcreat(word *wptr, traceback *trbck)
{
    word w;
    if ((w = (word)malloc(sizeof(struct word))) == NULL) {
        WORD_TRBCK(WDERRG);
        return WDERRG;
    }
    w->n = 0;
    w->b = NULL;

    *wptr = w;

    return WDERRN;
}

int
wrdnew(word w, traceback *trbck)
{
    wordlen n = w->n + 1;
    if (n >= MAX_WORD) {
        WORD_TRBCK(WDERRM);
        return WDERRM;
    }

    wordlen s;
    if (prv_test_wlwrap_mul(n, (wordlen)sizeof(buff), &s) == -1) {
        WORD_TRBCK(WDERRM);
        return WDERRM;
    }

    if ((w->b = (buff *)realloc(w->b, s)) == NULL) {
        WORD_TRBCK(WDERRG);
        return WDERRG;
    }

    w->n = n;

    if (bufinit(BUFF_MINBUF, &w->b[n - 1], trbck) != BFERRN) {
        WORD_TRBCK(WDERRO);
        return WDERRO;
    }

    return WDERRN;
}

int
wrddel(word w, wordindex i, traceback *trbck)
{
    wordlen n = w->n;
    if (i >= n) {
        WORD_TRBCK(WDERRI);
        return WDERRI;
    }

    buffree(&w->b[i]);

    for (wordindex s = i; s < (n - 1); s++) {
        buff b1 = w->b[s],
             b2 = w->b[s + 1];

        w->b[s] = b2;
        w->b[s + 1] = b1;
    }

    n = --w->n;

    wordlen s;
    if (prv_test_wlwrap_mul(n, (wordlen)sizeof(buff), &s) == -1) {
        WORD_TRBCK(WDERRM);
        return WDERRM;
    }

    w->b = (buff *)realloc(w->b, s);
    if (w->b == NULL) {
        WORD_TRBCK(WDERRG);
        return WDERRG;
    }

    return WDERRN;
}

wordlen
wrdtot(word w)
{
    return w->n;
}

char *
wrdget(word w, wordindex i)
{
    if (i >= w->n)
        return NULL;

    return bufget(w->b[i]);
}

int
wrdset(word w, wordindex i, const char *s, traceback *trbck)
{
    if (i >= w->n) {
        WORD_TRBCK(WDERRI);
        return WDERRI;
    }

    buffree(&w->b[i]);

    if (bufinit(BUFF_MINBUF, &w->b[i], trbck) != BFERRN) {
        WORD_TRBCK(WDERRO);
        return WDERRO;
    }

    if (bufcopy(s, w->b[i], trbck) != BFERRN) {
        WORD_TRBCK(WDERRO);
        return WDERRO;
    }

    return WDERRN;
}

int
wrdadd(word w, const char *s, traceback *trbck)
{
    wordlen n = w->n + 1;
    if (n >= MAX_WORD) {
        WORD_TRBCK(WDERRM);
        return WDERRM;
    }

    wordlen size;
    if (prv_test_wlwrap_mul(n, (wordlen)sizeof(buff), &size) == -1) {
        WORD_TRBCK(WDERRM);
        return WDERRM;
    }

    if ((w->b = (buff *)realloc(w->b, size)) == NULL) {
        WORD_TRBCK(WDERRG);
        return WDERRG;
    }

    w->n = n;

    if (bufinit(BUFF_MINBUF, &w->b[n - 1], trbck) != BFERRN) {
        WORD_TRBCK(WDERRO);
        return WDERRO;
    }

    if (bufcopy(s, w->b[n - 1], trbck) != BFERRN) {
        WORD_TRBCK(WDERRO);
        return WDERRO;
    }

    return WDERRN;
}

static int
prv_test_wlwrap_mul(wordlen a, wordlen b, wordlen *r)
{
    if (a > MAX_WORD / b)
        return -1;

    *r = a * b;

    return 0;
}

void
wrdperr(const char *s, int e)
{
    fprintf(stderr, "%s: %s\n", s, wrderr(e));
}

const char *
wrderr(int e)
{
    if (e > 0)
        return NULL;
    else
        e = -e;

    static const char *estr[] = {
        "No error (WDERRN).",
        "Generic error (WDERRG).",
        "Invalid argument (WDERRI).",
        "Buffer initialization error (WDERRB).",
        "Invalid syntax (WDERRS).",
        "Error in a operation (WDERRO).",
        "Error creating a word (WDERRW).",
        "No more words can be appended (WDERRM).",
    };

    size_t etot = sizeof(estr) / sizeof(estr[0]);

    if ((size_t)e >= etot)
        return NULL;

    return estr[e];
}

void
wrdfree(word *wptr)
{
    word w = *wptr;
    if (w == NULL)
        return;

    while (w->n-- > 0)
        buffree(&w->b[w->n]);

    free(w->b);
    free(w);

    *wptr = NULL;
}
