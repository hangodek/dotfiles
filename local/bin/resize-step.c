#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

static int send_hypr_cmd(const char *cmd, char *response_buf, size_t buf_size) {
    const char *his = getenv("HYPRLAND_INSTANCE_SIGNATURE");
    if (!his) return -1;

    const char *runtime_dir = getenv("XDG_RUNTIME_DIR");
    char sock_path[512];
    if (runtime_dir && strlen(runtime_dir) > 0) {
        snprintf(sock_path, sizeof(sock_path), "%s/hypr/%s/.socket.sock", runtime_dir, his);
    } else {
        snprintf(sock_path, sizeof(sock_path), "/run/user/%d/hypr/%s/.socket.sock", getuid(), his);
    }

    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) return -1;

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, sock_path, sizeof(addr.sun_path) - 1);

    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        close(fd);
        return -1;
    }

    if (write(fd, cmd, strlen(cmd)) < 0) {
        close(fd);
        return -1;
    }

    if (response_buf && buf_size > 0) {
        ssize_t n = read(fd, response_buf, buf_size - 1);
        if (n >= 0) {
            response_buf[n] = '\0';
        } else {
            response_buf[0] = '\0';
        }
    }

    close(fd);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        return 0;
    }

    const char *action = argv[1];
    int step = 192; // 10% of standard 1920 width

    if (argc > 2) {
        double ratio = atof(argv[2]);
        if (ratio > 0.0) {
            step = (int)(1920.0 * ratio);
        }
    }

    int delta = 0;
    if (strcmp(action, "expand") == 0) {
        delta = step;
    } else if (strcmp(action, "shrink") == 0) {
        delta = -step;
    } else {
        return 0;
    }

    char cmd[128];
    snprintf(cmd, sizeof(cmd), "dispatch hl.dsp.window.resize { x = %d, y = 0, relative = true }", delta);
    send_hypr_cmd(cmd, NULL, 0);
    return 0;
}
