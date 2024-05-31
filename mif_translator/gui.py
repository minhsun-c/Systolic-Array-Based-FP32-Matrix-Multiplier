import tkinter as tk
import numpy as np
import math

class Window:
    def __init__(self, mat1, mat2, matmul, matFPGA):
        self.wd = tk.Tk()
        self.matrices = [mat1, mat2, matmul, matFPGA]
        self.colorList = [
            'lightblue', 'lightgreen', 
            'yellow', 'lightgrey'
        ]
        self.label = [
            'Matrix1', 'Matrix2',
            'Result Calculated via Python',
            'Result Calculated via FPGA'
        ]
        self.font = ("Comic Sans MS",20)
        self.maxDim = self.getMaxDim()
    def show_gui(self, title, size):
        self.wd.title(title)
        self.wd.geometry(size)
        self.wd.resizable(False, False)
    def getMaxDim(self):
        maxDim = 0
        for mat in self.matrices:
            if isinstance(mat, (np.ndarray)):
                maxDim = max(maxDim, mat.shape[0], mat.shape[1])
        return maxDim
    def getWindowSize(self):
        self.horSize = 130 * self.maxDim * 2 + 20
        if isinstance(self.matrices[3], (np.ndarray)):
            self.verSize = (70 * self.maxDim * 3 + 70 * 3 + 20)
        else:
            self.verSize = (70 * self.maxDim * 2 + 70 * 3 + 20)
        return f'{self.horSize}x{self.verSize}'
    def place_all(self):
        gap1 = (self.horSize - 130 * 2 * self.maxDim) // 2
        gap2 = (self.horSize - 130 * 1 * self.maxDim) // 2
        ex0, ey0 = self.place_mat(0,    gap1,       70)
        ex1, ey1 = self.place_mat(1,    ex0+10,     70)
        ex2, ey2 = self.place_mat(2,    gap2,       70+ey0)
        if isinstance(self.matrices[3], (np.ndarray)):
            ex3, ey3 = self.place_mat(3,    gap2,       70+ey2)
        self.place_label(0, gap1,       0)
        self.place_label(1, ex0+gap1,   0)
        self.place_label(2, gap2,       ey0+gap1)
        if isinstance(self.matrices[3], (np.ndarray)):
            self.place_label(3, gap2,       ey2+10)
    def driver(self):
        self.show_gui(
            'Matrix Multiplication', 
            self.getWindowSize()
        )
        self.place_all()
        self.wd.mainloop()
    def decorate(self, color, textVar):
        return tk.Entry(self.wd, bg=color, font=self.font, textvariable=textVar)
    def gen_blocks(self, idx):
        Matrix = self.matrices[idx]
        Dim = Matrix.shape
        Size = np.prod(Dim)
        tArea = [tk.StringVar() for i in range(Size)]
        for i in range(Size):
            text = str(Matrix[i//Dim[1]][i%Dim[1]])
            tArea[i].set(text)
        iArea = [self.decorate(self.colorList[idx], tArea[i]) for i in range(Size)]
        return tArea, iArea
    def place_mat(self, idx, start_x, start_y):
        width, height = 120, 50
        tArea, iArea = self.gen_blocks(idx)
        Matrix = self.matrices[idx]
        Dim = self.matrices[idx].shape
        for i in range(Dim[0]):
            for j in range(Dim[1]):
                iArea[i * Dim[1] + j].place(
                    x = start_x + j * (width  + 10),
                    y = start_y + i * (height + 10),
                    width = width,
                    height = height
                )
        return start_x + (width + 10) * self.maxDim, start_y + (height + 10) * self.maxDim
    def place_label(self, idx, start_x, start_y):
        lb = tk.Label(self.wd, text=self.label[idx],
            font = self.font,
            justify='center'
        )
        lb.place(
            x = start_x, y = start_y,
            width = 130 * self.maxDim, height = 60
        )