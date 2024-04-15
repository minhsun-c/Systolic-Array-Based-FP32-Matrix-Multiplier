`define AddMode 1'b0
`define SubMode 1'b1
`define FPZero  32'b0
`include "src/FPAdderSubtractor.v"
`include "src/FPLZDetector.v"
`include "src/FPMultiplier.v"
`include "src/IntAdderSubtractor.v"
`include "src/IntMultiplier.v"
`include "src/ProcessingElement.v"
