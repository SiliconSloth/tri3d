endian msb

origin $00000000
include "lib/N64.INC"
include "lib/N64_GFX.INC"
include "lib/N64_RSP.INC"

arch n64.rsp
base $0000

RSPStart:
  RSPDPC(RDPBuffer, RDPBufferEnd)
  break // Set SP Status Halt, Broke & Check For Interrupt
align(8)

RSPData:
base $0000

align(8)
RDPBuffer:
arch n64.rdp
  Set_Scissor 0<<2,0<<2, 0,0, 320<<2,240<<2 // Set Scissor: XH 0.0,YH 0.0, Scissor Field Enable Off,Field Off, XL 320.0,YL 240.0
  Set_Other_Modes CYCLE_TYPE_FILL
  Set_Color_Image IMAGE_DATA_FORMAT_RGBA,SIZE_OF_PIXEL_16B,320-1, $A005F980 // Set Color Image: FORMAT RGBA,SIZE 16B,WIDTH 320, DRAM ADDRESS $00100000
  Set_Fill_Color $23692369 // Set Fill Color: PACKED COLOR 16B R5G5B5A1 Pixels
  Fill_Rectangle 319<<2,239<<2, 0<<2,0<<2 // Fill Rectangle: XL 319.0,YL 239.0, XH 0.0,YH 0.0

  Set_Other_Modes SAMPLE_TYPE|BI_LERP_0|ALPHA_DITHER_SEL_NO_DITHER|B_M1A_0_2
  Set_Combine_Mode $0,$00, 0,0, $6,$01, $0,$F, 1,0, 0,0,0, 7,7,7 // Set Combine Mode: SubA RGB0,MulRGB0, SubA Alpha0,MulAlpha0, SubA RGB1,MulRGB1, SubB RGB0,SubB RGB1, SubA Alpha1,MulAlpha1, AddRGB0,SubB Alpha0,AddAlpha0, AddRGB1,SubB Alpha1,AddAlpha1

  Sync_Pipe // Stall Pipeline, Until Preceeding Primitives Completely Finish
  Set_Blend_Color $FCB195FF // Set Blend Color: RGBA
RDPTriangle1:
  Fill_Triangle 1,0,0, 768,400,240, 240,0,-1,24576, 180,0,-0,32768, 180,0,1,32768 // Dir 1,Level 0,Tile 0, YL 100.0,YM 50.0,YH 50.0, XL 75.0,DxLDy -1.0, XH 25.0,DxHDy 0.0, XM 25.0,DxMDy 0.0
  Sync_Full // Ensure Entire Scene Is Fully Drawn
RDPBufferEnd:

align(8)