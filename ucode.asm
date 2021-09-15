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

  lw a0, Coeffs+TC_dxldy(r0)
  sw a0, 12(a2)

  lw a0, Coeffs+TC_xh(r0)
  sw a0, 16(a2)

  lw a0, Coeffs+TC_dxhdy(r0)
  sw a0, 20(a2)

  lw a0, Coeffs+TC_xm(r0)
  sw a0, 24(a2)

  lw a0, Coeffs+TC_dxmdy(r0)
  sw a0, 28(a2)

  la a3, Vertex1

  lsv v0[0], 0(a3)
  lsv v1[0], 2(a3)
  lsv v2[0], 4(a3)
  lsv v3[0], 6(a3)
  lsv v4[0], 8(a3)
  lsv v5[0], 10(a3)
  lsv v6[0], 12(a3)
  lsv v7[0], 14(a3)

  vsubc v9, v5, v1
  vsub v8, v4, v0

  vsubc v11, v7, v3
  vsub v10, v6, v2

  vrcph v12[0], v10[0]
  vrcpl v13[0], v11[0]
  vrcph v12[0], v10[1]
  vrcpl v13[1], v11[1]
  vrcph v12[1], v10[2]
  vrcpl v13[2], v11[2]
  vrcph v12[2], v10[3]
  vrcpl v13[3], v11[3]
  vrcph v12[3], v10[4]
  vrcpl v13[4], v11[4]
  vrcph v12[4], v10[5]
  vrcpl v13[5], v11[5]
  vrcph v12[5], v10[6]
  vrcpl v13[6], v11[6]
  vrcph v12[6], v10[7]
  vrcpl v13[7], v11[7]
  vrcph v12[7], v10[0]

  la a0, 1
  mtc2 a0, v31[0]
  la a0, 2
  mtc2 a0, v31[2]

  vmudn v13, v13, v31[1]
  vmadm v12, v12, v31[1]
  vmadn v13, v30, v30

  vmudl v15, v9, v13
  vmadm v14, v8, v13
  vmadn v15, v9, v12
  vmadh v14, v8, v12

  vge v16, v30, v10
  vmrg v14, v30, v14
  vmrg v15, v30, v15

  sqv v14[0], 16(r0)

  ssv v14[0], 28(a2)
  ssv v15[0], 30(a2)

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