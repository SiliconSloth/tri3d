.rsp
.create outfile, 0

.include "lib/N64_GFX.asm"
.include "lib/N64_RSP.asm"
.include "lib/N64_RDP.asm"

V_x equ 0
V_y equ 4
V_z equ 8
V_w equ 12

V_r equ 16
V_g equ 20
V_b equ 24

V_s equ 28
V_t equ 32

V_size equ 36

RDPStartPointer equ 0
RDPEndPointer equ 4
Vertices equ 8


.macro Load, addr, part, ind, out
  lsv out[0],  addr + part * 2 + V_size * (ind - 3)(a0)
  lsv out[2],  addr + part * 2 + V_size * ind(a0)

  lsv out[4],  addr + part * 2 + V_size * (ind - 3)(a1)
  lsv out[6],  addr + part * 2 + V_size * ind(a1)

  lsv out[8],  addr + part * 2 + V_size * (ind - 3)(a2)
  lsv out[10], addr + part * 2 + V_size * ind(a2)

  lsv out[12], addr + part * 2 + V_size * (ind - 3)(a3)
  lsv out[14], addr + part * 2 + V_size * ind(a3)
.endmacro


RSPStart:
  la a0, Vertices + V_size * 3
  la a1, Vertices + V_size * 9
  la a2, Vertices + V_size * 15
  la a3, Vertices + V_size * 21

  Load V_t, 1, 2, v0

  sqv v0[0],  16(r0)

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