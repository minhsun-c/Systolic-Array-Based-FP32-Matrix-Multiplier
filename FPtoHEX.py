def Convert(n):
    isZero = '1' if n == 0 else '0'
    sign = '1' if n < 0 else '0'
    if (sign == '1'): n = -1 * n
    exp = 127
    while 1:
        if (n >= 2):
            n /= 2
            exp += 1
        elif (n < 1):
            n *= 2
            exp -= 1
        else:
            break
    frac = ""
    n = n - 1
    for i in range(23):
        if (n > 0):
            n *= 2
            if (n >= 1):
                n -= 1
                frac += '1'
            else :
                frac += '0'
        else:
            frac += '0'
    exp = bin(exp)[2:]
    if (len(exp) < 8):
        exp = '0' * (8 - len(exp)) + exp
    return [isZero, sign+exp+frac]
    
while 1:
    ip = float(input())
    rv = Convert(ip)
    if rv[0] == '1':
        print(0)
    else:
        print(hex(int(rv[1], 2)))

