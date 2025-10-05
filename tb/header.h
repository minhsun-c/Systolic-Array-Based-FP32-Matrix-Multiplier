#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <sstream>
#include <vector>
#include "VSystolicArray.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#ifndef NN
#define NN 2
#endif

// Provided by testbench.cpp
extern vluint64_t tb_time;
double sc_time_stamp();  // defined in testbench.cpp

// Primary template MUST be declared before including the specialization.
template <int N>
inline void bind_ports(VSystolicArray *top,
                       std::array<uint32_t *, N> &Wp,
                       std::array<uint32_t *, N> &Np,
                       std::array<uint32_t *, N * N> &OUTp);

// Include the generated specialization: template<> inline void
// bind_ports<NN>(...) { ... }
#include "dut_bind.h"

// ---- Common utilities ----
inline void tick(VSystolicArray *top, VerilatedVcdC *tfp)
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

inline uint32_t packf(float f)
{
    uint32_t u;
    std::memcpy(&u, &f, 4);
    return u;
}
inline float unpackf(uint32_t u)
{
    float f;
    std::memcpy(&f, &u, 4);
    return f;
}
inline bool feq(float a, float b, float eps = 1e-5f)
{
    if (std::isnan(a) || std::isnan(b))
        return false;
    return std::fabs(a - b) <=
           eps * std::max(1.0f, std::max(std::fabs(a), std::fabs(b)));
}

// ---- NxN generic types ----
template <int N>
using Row = std::array<float, N>;
template <int N>
using Mat = std::array<Row<N>, N>;
template <int N>
struct BeatN {
    std::array<float, N> W, T;
};  // west & top edges

// 2N−1 anti-diagonal (wavefront) schedule
template <int N>
inline std::vector<BeatN<N>> make_wavefront(const Mat<N> &A, const Mat<N> &B)
{
    std::vector<BeatN<N>> beats;
    beats.reserve(2 * N - 1);
    for (int t = 0; t <= 2 * N - 2; ++t) {
        BeatN<N> b{};
        for (int i = 0; i < N; ++i) {
            int j = t - i;
            b.W[i] = (0 <= j && j < N) ? A[i][j] : 0.0f;
        }
        for (int j = 0; j < N; ++j) {
            int i = t - j;
            b.T[j] = (0 <= i && i < N) ? B[i][j] : 0.0f;
        }
        beats.push_back(b);
    }
    return beats;
}

// Software reference C=A*B
template <int N>
inline void matmul_ref(const Mat<N> &A, const Mat<N> &B, Mat<N> &C)
{
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            float s = 0.f;
            for (int k = 0; k < N; ++k)
                s += A[i][k] * B[k][j];
            C[i][j] = s;
        }
}

// Drive zeros on edges
template <int N>
inline void drive_zero(std::array<uint32_t *, N> &Wp,
                       std::array<uint32_t *, N> &Np)
{
    for (int i = 0; i < N; ++i) {
        *Wp[i] = 0;
        *Np[i] = 0;
    }
}

// Pulse active-low reset
inline void pulse_reset(VSystolicArray *top, VerilatedVcdC *tfp, int cycles = 2)
{
    top->reset = 0;
    for (int i = 0; i < cycles; ++i)
        tick(top, tfp);
    top->reset = 1;
    tick(top, tfp);
}

// Drive beats
template <int N>
inline void drive_beats(VSystolicArray *top,
                        VerilatedVcdC *tfp,
                        const std::vector<BeatN<N>> &beats,
                        std::array<uint32_t *, N> &Wp,
                        std::array<uint32_t *, N> &Np)
{
    for (const auto &b : beats) {
        for (int i = 0; i < N; ++i)
            *Wp[i] = packf(b.W[i]);
        for (int j = 0; j < N; ++j)
            *Np[j] = packf(b.T[j]);
        tick(top, tfp);
    }
}

// Compare all N×N outputs
template <int N>
inline void check_outputs(std::array<uint32_t *, N * N> &OUTp,
                          const Mat<N> &Cexp,
                          float eps = 1e-5f)
{
    bool ok = true;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            float got = unpackf(*OUTp[i * N + j]);
            float exp = Cexp[i][j];
            if (!feq(got, exp, eps)) {
                std::printf("Mismatch C[%d][%d]: got %.7f, exp %.7f\n", i, j,
                            got, exp);
                ok = false;
            }
        }
    if (!ok) {
        std::fprintf(stderr, "[FAIL] NxN mismatch\n");
        std::exit(1);
    }
    std::puts("[OK] NxN result matches within tolerance.");
}

template <int N>
inline void print_mat(const char *label, const Mat<N> &M)
{
    std::printf("%s = [\n", label);
    for (int i = 0; i < N; ++i) {
        std::printf("  [");
        for (int j = 0; j < N; ++j) {
            std::printf("% .7f%s", M[i][j], (j == N - 1 ? "" : ", "));
        }
        std::printf("]%s\n", (i == N - 1 ? "" : ","));
    }
    std::printf("]\n");
}

template <int N>
inline void run_mat_case(VSystolicArray *top,
                         VerilatedVcdC *tfp,
                         const char *name,
                         const Mat<N> &A,
                         const Mat<N> &B,
                         int pe_latency = 4)
{
    std::printf("\n=== %s (N=%d) ===\n", name, N);

    // Show what we're multiplying
    print_mat<N>("A", A);
    print_mat<N>("B", B);

    // Optional: show the software reference result too
    Mat<N> Cexp;
    matmul_ref<N>(A, B, Cexp);
    print_mat<N>("C_ref (software)", Cexp);

    std::array<uint32_t *, N> Wp, Np;
    std::array<uint32_t *, N * N> OUTp;
    bind_ports<N>(top, Wp, Np, OUTp);

    pulse_reset(top, tfp);

    auto beats = make_wavefront<N>(A, B);
    drive_beats<N>(top, tfp, beats, Wp, Np);

    drive_zero<N>(Wp, Np);
    tick(top, tfp);
    for (int i = 0; i < pe_latency + 2 * N; ++i) {
        drive_zero<N>(Wp, Np);
        tick(top, tfp);
    }

    // Compare DUT vs software
    check_outputs<N>(OUTp, Cexp);
}


// Read A and B (each N×N, row-major) from a text file.
// - Accepts whitespace-separated numbers
// - Ignores comments after '#'
// - Allows commas/semicolons (treated as spaces)
// Expected: exactly 2*N*N numbers total (first A, then B)
template <int N>
inline bool load_two_mats_txt(const std::string &path, Mat<N> &A, Mat<N> &B)
{
    std::ifstream fin(path);
    if (!fin) {
        std::perror(("open " + path).c_str());
        return false;
    }
    std::vector<float> vals;
    std::string line;
    while (std::getline(fin, line)) {
        // strip comments
        if (auto p = line.find('#'); p != std::string::npos)
            line.resize(p);
        // treat CSV as whitespace
        for (char &c : line)
            if (c == ',' || c == ';')
                c = ' ';
        std::istringstream iss(line);
        double x;
        while (iss >> x)
            vals.push_back(static_cast<float>(x));
    }
    const size_t need = size_t(2 * N * N);
    if (vals.size() != need) {
        std::fprintf(
            stderr,
            "[load_two_mats_txt] got %zu numbers, expected %zu (2*%d*%d)\n",
            vals.size(), need, N, N);
        return false;
    }
    size_t k = 0;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            A[i][j] = vals[k++];
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            B[i][j] = vals[k++];
    return true;
}
