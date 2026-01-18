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

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "buff.h"
#include "bufferr.h"
#include "except.h"
#include "parameters.h"
#include "template.h"
#include "templateerr.h"
#include "util.h"
#include "word.h"
#include "worderr.h"

#define TEMPLATE_OPTN   8
#define TEMPLATE_OVAR   0
#define TEMPLATE_OSTART 1
#define TEMPLATE_OEND   2
#define TEMPLATE_OAPPN  3
#define TEMPLATE_OSET   4
#define TEMPLATE_OPARAM 5
#define TEMPLATE_OSPACE 6
#define TEMPLATE_OREQ   7

#define TEMPLATE_CREQ   '*'
#define TEMPLATE_CVAR   '$'
#define TEMPLATE_CSTART '{'
#define TEMPLATE_CEND   '}'
#define TEMPLATE_CAPPN  '+'
#define TEMPLATE_CSET   ':'

#define TEMPLATE_TRBCK(ret) except_addsf(ret, template_strerr(ret), trbck)

enum states { WRITE, IGNORE, END };

struct param {
    buff k;
    buff v;
    word c;
    char *l;
    bool o[TEMPLATE_OPTN];
    bool g;
    bool i;
};

struct template {
    templatelen n;
    param *p;
};

static int  parse(const char *fn, template t, traceback *trbck);

static int  compar_str(const void * s1, const void *s2);

static int  get_option(int o, param p, traceback *trbck);

static int  set_option(int o, param p, traceback *trbck);

static int  unset_option(int o, param p, traceback *trbck);

static void     freeline(param p);

static int  columns2value(param p, traceback *trbck);

static int  prv_test_tlwrap_mul(templatelen a, templatelen b, templatelen *r);

int
template_init(const char *fn, template *tptr, traceback *trbck)
{
    if (template_create(tptr, trbck) != TPERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    if (parse(fn, *tptr, trbck) != TPERRN) {
        TEMPLATE_TRBCK(TPERRP);
        template_free(tptr);
        return TPERRP;
    }

    return TPERRN;
}

int
template_create(template *tptr, traceback *trbck)
{
    template t;
    if ((t = (template)malloc(sizeof(struct template))) == NULL) {
        TEMPLATE_TRBCK(TPERRG);
        return TPERRG;
    }
    t->n = 0;
    t->p = NULL;

    *tptr = t;
    
    return TPERRN;
}

static int
parse(const char *fn, template t, traceback *trbck)
{
    int err = TPERRN;

    FILE *f;
    if ((f = fopen(fn, "r")) == NULL) {
        TEMPLATE_TRBCK(TPERRG);
        return TPERRG;
    }

    size_t len = 0;
    char *l = NULL;
    ssize_t r = 0;
    while ((r = getline(&l, &len, f)) != -1) {
        if (template_newparam(t, NULL, trbck) != TPERRN) {
            TEMPLATE_TRBCK(TPERRC);
            err = TPERRC;
            break;
        }

        if (template_setparam(l, t->p[t->n - 1], trbck) != TPERRN) {
            TEMPLATE_TRBCK(TPERRP);
            err = TPERRP;
            break;
        }
    }

    if (err != TPERRN && ferror(f) != 0) {
        TEMPLATE_TRBCK(TPERRG);
        err = TPERRG;
    }

    free(l);
    fclose(f);

    return err;
}

int
template_newparam(template t, templateindex *i, traceback *trbck)
{
    templateindex n = t->n + (templateindex)1;
    if (n >= MAX_TEMPLATE) {
        TEMPLATE_TRBCK(TPERRM);
        return TPERRM;
    }

    templatelen s;
    if (prv_test_tlwrap_mul(n, sizeof(param), &s) == -1) {
        TEMPLATE_TRBCK(TPERRM);
        return TPERRM;
    }

    if ((t->p = (param *)realloc(t->p, s)) == NULL) {
        TEMPLATE_TRBCK(TPERRG);
        return TPERRG;
    }

    t->n = n;

    /* If malloc() fails, this will point to NULL. */
    t->p[n - 1] = NULL;

    param p;
    if ((p = (param)malloc(sizeof(struct param))) == NULL) {
        TEMPLATE_TRBCK(TPERRG);
        return TPERRG;
    }

    p->k = NULL;
    p->v = NULL;
    p->c = NULL;
    p->l = NULL;
    p->g = false;
    p->i = false;

    for (int i = 0; i < TEMPLATE_OPTN; i++)
        p->o[i] = false;

    t->p[n - 1] = p;

    /* index */
    if (i != NULL)
        *i = n - ((templateindex)1);

    return TPERRN;
}

int
template_setparam(const char *s, param p, traceback *trbck)
{
    enum states st;

    if (test_empty(s) || test_comment(s)) {
        p->g = true;
        p->l = get_line(s);
        if (p->l == NULL) {
            TEMPLATE_TRBCK(TPERRG);
            return TPERRG;
        }

        return TPERRN;
    } else {
        p->g = false;
    }

    if (bufinit(BUFF_MINBUF, &p->k, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    if (bufinit(BUFF_MINBUF, &p->v, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    buff b = p->k;
    const char *lstr = ltrim(s);
    char c;
    int err = TPERRN;
    bool invalid = false;

    while ((c = *lstr++) != '\0' && c != '\n') {
        if (!get_option(TEMPLATE_OSET, p, NULL)) {
            switch (c) {
            case TEMPLATE_CREQ:
                /* If defined as var, write `*` instead of interpreting 
                 * the literal meaning.
                 */
                if (get_option(TEMPLATE_OVAR, p, NULL)) {
                    st = WRITE;
                    break;
                }
                
                st = IGNORE;
                set_option(TEMPLATE_OREQ, p, NULL);
                break;
            case TEMPLATE_CVAR:
                if (get_option(TEMPLATE_OPARAM, p, NULL))
                    invalid = true;

                if (!invalid && get_option(TEMPLATE_OVAR, p, NULL))
                    invalid = true;

                if (invalid) {
                    st = END;
                    err = TPERRS;
                    break;
                }

                st = WRITE;
                b = p->k;
                set_option(TEMPLATE_OVAR, p, NULL);
                break;
            case TEMPLATE_CSTART:
                if (!get_option(TEMPLATE_OVAR, p, NULL))
                    invalid = true;

                if (invalid) {
                    st = END;
                    err = TPERRS;
                    break;
                }

                st = WRITE;
                set_option(TEMPLATE_OSTART, p, NULL);
                /* Allow writing spaces. */
                set_option(TEMPLATE_OSPACE, p, NULL);
                break;
            case TEMPLATE_CEND:
                if (!get_option(TEMPLATE_OSTART, p, NULL))
                    invalid = true;

                if (invalid) {
                    st = END;
                    err = TPERRS;
                    break;
                }

                st = WRITE;
                set_option(TEMPLATE_OEND, p, NULL);
                break;
            case TEMPLATE_CAPPN:
                /* Invalid if it is not a var or a param. */
                if (!get_option(TEMPLATE_OVAR, p, NULL) \
                    && !get_option(TEMPLATE_OPARAM, p, NULL)) {
                    invalid = true;
                }

                if (!invalid && get_option(TEMPLATE_OVAR, p, NULL)) {
                    /* If it is `${key`, that is, invalid. */
                    if (get_option(TEMPLATE_OSTART, p, NULL))
                        invalid = !get_option(TEMPLATE_OEND, p, NULL);
                }

                if (invalid) {
                    st = END;
                    err = TPERRS;
                    break;
                }

                st = IGNORE;
                set_option(TEMPLATE_OAPPN, p, NULL);
                break;
            case TEMPLATE_CSET:
                /* Same as TEMPLATE_CAPPN. */
                if (!get_option(TEMPLATE_OVAR, p, NULL) \
                    && !get_option(TEMPLATE_OPARAM, p, NULL)) {
                    invalid = true;
                }

                /* Same as TEMPLATE_CAPPN. */
                if (!invalid && get_option(TEMPLATE_OVAR, p, NULL)) {
                    if (get_option(TEMPLATE_OSTART, p, NULL))
                        invalid = !get_option(TEMPLATE_OEND, p, NULL);
                }

                if (invalid) {
                    st = END;
                    err = TPERRS;
                    break;
                }

                st = IGNORE;
                b = p->v;
                set_option(TEMPLATE_OSET, p, NULL);
                break;
            default:
                if (isspace(c) != 0 && \
                    !get_option(TEMPLATE_OSPACE, p, NULL)) {
                    invalid = true;
                }

                if (!invalid && !test_param(c))
                    invalid = true;

                if (invalid) {
                    st = END;
                    err = TPERRS;
                    break;
                }

                st = WRITE;
                b = p->k;
                if (!get_option(TEMPLATE_OVAR, p, NULL))
                    set_option(TEMPLATE_OPARAM, p, NULL);
            }
        } else {
            st = WRITE;
        }

        if (st == WRITE) {
            if (bufadd(c, b, trbck) != BFERRN) {
                err = TPERRO;
                break;
            }
        } else if (st == IGNORE) {
            continue;
        } else if (st == END) {
            break;
        }
    }

    /* Columns */
    if (err == TPERRN \
        && p->v != NULL \
        && bufget(p->v) != NULL \
        && wrdinit(bufget(p->v), &p->c, false, trbck) != WDERRN) {
        err = TPERRO;
    }

    if (err != TPERRN)
        TEMPLATE_TRBCK(err);

    return err;
}

bool
template_checkvar(const char *s)
{
    char c;
    bool vflag, sflag, eflag, cflag;

    /*
     * vflag = TEMPLATE_CVAR
     * sflag = TEMPLATE_CSTART
     * eflag = TEMPLATE_CEND
     * cflag = any
     */

    vflag = sflag = eflag = cflag = false;

    while ((c = *s++) != '\0') {
        switch (c) {
        case TEMPLATE_CVAR:
            if (vflag)
                return false;

            vflag = true;
            break;
        case TEMPLATE_CSTART:
            if (!vflag)
                return false;

            if (cflag)
                return false;

            sflag = true;
            break;
        case TEMPLATE_CEND:
            if (!cflag)
                return false;

            if (!sflag)
                return false;

            eflag = true;
            break;
        default:
            if (!vflag)
                return false;

            if (eflag)
                return false;

            cflag = true;
        }
    }

    bool valid = false;

    /* ${key} */
    if (vflag && sflag && eflag && cflag)
        valid = true;

    /* $key */
    if (!valid && (vflag && cflag)) {
        /* ${key */
        if (!sflag && !eflag)
            valid = true;
    }

    return valid;
}

bool
template_checkparam(const char *s)
{
    /*
     * These are special parameters, as they are dynamic by nature, so comparing them
     * with template_parameters will return false, which is wrong.
     */
    if (strncmp("env.", s, 4) == 0 || strncmp("meta.", s, 5) == 0)
        return true;

    return bsearch(
        (const void *)s,
        (const void *)template_parameters,
        template_parameters_total,
        sizeof(char *),
        compar_str
    ) != NULL;
}

static int
compar_str(const void * s1, const void *s2)
{
    return strcmp((const char *)s1, *(const char **)s2);
}

static int
get_option(int o, param p, traceback *trbck)
{
    if (o < 0 || o >= TEMPLATE_OPTN) {
        TEMPLATE_TRBCK(TPERRI);
        return TPERRI;
    }
    return p->o[o];
}

static int
set_option(int o, param p, traceback *trbck)
{
    if (o < 0 || o >= TEMPLATE_OPTN) {
        TEMPLATE_TRBCK(TPERRI);
        return TPERRI;
    }
    p->o[o] = true;

    return TPERRN;
}

static int
unset_option(int o, param p, traceback *trbck)
{
    if (o < 0 || o >= TEMPLATE_OPTN) {
        TEMPLATE_TRBCK(TPERRI);
        return TPERRI;
    }
    p->o[o] = false;

    return TPERRN;
}

void
template_setignore(param p)
{
    if (p->i)
        return;

    buffree(&p->k);
    buffree(&p->v);
    wrdfree(&p->c);

    p->i = true;
}

bool
template_isignore(param p)
{
    return p->i;
}

void
template_setappend(param p)
{
    set_option(TEMPLATE_OAPPN, p, NULL);
}

void
template_setnappend(param p)
{
    unset_option(TEMPLATE_OAPPN, p, NULL);
}

bool
template_isappend(param p)
{
    return get_option(TEMPLATE_OAPPN, p, NULL);
}

bool
template_isvar(param p)
{
    return get_option(TEMPLATE_OVAR, p, NULL) \
           && !get_option(TEMPLATE_OPARAM, p, NULL);
}

char *
template_getkey(param p)
{
    return p->k == NULL ? NULL : bufget(p->k);
}

int
template_setkey(param p, const char *k, traceback *trbck)
{
    buffree(&p->k);

    if (bufinit(BUFF_MINBUF, &p->k, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    if (bufcopy(k, p->k, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    p->g = false;
    p->i = false;
    freeline(p);

    return TPERRN;
}

static void
freeline(param p)
{
    if (p->l == NULL)
        return;

    free(p->l);
    p->l = NULL;
}

char *
template_getline(param p)
{
    return p->l;
}

int
template_setvalue(param p, const char *v, traceback *trbck)
{
    buffree(&p->v);

    if (bufinit(BUFF_MINBUF, &p->v, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    if (bufcopy(v, p->v, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    wrdfree(&p->c);

    if (wrdinit(v, &p->c, false, trbck) != WDERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }
    
    template_setnrequire(p);

    return TPERRN;
}

char *
template_getvalue(param p)
{
    return p->v == NULL ? NULL : bufget(p->v);
}

wordlen
template_getcolumns(param p)
{
    return p->c == NULL ? 0 : wrdtot(p->c);
}

char *
template_getcolumn(param p, wordindex c)
{
    return p->c == NULL ? NULL : wrdget(p->c, c);
}

int
template_setcolumn(param p, wordindex c, const char *s, traceback *trbck)
{
    if (wrdset(p->c, c, s, trbck) != WDERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    if (columns2value(p, trbck) != TPERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    return TPERRN;
}

int
template_newcolumn(param p, const char *s, traceback *trbck)
{
    if (p->c == NULL && wrdcreat(&p->c, trbck) != WDERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    if (wrdadd(p->c, s, trbck) != WDERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    if (columns2value(p, trbck) != TPERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    return TPERRN;
}

int
template_delcolumn(param p, wordindex c, traceback *trbck)
{
    if (p->c == NULL) {
        TEMPLATE_TRBCK(TPERRI);
        return TPERRI;
    }

    if (wrddel(p->c, c, trbck) != WDERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    if (columns2value(p, trbck) != TPERRN) {
        TEMPLATE_TRBCK(TPERRO);
        return TPERRO;
    }

    return TPERRN;
}

static int
columns2value(param p, traceback *trbck)
{
    buffree(&p->v);
    
    if (bufinit(BUFF_MINBUF, &p->v, trbck) != BFERRN) {
        TEMPLATE_TRBCK(TPERRB);
        return TPERRB;
    }

    int err = TPERRN;
    for (wordlen c = 0, t = template_getcolumns(p); c < t; c++) {
        char *e;
        if ((e = escape_word(template_getcolumn(p, c), trbck)) == NULL) {
            TEMPLATE_TRBCK(TPERRO);
            err = TPERRO;
            break;
        }

        if (bufcopy(e, p->v, trbck) != BFERRN) {
            TEMPLATE_TRBCK(TPERRO);
            free(e);
            err = TPERRO;
            break;
        }

        if (t > 1 && c < (t - 1)) {
            if (bufadd(' ', p->v, trbck) != BFERRN) {
                TEMPLATE_TRBCK(TPERRO);
                free(e);
                err = TPERRO;
                break;
            }
        }

        free(e);
    }

    return err;
}

bool
template_isgarbage(param p)
{
    return p->g;
}

void
template_setrequire(param p)
{
    set_option(TEMPLATE_OREQ, p, NULL);
}

void
template_setnrequire(param p)
{
    unset_option(TEMPLATE_OREQ, p, NULL);
}

bool
template_isrequire(param p)
{
    return get_option(TEMPLATE_OREQ, p, NULL);
}

param
template_getparam(template t, templateindex i)
{
    if (i >= t->n)
        return NULL;

    return t->p[i];
}

param
template_getrow(template t, templateindex r, const char *k)
{
    for (templateindex i = 0, j = 0; i < t->n; i++) {
        param p = t->p[i];

        if (p->g)
            continue;

        if (p->i)
            continue;

        if (strcmp(bufget(p->k), k) != 0)
            continue;

        if (j != r) {
            j++;
            continue;
        }

        return p;
    }

    return NULL;
}

param
template_yieldrow(template t, const char *k, templateindex *s)
{
    templateindex i = *s;
    for (; i < t->n; i++) {
        param p = t->p[i];

        if (p->g)
            continue;

        if (p->i)
            continue;

        if (strcmp(bufget(p->k), k) != 0)
            continue;

        *s = i + 1;

        return p;
    }

    *s = i;

    return NULL;
}

templatelen
template_getrows(template t)
{
    return t->n;
}

int
template_printrows(template t, FILE *stream, traceback *trbck)
{
    for (templatelen l = template_getrows(t), i = 0; i < l; i++) {
        param p = template_getparam(t, i);

        if (template_printrow(p, stream, trbck) != TPERRN) {
            TEMPLATE_TRBCK(TPERRO);
            return TPERRO;
        }
    }

    return TPERRN;
}

int
template_printrow(param p, FILE *stream, traceback *trbck)
{
    #define TEMPLATE_PRINTROW_PRINTF(...) \
        do { \
            if (fprintf(stream, __VA_ARGS__) < 0) { \
                TEMPLATE_TRBCK(TPERRG); \
                return TPERRG; \
            } \
        } while (0)

    if (template_isignore(p))
        return TPERRN;

    if (template_isgarbage(p)) {
        char *l;
        if ((l = template_getline(p)) == NULL)
            l = "";
        TEMPLATE_PRINTROW_PRINTF("%s\n", l);
        return TPERRN;
    }

    if (template_isrequire(p))
        TEMPLATE_PRINTROW_PRINTF("*");

    TEMPLATE_PRINTROW_PRINTF("%s", template_getkey(p));

    char *v = template_getvalue(p);
    if (v != NULL) {
        if (template_isappend(p))
            TEMPLATE_PRINTROW_PRINTF("+");
        TEMPLATE_PRINTROW_PRINTF(": %s", ltrim(v));
    }

    TEMPLATE_PRINTROW_PRINTF("\n");

    return TPERRN;
}

static int
prv_test_tlwrap_mul(templatelen a, templatelen b, templatelen *r)
{
    if (a > MAX_TEMPLATE / b)
        return -1;

    *r = a * b;

    return 0;
}

void
template_perr(const char *s, int e)
{
    fprintf(stderr, "%s: %s\n", s, template_strerr(e));
}

const char *
template_strerr(int e)
{
    if (e > 0)
        return NULL;
    else
        e = -e;

    static const char *estr[] = {
        "No error (TPERRN).",
        "Generic error (TPERRG).",
        "Invalid argument (TPERRI).",
        "Invalid syntax (TPERRS).",
        "Buffer initialization error (TPERRB).",
        "Buffer not initialized (TPERRU).",
        "Parsing error (TPERRP).",
        "Error creating parameter (TPERRC).",
        "Error in a operation (TPERRO).",
        "No more rows can be appended (TPERRM).",
    };

    size_t etot = sizeof(estr) / sizeof(estr[0]);

    if ((size_t)e >= etot)
        return NULL;

    return estr[e];
}

void
template_free(template *tptr)
{
    if (*tptr == NULL)
        return;

    template t = *tptr;
    while (t->n-- > 0)
        template_freeparam(&t->p[t->n]);

    free(t->p);
    free(t);

    *tptr = NULL;
}

void
template_freeparam(param *pptr)
{
    param p = *pptr;
    if (p == NULL)
        return;

    buffree(&p->k);
    buffree(&p->v);
    wrdfree(&p->c);
    freeline(p);
    free(p);

    *pptr = NULL;
}
