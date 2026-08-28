#include <err.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/socket.h>
#include <sys/syscall.h>
#include <sysexits.h>
#include <unistd.h>

static int mksock(const char *path);
static void usage(void);

#ifndef UNIX_PATH_MAX
#define UNIX_PATH_MAX (sizeof(((struct sockaddr_un *)0)->sun_path))
#endif

int
main(int argc, char **argv)
{
    const char *unixpath;

    if ((unixpath = argv[1]) == NULL) {
        usage();
        return EX_USAGE;
    }

    if (mksock(unixpath) == -1)
        err(EX_SOFTWARE, "mksock(%s)", unixpath);

    return EX_OK;
}

static int
mksock(const char *path)
{
    size_t pathlen;
    size_t salen;
    struct sockaddr_un sa = {0};
    int fd;

    if ((pathlen = strlen(path)) >= UNIX_PATH_MAX) {
        errno = ENAMETOOLONG;
        return -1;
    }

    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1)
        return -1;

    sa.sun_family = AF_UNIX;

    (void)memcpy(sa.sun_path, path, pathlen);
    salen = SUN_LEN(&sa);

    if (bind(fd, (struct sockaddr *)&sa, salen) == -1)
        return -1;

    if (close(fd) == -1)
        return -1;

    return 0;
}

static void
usage(void)
{
    fprintf(stderr, "usage: mksock <path>\n");
}
