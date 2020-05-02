; Platform support dictionary words for GoSXB

dword     dCPU_HZ,"$CPU_HZ"
          FCONSTANT cpu_clk
eword

dword     dROMFS,"$ROMFS"
          ldy #.loword(romfs)
          lda #.hiword(romfs)
          PUSHNEXT
eword
