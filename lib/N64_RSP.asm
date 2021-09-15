// Generated from N64_RSP.INC
//==============================
// N64 Reality Signal Processor
//==============================
// RSP MIPS 4000 CPU Registers R0..R31
// RSP CP2 128-Bit Vector Registers: V0..V31
// RSP CP2 Vector Elements (128-Bit Vector = 16 Elements): E0..E15

// RSP CP0 Control Registers (MTF0/MTC0):
c0 equ $0   // RSP CP0 Control Register 00: I/DMEM Address For DMA (RW) ($04040000)
c1 equ $1   // RSP CP0 Control Register 01:   DRAM Address For DMA (RW) ($04040004)
c2 equ $2   // RSP CP0 Control Register 02: DMA READ  Length (DRAM -> I/DMEM) (RW) ($04040008)
c3 equ $3   // RSP CP0 Control Register 03: DMA WRITE Length (DRAM <- I/DMEM) (RW) ($0404000C)
c4 equ $4   // RSP CP0 Control Register 04: RSP Status (RW) ($04040010)
c5 equ $5   // RSP CP0 Control Register 05: DMA Full (R) ($04040014)
c6 equ $6   // RSP CP0 Control Register 06: DMA Busy (R) ($04040018)
c7 equ $7   // RSP CP0 Control Register 07: CPU-RSP Semaphore (RW) ($0404001C)
c8 equ $8   // RSP CP0 Control Register 08: RDP Command Buffer START (RW) ($04100000)
c9 equ $9   // RSP CP0 Control Register 09: RDP Command Buffer END (RW) ($04100004)
c10 equ $10 // RSP CP0 Control Register 10: RDP Command Buffer CURRENT (R) ($04100008)
c11 equ $11 // RSP CP0 Control Register 11: RDP Status (RW) ($0410000C)
c12 equ $12 // RSP CP0 Control Register 12: RDP Clock Counter (R) ($04100010)
c13 equ $13 // RSP CP0 Control Register 13: RDP Command Buffer BUSY (R) ($04100014)
c14 equ $14 // RSP CP0 Control Register 14: RDP Pipe BUSY (R) ($04100018)
c15 equ $15 // RSP CP0 Control Register 15: RDP TMEM BUSY (R) ($0410001C)

// RSP CP2 Control Registers (CFC2/CTC2):

// RSP Status Read Flags:
RSP_HLT equ 0x0001 // SP_STATUS: Halt (Bit 0)
RSP_BRK equ 0x0002 // SP_STATUS: Break (Bit 1)
RSP_BSY equ 0x0004 // SP_STATUS: DMA Busy (Bit 2)
RSP_FUL equ 0x0008 // SP_STATUS: DMA Full (Bit 3)
RSP_IOF equ 0x0010 // SP_STATUS: IO Full (Bit 4)
RSP_STP equ 0x0020 // SP_STATUS: Single Step (Bit 5)
RSP_IOB equ 0x0040 // SP_STATUS: Interrupt On Break (Bit 6)
RSP_SG0 equ 0x0080 // SP_STATUS: Signal 0 Set (Bit 7)
RSP_SG1 equ 0x0100 // SP_STATUS: Signal 1 Set (Bit 8)
RSP_SG2 equ 0x0200 // SP_STATUS: Signal 2 Set (Bit 9)
RSP_SG3 equ 0x0400 // SP_STATUS: Signal 3 Set (Bit 10)
RSP_SG4 equ 0x0800 // SP_STATUS: Signal 4 Set (Bit 11)
RSP_SG5 equ 0x1000 // SP_STATUS: Signal 5 Set (Bit 12)
RSP_SG6 equ 0x2000 // SP_STATUS: Signal 6 Set (Bit 13)
RSP_SG7 equ 0x4000 // SP_STATUS: Signal 7 Set (Bit 14)

// RSP Status Write Flags:
CLR_HLT equ 0x0000001 // SP_STATUS: Clear Halt (Bit 0)
SET_HLT equ 0x0000002 // SP_STATUS:   Set Halt (Bit 1)
CLR_BRK equ 0x0000004 // SP_STATUS: Clear Broke (Bit 2)
CLR_INT equ 0x0000008 // SP_STATUS: Clear Interrupt (Bit 3)
SET_INT equ 0x0000010 // SP_STATUS:   Set Interrupt (Bit 4)
CLR_STP equ 0x0000020 // SP_STATUS: Clear Single Step (Bit 5)
SET_STP equ 0x0000040 // SP_STATUS:   Set Single Step (Bit 6)
CLR_IOB equ 0x0000080 // SP_STATUS: Clear Interrupt On Break (Bit 7)
SET_IOB equ 0x0000100 // SP_STATUS:   Set Interrupt On Break (Bit 8)
CLR_SG0 equ 0x0000200 // SP_STATUS: Clear Signal 0 (Bit 9)
SET_SG0 equ 0x0000400 // SP_STATUS:   Set Signal 0 (Bit 10)
CLR_SG1 equ 0x0000800 // SP_STATUS: Clear Signal 1 (Bit 11)
SET_SG1 equ 0x0001000 // SP_STATUS:   Set Signal 1 (Bit 12)
CLR_SG2 equ 0x0002000 // SP_STATUS: Clear Signal 2 (Bit 13)
SET_SG2 equ 0x0004000 // SP_STATUS:   Set Signal 2 (Bit 14)
CLR_SG3 equ 0x0008000 // SP_STATUS: Clear Signal 3 (Bit 15)
SET_SG3 equ 0x0010000 // SP_STATUS:   Set Signal 3 (Bit 16)
CLR_SG4 equ 0x0020000 // SP_STATUS: Clear Signal 4 (Bit 17)
SET_SG4 equ 0x0040000 // SP_STATUS:   Set Signal 4 (Bit 18)
CLR_SG5 equ 0x0080000 // SP_STATUS: Clear Signal 5 (Bit 19)
SET_SG5 equ 0x0100000 // SP_STATUS:   Set Signal 5 (Bit 20)
CLR_SG6 equ 0x0200000 // SP_STATUS: Clear Signal 6 (Bit 21)
SET_SG6 equ 0x0400000 // SP_STATUS:   Set Signal 6 (Bit 22)
CLR_SG7 equ 0x0800000 // SP_STATUS: Clear Signal 7 (Bit 23)
SET_SG7 equ 0x1000000 // SP_STATUS:   Set Signal 7 (Bit 24)

// RDP Status Read Flags:
RDP_XBS equ 0x001 // DPC_STATUS: Use XBUS DMEM DMA Or DRAM DMA (Bit 0)
RDP_FRZ equ 0x002 // DPC_STATUS: RDP Frozen (Bit 1)
RDP_FLS equ 0x004 // DPC_STATUS: RDP Flushed (Bit 2)
RDP_GCL equ 0x008 // DPC_STATUS: GCLK Alive (Bit 3)
RDP_TMB equ 0x010 // DPC_STATUS: TMEM Busy (Bit 4)
RDP_PLB equ 0x020 // DPC_STATUS: RDP PIPELINE Busy (Bit 5)
RDP_CMB equ 0x040 // DPC_STATUS: RDP COMMAND Unit Busy (Bit 6)
RDP_CMR equ 0x080 // DPC_STATUS: RDP COMMAND Buffer Ready (Bit 7)
RDP_DMA equ 0x100 // DPC_STATUS: RDP DMA Busy (Bit 8)
RDP_CME equ 0x200 // DPC_STATUS: RDP COMMAND END Register Valid (Bit 9)
RDP_CMS equ 0x400 // DPC_STATUS: RDP COMMAND START Register Valid (Bit 10)

// RDP Status Write Flags:
CLR_XBS equ 0x001 // DPC_STATUS: Clear XBUS DMEM DMA (Bit 0)
SET_XBS equ 0x002 // DPC_STATUS:   Set XBUS DMEM DMA (Bit 1)
CLR_FRZ equ 0x004 // DPC_STATUS: Clear FREEZE (Bit 2)
SET_FRZ equ 0x008 // DPC_STATUS:   Set FREEZE (Bit 3)
CLR_FLS equ 0x010 // DPC_STATUS: Clear FLUSH (Bit 4)
SET_FLS equ 0x020 // DPC_STATUS:   Set FLUSH (Bit 5)
CLR_TMC equ 0x040 // DPC_STATUS: Clear TMEM COUNTER (Bit 6)
CLR_PLC equ 0x080 // DPC_STATUS: Clear PIPELINE COUNTER (Bit 7)
CLR_CMC equ 0x100 // DPC_STATUS: Clear COMMAND COUNTER (Bit 8)
CLR_CLK equ 0x200 // DPC_STATUS: Clear CLOCK COUNTER (Bit 9)

// CPU Side SP
.macro SetSPPC, start // Set RSP Program Counter: Start Address
  lui a0, SP_PC_BASE // A0 = SP PC Base Register ($A4080000)
  ori t0, r0, start // T0 = RSP Program Counter Set To Start Of RSP Code
  sw t0, SP_PC(a0) // Store RSP Program Counter To SP PC Register ($A4080000)
.endmacro

.macro StartSP // Start RSP Execution: RSP Status = Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  ori t0, r0, CLR_HLT|CLR_BRK|CLR_INT|CLR_STP|CLR_IOB // T0 = RSP Status: Clear Halt, Broke, Interrupt, Single Step, Interrupt On Break
  sw t0, SP_STATUS(a0) // Store RSP Status To SP Status Register ($A4040010)
.endmacro

.macro SPStatusWR, flags // RSP Status: Write Flags
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  li t0, flags // T0 = RSP Status: Write Flags
  sw t0, SP_STATUS(a0) // Store RSP Status To SP Status Register ($A4040010)
.endmacro

// RSP Side SP
.macro RSPSPStatusWR, flags // RSP Status: Write Flags
  li t0, flags // T0 = RSP Status: Write Flags
  mtc0 t0, c4 // Store RSP Status To SP Status Register ($A4040010)
.endmacro

// CPU Side RSP DMA
.macro DMASPRD, start, end, dest, length // RSP DMA Data Read DRAM->RSP MEM: Start Address, End Address, Destination RSP MEM Address
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  lui t0, SP_MEM_BASE // T0 = SP Memory Base Register ($A4000000)
  ori t0, dest&0x1FFF // T0 = SP Memory Address Offset ($A4000000..$A4001FFF 8KB)
  sw t0, SP_MEM_ADDR(a0) // Store Memory Offset To SP Memory Address Register ($A4040000)
  la t0, start&0x7FFFFFF // T0 = Aligned DRAM Physical RAM Offset ($00000000..$007FFFFF 8MB)
  sw t0, SP_DRAM_ADDR(a0) // Store RAM Offset To SP DRAM Address Register ($A4040004)
  la t0, (end-start)-1 // T0 = Length Of DMA Transfer In Bytes - 1
  sw t0, SP_RD_LEN(a0) // Store DMA Length To SP Read Length Register ($A4040008)
.endmacro

.macro DMASPWR, start, end, source // RSP DMA Data Write RSP MEM->DRAM: Start Address, End Address, Source RSP MEM Address
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  lui t0, SP_MEM_BASE // T0 = SP Memory Base Register ($A4000000)
  ori t0, source&0x1FFF // T0 = SP Memory Address Offset ($A4000000..$A4001FFF 8KB)
  sw t0, SP_MEM_ADDR(a0) // Store Memory Offset To SP Memory Address Register ($A4040000)
  la t0, start&0x7FFFFFF // T0 = Aligned DRAM Physical RAM Offset ($00000000..$007FFFFF 8MB)
  sw t0, SP_DRAM_ADDR(a0) // Store RAM Offset To SP DRAM Address Register ($A4040004)
  la t0, (end-start)-1 // T0 = Length Of DMA Transfer In Bytes - 1
  sw t0, SP_WR_LEN(a0) // Store DMA Length To SP Write Length Register ($A404000C)
.endmacro

.macro DMASPWait // Wait For RSP DMA To Finish (DMA Busy = 0, DMA Full = 0)
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  anon\@:
    lw t0, SP_STATUS(a0) // T0 = RSP Status Register ($A4040010)
    andi t0, RSP_BSY|RSP_FUL // AND RSP Status Status With $C: DMA Busy (Bit 2) DMA Full (Bit 3)
    bnez t0, anon\@ // IF TRUE RSP DMA Busy & Full
    nop // Delay Slot
.endmacro

.macro DMASPFull // Wait For RSP DMA Full To Finish (DMA Full = 0)
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  anon\@:
    lw t0, SP_DMA_FULL(a0) // T0 = RSP DMA Full Register ($A4040014)
    bnez t0, anon\@ // IF TRUE RSP DMA Full
    nop // Delay Slot
.endmacro

.macro DMASPBusy // Wait For RSP DMA Busy To Finish (DMA Busy = 0)
  lui a0, SP_BASE // A0 = SP Base Register ($A4040000)
  anon\@:
    lw t0, SP_DMA_BUSY(a0) // T0 = RSP DMA Busy Register ($A4040018)
    bnez t0, anon\@ // IF TRUE RSP DMA Busy
    nop // Delay Slot
.endmacro

// RSP Side RSP DMA
.macro RSPDMASPRD, start, end, dest // RSP DMA Data Read DRAM->RSP MEM: Start Address, End Address, Destination RSP MEM Address
  li a0, dest&0x1FFF // A0 = SP Memory Address Offset ($A4000000..$A4001FFF 8KB)
  mtc0 a0, c0 // Store Memory Offset To SP Memory Address Register ($A4040000)
  la a0, start&0x7FFFFFF // A0 = Aligned DRAM Physical RAM Offset ($00000000..$007FFFFF 8MB)
  mtc0 a0, c1 // Store RAM Offset To SP DRAM Address Register ($A4040004)
  la a0, (end-start)-1 // A0 = Length Of DMA Transfer In Bytes - 1
  mtc0 a0, c2 // Store DMA Length To SP Read Length Register ($A4040008)
.endmacro

.macro RSPDMASPWR, start, end, source // RSP DMA Data Write RSP MEM->DRAM: Start Address, End Address, Source RSP MEM Address
  li a0, source&0x1FFF // A0 = SP Memory Address Offset ($A4000000..$A4001FFF 8KB)
  mtc0 a0, c0 // Store Memory Offset To SP Memory Address Register ($A4040000)
  la a0, start&0x7FFFFFF // A0 = Aligned DRAM Physical RAM Offset ($00000000..$007FFFFF 8MB)
  mtc0 a0, c1 // Store RAM Offset To SP DRAM Address Register ($A4040004)
  la a0, (end-start)-1 // A0 = Length Of DMA Transfer In Bytes - 1
  mtc0 a0, c3 // Store DMA Length To SP Write Length Register ($A404000C)
.endmacro

.macro RSPDMASPWait // Wait For RSP DMA To Finish (DMA Busy = 0, DMA Full = 0)
  anon\@:
    mfc0 t0, c4 // T0 = RSP Status Register ($A4040010)
    andi t0, RSP_BSY|RSP_FUL // AND RSP Status Status With $C: DMA Busy (Bit 2) DMA Full (Bit 3)
    bnez t0, anon\@ // IF TRUE RSP DMA Busy & Full
    nop // Delay Slot
.endmacro

.macro RSPDMASPFull // Wait For RSP DMA Full To Finish (DMA Full = 0)
  anon\@:
    mfc0 t0, c5 // T0 = RSP DMA Full Register ($A4040014)
    bnez t0, anon\@ // IF TRUE RSP DMA Full
    nop // Delay Slot
.endmacro

.macro RSPDMASPBusy // Wait For RSP DMA Busy To Finish (DMA Busy = 0)
  anon\@:
    mfc0 t0, c6 // T0 = RSP DMA Busy Register ($A4040018)
    bnez t0, anon\@ // IF TRUE RSP DMA Busy
    nop // Delay Slot
.endmacro

// CPU Side DP
.macro DPStatusWR, flags // RDP Status: Write Flags
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, flags // T0 = DP Status: Write Flags
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearXBUS // RDP Status: Clear XBUS (Switch To CPU RDRAM For RDP Commands)
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_XBS // T0 = DP Status: Clear XBUS DMEM DMA (Bit 0)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro SetXBUS // RDP Status: Set XBUS (Switch To RSP DMEM For RDP Commands)
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, SET_XBS // T0 = DP Status: Set XBUS DMEM DMA (Bit 1)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearFREEZE // RDP Status: Clear FREEZE
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_FRZ // T0 = DP Status: Clear FREEZE (Bit 2)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro SetFREEZE // RDP Status: Set FREEZE
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, SET_FRZ // T0 = DP Status: Set FREEZE (Bit 3)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearFLUSH // RDP Status: Clear FLUSH
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_FLS // T0 = DP Status: Clear FLUSH (Bit 4)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro SetFLUSH // RDP Status: Set FLUSH
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, SET_FLS // T0 = DP Status: Set FLUSH (Bit 5)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearTMEM // RDP Status: Clear TMEM COUNTER
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_TMC // T0 = DP Status: Clear TMEM COUNTER (Bit 6)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearPIPE // RDP Status: Clear PIPELINE COUNTER
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_PLC // T0 = DP Status: Clear PIPELINE COUNTER (Bit 7)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearCOMMAND // RDP Status: Clear COMMAND COUNTER
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_CMC // T0 = DP Status: Clear COMMAND COUNTER (Bit 8)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro ClearCLOCK // RDP Status: Clear CLOCK COUNTER
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  ori t0, r0, CLR_CLK // T0 = DP Status: Clear CLOCK COUNTER (Bit 9)
  sw t0, DPC_STATUS(a0) // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro DPCOMMANDBusy // Wait For RDP Command Buffer BUSY To Finish (DMA Busy = 0)
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  anon\@:
    lw t0, DPC_BUFBUSY(a0) // T0 = RDP Command Buffer BUSY Register ($A4100014)
    bnez t0, anon\@ // IF TRUE RDP Command Buffer Busy
    nop // Delay Slot
.endmacro

.macro DPPIPEBusy // Wait For RDP Pipe BUSY To Finish (DMA Busy = 0)
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  anon\@:
    lw t0, DPC_PIPEBUSY(a0) // T0 = RDP Pipe BUSY Register ($A4100018)
    bnez t0, anon\@ // IF TRUE RDP Pipe Busy
    nop // Delay Slot
.endmacro

.macro DPTMEMBusy // Wait For RDP TMEM BUSY To Finish (DMA Busy = 0)
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  anon\@:
    lw t0, DPC_TMEM(a0) // T0 = RDP TMEM BUSY Register ($A410001C)
    bnez t0, anon\@ // IF TRUE RDP TMEM Busy
    nop // Delay Slot
.endmacro

// RSP Side DP
.macro RSPDPC, start, end // Run DPC Command Buffer: Start Address, End Address
  la a0, start // A0 = DPC Command Start Address
  mtc0 a0, c8 // Store DPC Command Start Address To DP Start Register ($A4100000)
  addi a0, end-start // A0 = DPC Command End Address
  mtc0 a0, c9 // Store DPC Command End Address To DP End Register ($A4100004)
.endmacro

.macro RSPDPStatusWR, flags // RDP Status: Write Flags
  ori t0, r0, flags // T0 = DP Status: Write Flags
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearXBUS // RDP Status: Clear XBUS (Switch To CPU RDRAM For RDP Commands)
  ori t0, r0, CLR_XBS // T0 = DP Status: Clear XBUS DMEM DMA (Bit 0)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPSetXBUS // RDP Status: Set XBUS (Switch To RSP DMEM For RDP Commands)
  ori t0, r0, SET_XBS // T0 = DP Status: Set XBUS DMEM DMA (Bit 1)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearFREEZE // RDP Status: Clear FREEZE
  ori t0, r0, CLR_FRZ // T0 = DP Status: Clear FREEZE (Bit 2)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPSetFREEZE // RDP Status: Set FREEZE
  ori t0, r0, SET_FRZ // T0 = DP Status: Set FREEZE (Bit 3)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearFLUSH // RDP Status: Clear FLUSH
  ori t0, r0, CLR_FLS // T0 = DP Status: Clear FLUSH (Bit 4)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPSetFLUSH // RDP Status: Set FLUSH
  ori t0, r0, SET_FLS // T0 = DP Status: Set FLUSH (Bit 5)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearTMEM // RDP Status: Clear TMEM COUNTER
  ori t0, r0, CLR_TMC // T0 = DP Status: Clear TMEM COUNTER (Bit 6)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearPIPE // RDP Status: Clear PIPELINE COUNTER
  ori t0, r0, CLR_PLC // T0 = DP Status: Clear PIPELINE COUNTER (Bit 7)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearCOMMAND // RDP Status: Clear COMMAND COUNTER
  ori t0, r0, CLR_CMC // T0 = DP Status: Clear COMMAND COUNTER (Bit 8)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPClearCLOCK // RDP Status: Clear CLOCK COUNTER
  ori t0, r0, CLR_CLK // T0 = DP Status: Clear CLOCK COUNTER (Bit 9)
  mtc0 t0, c11 // Store DP Status To DP Status Register ($A410000C)
.endmacro

.macro RSPDPCOMMANDBusy // Wait For RDP Command Buffer BUSY To Finish (DMA Busy = 0)
  anon\@:
    mfc0 t0, c13 // T0 = RDP Command Buffer BUSY Register ($A4100014)
    bnez t0, anon\@ // IF TRUE RDP Command Buffer Busy
    nop // Delay Slot
.endmacro

.macro RSPDPPIPEBusy // Wait For RDP Pipe BUSY To Finish (DMA Busy = 0)
  anon\@:
    mfc0 t0, c14 // T0 = RDP Pipe BUSY Register ($A4100018)
    bnez t0, anon\@ // IF TRUE RDP Pipe Busy
    nop // Delay Slot
.endmacro

.macro RSPDPTMEMBusy // Wait For RDP TMEM BUSY To Finish (DMA Busy = 0)
  anon\@:
    mfc0 t0, c15 // T0 = RDP TMEM BUSY Register ($A410001C)
    bnez t0, anon\@ // IF TRUE RDP TMEM Busy
    nop // Delay Slot
.endmacro

// RSP CP2 Vector Operation Instructions (COP2):
// vmulf vd,vs,vt[e] ; Vector Multiply Signed Fractions: VMULF VD,VS,VT[ELEMENT]
// vmulu vd,vs,vt[e] ; Vector Multiply Unsigned Fractions: VMULU VD,VS,VT[ELEMENT]
// vrndp vd,vs,vt[e] ; Vector DCT Round Positive: VRNDP VD,VS,VT[ELEMENT] (Reserved: MPEG DCT Rounding)
// vmulq vd,vs,vt[e] ; Vector Multiply Integer: VMULQ VD,VS,VT[ELEMENT] (Reserved: MPEG Inverse Quantization)
// vmudl vd,vs,vt[e] ; Vector Multiply  Low Partial Products: VMUDL VD,VS,VT[ELEMENT]
// vmudm vd,vs,vt[e] ; Vector Multiply  Mid Partial Products: VMUDM VD,VS,VT[ELEMENT]
// vmudn vd,vs,vt[e] ; Vector Multiply  Mid Partial Products: VMUDN VD,VS,VT[ELEMENT]
// vmudh vd,vs,vt[e] ; Vector Multiply High Partial Products: VMUDH VD,VS,VT[ELEMENT]
// vmacf vd,vs,vt[e] ; Vector Multiply Accumulate Signed Fractions: VMACF VD,VS,VT[ELEMENT]
// vmacu vd,vs,vt[e] ; Vector Multiply Accumulate Unsigned Fractions: VMACU VD,VS,VT[ELEMENT]
// vrndn vd,vs,vt[e] ; Vector DCT Round Negative: VRNDN VD,VS,VT[ELEMENT] (Reserved: MPEG DCT Rounding)
// vmacq vd,vs,vt[e] ; Vector Multiply Accumulate Integer: VMACQ VD,VS,VT[ELEMENT] (Reserved: MPEG Inverse Quantization)
// vmadl vd,vs,vt[e] ; Vector Multiply Accumulate  Low Partial Products: VMADL VD,VS,VT[ELEMENT]
// vmadm vd,vs,vt[e] ; Vector Multiply Accumulate  Mid Partial Products: VMADM VD,VS,VT[ELEMENT]
// vmadn vd,vs,vt[e] ; Vector Multiply Accumulate  Mid Partial Products: VMADN VD,VS,VT[ELEMENT]
// vmadh vd,vs,vt[e] ; Vector Multiply Accumulate High Partial Products: VMADH VD,VS,VT[ELEMENT]
// vadd  vd,vs,vt[e] ; Vector Add Short Elements: VADD VD,VS,VT[ELEMENT]
// vsub  vd,vs,vt[e] ; Vector Subtract Short Elements: VSUB VD,VS,VT[ELEMENT]
// vsut  vd,vs,vt[e] ; Vector Subtract Short Elements (VT-VS): VSUT VD,VS,VT[ELEMENT] (Reserved)
// vabs  vd,vs,vt[e] ; Vector Absolute Value Of Short Elements: VABS VD,VS,VT[ELEMENT]
// vaddc vd,vs,vt[e] ; Vector Add Short Elements With Carry: VADDC VD,VS,VT[ELEMENT]
// vsubc vd,vs,vt[e] ; Vector Subtract Short Elements With Carry: VSUBC VD,VS,VT[ELEMENT]
// vaddb vd,vs,vt[e] ; Vector Add Byte Elements: VADDB VD,VS,VT[ELEMENT] (Reserved)
// vsubb vd,vs,vt[e] ; Vector Subtract Byte Elements: VSUBB VD,VS,VT[ELEMENT] (Reserved)
// vaccb vd,vs,vt[e] ; Vector Add Byte Elements With Carry: VACCB VD,VS,VT[ELEMENT] (Reserved)
// vsucb vd,vs,vt[e] ; Vector Subtract Byte Elements With Carry: VSUCB VD,VS,VT[ELEMENT] (Reserved)
// vsad  vd,vs,vt[e] ; Vector SAD: VSAD VD,VS,VT[ELEMENT] (Reserved)
// vsac  vd,vs,vt[e] ; Vector SAC: VSAC VD,VS,VT[ELEMENT] (Reserved)
// vsum  vd,vs,vt[e] ; Vector SUM: VSUM VD,VS,VT[ELEMENT] (Reserved)
// vsar  vd,vs,vt[e] ; Vector Accumulator Read: VSAR VD,VS,VT[ELEMENT]
// vacc  vd,vs,vt[e] ; Vector Add Elements With Carry: VACC VD,VS,VT[ELEMENT] (Reserved)
// vsuc  vd,vs,vt[e] ; Vector Subtract Elements With Carry: VSUC VD,VS,VT[ELEMENT] (Reserved)
// vlt   vd,vs,vt[e] ; Vector Select Less Than: VLT VD,VS,VT[ELEMENT]
// veq   vd,vs,vt[e] ; Vector Select Equal: VEQ VD,VS,VT[ELEMENT]
// vne   vd,vs,vt[e] ; Vector Select Not Equal: VNE VD,VS,VT[ELEMENT]
// vge   vd,vs,vt[e] ; Vector Select Greater Than Or Equal: VGE VD,VS,VT[ELEMENT]
// vcl   vd,vs,vt[e] ; Vector Select Clip Test Low: VCL VD,VS,VT[ELEMENT]
// vch   vd,vs,vt[e] ; Vector Select Clip Test High: VCH VD,VS,VT[ELEMENT]
// vcr   vd,vs,vt[e] ; Vector Select Crimp Test Low: VCR VD,VS,VT[ELEMENT]
// vmrg  vd,vs,vt[e] ; Vector Select Merge: VMRG VD,VS,VT[ELEMENT]
// vand  vd,vs,vt[e] ; Vector Logical AND Short Elements: VAND VD,VS,VT[ELEMENT]
// vnand vd,vs,vt[e] ; Vector Logical NOT AND Short Elements: VNAND VD,VS,VT[ELEMENT]
// vor   vd,vs,vt[e] ; Vector Logical OR Short Elements: VOR VD,VS,VT[ELEMENT]
// vnor  vd,vs,vt[e] ; Vector Logical NOT OR Short Elements: VNOR VD,VS,VT[ELEMENT]
// vxor  vd,vs,vt[e] ; Vector Logical Exclusive OR Short Elements: VXOR VD,VS,VT[ELEMENT]
// vnxor vd,vs,vt[e] ; Vector Logical NOT Exclusive OR Short Elements: VNXOR VD,VS,VT[ELEMENT]
// v056  vd,vs,vt[e] ; Vector Row 5 Column 6: V056 VD,VS,VT[ELEMENT] (Reserved)
// v057  vd,vs,vt[e] ; Vector Row 5 Column 7: V057 VD,VS,VT[ELEMENT] (Reserved)

// vrcp  vd[de],vt[e] ; Vector Element Scalar Reciprocal (Single Precision): VRCP VD[ELEMENT],VT[ELEMENT]
// vrcpl vd[de],vt[e] ; Vector Element Scalar Reciprocal Low: VRCPL VD[ELEMENT],VT[ELEMENT]
// vrcph vd[de],vt[e] ; Vector Element Scalar Reciprocal High: VRCPH VD[ELEMENT],VT[ELEMENT]
// vmov  vd[de],vt[e] ; Vector Element Scalar Move: VMOV VD[ELEMENT],VT[ELEMENT]
// vrsq  vd[de],vt[e] ; Vector Element Scalar SQRT Reciprocal (Single Precision): VRSQ VD[ELEMENT],VT[ELEMENT]
// vrsql vd[de],vt[e] ; Vector Element Scalar SQRT Reciprocal Low: VRSQL VD[ELEMENT],VT[ELEMENT]
// vrsqh vd[de],vt[e] ; Vector Element Scalar SQRT Reciprocal High: VRSQH VD[ELEMENT],VT[ELEMENT]

// vnop ; Vector Null Instruction: VNOP

// vextt vd,vs,vt[e] ; Vector Extract Triple (5/5/5/1): VEXTT VD,VS,VT[ELEMENT] (Reserved)
// vextq vd,vs,vt[e] ; Vector Extract Quad (4/4/4/4): VEXTQ VD,VS,VT[ELEMENT] (Reserved)
// vextn vd,vs,vt[e] ; Vector Extract Nibble (4/4/4/4) (Sign Extended): VEXTN VD,VS,VT[ELEMENT] (Reserved)
// v073  vd,vs,vt[e] ; Vector Row 7 Column 3: V073 VD,VS,VT[ELEMENT] (Reserved)
// vinst vd,vs,vt[e] ; Vector Insert Triple (5/5/5/1): VINST VD,VS,VT[ELEMENT] (Reserved)
// vinsq vd,vs,vt[e] ; Vector Insert Quad (4/4/4/4): VINSQ VD,VS,VT[ELEMENT] (Reserved)
// vinsn vd,vs,vt[e] ; Vector Insert Nibble (4/4/4/4) (Sign Extended): VINSN VD,VS,VT[ELEMENT] (Reserved)

// vnull ; Vector Null Instruction: VNULL (Reserved)

// RSP CP2 Vector Load Instructions (LWC2):
// lbv vt[e],offset(base) ; Load Byte To Vector: LBV VT[ELEMENT],$OFFSET(BASE)
// lsv vt[e],offset(base) ; Load Short To Vector: LSV VT[ELEMENT],$OFFSET(BASE)
// llv vt[e],offset(base) ; Load Long To Vector: LLV VT[ELEMENT],$OFFSET(BASE)
// ldv vt[e],offset(base) ; Load Double To Vector: LDV VT[ELEMENT],$OFFSET(BASE)
// lqv vt[e],offset(base) ; Load Quad To Vector: LQV VT[ELEMENT],$OFFSET(BASE)
// lrv vt[e],offset(base) ; Load Rest To Vector: LRV VT[ELEMENT],$OFFSET(BASE)
// lpv vt[e],offset(base) ; Load Packed Signed To Vector: LPV VT[ELEMENT],$OFFSET(BASE)
// luv vt[e],offset(base) ; Load Packed Unsigned To Vector: LUV VT[ELEMENT],$OFFSET(BASE)
// lhv vt[e],offset(base) ; Load Half Bytes To Vector: LHV VT[ELEMENT],$OFFSET(BASE)
// lfv vt[e],offset(base) ; Load Fourth Bytes To Vector: LFV VT[ELEMENT],$OFFSET(BASE)
// lwv vt[e],offset(base) ; Load Transposed Wrapped Bytes To Vector: LWV VT[ELEMENT],$OFFSET(BASE) (Reserved)
// ltv vt[e],offset(base) ; Load Transposed Bytes To Vector: LTV VT[ELEMENT],$OFFSET(BASE)

// RSP CP2 Vector Store Instructions (SWC2):
// sbv vt[e],offset(base) ; Store Byte From Vector: SBV VT[ELEMENT],$OFFSET(BASE)
// ssv vt[e],offset(base) ; Store Short From Vector: SSV VT[ELEMENT],$OFFSET(BASE)
// slv vt[e],offset(base) ; Store Long From Vector: SLV VT[ELEMENT],$OFFSET(BASE)
// sdv vt[e],offset(base) ; Store Double From Vector: SDV VT[ELEMENT],$OFFSET(BASE)
// sqv vt[e],offset(base) ; Store Quad From Vector: SQV VT[ELEMENT],$OFFSET(BASE)
// srv vt[e],offset(base) ; Store Rest From Vector: SRV VT[ELEMENT],$OFFSET(BASE)
// spv vt[e],offset(base) ; Store Packed Signed From Vector: SPV VT[ELEMENT],$OFFSET(BASE)
// suv vt[e],offset(base) ; Store Packed Unsigned From Vector: SUV VT[ELEMENT],$OFFSET(BASE)
// shv vt[e],offset(base) ; Store Half Bytes From Vector: SHV VT[ELEMENT],$OFFSET(BASE)
// sfv vt[e],offset(base) ; Store Fourth Bytes From Vector: SFV VT[ELEMENT],$OFFSET(BASE)
// swv vt[e],offset(base) ; Store Transposed Wrapped Bytes From Vector: SWV VT[ELEMENT],$OFFSET(BASE)
// stv vt[e],offset(base) ; Store Transposed Bytes From Vector: STV VT[ELEMENT],$OFFSET(BASE)
