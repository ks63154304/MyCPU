# ChiselRiscV

This repository is a term project of [Computer Architecture 2024: Term Project](https://hackmd.io/@sysprog/arch2024-projects)

## Desctiption

The most content of the introduction is written [here](https://hackmd.io/KHpg4bPYSPet9Xtrtkqt-g?view). This project is in progress, so somewhere maybe have trouble.

## How to run

Compile a simple `c` program and test it.
```bash
make sbtrun TEST_C_FILE=./c/src/ctest.c
```
This will produce a `vcd` file in `./test_run_dir/CPU_should_work_through_hex/`.

Run [arch-test-target](https://github.com/riscv-non-isa/riscv-arch-test) test.
```bash
make riscof
```

Use the following command to run the tests mentioned [here](https://hackmd.io/KHpg4bPYSPet9Xtrtkqt-g?view).

```bash
make test1; make test2; make test3
```