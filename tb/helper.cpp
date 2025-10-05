#include "header.h"

// Provide the sim time from the .cpp (defined once there)
extern vluint64_t tb_time;

// One full clock (falling + rising)
void tick(VSystolicArray *top, VerilatedVcdC *tfp)
{
    top->clk = 0;
    top->eval();
    tb_time += 1;
    if (tfp)
        tfp->dump(tb_time);
    top->clk = 1;
    top->eval();
    tb_time += 1;
    if (tfp)
        tfp->dump(tb_time);
}

// Pack/unpack IEEE-754 float <-> 32-bit
static inline uint32_t packf(float f)
{
    uint32_t u;
    std::memcpy(&u, &f, 4);
    return u;
}
static inline float unpackf(uint32_t u)
{
    float f;
    std::memcpy(&f, &u, 4);
    return f;
}

static inline bool feq(float a, float b, float eps = 1e-5f)
{
    if (std::isnan(a) || std::isnan(b))
        return false;
    return std::fabs(a - b) <=
           eps * std::max(1.0f, std::max(std::fabs(a), std::fabs(b)));
}



// 2x2 wavefront (anti-diagonal) schedule:
// t0: W0=a11, W1=0,    N0=b11, N1=0
// t1: W0=a12, W1=a21,  N0=b21, N1=b12
// t2: W0=0,   W1=a22,  N0=0,   N1=b22
static inline std::vector<Beat> wavefront2x2(const float A[2][2],
                                             const float B[2][2])
{
    return {
        {A[0][0], 0.0f, B[0][0], 0.0f},
        {A[0][1], A[1][0], B[1][0], B[0][1]},
        {0.0f, A[1][1], 0.0f, B[1][1]},
    };
}

void drive_zero(VSystolicArray *top)
{
    top->W0_i = 0;
    top->W1_i = 0;
    top->N0_i = 0;
    top->N1_i = 0;
}

static inline void drive_float_beats(VSystolicArray *top,
                                     VerilatedVcdC *tfp,
                                     const std::vector<Beat> &beats)
{
    for (const auto &b : beats) {
        top->W0_i = packf(b.W0);
        top->W1_i = packf(b.W1);
        top->N0_i = packf(b.N0);
        top->N1_i = packf(b.N1);
        tick(top, tfp);
    }
}

static inline void matmul2x2_ref(const float A[2][2],
                                 const float B[2][2],
                                 float C[2][2])
{
    C[0][0] = A[0][0] * B[0][0] + A[0][1] * B[1][0];
    C[0][1] = A[0][0] * B[0][1] + A[0][1] * B[1][1];
    C[1][0] = A[1][0] * B[0][0] + A[1][1] * B[1][0];
    C[1][1] = A[1][0] * B[0][1] + A[1][1] * B[1][1];
}

static void check_outputs(VSystolicArray *top,
                          const float Cexp[2][2],
                          float eps = 1e-5f)
{
    float o00 = unpackf(top->out0_0);
    float o01 = unpackf(top->out0_1);
    float o10 = unpackf(top->out1_0);
    float o11 = unpackf(top->out1_1);

    printf("Got:\n  [[%.7f, %.7f],\n   [%.7f, %.7f]]\n", o00, o01, o10, o11);
    printf("Exp:\n  [[%.7f, %.7f],\n   [%.7f, %.7f]]\n", Cexp[0][0], Cexp[0][1],
           Cexp[1][0], Cexp[1][1]);

    bool ok = feq(o00, Cexp[0][0], eps) && feq(o01, Cexp[0][1], eps) &&
              feq(o10, Cexp[1][0], eps) && feq(o11, Cexp[1][1], eps);

    if (!ok) {
        fprintf(stderr, "[FAIL] Mismatch (eps=%g)\n", eps);
        std::exit(1);
    }
    puts("[OK] Matrix result matches within tolerance.");
}

static void pulse_reset(VSystolicArray *top, VerilatedVcdC *tfp, int cycles = 2)
{
    // active-low reset
    top->reset = 0;
    top->W0_i = top->W1_i = top->N0_i = top->N1_i = 0;
    for (int i = 0; i < cycles; ++i)
        tick(top, tfp);
    top->reset = 1;
    // give one clean cycle after deassert
    top->W0_i = top->W1_i = top->N0_i = top->N1_i = 0;
    tick(top, tfp);
}

void run_mat_case(VSystolicArray *top, VerilatedVcdC *tfp, const MatCase &tc)
{
    printf("\n=== %s ===\n", tc.name.c_str());

    // reset the register in PE
    pulse_reset(top, tfp);

    // translate matrices to beats and feed
    auto beats = wavefront2x2(tc.A, tc.B);
    drive_float_beats(top, tfp, beats);

    // one idle beat, then drain
    drive_zero(top);
    tick(top, tfp);
    drive_zero(top);
    for (int i = 0; i < tc.drain_cycles; ++i)
        tick(top, tfp);

    // check
    float Cexp[2][2];
    matmul2x2_ref(tc.A, tc.B, Cexp);
    check_outputs(top, Cexp);
}
