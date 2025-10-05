#!/usr/bin/env python3
import argparse, sys

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-N", "--n", type=int, required=True)
    ap.add_argument("--top", default="SystolicArray")              # Verilog top name
    ap.add_argument("--top-class", default=None)                   # Verilated class (default: V+top)
    ap.add_argument("--out", default="-")                          # file or stdout
    ap.add_argument("--w-tmpl", default="W{idx}_i")
    ap.add_argument("--n-tmpl", default="N{idx}_i")
    ap.add_argument("--out-tmpl", default="out{row}_{col}")
    a = ap.parse_args()
    if a.n <= 0: sys.exit("N must be >= 1")
    cls = a.top_class or f"V{a.top}"
    N = a.n

    L = []
    L += [ "#pragma once",
           "#include <array>",
           "#include <cstdint>",
           f"#include \"{cls}.h\"",
           "",
           f"template<>",
           f"inline void bind_ports<{N}>({cls}* top,",
           f"    std::array<uint32_t*, {N}>& Wp,",
           f"    std::array<uint32_t*, {N}>& Np,",
           f"    std::array<uint32_t*, {N*N}>& OUTp)",
           "{" ]
    for i in range(N):
        L.append(f"    Wp[{i}] = &top->{a.w_tmpl.format(idx=i)};")
    for j in range(N):
        L.append(f"    Np[{j}] = &top->{a.n_tmpl.format(idx=j)};")
    for i in range(N):
        for j in range(N):
            L.append(f"    OUTp[{i}*{N}+{j}] = &top->{a.out_tmpl.format(row=i,col=j)};")
    L.append("}")
    txt = "\n".join(L) + "\n"

    if a.out == "-" or a.out == "/dev/stdout":
        sys.stdout.write(txt)
    else:
        with open(a.out, "w") as f: f.write(txt)
        print(f"[gen] wrote {a.out} for N={N} (class {cls})")

if __name__ == "__main__":
    main()
