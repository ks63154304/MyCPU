package ChiselRiscV
package tests

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class HexTest extends AnyFlatSpec with ChiselScalatestTester {
    def getProgramFile: Option[String] = {
        if (scalaTestContext.value.get.configMap.contains("programFile")) {
        Some(scalaTestContext.value.get.configMap("programFile").toString)
        } else {
        None
        }
    }

    behavior of "CPU"
        it should "work through hex" in {
            val programFile = getProgramFile
            val config = () => {
                val cpu = new Top
                cpu.mem.loadMemoryFromHexFile(programFile)
                cpu
            }
            test(config()) { dut =>
                while(!dut.exit.peek().litToBoolean) {
                    dut.clock.setTimeout(0)
                    dut.clock.step()
                }
                dut.clock.step()
            }
        }
}
