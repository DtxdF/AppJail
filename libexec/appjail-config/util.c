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
#include <err.h>
#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>

#include "buff.h"
#include "bufferr.h"
#include "except.h"
#include "util.h"

#define UTIL_TRBCK(msg) except_addsf(-1, msg, trbck)

char *
ltrim(const char *s)
{
    while (isspace(*s))
            s++;
    return (char *)s;
}

char *
escape_word(const char *s, traceback *trbck)
{
    buff b = NULL;
    if (bufinit(BUFF_MINBUF, &b, trbck) != BFERRN) {
        UTIL_TRBCK(NULL);
        return NULL;
    }

    if (bufadd('"', b, trbck) != BFERRN) {
        UTIL_TRBCK(NULL);
        buffree(&b);
        return NULL;
    }

    char c;
    while ((c = *s++) != '\0') {
        switch (c) {
        case '"':
        case '\\':
            if (bufadd('\\', b, trbck) != BFERRN) {
                UTIL_TRBCK(NULL);
                buffree(&b);
                return NULL;
            }
        default:
            if (bufadd(c, b, trbck) != BFERRN) {
                UTIL_TRBCK(NULL);
                buffree(&b);
                return NULL;
            }
        }
    }

    if (bufadd('"', b, trbck) != BFERRN) {
        UTIL_TRBCK(NULL);
        buffree(&b);
        return NULL;
    }

    char *e = strdup(bufget(b));
    if (e == NULL) {
        UTIL_TRBCK("strdup()");
        buffree(&b);
        return NULL;
    }

    buffree(&b);

    return e;
}

char *
get_line(const char *s)
{
    char *string, *tofree, *line;

    tofree = string = strdup(s);
    if (string == NULL)
        return NULL;
    line = strsep(&string, "\n");
    line = strdup(line);
    if (line == NULL) {
        free(tofree);
        return NULL;
    }

    free(tofree);

    return line;
}

tparam
get_tparam(const char *s)
{
    #define GETPARAM_SEP_CHAR "="

    char *string, *tofree;

    tofree = string = strdup(s);
    if (string == NULL)
        return NULL;

    tparam p = (tparam)malloc(sizeof(struct tparam));
    if (p == NULL) {
        free(tofree);
        return NULL;
    }

    p->parameter = ltrim(strsep(&string, GETPARAM_SEP_CHAR));
    p->parameter = strdup(p->parameter);

    if (p->parameter == NULL) {
        free(p);
        free(tofree);
        return NULL;
    }

    p->value = strsep(&string, GETPARAM_SEP_CHAR);

    if (p->value != NULL) {
        p->value = strdup(p->value);

        if (p->value == NULL) {
            free(p->parameter);
            free(p);
            free(tofree);
            return NULL;
        }
    }

    free(tofree);

    return p;
}

void
free_tparam(tparam *tptr)
{
    tparam p = *tptr;

    if (p == NULL)
        return;

    free(p->parameter);
    free(p->value);
    free(p);

    *tptr = NULL;
}

char *
get_jail_template(const char *jail)
{
    char *jaildir = get_jaildir(jail);

    char *b = NULL;

    if (asprintf(&b, "%s/%s", jaildir, "conf/template.conf") == -1 \
        && b == NULL) {
        return NULL;
    }

    free(jaildir);

    return b;
}

char *
get_jaildir(const char *jail)
{
    char *jaildir = getenv("APPJAIL_CONFIG_JAILDIR");

    if (jaildir == NULL)
        jaildir = UTIL_JAILDIR;

    char *b = NULL;

    if (asprintf(&b, "%s/%s", jaildir, jail) == -1 \
        && b == NULL) {
        return NULL;
    }

    return b;
}

bool
test_jailname(const char *jail)
{
    char c;
    bool first = true,
         valid = false;

    /* regex: ^[a-zA-Z0-9_][a-zA-Z0-9_-]*$ */

    while (!valid) {
        switch ((c = *jail++)) {
        case '-':
            if (first)
                return false;
            break;
        case '_':
            break;
        case '\0':
            valid = true;
            break;
        default:
            if (isalnum(c) == 0)
                return false;
        }

        first = false;
    }

    return valid;
}

bool
test_empty(const char *s)
{
    char c;

    while ((c = *s++) != '\0' && isspace(c))
        ;

    return c == '\0' || isspace(c);
}

bool
test_comment(const char *s)
{
    const char *c = ltrim(s);

    return c[0] == '#';
}

bool
test_param(int c)
{
    switch ((unsigned char)c) {
    case '-':
    case '_':
    case '.':
        return true;
        break;
    default:
        return isalnum(c) != 0 \
               || isspace(c) != 0;
    }
}

void
print_multichar(int n, int c, FILE *s)
{
    while (n-- > 0)
        fprintf(s, "%c", (unsigned char)c);
}

unsigned long long
safe_strtoull(const char *s)
{
    char *x = NULL;
    unsigned long long l;

    errno = 0;
    l = strtoull(s, &x, 0);

    if (x == NULL || x == s || *x != '\0' || errno != 0) {
        if (errno != EINVAL && errno != ERANGE)
            errno = EINVAL;

        err(EX_DATAERR, "strtoull()");
    }

    return l;
}

bool
safe_strtob(const char *s)
{
    bool result;

    result = safe_strtoull(s);

    if (result == 0)
        return false;
    else if (result == 1)
        return true;
    else
        errx(EX_DATAERR, "Bool requires only 0s and 1s.");
}

char *
safe_strdup(const char *s)
{
    char *copystr;

    errno = 0;

    if ((copystr = strdup(s)) == NULL)
        err(EX_SOFTWARE, "strdup()");

    return copystr;
}
