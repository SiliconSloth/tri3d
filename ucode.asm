endian msb

origin $00000000
include "lib/N64.INC"
include "lib/N64_GFX.INC"
include "lib/N64_RSP.INC"

arch n64.rsp
base $0000

RSPStart:
  lw a0,RDPStartPointer(r0)
  mtc0 a0,c8 // Store DPC Command Start Address To DP Start Register ($A4100000)
  
  lw a0,RDPEndPointer(r0)
  mtc0 a0,c9 // Store DPC Command End Address To DP End Register ($A4100004)
  break // Set SP Status Halt, Broke & Check For Interrupt
align(8)

RSPData:
base $0000

RDPStartPointer:
  dw 0
RDPEndPointer:
  dw 0

align(8)
RDPBuffer:
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

  Set_Other_Modes SAMPLE_TYPE|ALPHA_DITHER_SEL_NO_DITHER|IMAGE_READ_EN|Z_COMPARE_EN|Z_UPDATE_EN
  Set_Combine_Mode $0,$00, 0,0, $6,$01, $0,$F, 1,0, 0,0,0, 4,7,7 // Set Combine Mode: SubA RGB0,MulRGB0, SubA Alpha0,MulAlpha0, SubA RGB1,MulRGB1, SubB RGB0,SubB RGB1, SubA Alpha1,MulAlpha1, AddRGB0,SubB Alpha0,AddAlpha0, AddRGB1,SubB Alpha1,AddAlpha1

align(8)