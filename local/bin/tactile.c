#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main() {
    const char *home = getenv("HOME");
    char qml_path[512];
    if (home) {
        snprintf(qml_path, sizeof(qml_path), "%s/dotfiles/config/tactile/Tactile.qml", home);
    } else {
        snprintf(qml_path, sizeof(qml_path), "/home/han/dotfiles/config/tactile/Tactile.qml");
    }

    execlp("quickshell", "quickshell", "-p", qml_path, NULL);
    return 0;
}
