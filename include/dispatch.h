#ifndef DISPATH_H
#define DISPATH_H

#include "types.h"

void poll_rdp();
void init_ucode();
void run_frame_setup(void *color_image, void *z_image, void *texture, void *palette);
void flush_commands();

void load_triangle(TriangleCoeffs coeffs);
void load_color(uint32_t color);
void load_sync();

#endif