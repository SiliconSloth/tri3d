#ifndef TRIANGLE_H
#define TRIANGLE_H

#include "types.h"

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3);
void load_triangle_clipped(VertexInfo v1, VertexInfo v2, VertexInfo v3, Box box);
void load_triangle_culled(VertexInfo v1, VertexInfo v2, VertexInfo v3, Box box, fixed32 camera_z);

#endif