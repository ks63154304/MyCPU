.PHONY: sbtrun riscof riscofbuild riscofrun clean
default:sbtrun

export WORK := $(shell pwd)/build/arch-test
TEST_C_FILE ?= ./c/src/ctest.c
TEST_FIL     = $(patsubst $(dir $(TEST_C_FILE))%.c,./build/c/%, $(TEST_C_FILE))

$(TEST_FILE):$(TEST_C_FILE)
	mkdir -p build/c
	riscv32-unknown-elf-as -R -march=rv32i_zicsr -mabi=ilp32 -o ./build/c/init.o ./c/scripts/init.S
	riscv32-unknown-elf-gcc $< -O0 -march=rv32im_zicsr -mabi=ilp32 -c -o $@.o
	riscv32-unknown-elf-ld $@.o ./build/c/init.o -b elf32-littleriscv -T ./c/scripts/link.ld -o $@
	riscv32-unknown-elf-objcopy $@ -O binary $@.bin
	od $@.bin -An -tx1 -w1 -v > $@.hex
	riscv32-unknown-elf-objdump $@ -b elf32-littleriscv -D > $@.dump

sbtrun:$(TEST_FILE)
	sbt "testOnly ChiselRiscV.tests.HexTest -- -DprogramFile=$(TEST_FILE).hex -DwriteVcd=1"

riscof:
	mkdir -p $(WORK)
	riscof run --work-dir=$(WORK) \
		--config=./arch-test-target/config.ini \
		--suite=./arch-test-target/riscv-arch-test/riscv-test-suite \
		--env=./arch-test-target/riscv-arch-test/riscv-test-suite/env

clean:
	rm -rf ./build