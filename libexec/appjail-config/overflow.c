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

#include <limits.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "overflow.h"

int
test_ullwrap_add(unsigned long long a, unsigned long long b, unsigned long long *r)
{
    if (ULLONG_MAX - a < b)
        return -1;

    *r = a + b;

    return 0;
}

int
test_ullwrap_mul(unsigned long long a, unsigned long long b, unsigned long long *r)
{
    if (a > ULLONG_MAX / b)
        return -1;

    *r = a * b;

    return 0;
}

int
test_swrap_add(size_t a, size_t b, size_t *r)
{
    if (SIZE_MAX - a < b)
        return -1;

    *r = a + b;

    return 0;
}

int
test_swrap_mul(size_t a, size_t b, size_t *r)
{
    if (a > SIZE_MAX / b)
        return -1;

    *r = a * b;

    return 0;
}

int
test_uiwrap_add(unsigned int a, unsigned int b, unsigned int *r)
{
    if (UINT_MAX - a < b)
        return -1;

    *r = a + b;

    return 0;
}

int
test_uiwrap_mul(unsigned int a, unsigned int b, unsigned int *r)
{
    if (a > UINT_MAX / b)
        return -1;

    *r = a * b;

    return 0;
}
