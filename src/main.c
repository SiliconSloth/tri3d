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

static uint16_t z_buffer[320 * 240] __attribute__ ((aligned (64)));

#define FOV 60
#define NEAR 4.0
#define FAR 40.0

fixed32 camera_z;

static Box clip_box = {
	FIXED32(-1), FIXED32(320),
	FIXED32(-1), FIXED32(240),
	FIXED32(0), FIXED32(1)
};

void draw_point(display_context_t disp, int x, int y, uint32_t color) {
	if (x >= 1 && x < 319 && y >= 1 && y < 239) {
		graphics_draw_pixel(disp, x,   y,   color);
		graphics_draw_pixel(disp, x+1, y,   color);
		graphics_draw_pixel(disp, x-1, y,   color);
		graphics_draw_pixel(disp, x,   y+1, color);
		graphics_draw_pixel(disp, x,   y-1, color);
	}
}

static fixed32 transformed_vertices[8][4];

void load_cube(float x, float y, float z, Matrix4 *view_transform) {
	Matrix4 translation;
	matrix_translate(&translation, x, y, z);

	Matrix4 transformation;
	matrix_mul(view_transform, &translation, &transformation);

	PROFILE_START(PS_TRANSFORM, 0);
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 8; j++) {
			poll_rdp();
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(transformation.m[k][i], k == 3? FIXED32(1) : vertices[j][k]);
			}
			transformed_vertices[j][i] = sum;
		}
	}
	PROFILE_STOP(PS_TRANSFORM, 0);

	PROFILE_START(PS_TRIANGLE, 0);
	for (int i = 0; i < sizeof(indices) / sizeof(indices[0]); i++) {
		PROFILE_START(PS_COLLATE, 0);
		poll_rdp();

		PROFILE_START(PS_NULL, 0);
		PROFILE_STOP(PS_NULL, 0);

		int i1 = indices[i][0];
		int i2 = indices[i][1];
		int i3 = indices[i][2];

		VertexInfo v1 = {
			transformed_vertices[i1][0], transformed_vertices[i1][1], transformed_vertices[i1][2], transformed_vertices[i1][3],
			vertex_colors[i1][0], vertex_colors[i1][1], vertex_colors[i1][2], vertex_colors[i1][3],
			tex_coords[(i % 2) * 3][0], tex_coords[(i % 2) * 3][1]
		};
			
		VertexInfo v2 = {
			transformed_vertices[i2][0], transformed_vertices[i2][1], transformed_vertices[i2][2], transformed_vertices[i2][3],
			vertex_colors[i2][0], vertex_colors[i2][1], vertex_colors[i2][2], vertex_colors[i1][3],
			tex_coords[(i % 2) * 3 + 1][0], tex_coords[(i % 2) * 3 + 1][1]
		};

		VertexInfo v3 = {
			transformed_vertices[i3][0], transformed_vertices[i3][1], transformed_vertices[i3][2], transformed_vertices[i3][3],
			vertex_colors[i3][0], vertex_colors[i3][1], vertex_colors[i3][2], vertex_colors[i1][3],
			tex_coords[(i % 2) * 3 + 2][0], tex_coords[(i % 2) * 3 + 2][1]
		};

		PROFILE_STOP(PS_COLLATE, 0);
		load_triangle_culled(v1, v2, v3, clip_box, camera_z);
	}
	PROFILE_STOP(PS_TRIANGLE, 0);
}

void make_view_matrix(Matrix4 *out) {
	Matrix4 camera_transform, perspective, screen_scale, screen_translate;

	matrix_translate(&camera_transform, 0, 0, 10);
	matrix_perspective(&perspective, FOV * M_PI / 180, NEAR, FAR);
	matrix_scale(&screen_scale, 160, 160, 1);
	matrix_translate(&screen_translate, 160, 120, 0);

	camera_z = perspective.m[3][0] + perspective.m[3][1] + perspective.m[3][2] + perspective.m[3][3];
	
	Matrix4 temp1, temp2;
	matrix_mul(&screen_translate, &screen_scale, &temp1);
	matrix_mul(&temp1, &perspective, &temp2);
	matrix_mul(&temp2, &camera_transform, out);
}

void make_frame_matrix(float t, Matrix4 *view_transform, Matrix4 *out) {
	Matrix4 rotation1, rotation2;

	matrix_rotate_z(&rotation1, t);
	matrix_rotate_x(&rotation2, t * 1.1);

	Matrix4 temp;
	matrix_mul(view_transform, &rotation2, &temp);
	matrix_mul(&temp, &rotation1, out);
}

int main(void){
	static display_context_t disp = 0;

	init_interrupts();

	display_init(RESOLUTION_320x240, DEPTH_16_BPP, 3, GAMMA_NONE, ANTIALIAS_RESAMPLE);
	controller_init();
	rsp_init();
	timer_init();
	profile_init();
	debug_init_isviewer();
	// debug_init_usblog();

	init_ucode();
	
	Matrix4 view_transform;
	make_view_matrix(&view_transform);

	float t = 1.102;
	uint32_t last_time = 0;
	while (1) {
		while(!(disp = display_lock()));

		t += 0.01;
    
		profile_next_frame();

		PROFILE_START(PS_FRAME, 0);

		Matrix4 transformation;
		make_frame_matrix(t, &view_transform, &transformation);

		run_frame_setup(__safe_buffer[disp-1], &z_buffer, &texture, &palette);
		// run_frame_setup(&z_buffer, __safe_buffer[disp-1], &texture, &palette);

		PROFILE_START(PS_CUBE, 0);
		for (int z = 0; z < 6; z++) {
			for (int y = 0; y < 6; y++) {
				for (int x = 0; x < 6; x++) {
					load_cube(x * 8 - 20, y * 8 - 20, z * 8 - 20, &transformation);
				}
			}
		}
		PROFILE_STOP(PS_CUBE, 0);

		flush_triangles();
		flush_commands();
		
		// for (size_t i = 0; i < 320 * 240; i++) {
		// 	__safe_buffer[disp - 1][i] = __safe_buffer[disp - 1][i] & 0xF800;
		// }

		PROFILE_STOP(PS_FRAME, 0);

		uint32_t time = TICKS_READ();
		char text_buffer[64];
		sprintf(text_buffer, "%lu", TICKS_PER_SECOND / (time - last_time));
		graphics_draw_text(disp, 20, 20, text_buffer);
		last_time = time;

		display_show(disp);

		controller_scan();
		struct controller_data keys = get_keys_down();
		if (keys.c[0].Z) {
			profile_dump(disp);
		}
	}
}
