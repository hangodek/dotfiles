#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        return 0;
    }

    const char *runtime_dir = getenv("XDG_RUNTIME_DIR");
    char sock_path[512];
    if (runtime_dir && strlen(runtime_dir) > 0) {
        snprintf(sock_path, sizeof(sock_path), "%s/tactile-control.sock", runtime_dir);
    } else {
        snprintf(sock_path, sizeof(sock_path), "/run/user/%d/tactile-control.sock", getuid());
    }

    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd >= 0) {
        struct sockaddr_un addr;
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        strncpy(addr.sun_path, sock_path, sizeof(addr.sun_path) - 1);

        if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) == 0) {
            write(fd, argv[1], strlen(argv[1]));
            close(fd);
            return 0;
        }
        close(fd);
    }

    // Fallback: execute standalone python helper if daemon control socket is unavailable
    const char *home = getenv("HOME");
    char script_path[512];
    if (home) {
        snprintf(script_path, sizeof(script_path), "%s/dotfiles/local/bin/swap-window.py", home);
    } else {
        snprintf(script_path, sizeof(script_path), "/home/han/dotfiles/local/bin/swap-window.py");
    }

    execlp("python3", "python3", script_path, argv[1], NULL);
    return 0;
}
