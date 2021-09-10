endian msb

origin $00000000
include "lib/N64.INC"
include "lib/N64_GFX.INC"
include "lib/N64_RSP.INC"

constant TC_major(0)

constant TC_yl(4)
constant TC_ym(8)
constant TC_yh(12)

constant TC_xl(16)
constant TC_dxldy(20)

constant TC_xh(24)
constant TC_dxhdy(28)

constant TC_xm(32)
constant TC_dxmdy(36)

constant RDPStartPointer(0)
constant RDPEndPointer(4)
constant Coeffs(8)

arch n64.rsp
base $0000

RSPStart:
  la a0,$0F000000

  lb a1,Coeffs+TC_major(r0)
  sll a1,23
  or a0,a1

  lw a1,Coeffs+TC_yl(r0)
  srl a1,14
  or a0,a1

  lw a2,RDPStartPointer(r0)
  sw a0,0(a2)

  lw a0,Coeffs+TC_ym(r0)
  la a1,$FFFFC000
  and a0,a1
  sll a0,2

  lw a1,Coeffs+TC_yh(r0)
  srl a1,14
  or a0,a1

  sw a0,4(a2)

  lw a0,Coeffs+TC_xl(r0)
  sw a0,8(a2)

  lw a0,Coeffs+TC_dxldy(r0)
  sw a0,12(a2)

  lw a0,Coeffs+TC_xh(r0)
  sw a0,16(a2)

  lw a0,Coeffs+TC_dxhdy(r0)
  sw a0,20(a2)

  lw a0,Coeffs+TC_xm(r0)
  sw a0,24(a2)

  lw a0,Coeffs+TC_dxmdy(r0)
  sw a0,28(a2)

  la a0,$CAFEABBA
  sw a0,32(r0)
  llv v0[e0],32(r0)
  llv v0[e4],32(r0)
  llv v0[e8],32(r0)
  llv v0[e12],32(r0)

  sqv v0[e0],16(r0)

  mtc0 a2,c8 // Store DPC Command Start Address To DP Start Register ($A4100000)
  
  lw a0,RDPEndPointer(r0)
  mtc0 a0,c9 // Store DPC Command End Address To DP End Register ($A4100004)
  break // Set SP Status Halt, Broke & Check For Interrupt
align(8)

RDPBuffer:
base $0000
arch n64.rdp
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL
  Set_Z_Image 0 // Set Z Image: DRAM ADDRESS
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, 0 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS
  Set_Fill_Color $FFFFFFFF // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels (Clear ZBuffer)
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Sync_Pipe // Stall Pipeline, Until Preceeding Primitives Completely Finish
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, 0 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS
  Set_Fill_Color $48174817 // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Set_Other_Modes EN_TLUT|SAMPLE_TYPE|BI_LERP_0|ALPHA_DITHER_SEL_NO_DITHER|FORCE_BLEND|IMAGE_READ_EN|Z_COMPARE_EN|Z_UPDATE_EN|PERSP_TEX_EN
  Set_Combine_Mode 1,4, 7,7, 1,4, 8,8, 7,7, 7,7,6, 7,7,6

  Set_Texture_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,1-1, 0 // Set Texture Image: FORMAT RGBA,SIZE 16B,WIDTH 1, Tlut DRAM ADDRESS
  Set_Tile 0,0,0, $100, 0,0, 0,0,0,0, 0,0,0,0 // Set Tile: TMEM Address $100, Tile 0
  Load_Tlut 0<<2,0<<2, 0, 47<<2,0<<2 // Load Tlut: SL 0.0,TL 0.0, Tile 0, SH 47.0,TH 0.0

  Sync_Tile // Sync Tile
  Set_Texture_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,4-1, 0 // Set Texture Image: SIZE 16B, WIDTH 4, Texture DRAM ADDRESS
  Set_Tile IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,1, $000, 0,0, 0,0,0,0, 0,0,0,0 // Set Tile: FORMAT RGBA,SIZE 16B,Tile Line Size 1 (64bit Words), TMEM Address $000, Tile 0
  Load_Tile 0<<2,0<<2, 0, 15<<2,15<<2 // Load Tile: SL 0.0,TL 0.0, Tile 0, SH 15.0,TH 15.0
  Sync_Tile // Sync Tile
  Set_Tile IMAGE_DATA_FORMAT_COLOR_INDX,SIZE_OF_PIXEL_4B,1, $000, 0,PALETTE_0, 0,0,0,0, 0,0,0,0 // Set Tile: FORMAT COLOR INDEX,SIZE 4B,Tile Line Size 1 (64bit Words), TMEM Address $000, Tile 0,Palette 0

align(8)