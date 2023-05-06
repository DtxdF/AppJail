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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "buff.h"
#include "bufferr.h"
#include "except.h"
#include "overflow.h"

#define BUFF_TRBCK(ret) except_addsf(ret, buferr(ret), trbck)

struct buff {
    char *b;
    size_t i;
    size_t l;
    size_t m;
};

int
bufinit(size_t l, buff *bptr, traceback *trbck)
{
    if (l <= 1) {
        BUFF_TRBCK(BFERRI);
        return BFERRI;
    }

    buff b;
    if ((b = (buff)malloc(sizeof(struct buff))) == NULL) {
        BUFF_TRBCK(BFERRG);
        return BFERRG;
    }

    b->b = NULL;
    b->i = 0;
    b->l = l;
    b->m = 0;

    *bptr = b;

    return BFERRN;
}

int
bufcopy(const char *s, buff b, traceback *trbck)
{
    char c;
    while ((c = *s++) != '\0') {
        if (bufadd(c, b, trbck) != BFERRN) {
            BUFF_TRBCK(BFERRO);
            return BFERRO;
        }
    }

    return BFERRN;
}

int
bufadd(char c, buff b, traceback *trbck)
{
    if ((b->i % b->l) == 0) {
        size_t m = b->m + 1;
        if (m >= SIZE_MAX) {
            BUFF_TRBCK(BFERRM);
            return BFERRM;
        }

        size_t s, l = b->l;
        if (test_swrap_mul(l, m, &s) == -1) {
            BUFF_TRBCK(BFERRM);
            return BFERRM;
        }
        
        /* Total. */
        size_t t;
        if (test_swrap_add(s, sizeof('\0'), &t) == -1) {
            BUFF_TRBCK(BFERRM);
            return BFERRM;
        }

        if ((b->b = (char *)realloc(b->b, t)) == NULL) {
            BUFF_TRBCK(BFERRG);
            return BFERRG;
        }

        b->m = m;
    }

    size_t i = b->i;

    if (++i >= SIZE_MAX) {
        BUFF_TRBCK(BFERRM);
        return BFERRM;
    }

    b->b[i - 1] = c;
    b->b[i] = '\0';

    b->i = i;

    return BFERRN;
}

char *
bufget(buff b)
{
    return b->b;
}

size_t
buflen(buff b)
{
    return b->i;
}

void
bufperr(const char *s, int e)
{
    fprintf(stderr, "%s: %s\n", s, buferr(e));
}

const char *
buferr(int e)
{
    if (e > 0)
        return NULL;
    else
        e = -e;

    static const char *estr[] = {
        "No error (BFERRN).",
        "Generic error (BFERRG).",
        "Invalid argument (BFERRI).",
        "Error in a operation (BFERRO).",
        "No more characters can be appended (BFERRM).",
    };

    size_t etot = sizeof(estr) / sizeof(estr[0]);

    if ((size_t)e >= etot)
        return NULL;

    return estr[e];
}

void
buffree(buff *bptr)
{
    buff b = *bptr;
    if (b == NULL)
        return;

    free(b->b);
    free(b);

    *bptr = NULL;
}
