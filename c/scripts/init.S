.section .text.init
.global _start
_start:
    li sp, 0x1000 # Initialize stack pointer
    call main   # Jump to main function
    unimp # Simulation end
