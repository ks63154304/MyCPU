.PHONY: sbtrun riscof test1 clean
default:sbtrun

export WORK := $(shell pwd)/build/arch-test
TEST_C_FILE ?= ./c/src/ctest.c
TEST_C_FILE_O = $(patsubst $(dir $(TEST_C_FILE))%.c,./build/c/src/%, $(TEST_C_FILE))
TEST_S_FILE_1 = $(patsubst $(dir ./c/test/test1.S)%.S,./build/c/test/%,./c/test/test1.S)
TEST_S_FILE_2 = $(patsubst $(dir ./c/test/test2.S)%.S,./build/c/test/%,./c/test/test2.S)
TEST_S_FILE_3 = $(patsubst $(dir ./c/test/test3.S)%.S,./build/c/test/%,./c/test/test3.S)

build/%:%.S
	mkdir -p build/$(dir $<)
	riscv32-unknown-elf-as -R -march=rv32i_zicsr -mabi=ilp32 -o ./build/c/test/init.o ./c/scripts/init.S
	riscv32-unknown-elf-gcc $< -O0 -march=rv32im_zicsr -mabi=ilp32 -c -o $@.o
	riscv32-unknown-elf-ld $@.o ./build/c/test/init.o -b elf32-littleriscv -T ./c/scripts/link.ld -o $@
	riscv32-unknown-elf-objcopy $@ -O binary $@.bin
	od $@.bin -An -tx1 -w1 -v > $@.hex
	riscv32-unknown-elf-objdump $@ -b elf32-littleriscv -D > $@.dump


build/%:%.c
	mkdir -p build/$(dir $<)
	riscv32-unknown-elf-as -R -march=rv32i_zicsr -mabi=ilp32 -o ./build/c/src/init.o ./c/scripts/init.S
	riscv32-unknown-elf-gcc $< -O0 -march=rv32im_zicsr -mabi=ilp32 -c -o $@.o
	riscv32-unknown-elf-ld $@.o ./build/c/src/init.o -b elf32-littleriscv -T ./c/scripts/link.ld -o $@
	riscv32-unknown-elf-objcopy $@ -O binary $@.bin
	od $@.bin -An -tx1 -w1 -v > $@.hex
	riscv32-unknown-elf-objdump $@ -b elf32-littleriscv -D > $@.dump

sbtrun:$(TEST_C_FILE_O)
	sbt "testOnly ChiselRiscV.tests.HexTest -- -DprogramFile=$(TEST_C_FILE_O).hex -DwriteVcd=1"

test1:$(TEST_S_FILE_1)
	sbt "testOnly ChiselRiscV.tests.HexTest -- -DprogramFile=$<.hex -DwriteVcd=1"

test2:$(TEST_S_FILE_2)
	sbt "testOnly ChiselRiscV.tests.HexTest -- -DprogramFile=$<.hex -DwriteVcd=1"

test3:$(TEST_S_FILE_3)
	sbt "testOnly ChiselRiscV.tests.HexTest -- -DprogramFile=$<.hex -DwriteVcd=1"

riscof:
	mkdir -p $(WORK)
	riscof run --work-dir=$(WORK) \
		--config=./arch-test-target/config.ini \
		--suite=./arch-test-target/riscv-arch-test/riscv-test-suite \
		--env=./arch-test-target/riscv-arch-test/riscv-test-suite/env

clean:
	rm -rf ./build