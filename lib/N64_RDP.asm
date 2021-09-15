// Generated from n64-rdp.arch

.macro No_Op
  .word 0
  .word 0
.endmacro

.macro Fill_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0x8000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Fill_ZBuffer_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0x9000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Texture_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0xA000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Texture_ZBuffer_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0xB000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Shade_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0xC000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Shade_ZBuffer_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0xD000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Shade_Texture_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0xE000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Shade_Texture_Z_Buffer_Triangle, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr
  .word 0xF000000 | ((arga & 0x01) << 23) | ((argb & 0x07) << 19) | ((argc & 0x07) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
.endmacro

.macro Shade_Coefficients, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr, args, argt, argu, argv, argw, argx, argy, argz, argaa, argbb, argcc, argdd, argee, argff
  .word ((arga & 0xFFFF) << 16) | (argb & 0xFFFF)
  .word ((argc & 0xFFFF) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16) | (argj & 0xFFFF)
  .word ((argk & 0xFFFF) << 16) | (argl & 0xFFFF)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16) | (argp & 0xFFFF)
  .word ((argq & 0xFFFF) << 16) | (argr & 0xFFFF)
  .word ((args & 0xFFFF) << 16) | (argt & 0xFFFF)
  .word ((argu & 0xFFFF) << 16) | (argv & 0xFFFF)
  .word ((argw & 0xFFFF) << 16) | (argx & 0xFFFF)
  .word ((argy & 0xFFFF) << 16) | (argz & 0xFFFF)
  .word ((argu & 0xFFFF) << 16) | (argv & 0xFFFF)
  .word ((argw & 0xFFFF) << 16) | (argx & 0xFFFF)
  .word ((argy & 0xFFFF) << 16) | (argz & 0xFFFF)
.endmacro

.macro Texture_Coefficients, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp, argq, argr, args, argt, argu, argv, argw, argx
  .word ((arga & 0xFFFF) << 16) | (argb & 0xFFFF)
  .word ((argc & 0xFFFF) << 16)
  .word ((argd & 0xFFFF) << 16) | (arge & 0xFFFF)
  .word ((argf & 0xFFFF) << 16)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
  .word ((argi & 0xFFFF) << 16)
  .word ((argj & 0xFFFF) << 16) | (argk & 0xFFFF)
  .word ((argl & 0xFFFF) << 16)
  .word ((argm & 0xFFFF) << 16) | (argn & 0xFFFF)
  .word ((argo & 0xFFFF) << 16)
  .word ((argp & 0xFFFF) << 16) | (argq & 0xFFFF)
  .word ((argr & 0xFFFF) << 16)
  .word ((args & 0xFFFF) << 16) | (argt & 0xFFFF)
  .word ((argu & 0xFFFF) << 16)
  .word ((argv & 0xFFFF) << 16) | (argw & 0xFFFF)
  .word ((argx & 0xFFFF) << 16)
.endmacro

.macro ZBuffer_Coefficients, arga, argb, argc, argd, arge, argf, argg, argh
  .word ((arga & 0xFFFF) << 16) | (argb & 0xFFFF)
  .word ((argc & 0xFFFF) << 16) | (argd & 0xFFFF)
  .word ((arge & 0xFFFF) << 16) | (argf & 0xFFFF)
  .word ((argg & 0xFFFF) << 16) | (argh & 0xFFFF)
.endmacro

.macro Texture_Rectangle, arga, argb, argc, argd, arge, argf, argg, argh, argi
  .word 0x24000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x07) << 24) | ((argd & 0xFFF) << 12) | (arge & 0xFFF)
  .word ((argf & 0xFFFF) << 16) | (argg & 0xFFFF)
  .word ((argh & 0xFFFF) << 16) | (argi & 0xFFFF)
.endmacro

.macro Texture_Rectangle_Flip, arga, argb, argc, argd, arge, argf, argg, argh, argi
  .word 0x25000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x07) << 24) | ((argd & 0xFFF) << 12) | (arge & 0xFFF)
  .word ((argf & 0xFFFF) << 16) | (argg & 0xFFFF)
  .word ((argh & 0xFFFF) << 16) | (argi & 0xFFFF)
.endmacro

.macro Sync_Load
  .word 0x26000000
  .word 0
.endmacro

.macro Sync_Pipe
  .word 0x27000000
  .word 0
.endmacro

.macro Sync_Tile
  .word 0x28000000
  .word 0
.endmacro

.macro Sync_Full
  .word 0x29000000
  .word 0
.endmacro

.macro Set_Key_GB, arga, argb, argc, argd, arge, argf
  .word 0x2A000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0xFF) << 24) | ((argd & 0xFF) << 16) | ((arge & 0xFF) << 8) | (argf & 0xFF)
.endmacro

.macro Set_Key_R, arga, argb, argc
  .word 0x2B000000
  .word ((arga & 0xFFF) << 16) | ((argb & 0xFF) << 8) | (argc & 0xFF)
.endmacro

.macro Set_Convert, arga, argb, argc, argd, arge, argf
  .word 0x2C000000 | ((arga & 0x1FF) << 13) | ((argb & 0x1FF) << 4) | ((argc & 0x1FF) >> 5)
  .word (((argc & 0x1FF) << 27) & 0xFFFFFFFF) | ((argd & 0x1FF) << 18) | ((arge & 0x1FF) << 9) | (argf & 0x1FF)
.endmacro

.macro Set_Scissor, arga, argb, argc, argd, arge, argf
  .word 0x2D000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x01) << 25) | ((argd & 0x01) << 24) | ((arge & 0xFFF) << 12) | (argf & 0xFFF)
.endmacro

.macro Set_Prim_Depth, arga, argb
  .word 0x2E000000
  .word ((arga & 0xFFFF) << 16) | (argb & 0xFFFF)
.endmacro

.macro Set_Other_Modes, arga
  .word 0x2F000000 | ((arga & 0xFFFFFFFFFFFFFF) >> 32)
  .word (arga & 0xFFFFFFFF)
.endmacro

.macro Load_Tlut, arga, argb, argc, argd, arge
  .word 0x30000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x07) << 24) | ((argd & 0xFFF) << 12) | (arge & 0xFFF)
.endmacro

.macro Set_Tile_Size, arga, argb, argc, argd, arge
  .word 0x32000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x07) << 24) | ((argd & 0xFFF) << 12) | (arge & 0xFFF)
.endmacro

.macro Load_Block, arga, argb, argc, argd, arge
  .word 0x33000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x07) << 24) | ((argd & 0xFFF) << 12) | (arge & 0xFFF)
.endmacro

.macro Load_Tile, arga, argb, argc, argd, arge
  .word 0x34000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0x07) << 24) | ((argd & 0xFFF) << 12) | (arge & 0xFFF)
.endmacro

.macro Set_Tile, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn
  .word 0x35000000 | ((arga & 0x07) << 21) | ((argb & 0x03) << 19) | ((argc & 0x1FF) << 9) | (argd & 0x1FF)
  .word ((arge & 0x07) << 24) | ((argf & 0x0F) << 20) | ((argg & 0x01) << 19) | ((argh & 0x01) << 18) | ((argi & 0x0F) << 14) | ((argj & 0x0F) << 10) | ((argk & 0x01) << 9) | ((argl & 0x01) << 8) | ((argm & 0x0F) << 4) | (argn & 0x0F)
.endmacro

.macro Fill_Rectangle, arga, argb, argc, argd
  .word 0x36000000 | ((arga & 0xFFF) << 12) | (argb & 0xFFF)
  .word ((argc & 0xFFF) << 12) | (argd & 0xFFF)
.endmacro

.macro Set_Fill_Color, arga
  .word 0x37000000
  .word (arga & 0xFFFFFFFF)
.endmacro

.macro Set_Fog_Color, arga
  .word 0x38000000
  .word (arga & 0xFFFFFFFF)
.endmacro

.macro Set_Blend_Color, arga
  .word 0x39000000
  .word (arga & 0xFFFFFFFF)
.endmacro

.macro Set_Prim_Color, arga, argb, argc
  .word 0x3A000000 | ((arga & 0x1F) << 8) | (argb & 0xFF)
  .word (argc & 0xFFFFFFFF)
.endmacro

.macro Set_Env_Color, arga
  .word 0x3B000000
  .word (arga & 0xFFFFFFFF)
.endmacro

.macro Set_Combine_Mode, arga, argb, argc, argd, arge, argf, argg, argh, argi, argj, argk, argl, argm, argn, argo, argp
  .word 0x3C000000 | ((arga & 0x0F) << 20) | ((argb & 0x1F) << 15) | ((argc & 0x07) << 12) | ((argd & 0x07) << 9) | ((arge & 0x0F) << 5) | (argf & 0x1F)
  .word ((argg & 0x0F) << 28) | ((argh & 0x0F) << 24) | ((argi & 0x07) << 21) | ((argj & 0x07) << 18) | ((argk & 0x07) << 15) | ((argl & 0x07) << 12) | ((argm & 0x07) << 9) | ((argn & 0x07) << 6) | ((argo & 0x07) << 3) | (argp & 0x07)
.endmacro

.macro Set_Texture_Image, arga, argb, argc, argd
  .word 0x3D000000 | ((arga & 0x07) << 21) | ((argb & 0x03) << 19) | (argc & 0x3FF)
  .word (argd & 0xFFFFFFFF)
.endmacro

.macro Set_Z_Image, arga
  .word 0x3E000000
  .word (arga & 0xFFFFFFFF)
.endmacro

.macro Set_Color_Image, arga, argb, argc, argd
  .word 0x3F000000 | ((arga & 0x07) << 21) | ((argb & 0x03) << 19) | (argc & 0x3FF)
  .word (argd & 0xFFFFFFFF)
.endmacro
