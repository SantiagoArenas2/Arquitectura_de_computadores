# Proyecto 1 - Calculadora de 4 bits
# Flujo basado en el Makefile del Pochoco SoC (Nicolas Villegas, UANDES 2026)
#
# Uso:
#   make sim    -> compila y corre el testbench, genera el VCD
#   make wave   -> abre GTKWave con el resultado
#   make prog   -> sintetiza, hace place & route y programa la FPGA
#   make stats  -> muestra el uso de recursos de la iCE40
#   make clean  -> borra todo lo generado

TOP   := calc_top
TB    := tb_calc_core
PCF   := goboard.pcf

SRC     := $(wildcard rtl/*.v)
TB_SRC  := $(wildcard tb/*.v)

BUILD := build
JSON  := $(BUILD)/$(TOP).json
ASC   := $(BUILD)/$(TOP).asc
BIN   := $(BUILD)/$(TOP).bin
VVP   := $(BUILD)/$(TB).vvp
VCD   := $(BUILD)/$(TB).vcd

.PHONY: all sim wave prog stats clean

all: prog

# ---------------------------------------------------------------
# Simulacion
# ---------------------------------------------------------------
# El testbench debe contener:
#   initial begin
#     $dumpfile("build/tb_calc_core.vcd");
#     $dumpvars(0, tb_calc_core);
#   end

sim: $(VCD)

$(VCD): $(SRC) $(TB_SRC) | $(BUILD)
	iverilog -g2005 -Wall -o $(VVP) -s $(TB) $(SRC) $(TB_SRC)
	vvp $(VVP)

wave: $(VCD)
	gtkwave $(VCD) waves.gtkw

# ---------------------------------------------------------------
# Sintesis, place & route, bitstream
# ---------------------------------------------------------------
$(JSON): $(SRC) | $(BUILD)
	yosys -p "read_verilog $(SRC); synth_ice40 -top $(TOP) -json $(JSON); stat"

$(ASC): $(JSON) $(PCF)
	nextpnr-ice40 --hx1k --package vq100 --json $(JSON) --pcf $(PCF) --asc $(ASC)

$(BIN): $(ASC)
	icepack $(ASC) $(BIN)

prog: $(BIN)
	iceprog $(BIN)

stats: $(JSON)
	@yosys -p "read_json $(JSON); stat"

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)
