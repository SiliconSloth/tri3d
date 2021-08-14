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

void load_triangle(TriangleCoeffs coeffs) {
	SP_DMEM[18] = 0x8000000 | (coeffs.major << 23) | (coeffs.yl >> 14);
	SP_DMEM[19] = ((coeffs.ym & 0x7FFC000) << 2) | (coeffs.yh >> 14);

	SP_DMEM[20] = coeffs.xl;
	SP_DMEM[21] = coeffs.dxldy;

	SP_DMEM[22] = coeffs.xh;
	SP_DMEM[23] = coeffs.dxhdy;

	SP_DMEM[24] = coeffs.xm;
	SP_DMEM[25] = coeffs.dxmdy;
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

	fixed32 dxldy = (y3 == y2) ? 0 : DIV_FX32(x3 - x2, y3 - y2);
	fixed32 dxmdy = (y2 == y1) ? 0 : DIV_FX32(x2 - x1, y2 - y1);
	fixed32 dxhdy = (y3 == y1) ? 0 : DIV_FX32(x3 - x1, y3 - y1);

	fixed32 y1_frac = y1 & 0xFFFF;
	fixed32 xh = x1 - MUL_FX32(y1_frac, dxhdy);
	fixed32 xm = x1 - MUL_FX32(y1_frac, dxmdy);

	fixed32 y2_gap = 0x4000 - (y2 & 0x3FFF);
	fixed32 xl = x2 + MUL_FX32(y2_gap, dxldy);

	bool major = MUL_FX32((x3 - x1), (y2 - y1)) - MUL_FX32((y3 - y1), (x2 - x1)) < 0;

	coeffs->major = major;

	coeffs->yl = y3;
	coeffs->ym = y2;
	coeffs->yh = y1;

	coeffs->xl = xl;
	coeffs->dxldy = dxldy;

	coeffs->xh = xh;
	coeffs->dxhdy = dxhdy;

	coeffs->xm = xm;
	coeffs->dxmdy = dxmdy;
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

	float xr1 = 20;
	float yr1 = -60;
	float xr2 = -46;
	float yr2 = 72;
	float xr3 = 80;
	float yr3 = -20;

	float t = 1.102;

	TriangleCoeffs coeffs;
	while (1) {
		while(!(disp = display_lock()));

		SP_DMEM[5] = (uint32_t) __safe_buffer[disp-1];

		t += 0.01;

		float x1 = xr1 * cosf(t) - yr1 * sinf(t) + 160;
		float y1 = xr1 * sinf(t) + yr1 * cosf(t) + 120;

		float x2 = xr2 * cosf(t) - yr2 * sinf(t) + 160;
		float y2 = xr2 * sinf(t) + yr2 * cosf(t) + 120;

		float x3 = xr3 * cosf(t) - yr3 * sinf(t) + 160;
		float y3 = xr3 * sinf(t) + yr3 * cosf(t) + 120;

		compute_triangle_coefficients(&coeffs, FIXED32(x1), FIXED32(y1), FIXED32(x2), FIXED32(y2), FIXED32(x3), FIXED32(y3));
		load_triangle(coeffs);

		rdp_sync(SYNC_PIPE);
		set_xbus();
		run_ucode();
		graphics_printf(disp, 200, 20, "%f", (float) ((y2 == y1) ? 0 : DIV_FX32(x2 - x1, y2 - y1)) / 65536);
		display_show(disp);
	}
}
