# Systolic Array Based FP32 Matrix Multiplier

## Description

This project accelerates matrix multiplication in deep learning. The core architecture is Systolic Array, proposed by H. T. Kung. 

The multiplier is composed with N*N pipelined processing elements. Inside each processing element, there is a FP32 multiplier and a FP32 Adder. Both FP32 multiplier and adder has a leading zero detector for normalization.