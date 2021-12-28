.rsp
.create outfile, 0

.include "lib/N64_GFX.asm"
.include "lib/N64_RSP.asm"
.include "lib/N64_RDP.asm"

.include "types.asm"
.include "ops.asm"
.include "coeffs.asm"


RDPStartPointer equ 0
RDPEndPointer equ 4
Vertices equ 8

zeros equ v30
consts equ v31

const_1  equ 0
const_2  equ 1
const_4  equ 2
const_r4 equ 3
max_gap  equ 3
y_mask   equ 4
maj_bit  equ 5
command  equ 6


RSPStart:
  la t0, 1
  mtc2 t0, consts[0]
  la t0, 2
  mtc2 t0, consts[2]
  la t0, 4
  mtc2 t0, consts[4]
  la t0, 0x4000
  mtc2 t0, consts[6]
  la t0, 0x3FFF
  mtc2 t0, consts[8]
  la t0, 0x80
  mtc2 t0, consts[10]
  la t0, 0xF00
  mtc2 t0, consts[12]

  LoadBase 0

  lw t8, RDPStartPointer(r0)
  StoreBase r0

  ComputeCoeffs v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26

  lw a2, RDPStartPointer(r0)
  mtc0 a2, dpc_start
  
  lw a0, RDPEndPointer(r0)
  mtc0 a0, dpc_end
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