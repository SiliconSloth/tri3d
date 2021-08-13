#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
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

#define FIXED32(v) ((fixed32) (v * 65536))

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

	TriangleCoeffs coeffs = {1, FIXED32(192), FIXED32(100), FIXED32(60),
								FIXED32(240), FIXED32(-1.375),
								FIXED32(180), FIXED32(-0.5),
								FIXED32(180), FIXED32(1.5)};

	while (1) {
		while(!(disp = display_lock()));

		SP_DMEM[5] = (uint32_t) __safe_buffer[disp-1];

		load_triangle(coeffs);

		rdp_sync(SYNC_PIPE);
		set_xbus();
		run_ucode();
		graphics_printf(disp, 200, 20, "%lX", __safe_buffer[disp-1]);
		graphics_printf(disp, 200, 30, "%lX", SP_DMEM[17]);
		graphics_printf(disp, 200, 40, "%lX", SP_DMEM[18]);
		display_show(disp);
	}
}
