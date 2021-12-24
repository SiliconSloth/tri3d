#ifndef DISPATH_H
#define DISPATH_H

#include "types.h"

void poll_rdp();
void init_ucode();
void run_frame_setup(void *color_image, void *z_image, void *texture, void *palette);
void flush_commands();

void load_triangle(TriangleCoeffs coeffs, VertexInfo v1, VertexInfo v2, VertexInfo v3);
void flush_triangles();
void load_color(uint32_t color);
void load_sync();

#endif