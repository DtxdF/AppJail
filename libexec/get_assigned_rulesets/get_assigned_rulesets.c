/*
 * Copyright (c) 2024, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
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
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <sys/syscall.h>
#include <errno.h>
#include <unistd.h>

#define DEVFS_MAX_LENGTH 20

int
main(int argc, char **argv)
{
    char *dn;
    if ((dn = argv[1]) == NULL) {
        fprintf(stderr, "usage: %s <directory>\n", argv[0]);
        return EX_USAGE;
    }

    if (chdir(dn) == -1)
        err(EX_IOERR, "chdir()");

    DIR *dirp;

    if ((dirp = opendir(".")) == NULL)
        err(EX_IOERR, "opendir()");

    errno = 0;

    char *pn = NULL;

    struct dirent *dp;

    while ((dp = readdir(dirp)) != NULL) {
        char *fn = dp->d_name;

        if (strcmp(fn, ".") == 0 || strcmp(fn, "..") == 0)
            continue;

        char *suffix = "conf/boot/devfs_ruleset";
        size_t size = dp->d_namlen + sizeof('/') + strlen(suffix);
        pn = malloc(sizeof(char) * size);

        snprintf(pn, size, "%s/%s", fn, suffix);

        if (eaccess(pn, R_OK) == -1) {
            free(pn);
            pn = NULL;
            errno = 0;
            continue;
        }

        FILE *fp;

        if ((fp = fopen(pn, "r")) == NULL) {
            perror("fopen()");
            free(pn);
            pn = NULL;
            continue;
        }

        size_t length;
        char devfs_ruleset[DEVFS_MAX_LENGTH];

        if ((length = fread(devfs_ruleset, sizeof(char), sizeof(devfs_ruleset), fp)) == 0) {
            if (ferror(fp) != 0)
                perror("fread()");

            fclose(fp);
            free(pn);
            pn = NULL;
            continue;
        }

        fclose(fp);

        devfs_ruleset[length--] = '\0';

        while (length > 0 && isspace(devfs_ruleset[length]) != 0)
            devfs_ruleset[length--] = '\0';

        printf("%s\n", devfs_ruleset);

        free(pn);
        pn = NULL;
    }

    if (pn != NULL)
        free(pn);

    if (errno != 0)
        err(EX_IOERR, "readdir()");

    closedir(dirp);

    return EX_OK;
}
