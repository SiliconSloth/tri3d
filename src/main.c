#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <libdragon.h>

#define TV_TYPE_LOC (*((volatile uint32_t *)0x80000300))
#define DPC_STATUS_REG (*((volatile uint32_t *)0xA410000C))
#define SP_DMEM ((volatile uint32_t *) 0xA4000000)

#define TV_TYPE_PAL 0
#define TV_TYPE_NTSC 1
#define TV_TYPE_MPAL 2

#define SET_XBS 2

extern const void tri3d_ucode_start;
extern const void tri3d_ucode_data_start;
extern const void tri3d_ucode_end;

extern void *__safe_buffer[];

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
} TriangleCoeffs;

static uint32_t num_triangles;

#define RDP_BUFFER_END ((volatile uint32_t *) (80 + num_triangles * 40))

void graphics_printf(display_context_t disp, int x, int y, char *szFormat, ...){
	char szBuffer[64];

	va_list pArgs;
	va_start(pArgs, szFormat);
	vsnprintf(szBuffer, sizeof szBuffer, szFormat, pArgs);
	va_end(pArgs);

	graphics_draw_text(disp, x, y, szBuffer);
}

void set_tv_type(uint32_t tv_type) {
	TV_TYPE_LOC = tv_type;
}

void set_xbus() {
	DPC_STATUS_REG = SET_XBS;
}

void load_triangle(TriangleCoeffs coeffs, uint32_t color) {
	volatile uint32_t *command = SP_DMEM + (uint32_t) RDP_BUFFER_END / sizeof(uint32_t);

	command[0] = 0x39000000;
	command[1] = color;

	command += 2;

	command[0] = 0x8000000 | (coeffs.major << 23) | ((uint32_t) coeffs.yl >> 14);
	command[1] = ((coeffs.ym & 0xFFFFC000) << 2) | ((uint32_t) coeffs.yh >> 14);

	command[2] = coeffs.xl;
	command[3] = coeffs.dxldy;

	command[4] = coeffs.xh;
	command[5] = coeffs.dxhdy;

	command[6] = coeffs.xm;
	command[7] = coeffs.dxmdy;

	num_triangles++;
}

void compute_triangle_coefficients(TriangleCoeffs *coeffs, fixed32 x1, fixed32 y1, fixed32 x2, fixed32 y2, fixed32 x3, fixed32 y3) {
	fixed32 temp_x, temp_y;
	
	if (y1 > y2) {
		temp_x = x1;
		x1 = x2;
		x2 = temp_x;

		temp_y = y1;
		y1 = y2;
		y2 = temp_y;
	}
	
	if (y2 > y3) {
		temp_x = x2;
		x2 = x3;
		x3 = temp_x;

		temp_y = y2;
		y2 = y3;
		y3 = temp_y;

		if (y1 > y2) {
			temp_x = x1;
			x1 = x2;
			x2 = temp_x;

			temp_y = y1;
			y1 = y2;
			y2 = temp_y;
		}
	}

	fixed32 dxldy = (y3 - y2 < FIXED32(1)) ? 0 : DIV_FX32(x3 - x2, y3 - y2);
	fixed32 dxmdy = (y2 - y1 < FIXED32(1)) ? 0 : DIV_FX32(x2 - x1, y2 - y1);
	fixed32 dxhdy = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(x3 - x1, y3 - y1);

	fixed32 y1_frac = y1 & 0xFFFF;
	fixed32 xh = x1 - MUL_FX32(y1_frac, dxhdy);
	fixed32 xm = x1 - MUL_FX32(y1_frac, dxmdy);

	fixed32 y2_gap = 0x4000 - (y2 & 0x3FFF);
	fixed32 xl = x2 + MUL_FX32(y2_gap, dxldy);

	bool major = MUL_FX32((x3 - x1), (y2 - y1)) - MUL_FX32((y3 - y1), (x2 - x1)) < 0;

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
}

void load_triangle_verts(fixed32 x1, fixed32 y1, fixed32 x2, fixed32 y2, fixed32 x3, fixed32 y3, uint32_t color) {
	TriangleCoeffs coeffs;
	compute_triangle_coefficients(&coeffs, x1, y1, x2, y2, x3, y3);
	load_triangle(coeffs, color);
}

#define RADIUS 100

static const fixed32 vertices[8][3] = {
	{FIXED32(-20), FIXED32(-20), FIXED32(-20)},
	{FIXED32( 20), FIXED32(-20), FIXED32(-20)},
	{FIXED32( 20), FIXED32( 20), FIXED32(-20)},
	{FIXED32(-20), FIXED32( 20), FIXED32(-20)},
	{FIXED32(-20), FIXED32(-20), FIXED32( 20)},
	{FIXED32( 20), FIXED32(-20), FIXED32( 20)},
	{FIXED32( 20), FIXED32( 20), FIXED32( 20)},
	{FIXED32(-20), FIXED32( 20), FIXED32( 20)}
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

static fixed32 transformed_vertices[4][2];

void load_quad(float radius, float angle, float z_angle, uint32_t color) {
	fixed32 translation1[4][4] = {
		{FIXED32(1), FIXED32(0), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(1), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(0), FIXED32(1), FIXED32(0)},
		{FIXED32(RADIUS), FIXED32(0), FIXED32(0), FIXED32(1)}
	};

	fixed32 rotation1[4][4] = {
		{FIXED32(cosf(angle)),  FIXED32(sinf(angle)), FIXED32(0), FIXED32(0)},
		{FIXED32(-sinf(angle)), FIXED32(cosf(angle)), FIXED32(0), FIXED32(0)},
		{FIXED32(0), 			FIXED32(0), 		  FIXED32(1), FIXED32(0)},
		{FIXED32(0), 			FIXED32(0), 		  FIXED32(0), FIXED32(1)}
	};

	fixed32 rotation2[4][4] = {
		{FIXED32(1), 			FIXED32(0), 		  FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(cosf(z_angle)),  FIXED32(sinf(z_angle)), FIXED32(0)},
		{FIXED32(0), FIXED32(-sinf(z_angle)), FIXED32(cosf(z_angle)), FIXED32(0)},
		{FIXED32(0), 			FIXED32(0), 		  FIXED32(0), FIXED32(1)}
	};
	
	fixed32 translation2[4][4] = {
		{FIXED32(1), FIXED32(0), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(1), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(0), FIXED32(1), FIXED32(0)},
		{FIXED32(160), FIXED32(120), FIXED32(0), FIXED32(1)}
	};

	fixed32 transformation1[4][4];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(rotation1[k][i], translation1[j][k]);
			}
			transformation1[j][i] = sum;
		}
	}
	
	fixed32 transformation2[4][4];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(rotation2[k][i], transformation1[j][k]);
			}
			transformation2[j][i] = sum;
		}
	}
	
	fixed32 transformation3[4][4];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(translation2[k][i], transformation2[j][k]);
			}
			transformation3[j][i] = sum;
		}
	}

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 8; j++) {
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(transformation3[k][i], k == 3? FIXED32(1) : vertices[j][k]);
			}

			if (i < 2) {
				transformed_vertices[j][i] = sum;
			} else if (i  == 3) {
				transformed_vertices[j][0] = DIV_FX32(transformed_vertices[j][0], sum);
				transformed_vertices[j][1] = DIV_FX32(transformed_vertices[j][1], sum);
			}
		}
	}

	for (int i = 0; i < sizeof(indices) / sizeof(indices[0]); i++) {
		int i1 = indices[i][0];
		int i2 = indices[i][1];
		int i3 = indices[i][2];

		load_triangle_verts(transformed_vertices[i1][0], transformed_vertices[i1][1],
							transformed_vertices[i2][0], transformed_vertices[i2][1],
							transformed_vertices[i3][0], transformed_vertices[i3][1], color);
	}
}

int main(void){
	static display_context_t disp = 0;

	init_interrupts();

	set_tv_type(TV_TYPE_PAL);
	display_init(RESOLUTION_320x240, DEPTH_16_BPP, 2, GAMMA_NONE, ANTIALIAS_RESAMPLE);
	controller_init();
	rsp_init();
	
    unsigned long ucode_code_size = &tri3d_ucode_data_start - &tri3d_ucode_start;
    unsigned long ucode_data_size = &tri3d_ucode_end - &tri3d_ucode_data_start;

    load_ucode((void*)&tri3d_ucode_start, ucode_code_size);
    load_data((void*)&tri3d_ucode_data_start, ucode_data_size);

	float t = 1.102;

	while (1) {
		while(!(disp = display_lock()));

		num_triangles = 0;

		t += 0.01;

		load_quad(100, t,           	   t, 0xFF0000FF);
		load_quad(100, t + M_PI_4,  	   t, 0x00FF00FF);
		load_quad(100, t + M_PI_2,  	   t, 0x0000FFFF);
		load_quad(100, t + M_3PI_4, 	   t, 0xFFFF00FF);
		load_quad(100, t + M_PI,    	   t, 0xFF00FFFF);
		load_quad(100, t + M_PI + M_PI_4,  t, 0x00FFFFFF);
		load_quad(100, t + M_PI + M_PI_2,  t, 0xFF9900FF);
		load_quad(100, t + M_PI + M_3PI_4, t, 0x9900FFFF);

		SP_DMEM[7] = (uint32_t) __safe_buffer[disp-1];
		SP_DMEM[0] = (uint32_t) RDP_BUFFER_END;

		set_xbus();
		run_ucode();
		graphics_printf(disp, 200, 20, "%lu", &tri3d_ucode_end - &tri3d_ucode_data_start);
		display_show(disp);
	}
}
