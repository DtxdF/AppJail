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

#include <stddef.h>

/* Although `template` is intended to be generic, the following
 * parameters were extracted from jail(8).
 *
 * NOTE: `template_parameters` MUST be sorted using qsort(3):
 *
 * ```c
 * #include <stdio.h>
 * #include <stdlib.h>
 * #include <string.h>
 *
 * static int  compar(const void *, const void *);
 *
 * static char *template_parameters[] = {
 *     "...",
 * };
 *
 * static size_t template_parameters_total = sizeof(template_parameters) / sizeof(template_parameters[0]);
 *
 * int
 * main(void)
 * {
 *     qsort((void *)template_parameters, template_parameters_total, sizeof(template_parameters[0]), compar);
 *
 *     printf("const char *template_parameters[] = {\n");
 *     for (size_t i = 0; i < template_parameters_total; i++)
 *         printf("    \"%s\",\n", template_parameters[i]);
 *     printf("};\n");
 *
 *     return EXIT_SUCCESS;
 * }
 *
 * static int
 * compar(const void *s1, const void *s2)
 * {
 *     return strcmp(*(const char **)s1, *(const char **)s2);
 * }
 * ```
 */

const char *template_parameters[] = {
    "allow.chflags",
    "allow.dying",
    "allow.mlock",
    "allow.mount",
    "allow.mount.devfs",
    "allow.mount.fdescfs",
    "allow.mount.fusefs",
    "allow.mount.linprocfs",
    "allow.mount.linsysfs",
    "allow.mount.nodevfs",
    "allow.mount.nofdescfs",
    "allow.mount.nofusefs",
    "allow.mount.nolinprocfs",
    "allow.mount.nolinsysfs",
    "allow.mount.nonullfs",
    "allow.mount.noprocfs",
    "allow.mount.notmpfs",
    "allow.mount.nozfs",
    "allow.mount.nullfs",
    "allow.mount.procfs",
    "allow.mount.tmpfs",
    "allow.mount.zfs",
    "allow.nochflags",
    "allow.nodying",
    "allow.nomlock",
    "allow.nomount",
    "allow.noquotas",
    "allow.noraw_sockets",
    "allow.noread_msgbuf",
    "allow.noreserved_ports",
    "allow.noset_hostname",
    "allow.nosocket_af",
    "allow.nosuser",
    "allow.nosysvipc",
    "allow.nounprivileged_proc_debug",
    "allow.novmm",
    "allow.quotas",
    "allow.raw_sockets",
    "allow.read_msgbuf",
    "allow.reserved_ports",
    "allow.set_hostname",
    "allow.socket_af",
    "allow.suser",
    "allow.sysvipc",
    "allow.unprivileged_proc_debug",
    "allow.vmm",
    "children.cur",
    "children.max",
    "command",
    "depend",
    "devfs_ruleset",
    "enforce_statfs",
    "exec.clean",
    "exec.consolelog",
    "exec.created",
    "exec.fib",
    "exec.jail_user",
    "exec.noclean",
    "exec.nosystem_jail_user",
    "exec.poststart",
    "exec.poststop",
    "exec.prepare",
    "exec.prestart",
    "exec.prestop",
    "exec.release",
    "exec.start",
    "exec.stop",
    "exec.system_jail_user",
    "exec.system_user",
    "exec.timeout",
    "host",
    "host.domainname",
    "host.hostid",
    "host.hostname",
    "host.hostuuid",
    "interface",
    "ip4",
    "ip4.addr",
    "ip4.addr",
    "ip4.nosaddrsel",
    "ip4.saddrsel",
    "ip6",
    "ip6.addr",
    "ip6.addr",
    "ip6.nosaddrsel",
    "ip6.saddrsel",
    "ip_hostname",
    "jid",
    "linux",
    "linux.osname",
    "linux.osrelease",
    "linux.oss_version",
    "mount",
    "mount.devfs",
    "mount.fdescfs",
    "mount.fstab",
    "mount.nodevfs",
    "mount.nofdescfs",
    "mount.noprocfs",
    "mount.procfs",
    "noip_hostname",
    "nopersist",
    "osreldate",
    "osrelease",
    "persist",
    "securelevel",
    "stop.timeout",
    "sysvmsg",
    "sysvsem",
    "sysvshm",
    "vnet",
    "vnet.interface",
};

size_t template_parameters_total = sizeof(template_parameters) / sizeof(template_parameters[0]);
