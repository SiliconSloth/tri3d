#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <libdragon.h>

#include "types.h"
#include "dispatch.h"
#include "profile.h"

extern uint16_t *__safe_buffer[];

static uint16_t z_buffer[320 * 240];// __attribute__ ((aligned (8)));

static uint32_t texture[] = {
	0x11010101, 0x10101011,
	0x10000000, 0x00000001,
	0x00400040, 0x00222000,
	0x10040400, 0x02000201,
	0x00004000, 0x02000200,
	0x10040400, 0x02000201,
	0x00400040, 0x00222000,
	0x10000000, 0x00000001,
	0x10000000, 0x00000001,
	0x00005000, 0x00303000,
	0x10005000, 0x03030301,
	0x00555550, 0x03000300,
	0x10005000, 0x00303001,
	0x00005000, 0x00030000,
	0x10000000, 0x00000001,
	0x11010101, 0x10101011
};

static uint16_t palette[] = {
	0x0000, 0xFFFE, 0x1ABE, 0xF376,
	0xFB86, 0x1F9E, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000
};

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

void compute_gradients(fixed32 y1, fixed32 a1,
					   fixed32 y2, fixed32 a2,
					   fixed32 y3, fixed32 a3,
					   fixed32 x2, fixed32 x_mid,
					   fixed32 *dade, fixed32 *dadx) {
	*dade = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(a3 - a1, y3 - y1);

	fixed32 a_mid = a1 + MUL_FX32(y2 - y1, *dade);

	*dadx = (x2 - x_mid < FIXED32(1) && x_mid - x2 < FIXED32(1)) ? 0 : DIV_FX32(a2 - a_mid, x2 - x_mid);
}

void compute_triangle_coefficients(TriangleCoeffs *coeffs, VertexInfo v1, VertexInfo v2, VertexInfo v3) {
	VertexInfo temp;
	
	if (v1.y > v2.y) {
		temp = v1;
		v1 = v2;
		v2 = temp;
	}
	
	if (v2.y > v3.y) {
		temp = v2;
		v2 = v3;
		v3 = temp;

		if (v1.y > v2.y) {
			temp = v1;
			v1 = v2;
			v2 = temp;
		}
	}

	fixed32 x1 = v1.x, y1 = v1.y, z1 = v1.z;
	fixed32 x2 = v2.x, y2 = v2.y, z2 = v2.z;
	fixed32 x3 = v3.x, y3 = v3.y, z3 = v3.z;

	fixed32 dxldy = (y3 - y2 < FIXED32(1)) ? 0 : DIV_FX32(x3 - x2, y3 - y2);
	fixed32 dxmdy = (y2 - y1 < FIXED32(1)) ? 0 : DIV_FX32(x2 - x1, y2 - y1);
	fixed32 dxhdy = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(x3 - x1, y3 - y1);

	fixed32 y1_frac = y1 & 0xFFFF;
	fixed32 xh = x1 - MUL_FX32(y1_frac, dxhdy);
	fixed32 xm = x1 - MUL_FX32(y1_frac, dxmdy);

	fixed32 y2_gap = 0x4000 - (y2 & 0x3FFF);
	fixed32 xl = x2 + MUL_FX32(y2_gap, dxldy);

	bool major = MUL_FX32((x3 - x1), (y2 - y1)) - MUL_FX32((y3 - y1), (x2 - x1)) < 0;

	fixed32 x_mid = x1 + MUL_FX32(y2 - y1, dxhdy);

	fixed32 drde, dgde, dbde;
	fixed32 drdx, dgdx, dbdx;
	compute_gradients(y1, v1.r, y2, v2.r, y3, v3.r, x2, x_mid, &drde, &drdx);
	compute_gradients(y1, v1.g, y2, v2.g, y3, v3.g, x2, x_mid, &dgde, &dgdx);
	compute_gradients(y1, v1.b, y2, v2.b, y3, v3.b, x2, x_mid, &dbde, &dbdx);

	fixed32 dsde, dtde;
	fixed32 dsdx, dtdx;
	compute_gradients(y1, v1.s, y2, v2.s, y3, v3.s, x2, x_mid, &dsde, &dsdx);
	compute_gradients(y1, v1.t, y2, v2.t, y3, v3.t, x2, x_mid, &dtde, &dtdx);

	#define DEPTH_MUL 0x7C00

	fixed32 dzde, dzdx;
	compute_gradients(y1, z1, y2, z2, y3, z3, x2, x_mid, &dzde, &dzdx);

	fixed32 z = z1 - MUL_FX32(y1_frac, dzde);
	dzde *= DEPTH_MUL;
	dzdx *= DEPTH_MUL;

	coeffs->major = major;

	// Round up to next subpixel
	coeffs->yl = (y3 + 0x3FFF);
	coeffs->ym = (y2 + 0x3FFF);
	coeffs->yh = y1;

	coeffs->xl = xl;
	coeffs->dxldy = dxldy;

	coeffs->xh = xh;
	coeffs->dxhdy = dxhdy;

	coeffs->xm = xm;
	coeffs->dxmdy = dxmdy;

	coeffs->red   = v1.r - MUL_FX32(y1_frac, drde);
	coeffs->green = v1.g - MUL_FX32(y1_frac, dgde);
	coeffs->blue  = v1.b - MUL_FX32(y1_frac, dbde);

	coeffs->drdx = drdx;
	coeffs->dgdx = dgdx;
	coeffs->dbdx = dbdx;

	coeffs->drde = drde;
	coeffs->dgde = dgde;
	coeffs->dbde = dbde;

	coeffs->drdy = 0;
	coeffs->dgdy = 0;
	coeffs->dbdy = 0;

	coeffs->s = v1.s - MUL_FX32(y1_frac, dsde);
	coeffs->t = v1.t - MUL_FX32(y1_frac, dtde);
	coeffs->w = z * DEPTH_MUL;

	coeffs->dsdx = dsdx;
	coeffs->dtdx = dtdx;
	coeffs->dwdx = dzdx;

	coeffs->dsde = dsde;
	coeffs->dtde = dtde;
	coeffs->dwde = dzde;

	coeffs->dsdy = 0;
	coeffs->dtdy = 0;
	coeffs->dwdy = 0;

	coeffs->z = (FIXED32(1) - z) * DEPTH_MUL;
	coeffs->dzdx = -dzdx;
	coeffs->dzde = -dzde;
	coeffs->dzdy = 0;
}

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3) {
	TriangleCoeffs coeffs;
	compute_triangle_coefficients(&coeffs, v1, v2, v3);
	load_triangle(coeffs);
}

static const fixed32 vertices[8][3] = {
	{FIXED32(-2), FIXED32(-2), FIXED32(-2)},
	{FIXED32( 2), FIXED32(-2), FIXED32(-2)},
	{FIXED32( 2), FIXED32( 2), FIXED32(-2)},
	{FIXED32(-2), FIXED32( 2), FIXED32(-2)},
	{FIXED32(-2), FIXED32(-2), FIXED32( 2)},
	{FIXED32( 2), FIXED32(-2), FIXED32( 2)},
	{FIXED32( 2), FIXED32( 2), FIXED32( 2)},
	{FIXED32(-2), FIXED32( 2), FIXED32( 2)}
};

static const fixed32 vertex_colors[8][3] = {
	{FIXED32(  0), FIXED32(  0), FIXED32(  0)},
	{FIXED32(256), FIXED32(  0), FIXED32(  0)},
	{FIXED32(256), FIXED32(256), FIXED32(  0)},
	{FIXED32(  0), FIXED32(256), FIXED32(  0)},
	{FIXED32(  0), FIXED32(  0), FIXED32(256)},
	{FIXED32(256), FIXED32(  0), FIXED32(256)},
	{FIXED32(256), FIXED32(256), FIXED32(256)},
	{FIXED32(  0), FIXED32(256), FIXED32(256)}
};

static const fixed32 tex_coords[6][2] = {
	{FIXED32(-16), FIXED32(-16)},
	{FIXED32(496), FIXED32(496)},
	{FIXED32(496), FIXED32(-16)},
	{FIXED32(-16), FIXED32(-16)},
	{FIXED32(-16), FIXED32(496)},
	{FIXED32(496), FIXED32(496)}
};

static const int indices[12][3] = {
	{0, 2, 1},
	{0, 3, 2},
	{4, 6, 5},
	{4, 7, 6},
	{4, 3, 0},
	{4, 7, 3},
	{1, 6, 5},
	{1, 2, 6},
	{4, 1, 5},
	{4, 0, 1},
	{6, 3, 2},
	{6, 7, 3}
};

static fixed32 transformed_vertices[8][3];

void matrix_mul(fixed32 a[4][4], fixed32 b[4][4], fixed32 out[4][4]) {
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			poll_rdp();
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(a[k][i], b[j][k]);
			}
			out[j][i] = sum;
		}
	}
}

void load_cube(float x, float y, float z, fixed32 view_transform[4][4]) {
	transform_start = timer_ticks();
	prep_start = timer_ticks();
	
	fixed32 translation[4][4] = {
		{FIXED32(1), FIXED32(0), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(1), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(0), FIXED32(1), FIXED32(0)},
		{FIXED32(x), FIXED32(y), FIXED32(z), FIXED32(1)}
	};

	prep_time = timer_ticks() - prep_start;
	matrix_start = timer_ticks();

	fixed32 transformation[4][4];
	matrix_mul(view_transform, translation, transformation);

	matrix_time = timer_ticks() - matrix_start;
	vertex_start = timer_ticks();

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 8; j++) {
			poll_rdp();
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(transformation[k][i], k == 3? FIXED32(1) : vertices[j][k]);
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

	// uint32_t colors[6] = {
	// 	0xFF0000FF,
	// 	0x00FF00FF,
	// 	0x0000FFFF,
	// 	0xFFFF00FF,
	// 	0xFF00FFFF,
	// 	0x00FFFFFF
	// };

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

		// if (i % 2 == 0) {
		// 	load_sync();
		// // 	load_color(colors[i / 2]);
		// }

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
	
	fixed32 camera_transform[4][4] = {
		{FIXED32(1), FIXED32(0), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(1), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(0), FIXED32(1), FIXED32(0)},
		{FIXED32(0), FIXED32(0), FIXED32(30), FIXED32(1)}
	};
	
	fixed32 perspective[4][4] = {
		{FIXED32(2.0 * NEAR / (RIGHT - LEFT)),      FIXED32(0), 							   FIXED32(0), FIXED32(0)},
		{FIXED32(0), 						   	    FIXED32(2.0 * NEAR / (BOTTOM - TOP)),      FIXED32(0), FIXED32(0)},
		{FIXED32(-(RIGHT + LEFT) / (RIGHT - LEFT)), FIXED32(-(BOTTOM + TOP) / (BOTTOM - TOP)), FIXED32(-NEAR / (FAR - NEAR)), FIXED32(1)},
		{FIXED32(0),                                FIXED32(0),                                FIXED32(FAR * NEAR / (FAR - NEAR)), FIXED32(0)}
	};
	
	fixed32 screen_transform[4][4] = {
		{FIXED32(160), FIXED32(0), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(160), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(0), FIXED32(1), FIXED32(0)},
		{FIXED32(160), FIXED32(120), FIXED32(0), FIXED32(1)}
	};

	fixed32 temp_transform[4][4];
	fixed32 view_transform[4][4];
	matrix_mul(perspective, camera_transform, temp_transform);
	matrix_mul(screen_transform, temp_transform, view_transform);

	float t = 1.102;
	while (1) {
		while(!(disp = display_lock()));

		t += 0.01;

		fixed32 rotation1[4][4] = {
			{FIXED32(cosf(t)),  FIXED32(sinf(t)), FIXED32(0), FIXED32(0)},
			{FIXED32(-sinf(t)), FIXED32(cosf(t)), FIXED32(0), FIXED32(0)},
			{FIXED32(0), 	    FIXED32(0), 	  FIXED32(1), FIXED32(0)},
			{FIXED32(0), 		FIXED32(0), 	  FIXED32(0), FIXED32(1)}
		};

		float t2 = t * 1.1;
		fixed32 rotation2[4][4] = {
			{FIXED32(1), FIXED32(0), 		 FIXED32(0),        FIXED32(0)},
			{FIXED32(0), FIXED32(cosf(t2)),  FIXED32(sinf(t2)), FIXED32(0)},
			{FIXED32(0), FIXED32(-sinf(t2)), FIXED32(cosf(t2)), FIXED32(0)},
			{FIXED32(0), FIXED32(0), 		 FIXED32(0),        FIXED32(1)}
		};

		fixed32 transformation1[4][4];
		fixed32 transformation2[4][4];

		matrix_mul(rotation2, rotation1, transformation1);
		matrix_mul(view_transform, transformation1, transformation2);

		run_frame_setup(__safe_buffer[disp-1], &z_buffer, &texture, &palette);
		// run_frame_setup(&z_buffer, __safe_buffer[disp-1], &texture, &palette);

		for (int z = 0; z < 4; z++) {
			for (int y = 0; y < 4; y++) {
				for (int x = 0; x < 4; x++) {
					load_cube(x * 8 - 12, y * 8 - 12, z * 8 - 12, transformation2);
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
