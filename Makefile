TARGET	:= SYS2
VSRC	:= $(wildcard src/*.v)
TB 		:= test/tb_$(TARGET).v
OUT		:= build/$(TARGET)
WAVE	:= build/$(TARGET).vcd

all: $(OUT)

$(OUT): $(VSRC) $(TB) | build
	iverilog -o $(OUT) $(TB) $(VSRC)
	vvp $(OUT)

build:
	mkdir build

wave: $(OUT) $(WAVE)
	gtkwave $(WAVE)

clean:
	rm -rf build