package ChiselRiscV

import chisel3._

import common.Constants.WordLen

class Top extends Module {
    val gp   = IO(Output(UInt(WordLen.W)))
    val exit = IO(Output(Bool()))

    val core = Module(new Core)
    val mem  = Module(new Memory)
    mem.imem <> core.imem
    mem.dmem <> core.dmem
    mem.exit <> core.exit

    gp   := core.gp 
    exit := core.exit
}
