.rsp
.create outfile, 0

.include "lib/N64.asm"
.include "lib/N64_GFX.asm"
.include "lib/N64_RSP.asm"
.include "lib/N64_RDP.asm"

TC_major equ 0

TC_yl equ 4
TC_ym equ 8
TC_yh equ 12

TC_xl equ 16
TC_dxldy equ 20

TC_xh equ 24
TC_dxhdy equ 28

TC_xm equ 32
TC_dxmdy equ 36

RDPStartPointer equ 0
RDPEndPointer equ 4
Coeffs equ 8

Vertex1 equ 136
Vertex2 equ 144
Vertex3 equ 152


.macro ComputeGradient, x1I, x1F, y1I, y1F, x2I, x2F, y2I, y2F, dxdyI, dxdyF, dxI, dxF, dyI, dyF, rdyI, rdyF
  vsubc dxF, x2F, x1F
  vsub dxI, x2I, x1I

  vsubc dyF, y2F, y1F
  vsub dyI, y2I, y1I

  vrcph rdyI[0], dyI[0]
  vrcpl rdyF[0], dyF[0]
  vrcph rdyI[0], dyI[1]
  vrcpl rdyF[1], dyF[1]
  vrcph rdyI[1], dyI[2]
  vrcpl rdyF[2], dyF[2]
  vrcph rdyI[2], dyI[3]
  vrcpl rdyF[3], dyF[3]
  vrcph rdyI[3], dyI[4]
  vrcpl rdyF[4], dyF[4]
  vrcph rdyI[4], dyI[5]
  vrcpl rdyF[5], dyF[5]
  vrcph rdyI[5], dyI[6]
  vrcpl rdyF[6], dyF[6]
  vrcph rdyI[6], dyI[7]
  vrcpl rdyF[7], dyF[7]
  vrcph rdyI[7], dyI[0]

  vmudn rdyF, rdyF, consts[2]
  vmadm rdyI, rdyI, consts[2]
  vmadn rdyF, rdyF, consts[0]

  vmudl dxdyF, dxF, rdyF
  vmadm dxdyI, dxI, rdyF
  vmadn dxdyF, dxF, rdyI
  vmadh dxdyI, dxI, rdyI

  vge dyI, zeros, dyI
  vmrg dxdyI, zeros, dxdyI
  vmrg dxdyF, zeros, dxdyF
.endmacro


RSPStart:
  la a0, 0x0F000000

  lb a1, Coeffs+TC_major(r0)
  sll a1, 23
  or a0, a1

  lw a1, Coeffs+TC_yl(r0)
  srl a1, 14
  or a0, a1

  lw a2, RDPStartPointer(r0)
  sw a0, 0(a2)

  lw a0, Coeffs+TC_ym(r0)
  la a1, 0xFFFFC000
  and a0, a1
  sll a0, 2

  lw a1, Coeffs+TC_yh(r0)
  srl a1, 14
  or a0, a1

  sw a0, 4(a2)

  lw a0, Coeffs+TC_xl(r0)
  sw a0, 8(a2)

  // lw a0, Coeffs+TC_dxldy(r0)
  // sw a0, 12(a2)

  lw a0, Coeffs+TC_xh(r0)
  sw a0, 16(a2)

  // lw a0, Coeffs+TC_dxhdy(r0)
  // sw a0, 20(a2)

  lw a0, Coeffs+TC_xm(r0)
  sw a0, 24(a2)

  // lw a0, Coeffs+TC_dxmdy(r0)
  // sw a0, 28(a2)

  la a3, Vertex1

zeros equ v30
consts equ v31

  la a0, 0
  mtc2 a0, consts[0]
  la a0, 1
  mtc2 a0, consts[2]
  la a0, 2
  mtc2 a0, consts[4]

x1I equ v0
x1F equ v1
y1I equ v2
y1F equ v3

x2I equ v4
x2F equ v5
y2I equ v6
y2F equ v7

x3I equ v8
x3F equ v9
y3I equ v10
y3F equ v11

  lsv x1I[0], 0(a3)
  lsv x1F[0], 2(a3)
  lsv y1I[0], 4(a3)
  lsv y1F[0], 6(a3)

  lsv x2I[0], 8(a3)
  lsv x2F[0], 10(a3)
  lsv y2I[0], 12(a3)
  lsv y2F[0], 14(a3)
  
  lsv x3I[0], 16(a3)
  lsv x3F[0], 18(a3)
  lsv y3I[0], 20(a3)
  lsv y3F[0], 22(a3)

dxldyI equ v12
dxldyF equ v13
dxmdyI equ v14
dxmdyF equ v15
dxhdyI equ v16
dxhdyF equ v17

  ComputeGradient x2I, x2F, y2I, y2F, x3I, x3F, y3I, y3F, dxldyI, dxldyF, v18, v19, v20, v21, v22, v23
  ComputeGradient x1I, x1F, y1I, y1F, x2I, x2F, y2I, y2F, dxmdyI, dxmdyF, v18, v19, v20, v21, v22, v23
  ComputeGradient x1I, x1F, y1I, y1F, x3I, x3F, y3I, y3F, dxhdyI, dxhdyF, v18, v19, v20, v21, v22, v23

  //sqv x1I, 16(r0)

  ssv dxldyI[0], 12(a2)
  ssv dxldyF[0], 14(a2)
  ssv dxhdyI[0], 20(a2)
  ssv dxhdyF[0], 22(a2)
  ssv dxmdyI[0], 28(a2)
  ssv dxmdyF[0], 30(a2)

  mtc0 a2, c8 // Store DPC Command Start Address To DP Start Register ($A4100000)
  
  lw a0, RDPEndPointer(r0)
  mtc0 a0, c9 // Store DPC Command End Address To DP End Register ($A4100004)
  break // Set SP Status Halt, Broke & Check For Interrupt
.align 8

RDPBuffer:
  Set_Scissor 0<<2, 0<<2, 0, 0, 320<<2, 240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL
  Set_Z_Image 0 // Set Z Image: DRAM ADDRESS
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA, SIZE_OF_PIXEL_16B, 320-1, 0 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS
  Set_Fill_Color 0xFFFFFFFF // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels (Clear ZBuffer)
  Fill_Rectangle 319<<2, 239<<2, 0<<2, 0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Pipe // Stall Pipeline, Until Preceeding Primitives Completely Finish
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA, SIZE_OF_PIXEL_16B, 320-1, 0 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS
  Set_Fill_Color 0x48174817 // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels
  Fill_Rectangle 319<<2, 239<<2, 0<<2, 0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Set_Other_Modes EN_TLUT|SAMPLE_TYPE|BI_LERP_0|ALPHA_DITHER_SEL_NO_DITHER|FORCE_BLEND|IMAGE_READ_EN|Z_COMPARE_EN|Z_UPDATE_EN|PERSP_TEX_EN
  Set_Combine_Mode 1, 4, 7, 7, 1, 4, 8, 8, 7, 7, 7, 7, 6, 7, 7, 6

  Set_Texture_Image IMAGE_DATA_FORMAT_RGBA, SIZE_OF_PIXEL_16B, 1-1, 0 // Set Texture Image: FORMAT RGBA,SIZE 16B,WIDTH 1, Tlut DRAM ADDRESS
  Set_Tile 0, 0, 0, 0x100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 // Set Tile: TMEM Address $100, Tile 0
  Load_Tlut 0<<2, 0<<2, 0, 47<<2, 0<<2 // Load Tlut: SL 0.0,TL 0.0, Tile 0, SH 47.0,TH 0.0

  Sync_Tile // Sync Tile
  Set_Texture_Image IMAGE_DATA_FORMAT_RGBA, SIZE_OF_PIXEL_16B, 4-1, 0 // Set Texture Image: SIZE 16B, WIDTH 4, Texture DRAM ADDRESS
  Set_Tile IMAGE_DATA_FORMAT_RGBA, SIZE_OF_PIXEL_16B, 1, 0x000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 // Set Tile: FORMAT RGBA,SIZE 16B,Tile Line Size 1 (64bit Words), TMEM Address $000, Tile 0
  Load_Tile 0<<2, 0<<2, 0, 15<<2, 15<<2 // Load Tile: SL 0.0,TL 0.0, Tile 0, SH 15.0,TH 15.0
  Sync_Tile // Sync Tile
  Set_Tile IMAGE_DATA_FORMAT_COLOR_INDX, SIZE_OF_PIXEL_4B, 1, 0x000, 0, PALETTE_0, 0, 0, 0, 0, 0, 0, 0, 0 // Set Tile: FORMAT COLOR INDEX,SIZE 4B,Tile Line Size 1 (64bit Words), TMEM Address $000, Tile 0,Palette 0

.align 8
.close