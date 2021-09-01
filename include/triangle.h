#ifndef TRIANGLE_H
#define TRIANGLE_H

#include "types.h"

extern int32_t debug_xs[4096];
extern int32_t debug_ys[4096];
extern uint32_t num_debug;

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3);

#endif