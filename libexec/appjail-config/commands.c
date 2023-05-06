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

#include "commands.h"

Command commands[] = {
    {
        .isdefault  = false,
        .name       = "check",
        .cmd        = command_cmd_check,
        .help_cmd   = command_help_check,
        .usage_cmd  = command_usage_check,
        .desc       = "Check for invalid parameters, template syntax and other related issues."
    },
    {
        .isdefault  = false,
        .name       = "edit",
        .cmd        = command_cmd_edit,
        .help_cmd   = command_help_edit,
        .usage_cmd  = command_usage_edit,
        .desc       = "Open an editor to edit the template interactively."
    },
    {
        .isdefault  = false,
        .name       = "del",
        .cmd        = command_cmd_del,
        .help_cmd   = command_help_del,
        .usage_cmd  = command_usage_del,
        .desc       = "Delete a parameter."
    },
    {
        .isdefault  = false,
        .name       = "delAll",
        .cmd        = command_cmd_delAll,
        .help_cmd   = command_help_delAll,
        .usage_cmd  = command_usage_delAll,
        .desc       = "Delete all parameters."
    },
    {
        .isdefault  = false,
        .name       = "delColumn",
        .cmd        = command_cmd_delColumn,
        .help_cmd   = command_help_delColumn,
        .usage_cmd  = command_usage_delColumn,
        .desc       = "Delete a column in a parameter."
    },
    {
        .isdefault  = false,
        .name       = "get",
        .cmd        = command_cmd_get,
        .help_cmd   = command_help_get,
        .usage_cmd  = command_usage_get,
        .desc       = "Get the parameter's value."
    },
    {
        .isdefault  = false,
        .name       = "getAll",
        .cmd        = command_cmd_getAll,
        .help_cmd   = command_help_getAll,
        .usage_cmd  = command_usage_getAll,
        .desc       = "Dump all parameters."
    },
    {
        .isdefault  = false,
        .name       = "getColumn",
        .cmd        = command_cmd_getColumn,
        .help_cmd   = command_help_getColumn,
        .usage_cmd  = command_usage_getColumn,
        .desc       = "Get the column's value."
    },
    { 
        .isdefault  = true, 
        .name       = "help", 
        .cmd        = command_cmd_help, 
        .help_cmd   = command_help_help, 
        .usage_cmd  = command_usage_help, 
        .desc       = "Show help for commands." 
    },
    {
        .isdefault  = false,
        .name       = "jailConf",
        .cmd        = command_cmd_jailConf,
        .help_cmd   = command_help_jailConf,
        .usage_cmd  = command_usage_jailConf,
        .desc       = "Convert a template to a jail.conf(5) file."
    },
    {
        .isdefault  = false,
        .name       = "set",
        .cmd        = command_cmd_set,
        .help_cmd   = command_help_set,
        .usage_cmd  = command_usage_set,
        .desc       = "Update a value of an existing parameter or create a new one."
    },
    {
        .isdefault  = false,
        .name       = "setColumn",
        .cmd        = command_cmd_setColumn,
        .help_cmd   = command_help_setColumn,
        .usage_cmd  = command_usage_setColumn,
        .desc       = "Update a column's value in a parameter or create a new one."
    },
    {
        .isdefault  = false,
        .name       = "usage",
        .cmd        = command_cmd_usage,
        .help_cmd   = command_help_usage,
        .usage_cmd  = command_usage_usage,
        .desc       = "Show the syntax of a given command."
    },
};

size_t command_total = sizeof(commands) / sizeof(commands[0]);
