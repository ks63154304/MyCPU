#include <stdio.h>

int main() {
    // const unsigned int x = 1;
    // const unsigned int y = 2;
    // unsigned int z = x + y;

    // if (z == 1) z += 1;
    // else z += 2;


    asm volatile("li a0,-5");
    asm volatile("li a1, -10");
    asm volatile("li sp, 0");
    asm volatile("j jump_1");
    asm volatile("jumpback:");
    asm volatile("addi sp, sp, 1");
    asm volatile("j end");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("jump_1:");
    asm volatile("beq a0, a1, jumpback");
    asm volatile("addi	sp,sp,2");
    asm volatile("j end");
    asm volatile("addi	sp,sp,3");
    asm volatile("j end");
    asm volatile("end:");
    asm volatile("sw	sp,248(ra)");
    asm volatile("unimp");
    
    return 0;
}
