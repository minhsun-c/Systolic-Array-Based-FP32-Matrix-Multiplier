#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "header.h"

#ifndef NN
#define NN 2
#endif

vluint64_t tb_time = 0;
double sc_time_stamp()
{
    return tb_time;
}

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    const char *infile = nullptr;
    for (int i = 1; i < argc; ++i) {
        if (!std::strncmp(argv[i], "-F=", 3))
            infile = argv[i] + 3;
        else if (!std::strncmp(argv[i], "--in=", 5))
            infile = argv[i] + 5;
        else if (!std::strcmp(argv[i], "-F") && i + 1 < argc)
            infile = argv[++i];
    }

    auto *top = new VSystolicArray;
    auto *tfp = new VerilatedVcdC;
    top->trace(tfp, 0);
    tfp->open("build/wave.vcd");

    if (infile) {
        Mat<NN> A{}, B{};
        if (!load_two_mats_txt<NN>(infile, A, B)) {
            std::fprintf(stderr, "Failed to load matrices from %s\n", infile);
            return 1;
        }
        run_mat_case<NN>(top, tfp, infile, A, B);  // pe_latency default=4
    } else {
        // Fallback: your two built-in tests
        Mat<NN> A1{}, B1{};
        for (int i = 0; i < NN; ++i)
            for (int j = 0; j < NN; ++j) {
                A1[i][j] = float(i * NN + j + 1);
                B1[i][j] = (i == j) ? 1.f : 0.f;
            }
        Mat<NN> A2{}, B2{};
        for (int i = 0; i < NN; ++i)
            for (int j = 0; j < NN; ++j) {
                A2[i][j] = 0.5f * (i + 1) - 0.25f * (j + 1);
                B2[i][j] = 0.3f * (j + 1) - 0.2f * (i + 1);
            }
        run_mat_case<NN>(top, tfp, "A*I==A", A1, B1);
        run_mat_case<NN>(top, tfp, "fractional", A2, B2);
    }

    top->final();
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}
