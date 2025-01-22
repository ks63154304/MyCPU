package ChiselRiscV

import chisel3._
import chisel3.util.Cat
import chisel3.util.experimental.loadMemoryFromFileInline

import common.Constants.{WordLen, OutAddr, PrintAddr}

class ImemPortIo extends Bundle {
    val addr = Input(UInt(WordLen.W))
    val inst = Output(UInt(WordLen.W))
}

class DmemPortIo extends Bundle {
    val addr  = Input(UInt(WordLen.W))
    val wEn   = Input(Bool())
    val wData = Input(UInt(WordLen.W))
    val data  = Output(UInt(WordLen.W))
}

class Memory extends Module {
    val imem = IO(new ImemPortIo)
    val dmem = IO(new DmemPortIo)
    val exit = IO(Input(Bool()))

    val mem = Mem(math.pow(2, 24).toInt, UInt(8.W)) // 32KB
    
    def loadMemoryFromHexFile(filename: Option[String]): Unit = loadMemoryFromFileInline(mem, filename.get)

    imem.inst := Cat(
        mem(imem.addr + 3.U),
        mem(imem.addr + 2.U),
        mem(imem.addr + 1.U),
        mem(imem.addr )
    )
    
    dmem.data := Cat(
        mem(dmem.addr + 3.U),
        mem(dmem.addr + 2.U),
        mem(dmem.addr + 1.U),
        mem(dmem.addr)
    )
    when(dmem.wEn) {
        mem(dmem.addr + 3.U) := dmem.wData(31, 24)
        mem(dmem.addr + 2.U) := dmem.wData(23, 16)
        mem(dmem.addr + 1.U) := dmem.wData(15, 8)
        mem(dmem.addr)       := dmem.wData(8, 0)
    }

    val PrintAddr_mem = Cat(mem(PrintAddr + 3.U), mem(PrintAddr + 2.U), mem(PrintAddr + 1.U), mem(PrintAddr))
    when(PrintAddr_mem===1.U(WordLen.W)) {
        val memdata = Cat(mem(OutAddr + 3.U), mem(OutAddr + 2.U), mem(OutAddr + 1.U), mem(OutAddr))
        printf(cf"${Hexadecimal(memdata)}\n")
        mem(PrintAddr)       := 0.U(8.W)
        mem(PrintAddr + 1.U) := 0.U(8.W)
        mem(PrintAddr + 2.U) := 0.U(8.W)
        mem(PrintAddr + 3.U) := 0.U(8.W)
    }      
}
