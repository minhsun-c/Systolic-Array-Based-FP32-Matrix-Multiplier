import gui, mif, math
import numpy as np
import sys

if __name__ == '__main__':
    filename = sys.argv[1]
    data, matSize = mif.read_mif(filename)
    mat1, mat2 = mif.to_matrix(data, matSize)
    matFPGA = mif.getSolution(data, matSize)
    matmul = mat1 @ mat2
    window = gui.Window(mat1, mat2, matmul, matFPGA)
    window.driver()