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
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>

static void     raise_atoi_exception(const char *s);

static void     raise_invalid_number(int n);

static int      safe_atoi(const char *s, int *ret_i);

int
main(int argc, char **argv)
{
    int n = (argc - 1);

    if (n == 0) {
        printf("1\n");

        return EX_OK;
    } else if (n == 1) {
        int first_element = 0;

        if (safe_atoi(argv[1], &first_element) != 0)
            raise_atoi_exception(argv[1]);

        if (first_element <= 0)
            raise_invalid_number(first_element);

        if (first_element == 1) {
            printf("2\n");

            return EX_OK;
        } else {
            printf("1\n");

            return EX_OK;
        }
    }

    int first_element = 0;

    if (safe_atoi(argv[1], &first_element) != 0)
        raise_atoi_exception(argv[1]);

    if (first_element <= 0)
        raise_invalid_number(first_element);

    if (first_element > 1) {
        printf("1\n");

        return EX_OK;
    }

    int i;
    
    for (i = 1; i < n; i++) {
        int x = 0;

        if (safe_atoi(argv[i], &x) != 0)
            raise_atoi_exception(argv[i]);

        if (x <= 0)
            raise_invalid_number(x);

        int y = 0;

        if (safe_atoi(argv[i+1], &y) != 0)
            raise_atoi_exception(argv[i+1]);

        if (y <= 0)
            raise_invalid_number(y);

        if (x == (y - 1))
            continue;

        printf("%d\n", x + 1);

        return EX_OK;
    }

    int last_element = 0;

    if (safe_atoi(argv[i], &last_element) != 0)
        raise_atoi_exception(argv[i]);

    if (last_element <= 0)
        raise_invalid_number(last_element);

    printf("%d\n", last_element + 1);

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
