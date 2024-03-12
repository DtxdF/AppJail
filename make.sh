#!/bin/sh

#
# Script designed to be run for development purposes only.
#

"${SUEXEC:-doas}" make APPJAIL_VERSION=`make -V APPJAIL_VERSION`+`git rev-parse HEAD`
