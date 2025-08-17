#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gen.h"

static void printModuleInfo(int size, int width);
static void printInterConnects(int size, int width, int direction);
static void printPEs(int size);
static void printPE(int x_index, int y_index);

void printModule(int size, int width)
{
    printModuleInfo(size, width);
    printInterConnects(size, width, HORIZONTAL);
    printInterConnects(size, width, VERTICAL);
    printPEs(size);
    printf("endmodule\n");
}

static void printModuleInfo(int size, int width)
{
    printf("module Systolic_Array%dx%d (\n", size, size);
    printf("\toutput [%d:0]", width - 1);
    for (int i = 0; i < size; i++) {
        NEWLINE();
        printf("\t\t");
        for (int j = 0; j < size; j++)
            printf(" out%d_%d,", i, j);
    }
    NEWLINE();
    printf("\tinput [%d:0]\n\t\t", width - 1);
    for (int i = 0; i < size; i++) {
        printf(" W%d_i,", i);
    }
    NEWLINE();
    printf("\t\t");
    for (int i = 0; i < size; i++) {
        printf(" N%d_i,", i);
    }
    NEWLINE();
    printf("\tinput clk, reset\n");
    printf(");\n");
    NEWLINE();
}

static void printInterConnects(int size, int width, int direction)
{
    char dir[2][5] = {"ROW", "COL"};
    printf("\twire [%d:0]\n", width - 1);
    // ROWi_j
    // COLi_j
    for (int i = 0; i < size; i++) {
        printf("\t\t");
        for (int j = 0; j < size; j++) {
            printf("%s%02d_%02d", dir[direction], i, j);
            if (j < size - 1)
                printf(", ");
        }
        printf("%s", (i == size - 1) ? ";\n" : ",\n");
    }
    NEWLINE();
}

/*
    P_Element PE_00_00 (
        .out(out0_0),	.right_o(ROW00__00_01),	.bottom_o(COL00__00_01),
        .left_i(W0),	.top_i(N0),
        .clk(clk),	.rst_n(reset)
    );
*/

static void printPE(int x_index, int y_index)
{
    printf("\tP_Element PE_%02d_%02d (\n", x_index, y_index);
    printf("\t\t.out(out%d_%d),", x_index, y_index);

    // Horizontal Output: right_o
    printf("\t.right_o(ROW%02d_%02d),", x_index, y_index);

    // Vertical Output: bottom_o
    printf("\t.bottom_o(COL%02d_%02d),\n", x_index, y_index);

    // Horizontal Input
    if (y_index == 0)
        printf("\t\t.left_i(W%d_i),", x_index);
    else
        printf("\t\t.left_i(ROW%02d_%02d),", x_index, y_index - 1);

    // Vertical Input
    if (x_index == 0)
        printf("\t.top_i(N%d_i),\n", y_index);
    else
        printf("\t.top_i(COL%02d_%02d),\n", x_index - 1, y_index);

    printf("\t\t.clk(clk),\t.rst_n(reset)\n");
    printf("\t);\n");
}

static void printPEs(int size)
{
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printPE(i, j);
        }
    }
}