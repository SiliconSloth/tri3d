// Generated from N64_GFX.INC
//==============
// N64 Graphics
//==============
BPP0 equ 0x0000  // VI Status/Control: Color Depth Blank (No Data Or Sync) (Bit 0..1)
//*RESERVED*($0001)   // VI Status/Control: Color Depth Reserved (Bit 0..1)
BPP16 equ 0x0002 // VI Status/Control: Color Depth 16BPP R5/G5/B5/A1 (Bit 0..1)
BPP32 equ 0x0003 // VI Status/Control: Color Depth 32BPP R8/G8/B8/A8 (Bit 0..1)
GAMMA_DITHER_EN equ 0x00004 // VI Status/Control: Gamma Dither Enable (Requires: Gamma Enable) (Bit 2)
GAMMA_EN equ 0x00008        // VI Status/Control: Gamma Enable (Gamma Boost For YUV Images) (Bit 3)
DIVOT_EN equ 0x00010    // VI Status/Control: Divot Enable (Used With Anti-alias) (Bit 4)
VBUS_CLK_EN equ 0x00020 // VI Status/Control: Video Bus Clock Enable (Bit 5)
INTERLACE equ 0x00040 // VI Status/Control: Interlace/Serrate (Used With Interlaced Display) (Bit 6)
TST_MODE equ 0x00080  // VI Status/Control: Test Mode (Bit 7)
AA_MODE_0 equ 0x00000 // VI Status/Control: AA Mode 0 = Anti­-alias & Resample (Always Fetch Extra Lines) (Bit 8..9)
AA_MODE_1 equ 0x00100 // VI Status/Control: AA Mode 1 = Anti­-alias & Resample (Fetch Extra Lines When Needed) (Bit 8..9)
AA_MODE_2 equ 0x00200 // VI Status/Control: AA Mode 2 = Resample Only (Bit 8..9)
AA_MODE_3 equ 0x00300 // VI Status/Control: AA Mode 3 = Replicate Pixels & No Interpolation (Bit 8..9)
DIAG_0 equ 0x00400 // VI Status/Control: Diagnotic 0 (Bit 10..11)
DIAG_1 equ 0x00800 // VI Status/Control: Diagnotic 1 (Bit 10..11)
PIXEL_ADV_0 equ 0x00000 // VI Status/Control: Pixel Advance 0 (Bit 12..15)
PIXEL_ADV_1 equ 0x01000 // VI Status/Control: Pixel Advance 1 (Bit 12..15)
PIXEL_ADV_2 equ 0x02000 // VI Status/Control: Pixel Advance 2 (Bit 12..15)
PIXEL_ADV_3 equ 0x03000 // VI Status/Control: Pixel Advance 3 (Bit 12..15)
PIXEL_ADV_4 equ 0x04000 // VI Status/Control: Pixel Advance 4 (Bit 12..15)
PIXEL_ADV_5 equ 0x05000 // VI Status/Control: Pixel Advance 5 (Bit 12..15)
PIXEL_ADV_6 equ 0x06000 // VI Status/Control: Pixel Advance 6 (Bit 12..15)
PIXEL_ADV_7 equ 0x07000 // VI Status/Control: Pixel Advance 7 (Bit 12..15)
PIXEL_ADV_8 equ 0x08000 // VI Status/Control: Pixel Advance 8 (Bit 12..15)
PIXEL_ADV_9 equ 0x09000 // VI Status/Control: Pixel Advance 9 (Bit 12..15)
PIXEL_ADV_A equ 0x0A000 // VI Status/Control: Pixel Advance A (Bit 12..15)
PIXEL_ADV_B equ 0x0B000 // VI Status/Control: Pixel Advance B (Bit 12..15)
PIXEL_ADV_C equ 0x0C000 // VI Status/Control: Pixel Advance C (Bit 12..15)
PIXEL_ADV_D equ 0x0D000 // VI Status/Control: Pixel Advance D (Bit 12..15)
PIXEL_ADV_E equ 0x0E000 // VI Status/Control: Pixel Advance E (Bit 12..15)
PIXEL_ADV_F equ 0x0F000 // VI Status/Control: Pixel Advance F (Bit 12..15)
DITHER_FILTER_EN equ 0x10000 // VI Status/Control: Dither Filter Enable (Used With 16BPP Display) (Bit 16)

.macro ScreenNTSC, width, height, status, origin
  lui a0, VI_BASE // A0 = VI Base Register ($A4400000)
  li t0, status      // T0 = Status/Control
  sw t0, VI_STATUS(a0) // Store Status/Control To VI Status Register ($A4400000)
  la t0, origin      // T0 = Origin (Frame Buffer Origin In Bytes)
  sw t0, VI_ORIGIN(a0) // Store Origin To VI Origin Register ($A4400004)
  ori t0, r0, width   // T0 = Width (Frame Buffer Line Width In Pixels)
  sw t0, VI_WIDTH(a0)  // Store Width To VI Width Register ($A4400008)
  ori t0, r0, 0x200      // T0 = Vertical Interrupt (Interrupt When Current Half-Line $200)
  sw t0, VI_V_INTR(a0) // Store Vertical Interrupt To VI Interrupt Register ($A440000C)
  ori t0, r0, 0         // T0 = Current Vertical Line (Current Half-Line, Sampled Once Per Line = 0)
  sw t0, VI_V_CURRENT_LINE(a0) // Store Current Vertical Line To VI Current Register ($A4400010)
  li t0, 0x3E52239      // T0 = Video Timing (Start Of Color Burst In Pixels from H-Sync = 3, Vertical Sync Width In Half Lines = 229, Color Burst Width In Pixels = 34, Horizontal Sync Width In Pixels = 57)
  sw t0, VI_TIMING(a0) // Store Video Timing To VI Burst Register ($A4400014)
  ori t0, r0, 0x20D      // T0 = Vertical Sync (Number Of Half-Lines Per Field = 525)
  sw t0, VI_V_SYNC(a0) // Store Vertical Sync To VI V Sync Register ($A4400018)
  ori t0, r0, 0xC15      // T0 = Horizontal Sync (5-bit Leap Pattern Used For PAL only = 0, Total Duration Of A Line In 1/4 Pixel = 3093)
  sw t0, VI_H_SYNC(a0) // Store Horizontal Sync To VI H Sync Register ($A440001C)
  li t0, 0xC150C15           // T0 = Horizontal Sync Leap (Identical To H Sync = 3093, Identical To H Sync = 3093)
  sw t0, VI_H_SYNC_LEAP(a0) // Store Horizontal Sync Leap To VI Leap Register ($A4400020)
  li t0, 0x6C02EC        // T0 = Horizontal Video (Start Of Active Video In Screen Pixels = 108, End Of Active Video In Screen Pixels = 748)
  sw t0, VI_H_VIDEO(a0) // Store Horizontal Video To VI H Start Register ($A4400024)
  li t0, 0x2501FF        // T0 = Vertical Video (Start Of Active Video In Screen Half-Lines = 37, End Of Active Video In Screen Half-Lines = 511)
  sw t0, VI_V_VIDEO(a0) // Store Vertical Video To VI V Start Register ($A4400028)
  li t0, 0xE0204         // T0 = Vertical Burst (Start Of Color Burst Enable In Half-Lines = 14, End Of Color Burst Enable In Half-Lines = 516)
  sw t0, VI_V_BURST(a0) // Store Vertical Burst To VI V Burst Register ($A440002C)
  ori t0, r0, ((0x100*width)/160) // T0 = X-Scale (Horizontal Subpixel Offset In 2.10 Format = 0, 1/Horizontal Scale Up Factor In 2.10 Format)
  sw t0, VI_X_SCALE(a0)           // Store X-Scale To VI X Scale Register ($A4400030)
  ori t0, r0, ((0x100*height)/60) // T0 = Y-Scale (Vertical Subpixel Offset In 2.10 Format = 0, 1/Vertical Scale Up Factor In 2.10 Format)
  sw t0, VI_Y_SCALE(a0)           // Store Y-Scale To VI Y Scale Register ($A4400034)
.endmacro

.macro ScreenPAL, width, height, status, origin
  lui a0, VI_BASE // A0 = VI Base Register ($A4400000)
  li t0, status      // T0 = Status/Control
  sw t0, VI_STATUS(a0) // Store Status/Control To VI Status Register ($A4400000)
  la t0, origin      // T0 = Origin (Frame Buffer Origin In Bytes)
  sw t0, VI_ORIGIN(a0) // Store Origin To VI Origin Register ($A4400004)
  ori t0, r0, width   // T0 = Width (Frame Buffer Line Width In Pixels)
  sw t0, VI_WIDTH(a0)  // Store Width To VI Width Register ($A4400008)
  ori t0, r0, 0x200      // T0 = Vertical Interrupt (Interrupt When Current Half-Line $200)
  sw t0, VI_V_INTR(a0) // Store Vertical Interrupt To VI Interrupt Register ($A440000C)
  ori t0, r0, 0         // T0 = Current Vertical Line (Current Half-Line, Sampled Once Per Line = 0)
  sw t0, VI_V_CURRENT_LINE(a0) // Store Current Vertical Line To VI Current Register ($A4400010)
  li t0, 0x404233A      // T0 = Video Timing (Start Of Color Burst In Pixels from H-Sync = 4, Vertical Sync Width In Half Lines = 04, Color Burst Width In Pixels = 35, Horizontal Sync Width In Pixels = 58)
  sw t0, VI_TIMING(a0) // Store Video Timing To VI Burst Register ($A4400014)
  ori t0, r0, 0x271      // T0 = Vertical Sync (Number Of Half-Lines Per Field = 625)
  sw t0, VI_V_SYNC(a0) // Store Vertical Sync To VI V Sync Register ($A4400018)
  li t0, 0x150C69       // T0 = Horizontal Sync (5-bit Leap Pattern Used For PAL only = 21: %10101, Total Duration Of A Line In 1/4 Pixel = 3177)
  sw t0, VI_H_SYNC(a0) // Store Horizontal Sync To VI H Sync Register ($A440001C)
  li t0, 0xC6F0C6E           // T0 = Horizontal Sync Leap (Identical To H Sync = 3183, Identical To H Sync = 3182)
  sw t0, VI_H_SYNC_LEAP(a0) // Store Horizontal Sync Leap To VI Leap Register ($A4400020)
  li t0, 0x800300        // T0 = Horizontal Video (Start Of Active Video In Screen Pixels = 128, End Of Active Video In Screen Pixels = 768)
  sw t0, VI_H_VIDEO(a0) // Store Horizontal Video To VI H Start Register ($A4400024)
  li t0, 0x5F0239        // T0 = Vertical Video (Start Of Active Video In Screen Half-Lines = 95, End Of Active Video In Screen Half-Lines = 569)
  sw t0, VI_V_VIDEO(a0) // Store Vertical Video To VI V Start Register ($A4400028)
  li t0, 0x9026B         // T0 = Vertical Burst (Start Of Color Burst Enable In Half-Lines = 9, End Of Color Burst Enable In Half-Lines = 619)
  sw t0, VI_V_BURST(a0) // Store Vertical Burst To VI V Burst Register ($A440002C)
  ori t0, r0, ((0x100*width)/160) // T0 = X-Scale (Horizontal Subpixel Offset In 2.10 Format = 0, 1/Horizontal Scale Up Factor In 2.10 Format)
  sw t0, VI_X_SCALE(a0)           // Store X-Scale To VI X Scale Register ($A4400030)
  ori t0, r0, ((0x100*height)/60) // T0 = Y-Scale (Vertical Subpixel Offset In 2.10 Format = 0, 1/Vertical Scale Up Factor In 2.10 Format)
  sw t0, VI_Y_SCALE(a0)           // Store Y-Scale To VI Y Scale Register ($A4400034)
.endmacro

.macro WaitScanline, scanline // Wait For RDP To Reach Scanline
  lui a0, VI_BASE // A0 = VI Base Register ($A4400000)
  ori t0, r0, scanline // T0 = Scan Line
  anon\@:
    lw t1, VI_V_CURRENT_LINE(a0) // T1 = Current Scan Line
    bne t1, t0, anon\@ // IF (Current Scan Line != Scan Line) Wait
    nop // ELSE Continue (Delay Slot)
.endmacro

// RDP Commands
.macro DPC, start, end // Run DPC Command Buffer: Start Address, End Address
  lui a0, DPC_BASE // A0 = Reality Display Processer Control Interface Base Register ($A4100000)
  la a1, start // A1 = DPC Command Start Address
  sw a1, DPC_START(a0) // Store DPC Command Start Address To DP Start Register ($A4100000)
  la a1, end // A1 = DPC Command End Address
  sw a1, DPC_END(a0) // Store DPC Command End Address To DP End Register ($A4100004)
.endmacro

// No_Op: No Effect On RDP Command Execution, Useful For Padding Command Buffers

// Fill_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction

// Fill_ZBuffer_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4: Z Inverse Depth Integer, Fraction, DzDx Change In Z Per Change In X Coordinate Integer, Fraction (ZBuffer Coefficients)
// Word 5: DzDe Change In Z Along Major Edge Integer, Fraction, DzDy Change In Z Per Change In Y Coordinate Integer, Fraction

// Texture_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4:  S Texture Coordinate Integer, T Texture Coordinate Integer, W Normalized Inverse Depth Integer (Texture Coefficients)
// Word 5:  DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Integer
// Word 6:  S Texture Coordinate Fraction, T Texture Coordinate Fraction, W Normalized Inverse Depth Fraction
// Word 7:  DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Fraction
// Word 8:  DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Integer
// Word 9:  DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Integer
// Word 10: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Fraction
// Word 11: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Fraction

// Texture_ZBuffer_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4:  S Texture Coordinate Integer, T Texture Coordinate Integer, W Normalized Inverse Depth Integer (Texture Coefficients)
// Word 5:  DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Integer
// Word 6:  S Texture Coordinate Fraction, T Texture Coordinate Fraction, W Normalized Inverse Depth Fraction
// Word 7:  DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Fraction
// Word 8:  DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Integer
// Word 9:  DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Integer
// Word 10: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Fraction
// Word 11: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Fraction
// Word 12: Z Inverse Depth Integer, Fraction, DzDx Change In Z Per Change In X Coordinate Integer, Fraction (ZBuffer Coefficients)
// Word 13: DzDe Change In Z Along Major Edge Integer, Fraction, DzDy Change In Z Per Change In Y Coordinate Integer, Fraction

// Shade_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4:  Red Color Component Integer, Green Color Component Integer, Blue Color Component Integer, Alpha Color Component Integer (Shade Coefficients)
// Word 5:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Integer
// Word 6:  Red Color Component Fraction, Green Color Component Fraction, Blue Color Component Fraction, Alpha Color Component Fraction
// Word 7:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Fraction
// Word 8:  DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Integer
// Word 9:  DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Integer
// Word 10: DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Fraction
// Word 11: DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Fraction

// Shade_ZBuffer_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4:  Red Color Component Integer, Green Color Component Integer, Blue Color Component Integer, Alpha Color Component Integer (Shade Coefficients)
// Word 5:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Integer
// Word 6:  Red Color Component Fraction, Green Color Component Fraction, Blue Color Component Fraction, Alpha Color Component Fraction
// Word 7:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Fraction
// Word 8:  DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Integer
// Word 9:  DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Integer
// Word 10: DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Fraction
// Word 11: DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Fraction
// Word 12: Z Inverse Depth Integer, Fraction, DzDx Change In Z Per Change In X Coordinate Integer, Fraction (ZBuffer Coefficients)
// Word 13: DzDe Change In Z Along Major Edge Integer, Fraction, DzDy Change In Z Per Change In Y Coordinate Integer, Fraction

// Shade_Texture_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4:  Red Color Component Integer, Green Color Component Integer, Blue Color Component Integer, Alpha Color Component Integer (Shade Coefficients)
// Word 5:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Integer
// Word 6:  Red Color Component Fraction, Green Color Component Fraction, Blue Color Component Fraction, Alpha Color Component Fraction
// Word 7:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Fraction
// Word 8:  DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Integer
// Word 9:  DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Integer
// Word 10: DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Fraction
// Word 11: DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Fraction
// Word 12: S Texture Coordinate Integer, T Texture Coordinate Integer, W Normalized Inverse Depth Integer (Texture Coefficients)
// Word 13: DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Integer
// Word 14: S Texture Coordinate Fraction, T Texture Coordinate Fraction, W Normalized Inverse Depth Fraction
// Word 15: DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Fraction
// Word 16: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Integer
// Word 17: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Integer
// Word 18: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Fraction
// Word 19: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Fraction

// Shade_Texture_Z_Buffer_Triangle: lft,level,tile,yl,ym,yh, xl,xlf,dxldy,dxldyf, xh,xhf,dxhdy,dxhdyf, xm,xmf,dxmdy,dxmdyf
// Word 0: Left Major Flag (0=Left Major, 1=Right Major), Number Of Mip-Maps Minus One, Tile ID, Y Coordinate Of Low, Mid Minor, Major Edge (Fixed Point S.11.2)
// Word 1: X Coordinate Of Low    Edge Integer, Fraction, DxLDy Inverse Slope Of Low    Edge Integer, Fraction
// Word 2: X Coordinate Of Major  Edge Integer, Fraction, DxHDy Inverse Slope Of Major  Edge Integer, Fraction
// Word 3: X Coordinate Of Middle Edge Integer, Fraction, DxMDy Inverse Slope Of Middle Edge Integer, Fraction
// Word 4:  Red Color Component Integer, Green Color Component Integer, Blue Color Component Integer, Alpha Color Component Integer (Shade Coefficients)
// Word 5:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Integer
// Word 6:  Red Color Component Fraction, Green Color Component Fraction, Blue Color Component Fraction, Alpha Color Component Fraction
// Word 7:  DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Fraction
// Word 8:  DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Integer
// Word 9:  DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Integer
// Word 10: DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Fraction
// Word 11: DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Fraction
// Word 12: S Texture Coordinate Integer, T Texture Coordinate Integer, W Normalized Inverse Depth Integer (Texture Coefficients)
// Word 13: DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Integer
// Word 14: S Texture Coordinate Fraction, T Texture Coordinate Fraction, W Normalized Inverse Depth Fraction
// Word 15: DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Fraction
// Word 16: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Integer
// Word 17: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Integer
// Word 18: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Fraction
// Word 19: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Fraction
// Word 20: Z Inverse Depth Integer, Fraction, DzDx Change In Z Per Change In X Coordinate Integer, Fraction (ZBuffer Coefficients)
// Word 21: DzDe Change In Z Along Major Edge Integer, Fraction, DzDy Change In Z Per Change In Y Coordinate Integer, Fraction

// Shade_Coefficients: r,g,b,a, drdx,dgdx,dbdx,dadx, rf,gf,bf,af, drdxf,dgdxf,dbdxf,dadxf, drde,dgde,dbde,dade, drdy,dgdy,dbdy,dady, drdef,dgdef,dbdef,dadef, drdyf,dgdyf,dbdyf,dadyf
// Word 0: Red Color Component Integer, Green Color Component Integer, Blue Color Component Integer, Alpha Color Component Integer (Shade Coefficients)
// Word 1: DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Integer
// Word 2: Red Color Component Fraction, Green Color Component Fraction, Blue Color Component Fraction, Alpha Color Component Fraction
// Word 3: DrDx Change In Red, DgDx Change In Green, DbDx Change In Blue, DaDx Change In Alpha Per Change In X Coordinate Fraction
// Word 4: DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Integer
// Word 5: DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Integer
// Word 6: DrDe Change In Red, DgDe Change In Green, DbDe Change In Blue, DaDe Change In Alpha Along The Edge Fraction
// Word 7: DrDy Change In Red, DgDy Change In Green, DbDy Change In Blue, DaDy Change In Alpha Per Change In Y Coordinate Fraction

// Texture_Coefficients: s,t,w, dsdx,dtdx,dwdx, sf,tf,wf, dsdxf,dtdxf,dwdxf, dsde,dtde,dwde, dsdy,dtdy,dwdy, dsdef,dtdef,dwdef, dsdyf,dtdyf,dwdyf
// Word 0:  S Texture Coordinate Integer, T Texture Coordinate Integer, W Normalized Inverse Depth Integer
// Word 1:  DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Integer
// Word 2:  S Texture Coordinate Fraction, T Texture Coordinate Fraction, W Normalized Inverse Depth Fraction
// Word 3:  DsDx Change In S, DtDx Change In T, DwDx Change In W Per Change In X Coordinate Fraction
// Word 4:  DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Integer
// Word 5:  DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Integer
// Word 6: DsDe Change In S, DtDe Change In T, DwDe Change In W Along The Edge Fraction
// Word 7: DsDy Change In S, DtDy Change In T, DwDy Change In W Per Change In Y Coordinate Fraction

// ZBuffer_Coefficients: z,zf,dzdx,dzdxf, dzde,dzdef,dzdy,dzdyf
// Word 0: Z Inverse Depth Integer, Fraction, DzDx Change In Z Per Change In X Coordinate Integer, Fraction (ZBuffer Coefficients)
// Word 1: DzDe Change In Z Along Major Edge Integer, Fraction, DzDy Change In Z Per Change In Y Coordinate Integer, Fraction

// Texture_Rectangle: xl,yl, tile, xh,yh, s,t, dsdx,dtdy
// Word 0: Bottom Right X/Y, Tile ID, Top Left X/Y (Fixed Point 10.2)
// Word 1: S/T Texture Coordinate Top Left (Fixed Point S.10.5), DsDx Change In S Per Change In X, DtDy Change In T Per Change In Y (Fixed Point S.5.10)

// Texture_Rectangle_Flip: xl,yl, tile, xh,yh, s,t, dsdx,dtdy ; Same As Texture Rectangle Except Hardware Swaps S/T & DsDx/DtDy
// Word 0: Bottom Right X/Y, Tile ID, Top Left X/Y (Fixed Point 10.2)
// Word 1: S/T Texture Coordinate Top Left (Fixed Point S.10.5), DsDx Change In S Per Change In X, DtDy Change In T Per Change In Y (Fixed Point S.5.10)

// Sync_Load: Stall Execution Of Load Commands, Until Preceeding Primitives Completely Finish (Usually Preceed Load Commands)

// Sync_Pipe: Stall Pipeline, Until Preceeding Primitives Completely Finish (Software Can Optimize Usage)

// Sync_Tile: Allows Synchronization Between Commands That Write To The Same Tile Descriptor That An Immediately Previous Command Is Reading

// Sync_Full: Stall RDP Until Last DRAM Buffer Is Read Or Written From Any Preceeding Primitive (Needed If Memory Is To Be Reused)

// Set_Key_GB: wg,wb,cg,sg,cb,sb ; Set The Coefficients Used For Green/Blue Keying, KEY G/B = CLAMP(0.0, -ABS((G/B - CENTER)* SCALE) + WIDTH, 1.0) KEY ALPHA = MINIMUM OF KEY R/G/B
// Word: WIDTH G/B (Size Of Half Key Window Including Soft Edge)*SCALE, CENTER G/B Defines Color Or Intensity At Which Key Is Active (0..255), SCALE GB 1.0/(SIZE OF SOFT EDGE) (0..255)

// Set_Key_R: wr,cr,sr ; Set The Coefficients Used For Red Keying, KEY R = CLAMP(0.0, -ABS((R - CENTER)* SCALE) + WIDTH, 1.0) KEY ALPHA = MINIMUM OF KEY R/G/B
// Word: WIDTH R (Size Of Half Key Window Including Soft Edge)*SCALE, CENTER R Defines Color Or Intensity At Which Key Is Active (0..255), SCALE R 1.0/(SIZE OF SOFT EDGE) (0..255)

// Set_Convert: k0,k1,k2,k3,k4,k5 ; Updates The Coefficients For Converting YUV Pixels To RGB, R = C0*(Y-16)+C1*V, G = C0*(Y-16)+C2*U-C3*V, B = C0*(Y-16)+C4*U
// Word: K0, K1, K2, K3, K4, K5 Term Of YUV-RGB Conversion Matrix

// Set_Scissor: xh,yh,xl,yl,lo ; Set The Scissoring Of Primitives
// Word: Top Left X/Y, Bottom Right X/Y (Fixed Point 10.2), Scissor Field Enable & Scissor Field Even/Odd
SCISSOR_EVEN equ 0  // Set_Scissor O: Field Even (Bit 24)
SCISSOR_ODD equ 1   // Set_Scissor O: Field Odd (Bit 24)
SCISSOR_FIELD equ 1 // Set_Scissor F: Scissor Field Enable (Bit 25)

// Set_Prim_Depth: pz,pdz ; Set The Depth Of Primitives
// Word: Primitive Z Depth, Primitive Delta Z Depth

// Set_Other_Modes: Settings ; Set The Other Modes
// Set_Other_Modes LO Word
ALPHA_COMPARE_EN equ 0x00000000000001 // Set_Other_Modes A: Conditional Color Write On Alpha Compare (Bit 0)
DITHER_ALPHA_EN equ 0x00000000000002  // Set_Other_Modes B: Use Random Noise In Alpha Compare, Otherwise Use Blend Alpha In Alpha Compare (Bit 1)
Z_SOURCE_SEL equ 0x00000000000004 // Set_Other_Modes C: Choose Between Primitive Z And Pixel Z (Bit 2)
ANTIALIAS_EN equ 0x00000000000008 // Set_Other_Modes D: If Not Force Blend, Allow Blend Enable - Use CVG Bits (Bit 3)
Z_COMPARE_EN equ 0x00000000000010 // Set_Other_Modes E: Conditional Color Write Enable On Depth Comparison (Bit 4)
Z_UPDATE_EN equ 0x00000000000020  // Set_Other_Modes F: Enable Writing Of Z If Color Write Enabled (Bit 5)
IMAGE_READ_EN equ 0x00000000000040 // Set_Other_Modes G: Enable Color/CVG Read/Modify/Write Memory Access (Bit 6)
COLOR_ON_CVG equ 0x00000000000080  // Set_Other_Modes H: Only Update Color On Coverage Overflow (Transparent Surfaces) (Bit 7)
CVG_DEST_CLAMP equ 0x00000000000000 // Set_Other_Modes I: CVG Destination Clamp (Normal) (Bit 8..9)
CVG_DEST_WRAP equ 0x00000000000100  // Set_Other_Modes I: CVG Destination Wrap (WAS Assume Full CVG) (Bit 8..9)
CVG_DEST_ZAP equ 0x00000000000200   // Set_Other_Modes I: CVG Destination Zap (Force To Full CVG) (Bit 8..9)
CVG_DEST_SAVE equ 0x00000000000300  // Set_Other_Modes I: CVG Destination Save (Don't Overwrite Memory CVG) (Bit 8..9)
Z_MODE_OPAQUE equ 0x00000000000000           // Set_Other_Modes J: Z Mode Opaque (Bit 10..11)
Z_MODE_INTERPENETRATING equ 0x00000000000400 // Set_Other_Modes J: Z Mode Interpenetrating (Bit 10..11)
Z_MODE_TRANSPARENT equ 0x00000000000800      // Set_Other_Modes J: Z Mode Transparent (Bit 10..11)
Z_MODE_DECAL equ 0x00000000000C00            // Set_Other_Modes J: Z Mode Decal (Bit 10..11)
CVG_TIMES_ALPHA equ 0x00000000001000  // Set_Other_Modes K: Use CVG Times Alpha For Pixel Alpha And Coverage (Bit 12)
ALPHA_CVG_SELECT equ 0x00000000002000 // Set_Other_Modes L: Use CVG (Or CVG*Alpha) For Pixel Alpha (Bit 13)
FORCE_BLEND equ 0x00000000004000 // Set_Other_Modes M: Force Blend Enable (Bit 14)
//*RESERVED*($00000000008000) // Set_Other_Modes N: This Mode Bit Is Not Currently Used, But May Be In The Future (Bit 15)
B_M2B_1_0 equ 0x00000000000000 // Set_Other_Modes O: Blend Modeword, Multiply 2b Input Select 0, Cycle 1 (Bit 16..17)
B_M2B_1_1 equ 0x00000000010000 // Set_Other_Modes O: Blend Modeword, Multiply 2b Input Select 1, Cycle 1 (Bit 16..17)
B_M2B_1_2 equ 0x00000000020000 // Set_Other_Modes O: Blend Modeword, Multiply 2b Input Select 2, Cycle 1 (Bit 16..17)
B_M2B_1_3 equ 0x00000000030000 // Set_Other_Modes O: Blend Modeword, Multiply 2b Input Select 3, Cycle 1 (Bit 16..17)
B_M2B_0_0 equ 0x00000000000000 // Set_Other_Modes P: Blend Modeword, Multiply 2b Input Select 0, Cycle 0 (Bit 18..19)
B_M2B_0_1 equ 0x00000000040000 // Set_Other_Modes P: Blend Modeword, Multiply 2b Input Select 1, Cycle 0 (Bit 18..19)
B_M2B_0_2 equ 0x00000000080000 // Set_Other_Modes P: Blend Modeword, Multiply 2b Input Select 2, Cycle 0 (Bit 18..19)
B_M2B_0_3 equ 0x000000000C0000 // Set_Other_Modes P: Blend Modeword, Multiply 2b Input Select 3, Cycle 0 (Bit 18..19)
B_M2A_1_0 equ 0x00000000000000 // Set_Other_Modes Q: Blend Modeword, Multiply 2a Input Select 0, Cycle 1 (Bit 20..21)
B_M2A_1_1 equ 0x00000000100000 // Set_Other_Modes Q: Blend Modeword, Multiply 2a Input Select 1, Cycle 1 (Bit 20..21)
B_M2A_1_2 equ 0x00000000200000 // Set_Other_Modes Q: Blend Modeword, Multiply 2a Input Select 2, Cycle 1 (Bit 20..21)
B_M2A_1_3 equ 0x00000000300000 // Set_Other_Modes Q: Blend Modeword, Multiply 2a Input Select 3, Cycle 1 (Bit 20..21)
B_M2A_0_0 equ 0x00000000000000 // Set_Other_Modes R: Blend Modeword, Multiply 2a Input Select 0, Cycle 0 (Bit 22..23)
B_M2A_0_1 equ 0x00000000400000 // Set_Other_Modes R: Blend Modeword, Multiply 2a Input Select 1, Cycle 0 (Bit 22..23)
B_M2A_0_2 equ 0x00000000800000 // Set_Other_Modes R: Blend Modeword, Multiply 2a Input Select 2, Cycle 0 (Bit 22..23)
B_M2A_0_3 equ 0x00000000C00000 // Set_Other_Modes R: Blend Modeword, Multiply 2a Input Select 3, Cycle 0 (Bit 22..23)
B_M1B_1_0 equ 0x00000000000000 // Set_Other_Modes S: Blend Modeword, Multiply 1b Input Select 0, Cycle 1 (Bit 24..25)
B_M1B_1_1 equ 0x00000001000000 // Set_Other_Modes S: Blend Modeword, Multiply 1b Input Select 1, Cycle 1 (Bit 24..25)
B_M1B_1_2 equ 0x00000002000000 // Set_Other_Modes S: Blend Modeword, Multiply 1b Input Select 2, Cycle 1 (Bit 24..25)
B_M1B_1_3 equ 0x00000003000000 // Set_Other_Modes S: Blend Modeword, Multiply 1b Input Select 3, Cycle 1 (Bit 24..25)
B_M1B_0_0 equ 0x00000000000000 // Set_Other_Modes T: Blend Modeword, Multiply 1b Input Select 0, Cycle 0 (Bit 26..27)
B_M1B_0_1 equ 0x00000004000000 // Set_Other_Modes T: Blend Modeword, Multiply 1b Input Select 1, Cycle 0 (Bit 26..27)
B_M1B_0_2 equ 0x00000008000000 // Set_Other_Modes T: Blend Modeword, Multiply 1b Input Select 2, Cycle 0 (Bit 26..27)
B_M1B_0_3 equ 0x0000000C000000 // Set_Other_Modes T: Blend Modeword, Multiply 1b Input Select 3, Cycle 0 (Bit 26..27)
B_M1A_1_0 equ 0x00000000000000 // Set_Other_Modes U: Blend Modeword, Multiply 1a Input Select 0, Cycle 1 (Bit 28..29)
B_M1A_1_1 equ 0x00000010000000 // Set_Other_Modes U: Blend Modeword, Multiply 1a Input Select 1, Cycle 1 (Bit 28..29)
B_M1A_1_2 equ 0x00000020000000 // Set_Other_Modes U: Blend Modeword, Multiply 1a Input Select 2, Cycle 1 (Bit 28..29)
B_M1A_1_3 equ 0x00000030000000 // Set_Other_Modes U: Blend Modeword, Multiply 1a Input Select 3, Cycle 1 (Bit 28..29)
B_M1A_0_0 equ 0x00000000000000 // Set_Other_Modes V: Blend Modeword, Multiply 1a Input Select 0, Cycle 0 (Bit 30..31)
B_M1A_0_1 equ 0x00000040000000 // Set_Other_Modes V: Blend Modeword, Multiply 1a Input Select 1, Cycle 0 (Bit 30..31)
B_M1A_0_2 equ 0x00000080000000 // Set_Other_Modes V: Blend Modeword, Multiply 1a Input Select 2, Cycle 0 (Bit 30..31)
B_M1A_0_3 equ 0x000000C0000000 // Set_Other_Modes V: Blend Modeword, Multiply 1a Input Select 3, Cycle 0 (Bit 30..31)
// Set_Other_Modes HI Word
//*RESERVED*($00000F00000000) // Set_Other_Modes: Reserved For Future Use, Default Value Is $F (Bit 32..35)
ALPHA_DITHER_SEL_PATTERN equ 0x00000000000000   // Set_Other_Modes V1: Alpha Dither Selection Pattern (Bit 36..37)
ALPHA_DITHER_SEL_PATTERNB equ 0x00001000000000  // Set_Other_Modes V1: Alpha Dither Selection ~Pattern (Bit 36..37)
ALPHA_DITHER_SEL_NOISE equ 0x00002000000000     // Set_Other_Modes V1: Alpha Dither Selection Noise (Bit 36..37)
ALPHA_DITHER_SEL_NO_DITHER equ 0x00003000000000 // Set_Other_Modes V1: Alpha Dither Selection No Dither (Bit 36..37)
RGB_DITHER_SEL_MAGIC_SQUARE_MATRIX equ 0x00000000000000   // Set_Other_Modes V2: RGB Dither Selection Magic Square Matrix (Preferred If Filtered) (Bit 38..39)
RGB_DITHER_SEL_STANDARD_BAYER_MATRIX equ 0x00004000000000 // Set_Other_Modes V2: RGB Dither Selection Standard Bayer Matrix (Preferred If Not Filtered) (Bit 38..39)
RGB_DITHER_SEL_NOISE equ 0x00008000000000                 // Set_Other_Modes V2: RGB Dither Selection Noise (As Before) (Bit 38..39)
RGB_DITHER_SEL_NO_DITHER equ 0x0000C000000000             // Set_Other_Modes V2: RGB Dither Selection No Dither (Bit 38..39)
KEY_EN equ 0x00010000000000 // Set_Other_Modes W: Enables Chroma Keying (Bit 40)
CONVERT_ONE equ 0x00020000000000 // Set_Other_Modes X: Color Convert Texel That Was The Ouput Of The Texture Filter On Cycle0, Used To Qualify BI_LERP_1 (Bit 41)
BI_LERP_1 equ 0x00040000000000 // Set_Other_Modes Y: 1=BI_LERP, 0=Color Convert Operation In Texture Filter. Used In Cycle 1 (Bit 42)
BI_LERP_0 equ 0x00080000000000 // Set_Other_Modes Z: 1=BI_LERP, 0=Color Convert Operation In Texture Filter. Used In Cycle 0 (Bit 43)
MID_TEXEL equ 0x00100000000000 // Set_Other_Modes a: Indicates Texture Filter Should Do A 2x2 Half Texel Interpolation, Primarily Used For MPEG Motion Compensation Processing (Bit 44)
SAMPLE_TYPE equ 0x00200000000000 // Set_Other_Modes b: Determines How Textures Are Sampled: 0=1x1 (Point Sample), 1=2x2. Note That Copy (Point Sample 4 Horizontally Adjacent Texels) Mode Is Indicated By CYCLE_TYPE (Bit 45)
TLUT_TYPE equ 0x00400000000000   // Set_Other_Modes c: Type Of Texels In Table, 0=16b RGBA(5/5/5/1), 1=IA(8/8) (Bit 46)
EN_TLUT equ 0x00800000000000     // Set_Other_Modes d: Enable Lookup Of Texel Values From TLUT. Meaningful If Texture Type Is Index, Tile Is In Low TMEM, TLUT Is In High TMEM, And Color Image Is RGB (Bit 47)
TEX_LOD_EN equ 0x01000000000000  // Set_Other_Modes e: Enable Texture Level Of Detail (LOD) (Bit 48)
SHARPEN_TEX_EN equ 0x02000000000000 // Set_Other_Modes f: Enable Sharpened Texture (Bit 49)
DETAIL_TEX_EN equ 0x04000000000000  // Set_Other_Modes g: Enable Detail Texture (Bit 50)
PERSP_TEX_EN equ 0x08000000000000   // Set_Other_Modes h: Enable Perspective Correction On Texture (Bit 51)
CYCLE_TYPE_1_CYCLE equ 0x00000000000000 // Set_Other_Modes i: Display Pipeline Cycle Control Mode 1 Cycle (Bit 52..53)
CYCLE_TYPE_2_CYCLE equ 0x10000000000000 // Set_Other_Modes i: Display Pipeline Cycle Control Mode 2 Cycle (Bit 52..53)
CYCLE_TYPE_COPY equ 0x20000000000000    // Set_Other_Modes i: Display Pipeline Cycle Control Mode Copy (Bit 52..53)
CYCLE_TYPE_FILL equ 0x30000000000000    // Set_Other_Modes i: Display Pipeline Cycle Control Mode Fill (Bit 52..53)
//*RESERVED*($40000000000000) // Set_Other_Modes j: This Mode Bit Is Not Currently Used, But May Be In The Future (Bit 54)
ATOMIC_PRIM equ 0x80000000000000 // Set_Other_Modes k: Force Primitive To Be Written To Frame Buffer Before Read Of Following Primitive

// Load_Tlut: sl,tl,tile,sh,th ; Used To Initiate A Load From DRAM Of An Indexed Texture Lookup Table (TLUT) (This Table Dereferences Color Indexed Texels Before Texture Filtering)
// Word: Low S Index Into Table (0..255), Low T Normally Zero, Tile ID, High S Index Into Table, High T Normally Zero (Fixed Point 10.2, Fractional Bits Should Be Zero)

// Set_Tile_Size: sl,tl,tile,sh,th ; Set The Tile Size
// Word: Low S/T Coordinate Of Tile In Image, Tile ID, High S/T Coordinate Of Tile In Image (Fixed Point 10.2)

// Load_Block: sl,tl,tile,sh,dxt ; Loads A TMEM Tile With A Single Memory "Span" From SL,TL To SH,TL (During Tile Load, T Coordinate Is Incremented By DxT Every 8 TMEM Bytes)
// Word: Low S/T Coordinate Of Tile In Image, Tile ID, High S Coordinate Of Tile In Image (Fixed Point 10.2), Unsigned Increment Value

// Load_Tile: sl,tl,tile,sh,th ; Loads A TMEM Tile
// Word: Low S/T Coordinate Of Tile In Image, Tile ID, High S/T Coordinate Of Tile In Image (Fixed Point 10.2)

// Set_Tile: hi,lo ; Set The Tile
// Word: Set Tile Settings
// Set_Tile LO Word
SHIFT_S_0 equ 0x0 // Set_Tile: Shift 0 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_1 equ 0x1 // Set_Tile: Shift 1 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_2 equ 0x2 // Set_Tile: Shift 2 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_3 equ 0x3 // Set_Tile: Shift 3 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_4 equ 0x4 // Set_Tile: Shift 4 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_5 equ 0x5 // Set_Tile: Shift 5 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_6 equ 0x6 // Set_Tile: Shift 6 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_7 equ 0x7 // Set_Tile: Shift 7 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_8 equ 0x8 // Set_Tile: Shift 8 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_9 equ 0x9 // Set_Tile: Shift 9 Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_A equ 0xA // Set_Tile: Shift A Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_B equ 0xB // Set_Tile: Shift B Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_C equ 0xC // Set_Tile: Shift C Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_D equ 0xD // Set_Tile: Shift D Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_E equ 0xE // Set_Tile: Shift E Level Of Detail Shift For S Addresses (Bit 0..3)
SHIFT_S_F equ 0xF // Set_Tile: Shift F Level Of Detail Shift For S Addresses (Bit 0..3)
MASK_S_0 equ 0x0 // Set_Tile: Mask 0 For Wrapping/Mirroring In S Direction, Zero = Clamp (Bit 14..17)
MASK_S_1 equ 0x1 // Set_Tile: Mask 1 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_2 equ 0x2 // Set_Tile: Mask 2 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_3 equ 0x3 // Set_Tile: Mask 3 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_4 equ 0x4 // Set_Tile: Mask 4 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_5 equ 0x5 // Set_Tile: Mask 5 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_6 equ 0x6 // Set_Tile: Mask 6 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_7 equ 0x7 // Set_Tile: Mask 7 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_8 equ 0x8 // Set_Tile: Mask 8 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_9 equ 0x9 // Set_Tile: Mask 9 For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_A equ 0xA // Set_Tile: Mask A For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_B equ 0xB // Set_Tile: Mask B For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_C equ 0xC // Set_Tile: Mask C For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_D equ 0xD // Set_Tile: Mask D For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_E equ 0xE // Set_Tile: Mask E For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MASK_S_F equ 0xF // Set_Tile: Mask F For Wrapping/Mirroring In S Direction, Pass (Mask) LSBs Of S Address (Bit 4..7)
MIRROR_S equ 1 // Set_Tile: Mirror Enable For S Direction (Bit 8)
CLAMP_S equ 1  // Set_Tile:  Clamp Enable For S Direction (Bit 9)
SHIFT_T_0 equ 0x0 // Set_Tile: Shift 0 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_1 equ 0x1 // Set_Tile: Shift 1 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_2 equ 0x2 // Set_Tile: Shift 2 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_3 equ 0x3 // Set_Tile: Shift 3 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_4 equ 0x4 // Set_Tile: Shift 4 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_5 equ 0x5 // Set_Tile: Shift 5 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_6 equ 0x6 // Set_Tile: Shift 6 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_7 equ 0x7 // Set_Tile: Shift 7 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_8 equ 0x8 // Set_Tile: Shift 8 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_9 equ 0x9 // Set_Tile: Shift 9 Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_A equ 0xA // Set_Tile: Shift A Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_B equ 0xB // Set_Tile: Shift B Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_C equ 0xC // Set_Tile: Shift C Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_D equ 0xD // Set_Tile: Shift D Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_E equ 0xE // Set_Tile: Shift E Level Of Detail Shift For T Addresses (Bit 10..13)
SHIFT_T_F equ 0xF // Set_Tile: Shift F Level Of Detail Shift For T Addresses (Bit 10..13)
MASK_T_0 equ 0x0 // Set_Tile: Mask 0 For Wrapping/Mirroring In T Direction, Zero = Clamp (Bit 14..17)
MASK_T_1 equ 0x1 // Set_Tile: Mask 1 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_2 equ 0x2 // Set_Tile: Mask 2 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_3 equ 0x3 // Set_Tile: Mask 3 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_4 equ 0x4 // Set_Tile: Mask 4 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_5 equ 0x5 // Set_Tile: Mask 5 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_6 equ 0x6 // Set_Tile: Mask 6 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_7 equ 0x7 // Set_Tile: Mask 7 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_8 equ 0x8 // Set_Tile: Mask 8 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_9 equ 0x9 // Set_Tile: Mask 9 For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_A equ 0xA // Set_Tile: Mask A For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_B equ 0xB // Set_Tile: Mask B For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_C equ 0xC // Set_Tile: Mask C For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_D equ 0xD // Set_Tile: Mask D For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_E equ 0xE // Set_Tile: Mask E For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MASK_T_F equ 0xF // Set_Tile: Mask F For Wrapping/Mirroring In T Direction, Pass (Mask) LSBs Of T Address (Bit 14..17)
MIRROR_T equ 1 // Set_Tile: Mirror Enable For T Direction (Bit 18)
CLAMP_T equ 1  // Set_Tile:  Clamp Enable For T Direction (Bit 19)
PALETTE_0 equ 0x0 // Set_Tile: Palette Number 0 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_1 equ 0x1 // Set_Tile: Palette Number 1 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_2 equ 0x2 // Set_Tile: Palette Number 2 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_3 equ 0x3 // Set_Tile: Palette Number 3 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_4 equ 0x4 // Set_Tile: Palette Number 4 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_5 equ 0x5 // Set_Tile: Palette Number 5 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_6 equ 0x6 // Set_Tile: Palette Number 6 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_7 equ 0x7 // Set_Tile: Palette Number 7 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_8 equ 0x8 // Set_Tile: Palette Number 8 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_9 equ 0x9 // Set_Tile: Palette Number 9 For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_A equ 0xA // Set_Tile: Palette Number A For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_B equ 0xB // Set_Tile: Palette Number B For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_C equ 0xC // Set_Tile: Palette Number C For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_D equ 0xD // Set_Tile: Palette Number D For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_E equ 0xE // Set_Tile: Palette Number E For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
PALETTE_F equ 0xF // Set_Tile: Palette Number F For 4Bit Color Indexed Texels, This Number Is The MS 4Bits Of An 8Bit Index (Bit 20..23)
// Set_Tile/Set_Texture_Image/Set_Color_Image HI Word
SIZE_OF_PIXEL_4B equ 0  // Set_Tile/Set_Texture_Image/Set_Color_Image: Size Of Pixel/Texel Color Element 4B (Bit 51..52)
SIZE_OF_PIXEL_8B equ 1  // Set_Tile/Set_Texture_Image/Set_Color_Image: Size Of Pixel/Texel Color Element 8B (Bit 51..52)
SIZE_OF_PIXEL_16B equ 2 // Set_Tile/Set_Texture_Image/Set_Color_Image: Size Of Pixel/Texel Color Element 16B (Bit 51..52)
SIZE_OF_PIXEL_32B equ 3 // Set_Tile/Set_Texture_Image/Set_Color_Image: Size Of Pixel/Texel Color Element 32B (Bit 51..52)
IMAGE_DATA_FORMAT_RGBA equ 0       // Set_Tile/Set_Texture_Image/Set_Color_Image: Image Data Format RGBA (Bit 53..55)
IMAGE_DATA_FORMAT_YUV equ 1        // Set_Tile/Set_Texture_Image/Set_Color_Image: Image Data Format YUV (Bit 53..55)
IMAGE_DATA_FORMAT_COLOR_INDX equ 2 // Set_Tile/Set_Texture_Image/Set_Color_Image: Image Data Format COLOR_INDX (Bit 53..55)
IMAGE_DATA_FORMAT_IA equ 3         // Set_Tile/Set_Texture_Image/Set_Color_Image: Image Data Format IA (Bit 53..55)
IMAGE_DATA_FORMAT_I equ 4          // Set_Tile/Set_Texture_Image/Set_Color_Image: Image Data Format I (Bit 53..55)

// Fill_Rectangle: xl,yl,xh,yh
// Word: Bottom Right X/Y, Top Left X/Y (Fixed Point 10.2)

// Set_Fill_Color: Set The Filling Color
// Word: Packed Color: If The Color Image Was Set BE 16B RGBA, Then The Fill Color Would Be Two Horizontally Adjacent 16B RGBA Pixels

// Set_Fog_Color: Set The Fog Color
// Word: RGBA Color Components

// Set_Blend_Color: Set The Blending Color
// Word: RGBA Color Components

// Set_Prim_Color: minlev,levfrac,lo ; Set The Primitive Color
// Word: Prim Min Level: Minimum Clamp For LOD Fraction When In Detail Or Sharpen Texture Modes (Fixed Point 0.5), Prim Level Frac: Level Of Detail Fraction For Primitive, Used Primarily In Multi-Tile Operations For Rectangle Primitives (Fixed Point 0.8), RGBA Color Components

// Set_Env_Color: Set The Environment Color
// Word: RGBA Color Components

// Set_Combine_Mode: sub_aR0, mulR0, sub_aA0, mulA0, sub_aR1, mulR1, sub_bR0, sub_bR1, sub_aA1, mulA1, addR0, sub_bA0, addA0, addR1, sub_bA1, addA1 ; Set The Combine Mode
// Word: SUB_A, Multiply Input RGB Components CYCLE 0, SUB_A, Multiply Input ALPHA Components CYCLE 0, SUB_A, Multiply Input RGB Components CYCLE 1, SUB_B, Multiply Input RGB Components CYCLE 0, SUB_B, Multiply Input RGB Components CYCLE 1, SUB_A, Multiply Input ALPHA Components CYCLE 1, Adder Input RGB Components CYCLE 0, SUB_B Input ALPHA Components CYCLE 0, Adder Input ALPHA Components CYCLE 0, Adder Input RGB Components CYCLE 1, SUB_B Input ALPHA Components CYCLE 1, Adder Input ALPHA Components CYCLE 1

// Set_Texture_Image: Set The Texture Image
// Word: Image Data Format, Size Of Pixel/Texel Color Element, Width Of Image In Pixels - 1, Base Address (Top Left Corner) Of Image In DRAM

// Set_Z_Image: Set The Z Buffer Image
// Word: Base Address (Top Left Corner) Of Image In DRAM, In Bytes

// Set_Color_Image: Set The Color Image
// Word: Image Data Format, Size Of Pixel/Texel Color Element, Width Of Image In Pixels: Image Width=Width+1, Base Address (Top Left Corner) Of Image In DRAM
