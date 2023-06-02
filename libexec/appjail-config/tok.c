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

#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <unistd.h>

#include "except.h"
#include "word.h"
#include "worderr.h"

static void usage(void);
static void print_words(const char *word, bool quotes);

int
main(int argc, char **argv)
{
    int c;
    bool quotes = false;

    while ((c = getopt(argc, argv, ":Q")) != -1) {
        switch (c) {
            case 'Q':
                quotes = true;
                break;
            default:
                usage();
        }
    }

    char *words = argv[optind++];

    if (words == NULL)
        usage();

    print_words(words, quotes);

    return EXIT_SUCCESS;
}

static void
print_words(const char *words, bool quotes)
{
    word w = NULL;
    traceback trbck = except_newtrbck();

    if (wrdinit(words, &w, quotes, &trbck) != WDERRN) {
        except_printerr(trbck);
        except_free(&trbck);
        wrdfree(&w);
        exit(EXIT_FAILURE);
    }

    for (wordlen i = 0, l = wrdtot(w); i < l; i++)
        printf("%s\n", wrdget(w, i));

    except_free(&trbck);
    wrdfree(&w);
}

static void
usage(void)
{
    fprintf(stderr, "usage: tok [-Q] word\n");
    exit(EX_USAGE);
}
