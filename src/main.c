#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <libdragon.h>

#include "data.h"
#include "dispatch.h"
#include "matrix.h"
#include "profile.h"
#include "triangle.h"
#include "types.h"

extern uint16_t *__safe_buffer[];

static uint16_t z_buffer[320 * 240];// __attribute__ ((aligned (8)));

#define LEFT  (-1.0)
#define RIGHT (1.0)
#define TOP (-1.0)
#define BOTTOM (1.0)
#define NEAR (1.0)
#define FAR (80.0)

void graphics_printf(display_context_t disp, int x, int y, char *szFormat, ...){
	char szBuffer[64];

	va_list pArgs;
	va_start(pArgs, szFormat);
	vsnprintf(szBuffer, sizeof szBuffer, szFormat, pArgs);
	va_end(pArgs);

	graphics_draw_text(disp, x, y, szBuffer);
}

static fixed32 transformed_vertices[8][3];

void load_cube(float x, float y, float z, Matrix4 *view_transform) {
	transform_start = timer_ticks();
	prep_start = timer_ticks();
	
	Matrix4 translation;
	matrix_translate(&translation, x, y, z);

	prep_time = timer_ticks() - prep_start;
	matrix_start = timer_ticks();

	Matrix4 transformation;
	matrix_mul(view_transform, &translation, &transformation);

	matrix_time = timer_ticks() - matrix_start;
	vertex_start = timer_ticks();

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 8; j++) {
			poll_rdp();
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(transformation.m[k][i], k == 3? FIXED32(1) : vertices[j][k]);
			}

			if (i < 3) {
				transformed_vertices[j][i] = sum;
			} else {
				transformed_vertices[j][0] = DIV_FX32(transformed_vertices[j][0], sum);
				transformed_vertices[j][1] = DIV_FX32(transformed_vertices[j][1], sum);
				transformed_vertices[j][2] = DIV_FX32(transformed_vertices[j][2], sum);
			}
		}
	}

	vertex_time = timer_ticks() - vertex_start;
	transform_time = timer_ticks() - transform_start;
	load_start = timer_ticks();

	for (int i = 0; i < sizeof(indices) / sizeof(indices[0]); i++) {
		poll_rdp();

		int i1 = indices[i][0];
		int i2 = indices[i][1];
		int i3 = indices[i][2];

		VertexInfo v1 = {
			transformed_vertices[i1][0], transformed_vertices[i1][1], transformed_vertices[i1][2],
			vertex_colors[i1][0], vertex_colors[i1][1], vertex_colors[i1][2],
			MUL_FX32(tex_coords[(i % 2) * 3][0], transformed_vertices[i1][2]), MUL_FX32(tex_coords[(i % 2) * 3][1], transformed_vertices[i1][2])
		};
			
		VertexInfo v2 = {
			transformed_vertices[i2][0], transformed_vertices[i2][1], transformed_vertices[i2][2],
			vertex_colors[i2][0], vertex_colors[i2][1], vertex_colors[i2][2],
			MUL_FX32(tex_coords[(i % 2) * 3 + 1][0], transformed_vertices[i2][2]), MUL_FX32(tex_coords[(i % 2) * 3 + 1][1], transformed_vertices[i2][2])
		};

		VertexInfo v3 = {
			transformed_vertices[i3][0], transformed_vertices[i3][1], transformed_vertices[i3][2],
			vertex_colors[i3][0], vertex_colors[i3][1], vertex_colors[i3][2],
			MUL_FX32(tex_coords[(i % 2) * 3 + 2][0], transformed_vertices[i3][2]), MUL_FX32(tex_coords[(i % 2) * 3 + 2][1], transformed_vertices[i3][2])
		};

		load_triangle_verts(v1, v2, v3);
	}

	load_time = timer_ticks() - load_start;
}

int main(void){
	static display_context_t disp = 0;

	init_interrupts();

	display_init(RESOLUTION_320x240, DEPTH_16_BPP, 2, GAMMA_NONE, ANTIALIAS_RESAMPLE);
	controller_init();
	rsp_init();
	timer_init();

	init_ucode();
	
	Matrix4 camera_transform;
	matrix_translate(&camera_transform, 0, 0, 30);
	
	Matrix4 perspective;
	matrix_perspective(&perspective, LEFT, RIGHT, TOP, BOTTOM, NEAR, FAR);
	
	Matrix4 screen_scale, screen_translate, screen_transform;
	matrix_scale(&screen_scale, 160, 160, 1);
	matrix_translate(&screen_translate, 160, 120, 0);
	matrix_mul(&screen_translate, &screen_scale, &screen_transform);

	Matrix4 temp_transform;
	Matrix4 view_transform;
	matrix_mul(&perspective, &camera_transform, &temp_transform);
	matrix_mul(&screen_transform, &temp_transform, &view_transform);

	float t = 1.102;
	while (1) {
		while(!(disp = display_lock()));

		t += 0.01;

		Matrix4 rotation1;
		matrix_rotate_z(&rotation1, t);

		float t2 = t * 1.1;
		Matrix4 rotation2;
		matrix_rotate_x(&rotation2, t2);

		Matrix4 transformation1;
		Matrix4 transformation2;

		matrix_mul(&rotation2, &rotation1, &transformation1);
		matrix_mul(&view_transform, &transformation1, &transformation2);

		run_frame_setup(__safe_buffer[disp-1], &z_buffer, &texture, &palette);
		// run_frame_setup(&z_buffer, __safe_buffer[disp-1], &texture, &palette);

		for (int z = 0; z < 4; z++) {
			for (int y = 0; y < 4; y++) {
				for (int x = 0; x < 4; x++) {
					load_cube(x * 8 - 12, y * 8 - 12, z * 8 - 12, &transformation2);
				}
			}
		}

		flush_commands();
		
		// for (size_t i = 0; i < 320 * 240; i++) {
		// 	__safe_buffer[disp - 1][i] = __safe_buffer[disp - 1][i] & 0xF800;
		// }

		graphics_printf(disp, 20, 20, "%u", COUNTS_PER_SECOND / total_cpu_time);
		// graphics_printf(disp, 20, 40, "%8lu", cpu_time);
		// graphics_printf(disp, 20, 50, "%8lu", rdp_time);
		// graphics_printf(disp, 20, 70, "%8lu", total_cpu_time);
		// graphics_printf(disp, 20, 80, "%8lu", total_rdp_time);
		// graphics_printf(disp, 20, 100, "%8lu", transform_time);
		// graphics_printf(disp, 20, 110, "%8lu", load_time);
		// graphics_printf(disp, 20, 130, "%8lu", prep_time);
		// graphics_printf(disp, 20, 140, "%8lu", matrix_time);
		// graphics_printf(disp, 20, 150, "%8lu", vertex_time);
		
		display_show(disp);
	}
}
