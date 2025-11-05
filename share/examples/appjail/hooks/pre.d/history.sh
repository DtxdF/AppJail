#!/bin/sh

#
# Remember that AppJail calls itself, so ~/.appjail_history will easily grow,
# especially in scripts that perform polling such as appjail-dns or Overlord.
# This hook is only useful for demonstration or debugging purposes.
#

DATETIME=`date +"%Y-%m-%d.%H:%M:%S"` || exit $?

printf "%s\n" "${DATETIME} $*" >> ~/.appjail_history || exit $?
