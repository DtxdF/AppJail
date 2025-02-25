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

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <err.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>
#include <unistd.h>

static int	check_ipv4(const char *address);
static int	check_ipv6(const char *address);
static void	usage(void);

int
main(int argc, char **argv)
{
	int c;
	int rc = 0;;
	bool ipv4, ipv6;
	char *address = NULL;

	ipv4 = ipv6 = false;

	while ((c = getopt(argc, argv, "4:6:")) != -1) {
		switch (c) {
		case '4':
			address = optarg;
			ipv4 = true;
			break;
		case '6':
			address = optarg;
			ipv6 = true;
			break;
		case '?':
		default:
			usage();
		}
	}

	if (ipv4 == ipv6)
		usage();

	if (ipv4)
		rc = check_ipv4(address);
	else if (ipv6)
		rc = check_ipv6(address);
	else
		usage();

	return rc;
}

static int
check_ipv4(const char *address)
{
	int rc = 0;
	struct in_addr addr;

	switch ((rc = inet_pton(AF_INET, address, &addr))) {
	case 1:
		/* Valid */
		rc = 0;
		break;
	case 0:
		/* Invalid */
		rc = 1;
		break;
	case -1:
		/* Error */
		err(EX_SOFTWARE, "inet_pton()");
		break;
	}

	return rc;
}

static int
check_ipv6(const char *address)
{
	int rc = 0;
	struct in6_addr addr;

	switch ((rc = inet_pton(AF_INET6, address, &addr))) {
	case 1:
		/* Valid */
		rc = 0;
		break;
	case 0:
		/* Invalid */
		rc = 1;
		break;
	case -1:
		/* Error */
		err(EX_SOFTWARE, "inet_pton()");
		break;
	}

	return rc;
}

static void
usage(void)
{
	errx(EX_USAGE, "%s",
		"usage: ipcheck [-4 | -6] address");
}
