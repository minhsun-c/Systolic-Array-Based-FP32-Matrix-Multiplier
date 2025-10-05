# === Configuration ===
SIZE    ?= 2
TARGET  := SystolicArray
VSRC    := $(TARGET).v
VSRC    += $(wildcard src/*.v)

# Verilog TB (for Icarus)
TB_V    := test/tb_$(TARGET).v

# C++ TB (for Verilator) – adjust these to your actual files
TB_CPP  = tb/helper.cpp tb/testbench.cpp

VINC		:= -Iinclude
CINC		:= -Itb
OUT_DIR := build
OUT     := $(OUT_DIR)/$(TARGET)
WAVE    := $(OUT_DIR)/wave.vcd

# Choose simulator: iverilog or verilator
SIM ?= verilator

# === Default ===
all: mm

# === Simulator rules ===
ifeq ($(SIM),iverilog)
mm: build_systolic indent $(VSRC) $(TB_V) | $(OUT_DIR)
	@echo "[iverilog] Building..."
	# add -g2012 if you use SystemVerilog features
	iverilog -g2012 $(INC) -o $(OUT) $(TB_V) $(VSRC)
	vvp $(OUT)
	# If TB writes wave to a fixed name, normalize:
	@if [ -f wave.vcd ]; then mkdir -p $(OUT_DIR); mv -f wave.vcd $(WAVE); fi

else ifeq ($(SIM),verilator)
mm: obj_dir/V${TARGET}.mk | $(OUT_DIR)

obj_dir/V${TARGET}.mk: build_systolic ${VSRC} ${TB_CPP} $(PROG_BIN)
	verilator --top-module $(TARGET) --cc $(VSRC) $(VINC) \
	  --exe $(TB_CPP) --trace \
	  -CFLAGS "-std=c++17 $(CINC)" \
	  --build -Wno-fatal

obj_dir/V${TARGET}.exe: obj_dir/V${TARGET}.mk
	make -C obj_dir -f V$(TARGET).mk

.PHONY: run
run: obj_dir/V${TARGET}.exe indent
	./obj_dir/V$(TARGET) -N $(SIZE)
	@if [ -f wave.vcd ]; then mkdir -p $(OUT_DIR); mv -f wave.vcd $(WAVE); fi

endif

# === Utility rules ===
.PHONY: build_systolic
build_systolic:
	make -C gen_systolic SIZE=$(SIZE)
	cp gen_systolic/$(TARGET)$(SIZE)x$(SIZE).v $(TARGET).v

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

.PHONY: wave
wave: $(OUT)
	@echo "Opening GTKWave..."
	gtkwave $(WAVE)

.PHONY: indent
indent:
	clang-format -i tb/*
	verible-verilog-format --flagfile .verible-format.flags $(VSRC)

.PHONY: clean
clean:
	rm -rf $(OUT_DIR) obj_dir *.vcd $(TARGET).v
