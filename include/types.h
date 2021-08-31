#ifndef TYPES_H
#define TYPES_H

#include <stdint.h>

typedef int32_t fixed32;

#define FIXED32(v) ((fixed32) ((v) * 65536))
#define MUL_FX32(a, b) (((int64_t) (a)) * (b) / 65536)
#define DIV_FX32(a, b) (((int64_t) (a)) * 65536 / (b))

typedef struct {
    bool major;

	fixed32 yl;
	fixed32 ym;
	fixed32 yh;

	fixed32 xl;
	fixed32 dxldy;

	fixed32 xh;
	fixed32 dxhdy;

	fixed32 xm;
	fixed32 dxmdy;

	fixed32 red;
	fixed32 green;
	fixed32 blue;

	fixed32 drdx;
	fixed32 dgdx;
	fixed32 dbdx;

	fixed32 drde;
	fixed32 dgde;
	fixed32 dbde;

	fixed32 drdy;
	fixed32 dgdy;
	fixed32 dbdy;

	fixed32 s;
	fixed32 t;
	fixed32 w;

	fixed32 dsdx;
	fixed32 dtdx;
	fixed32 dwdx;

	fixed32 dsde;
	fixed32 dtde;
	fixed32 dwde;

	fixed32 dsdy;
	fixed32 dtdy;
	fixed32 dwdy;

	fixed32 z;
	fixed32 dzdx;
	fixed32 dzde;
	fixed32 dzdy;
} TriangleCoeffs;

typedef struct {
	fixed32 x;
	fixed32 y;
	fixed32 z;

	fixed32 r;
	fixed32 g;
	fixed32 b;

	fixed32 s;
	fixed32 t;
} VertexInfo;

#endif