#ifndef TYPES_H
#define TYPES_H

#include <stdbool.h>
#include <stdint.h>

typedef int32_t fixed32;

#define FIXED32(v) ((fixed32) ((v) * 65536))
#define MUL_FX32(a, b) (((int64_t) (a)) * (b) / 65536)
#define DIV_FX32(a, b) (((int64_t) (a)) * 65536 / (b))

typedef struct {
    fixed32 m[4][4];
} Matrix4;

typedef struct {
	fixed32 x;
	fixed32 y;
	fixed32 z;
	fixed32 w;

	fixed32 r;
	fixed32 g;
	fixed32 b;
	fixed32 a;

	fixed32 s;
	fixed32 t;
} VertexInfo;

typedef struct {
	fixed32 x;
	fixed32 y;
	fixed32 z;
} Vector3;

typedef struct {
	fixed32 min_x;
	fixed32 max_x;

	fixed32 min_y;
	fixed32 max_y;

	fixed32 min_z;
	fixed32 max_z;
} Box;

#endif