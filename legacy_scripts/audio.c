#include <unistd.h>
int main() {
    execlp("/home/manel/escolinha/scripts/pulseaudio.sh", NULL, NULL);
    return 0;
}