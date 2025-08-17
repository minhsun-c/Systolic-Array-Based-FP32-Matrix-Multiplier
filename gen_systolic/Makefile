SIZE  ?= 2
WIDTH ?= 32

OUT   := SystolicArray$(SIZE)x$(SIZE).v
BUILD := build
OBJ   := obj
BIN   := $(BUILD)/main
SRC	  := main.c gen.c

.PHONY: all clean indent

all: indent $(OUT)

$(OUT): $(BIN)
	./$(BIN) $(SIZE) $(WIDTH) > $@

$(BIN): $(SRC) | $(BUILD) $(OBJ)
	gcc -o $@ $(SRC)

$(BUILD) $(OBJ):
	mkdir -p $@

indent:
	clang-format -i *.c *.h

clean:
	rm -rf $(BUILD) $(OBJ) $(OUT)
