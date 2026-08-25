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
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) return -1;

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;

    if (runtime_dir && strlen(runtime_dir) > 0) {
        if (snprintf(addr.sun_path, sizeof(addr.sun_path), "%s/hypr/%s/.socket.sock", runtime_dir, his) >= (int)sizeof(addr.sun_path)) {
            close(fd);
            return -1;
        }
    } else {
        if (snprintf(addr.sun_path, sizeof(addr.sun_path), "/run/user/%d/hypr/%s/.socket.sock", getuid(), his) >= (int)sizeof(addr.sun_path)) {
            close(fd);
            return -1;
        }
    }

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
    const char *dir = (argc > 1) ? argv[1] : "left";

    // 1. Query active window JSON
    char buf[8192];
    const char *deck_tag = NULL;
    if (send_hypr_cmd("j/activewindow", buf, sizeof(buf)) == 0 && strlen(buf) > 0) {
        deck_tag = strstr(buf, "special:");
    }

    // 2. If active window didn't have a special workspace, check if a special workspace is visible on the monitor
    if (!deck_tag) {
        char mon_buf[8192];
        if (send_hypr_cmd("j/monitors", mon_buf, sizeof(mon_buf)) == 0 && strlen(mon_buf) > 0) {
            deck_tag = strstr(mon_buf, "special:");
        }
    }

    // 3. Scratchpad Deck Navigation Mode
    if (deck_tag) {
        if (strcmp(dir, "up") == 0 || strcmp(dir, "u") == 0) {
            execlp("scratchpad-deck", "scratchpad-deck", "prev", NULL);
            return 0;
        } else if (strcmp(dir, "down") == 0 || strcmp(dir, "d") == 0) {
            execlp("scratchpad-deck", "scratchpad-deck", "next", NULL);
            return 0;
        } else if (strcmp(dir, "left") == 0 || strcmp(dir, "l") == 0) {
            send_hypr_cmd("dispatch hl.dsp.focus { direction = \"l\" }", NULL, 0);
            return 0;
        } else if (strcmp(dir, "right") == 0 || strcmp(dir, "r") == 0) {
            send_hypr_cmd("dispatch hl.dsp.focus { direction = \"r\" }", NULL, 0);
            return 0;
        }
    }

    // 4. Standard main workspace directional focus
    char cmd[128];
    char hl_dir = 'l';
    if (strcmp(dir, "right") == 0 || strcmp(dir, "r") == 0) hl_dir = 'r';
    else if (strcmp(dir, "up") == 0 || strcmp(dir, "u") == 0) hl_dir = 'u';
    else if (strcmp(dir, "down") == 0 || strcmp(dir, "d") == 0) hl_dir = 'd';

    snprintf(cmd, sizeof(cmd), "dispatch hl.dsp.focus { direction = \"%c\" }", hl_dir);
    send_hypr_cmd(cmd, NULL, 0);
    return 0;
}
