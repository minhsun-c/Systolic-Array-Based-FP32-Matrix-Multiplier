#include "gen.h"

int main(int args, char *argv[])
{
    const int size = atoi(argv[1]);
    const int width = atoi(argv[2]);
    printModule(size, width);
}
