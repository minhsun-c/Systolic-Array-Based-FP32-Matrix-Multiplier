file=SYS2

iverilog -o build/$file test/tb_$file.v
vvp build/$file
# open $gtkwave build/$file.vcd
