#!/bin/sh

exec >&2

test $# -gt 0 || exit 0

STAGE="$1"; shift

test $# -gt 0 || exit 0

case "${STAGE}" in
    start) ;;
    *) exit 0 ;;
esac

while getopts ":" OPT; do
    case "${OPT}" in
        --) break ;;
        *) continue ;;
    esac
done
shift $((OPTIND-1))

test $# -gt 0 || exit 0

JAIL="$1"

appjail label get -l "load-kld" -- "${JAIL}" value > /dev/null 2>&1 || exit 0

LABELS=`appjail label list -eHIpt -- "${JAIL}" name` || exit $?

test -n "${LABELS}"  || exit $?

. /etc/rc.subr

for name in ${LABELS}; do
    case "${name}" in
        # We'll get this later.
        load-kld.*.regex|load-kld.*.module) continue ;;
        load-kld.*) ;;
        *) continue ;;
    esac

    regex=`appjail label get -l "${name}.regex" "${JAIL}" value 2> /dev/null`

    if [ -z "${regex}" ]; then
        module=`appjail label get -l "${name}.module" "${JAIL}" value 2> /dev/null`
    fi

    file=`appjail label get -l "${name}" "${JAIL}" value` || exit $?

    if [ -n "${regex}" ]; then
        load_kld -e "${regex}" "${file}" || exit $?
    elif [ -n "${module}" ]; then
        load_kld -m "${module}" "${file}" || exit $?
    else
        load_kld "${file}" || exit $?
    fi
done

exit 0
