#pragma once
#include <algorithm>
#include <cmath>
#include <cstring>
#include <string>
#include <vector>
#include "VSystolicArray.h"  // Verilated top from your RTL
#include "verilated.h"
#include "verilated_vcd_c.h"

struct Beat {
    float W0, W1, N0, N1;
};

struct MatCase {
    std::string name;
    float A[2][2];
    float B[2][2];
    int drain_cycles = 30;  // generous for 4-stage PE through 2x2 mesh
};

void tick(VSystolicArray *top, VerilatedVcdC *tfp);

void drive_zero(VSystolicArray *top);

void run_mat_case(VSystolicArray *top, VerilatedVcdC *tfp, const MatCase &tc);
