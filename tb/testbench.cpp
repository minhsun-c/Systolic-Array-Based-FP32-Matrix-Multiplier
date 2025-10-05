#include "header.h"

vluint64_t tb_time = 0;  // single definition
double sc_time_stamp()
{
    return tb_time;
}  // used by Verilator tracing

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    auto *top = new VSystolicArray;
    auto *tfp = new VerilatedVcdC;
    top->trace(tfp, 0);
    tfp->open("build/SYS2.vcd");

    // Active-low reset
    top->reset = 0;
    drive_zero(top);
    tick(top, tfp);
    tick(top, tfp);
    top->reset = 1;

    // --- Define normal 2x2 matrix tests ---
    MatCase t1{.name = "int-ish small",
               .A = {{1.0f, 2.0f}, {3.0f, 4.0f}},
               .B = {{5.0f, 6.0f}, {7.0f, 8.0f}},
               .drain_cycles = 30};

    MatCase t2{.name = "fractional & negatives",
               .A = {{0.5f, 0.25f}, {-0.75f, 0.5f}},
               .B = {{-1.0f, 0.5f}, {0.25f, -0.875f}},
               .drain_cycles = 30};

    MatCase t3{.name = "identity passthrough",
               .A = {{1.0f, 0.0f}, {0.0f, 1.0f}},
               .B = {{2.5f, -3.0f}, {4.0f, 0.125f}},
               .drain_cycles = 30};

    std::vector<MatCase> tests = {t1, t2, t3};

    for (const auto &tc : tests) {
        run_mat_case(top, tfp, tc);
        // spacer between tests
        drive_zero(top);
        for (int i = 0; i < 6; ++i)
            tick(top, tfp);
    }

    top->final();
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}
