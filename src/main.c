#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <libdragon.h>

#define DPC_STATUS_REG (*((volatile uint32_t *)0xA410000C))
#define SP_DMEM ((volatile uint32_t *) 0xA4000000)

#define SET_XBS 2

extern const void tri3d_ucode_start;
extern const void tri3d_ucode_data_start;
extern const void tri3d_ucode_end;

extern void *__safe_buffer[];

void graphics_printf(display_context_t disp, int x, int y, char *szFormat, ...){
	char szBuffer[64];

	va_list pArgs;
	va_start(pArgs, szFormat);
	vsnprintf(szBuffer, sizeof szBuffer, szFormat, pArgs);
	va_end(pArgs);

	graphics_draw_text(disp, x, y, szBuffer);
}

void set_xbus() {
	DPC_STATUS_REG |= SET_XBS;
}

int main(void){
	static display_context_t disp = 0;

	init_interrupts();

	display_init(RESOLUTION_320x240, DEPTH_16_BPP, 2, GAMMA_NONE, ANTIALIAS_RESAMPLE);
	controller_init();
	rsp_init();
	
    unsigned long ucode_code_size = &tri3d_ucode_data_start - &tri3d_ucode_start;
    unsigned long ucode_data_size = &tri3d_ucode_end - &tri3d_ucode_data_start;

    load_ucode((void*)&tri3d_ucode_start, ucode_code_size);
    load_data((void*)&tri3d_ucode_data_start, ucode_data_size);

	while (1) {
		while(!(disp = display_lock()));

		SP_DMEM[5] = (uint32_t) __safe_buffer[disp-1];

		SP_DMEM[20] -= 0x10000;
		SP_DMEM[22] -= 0x10000;
		SP_DMEM[24] -= 0x10000;

		rdp_sync(SYNC_PIPE);
		set_xbus();
		run_ucode();
		graphics_printf(disp, 200, 20, "%lX", __safe_buffer[disp-1]);
		display_show(disp);
	}
}
