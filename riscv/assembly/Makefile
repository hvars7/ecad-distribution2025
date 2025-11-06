# the name of the program we're going to build
PROJECT = program
# build directory
BUILD = build

# name of the Quartus program
FPGA_PROJECT_PATH = ../quartus
FPGA_PROJECT = clarvi

# source files
C_FILES := $(wildcard src/*.c)
AS_FILES := $(wildcard src/*.s)
ASP_FILES := $(wildcard src/*.S)

# object files
C_OBJ_FILES := $(patsubst src/%.c,build/%.o,$(C_FILES))
AS_OBJ_FILES := $(patsubst src/%.s,build/%.o,$(AS_FILES))
ASP_OBJ_FILES := $(patsubst src/%.S,build/%.o,$(ASP_FILES))


# settings for the compilers
RISCV_PREFIX = riscv32-unknown-elf-
CC = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump

TARGET_ARCH = -march=rv32i_zicsr
CC_FLAGS = -O0 $(TARGET_ARCH)

CC_LINK_FLAGS = $(CC_FLAGS) -static -fvisibility=hidden -nostdlib -nostartfiles

# Lists of rules: the name of a file, followed by the files it depends on.
# When typing 'make' not followed by a rule name, the first rule is followed.  This rule depends on
# everything, causing all the parts to be built

all: dirs $(BUILD)/mem.hex $(BUILD)/$(PROJECT).dump

# how to build a .o file from a .c file
$(BUILD)/%.o: src/%.c
	$(CC) -c -o $@ $< $(CC_FLAGS)

# how to build a .o file from a .s file
$(BUILD)/%.o: src/%.s
	$(CC) -c -o $@ $< $(CC_FLAGS)

# how to build a .o file from a .S file
$(BUILD)/%.o: src/%.S
	$(CC) -c -o $@ $< $(CC_FLAGS)

# link with gcc to build an elf executable
$(BUILD)/$(PROJECT).elf: link.ld ${AS_OBJ_FILES} ${C_OBJ_FILES} ${ASP_OBJ_FILES}
	$(CC) -o $@ $(CC_LINK_FLAGS) -T $^

# output human readable dump of elf file
$(BUILD)/$(PROJECT).dump: $(BUILD)/$(PROJECT).elf
	$(OBJDUMP) -S -s $< > $@

# extract the binary data from data and text sections to get a binary image of memory
$(BUILD)/mem.bin: $(BUILD)/$(PROJECT).elf
	$(OBJCOPY) -O binary --only-section=.data* --only-section=.text* $< $@

# convert to an ASCII hex file for simulation
$(BUILD)/mem.txt: $(BUILD)/mem.bin
	hexdump -v -e '"%08x\n"' $< > $@

# convert to an Intel HEX file for downloading to the FPGA
$(BUILD)/mem.hex: $(BUILD)/mem.txt
	python3 txt2hex.py $< $@ 4

# make software project folder
dirs:
	mkdir -p $(BUILD)

# run simulation
spike: all
	spike --isa=rv32i -m0x0:0x10000 $(BUILD)/$(PROJECT).elf

# run simulation with logs
spike-log: all
	spike --log-commits --isa=rv32i -l -m0x0:0x10000 $(BUILD)/$(PROJECT).elf

# run simulation step by step
spike-debug: all
	spike --isa=rv32i -d -m0x0:0x10000 $(BUILD)/$(PROJECT).elf

# run simulation on Verilator
clarvi-sim: all ../clarvi/obj_dir/Vclarvi_sim
	../clarvi/obj_dir/Vclarvi_sim

# build the clarvi verilog simulator
../clarvi/obj_dir/Vclarvi_sim:
	@echo "##############################################################################"
	@echo "# Building a simulator for clarvi"
	make -C ../clarvi

# update the memory files inside the FPGA bitfile
update-mem:	all
	cd ${FPGA_PROJECT_PATH} && quartus_cdb ${FPGA_PROJECT} -c ${FPGA_PROJECT} --update_mif
	cd ${FPGA_PROJECT_PATH} && quartus_asm --read_settings_files=on --write_settings_files=off ${FPGA_PROJECT} -c ${FPGA_PROJECT}

# download the bitfile to your board
download:
	cd ${FPGA_PROJECT_PATH} && quartus_pgm -m jtag -o P\;output_files/${FPGA_PROJECT}.sof@2

# build the whole FPGA from the command line
# not that it's harder to spot warnings in this output compared with the GUI
build_fpga:
	cd ${FPGA_PROJECT_PATH} && quartus_sh --flow compile ${FPGA_PROJECT}


# 'clean' rule: delete all the files so we can start afresh
clean:
	rm -rf $(BUILD)

# rule to start the docker container
docker:
	docker run -it -v $(PWD):/home/ecad/work ucamcstecad/ecad-riscv:latest
