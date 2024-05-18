import math
import numpy as np

def Bin2Hex(s):
    sol = ''
    for i in range(0, len(s), 4):
        if s[i:i+4] == '0000': sol += '0'
        elif s[i:i+4] == '0001': sol += '1'
        elif s[i:i+4] == '0010': sol += '2'
        elif s[i:i+4] == '0011': sol += '3'
        elif s[i:i+4] == '0100': sol += '4'
        elif s[i:i+4] == '0101': sol += '5'
        elif s[i:i+4] == '0110': sol += '6'
        elif s[i:i+4] == '0111': sol += '7'
        elif s[i:i+4] == '1000': sol += '8'
        elif s[i:i+4] == '1001': sol += '9'
        elif s[i:i+4] == '1010': sol += 'A'
        elif s[i:i+4] == '1011': sol += 'B'
        elif s[i:i+4] == '1100': sol += 'C'
        elif s[i:i+4] == '1101': sol += 'D'
        elif s[i:i+4] == '1110': sol += 'E'
        elif s[i:i+4] == '1111': sol += 'F'
    return sol

def getData(line, data_seg, addr_rad, data_rad):
    temp = line.replace(' ', '').replace('\t', '').replace('\n', '').replace(';', '').split(':')
    if '[' in temp[0]:
        idx = temp[0].split('..')
        start = int(idx[0].replace('[', ''), addr_rad)
        end   = int(idx[1].replace(']', ''), addr_rad)
    else:
        start = int(temp[0], addr_rad)
        end   = int(temp[0], addr_rad)
    nonzero = 0
    for i in range(start, end+1):
        subOut = []
        gap = int(32 // math.log2(data_rad))
        for j in range(0, len(temp[1]), gap):
            if data_rad == 2:
                out = Bin2Hex(temp[1][j:j+gap])
            elif data_rad == 16:
                out = temp[1][j:j+gap]
            subOut.append(out)
            nonzero += (out != '00000000')
        data_seg.append(subOut)
    return nonzero

def read_mif(file):
    mif = open(file, 'r')

    width, depth, addr_rad, data_rad, counter, nonzero = 0, 0, 0, 0, 0, 0
    data_seg = []
    for line in mif:
        if line[:2] == '--' or len(line) == 0 or line == '\n':
            pass
        elif 'WIDTH' in line:
            width = int(line.split('=')[1].replace(';', ''))
        elif 'DEPTH' in line:
            depth = int(line.split('=')[1].replace(';', ''))
        elif 'ADDRESS_RADIX' in line:
            a_radix = line.split('=')[1].replace(';', '')
            if 'HEX' in a_radix: addr_rad = 16
            elif 'BIN' in a_radix: addr_rad = 2
            else: addr_rad = 10
        elif 'DATA_RADIX' in line:
            d_radix = line.split('=')[1].replace(';', '')
            if 'HEX' in d_radix: data_rad = 16
            elif 'BIN' in d_radix: data_rad = 2
            else: data_rad = 10
        elif 'CONTENT BEGIN' in line:
            counter = 0
        elif 'END' in line:
            mif.close()
            break
        else:
            getData(line, data_seg, addr_rad, data_rad)  
    return data_seg, width // 64

def ieee754(iHexFP):
    if iHexFP == '00000000':
        return 0
    
    hexFP = int(iHexFP, 16)
    sign = 1 if (hexFP & 0x80000000) == 0 else -1
    expo = ((hexFP & 0x7F800000) >> 23) - 127
    frac = bin(hexFP & 0x007FFFFF)[2:]
    frac = '0' * (23 - len(frac)) + frac
    fp = 1
    for i, digit in enumerate(frac):
        if digit == '1':
            fp += (2 ** -(i + 1))
    return sign * fp * (2 ** expo)

def extract(data, matSize, x, y):
    subMat = np.zeros((matSize))
    for i in range(matSize):
        subMat[i] = ieee754(data[x+i][y])
    return subMat

def checkDim(matrix, matSize):
    for i in range(matSize): # remove upper rows
        if np.all(matrix[i, :] == 0):
            matrix = np.delete(matrix, i, 0)
        else:
            break
    for j in range(matSize): # remove left columns
        if np.all(matrix[:, j] == 0):
            matrix = np.delete(matrix, j, 1)
        else:
            break
    for i in range(matSize-1, -1, -1): # remove lower rows 
        if np.all(matrix[i, :] == 0):
            matrix = np.delete(matrix, i, 0)
        else:
            break
    for j in range(matSize-1, -1, -1): # remove right columns
        if np.all(matrix[:, j] == 0):
            matrix = np.delete(matrix, j, 1)
        else:
            break
    return matrix

def to_matrix(data, matSize):
    matrix1 = np.zeros((matSize, matSize))
    matrix2 = np.zeros((matSize, matSize))
    for j in range(matSize):
        matrix1[j] = extract(data, matSize, j, j)
    for j in range(matSize):
        matrix2[j] = extract(data, matSize, j, matSize+j)
    matrix2 = np.transpose(matrix2)
    matrix1 = checkDim(matrix1, matSize)
    matrix2 = checkDim(matrix2, matSize)
    return matrix1, matrix2

def getSolution(data, matSize):
    start = matSize * 2
    matrix = np.zeros((matSize, matSize))
    allzero = ['00000000' for i in range(matSize*2)]
    while True:
        if start >= len(data):
            return None
        elif data[start] == allzero:
            start += 1
        else:
            break
    for i in range(matSize * matSize):
        matrix[i//matSize][i%matSize] = ieee754(data[start+i][matSize * 2 - 1])
    return checkDim(matrix, matSize)