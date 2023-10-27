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

#include <err.h>
#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>

static void     usage(void);

static void     raise_atoi_exception(const char *s);

static void     raise_invalid_number(int n);

static int      safe_atoi(const char *s, int *ret_i);

int
main(int argc, char **argv)
{
    if (argc < 2)
        usage();

    int begin = 0;

    if (safe_atoi(argv[1], &begin) != 0)
        raise_atoi_exception(argv[1]);

    if (begin < 0)
        raise_invalid_number(begin);

    if (argc == 2) {
        printf("%d\n", begin);

        return EX_OK;
    }

    int n = (argc - 2);

    for (int i = 0; i < n; i++) {
        int k = i + 2;
        int x = 0;

        if (safe_atoi(argv[k], &x) != 0)
            raise_atoi_exception(argv[k]);

        if (x < 0)
            raise_invalid_number(x);

        if (begin == x)
            begin++;
    }

    printf("%d\n", begin);

    return EX_OK;
}

static void
raise_atoi_exception(const char *s)
{
    if (errno != 0) {
        if (errno != 0)
            err(EX_SOFTWARE, "atol()");
        else
            errx(EX_SOFTWARE, "Could not convert %s to an integer.", s);
    }
}

static void
raise_invalid_number(int n)
{
    errx(EX_DATAERR, "%d: Invalid number.", n);
}

static int
safe_atoi(const char *s, int *ret_i)
{
    char *x = NULL;
    long l;

    errno = 0;
    l = strtol(s, &x, 0);

    if (!x || x == s || *x || errno)
        return errno > 0 ? -errno : -EINVAL;

    if ((long)(int)l != l)
        return -ERANGE;

    *ret_i = (int)l;

    return 0;
}

static void
usage(void)
{
    errx(EX_USAGE, "%s",
         "usage: find-number-from-start begin [number1 ... numberN]");
}
