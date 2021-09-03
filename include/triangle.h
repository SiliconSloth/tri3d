#ifndef TRIANGLE_H
#define TRIANGLE_H

#include "types.h"

extern int32_t debug_xs[4096];
extern int32_t debug_ys[4096];
extern uint32_t num_debug;

extern fixed32 min_v;
extern fixed32 max_v;

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3);
void load_triangle_clipped(VertexInfo v1, VertexInfo v2, VertexInfo v3,
		fixed32 min_x, fixed32 max_x, fixed32 min_y, fixed32 max_y, fixed32 min_z, fixed32 max_z);

#endif