`define AddMode 1'b0
`define SubMode 1'b1
`define FPZero  32'b0
`include "src/FPAdderSubtractor.v"
`include "src/FPLZDetector.v"
`include "src/FPMultiplier.v"
`include "src/IntAdderSubtractor.v"
`include "src/IntMultiplier.v"
`include "src/ProcessingElement.v"
`include "src/SystolicArray2x2.v"
`include "src/SystolicArray3x3.v"
`include "src/SystolicArray10x10.v"