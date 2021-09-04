#include <stdbool.h>
#include <libdragon.h>

#include "dispatch.h"
#include "profile.h"

#define DPC_STATUS_REG (*((volatile uint32_t *)0xA410000C))
#define SP_DMEM ((volatile uint32_t *) 0xA4000000)

#define SET_XBS 2
#define RDP_DMA 0x100

extern const void tri3d_ucode_start;
extern const void tri3d_ucode_data_start;
extern const void tri3d_ucode_end;

#define SETUP_BUFFER_OFFSET 8
#define SETUP_BUFFER_SIZE 368
#define COMMAND_BUFFER_SIZE 1776

static uint32_t buffer_starts[] = {SETUP_BUFFER_SIZE, SETUP_BUFFER_SIZE + COMMAND_BUFFER_SIZE};
static int current_buffer = 0;
static uint32_t command_pointer;

static bool rdp_busy = false;

void set_xbus() {
	DPC_STATUS_REG = SET_XBS;
}

void poll_rdp() {
	if (rdp_busy && (DPC_STATUS_REG & RDP_DMA) == 0) {
		profiler_stop(&rdp_profiler);
		rdp_busy = false;
	}
}

void run_blocking() {
	while ((DPC_STATUS_REG & RDP_DMA) != 0);
	poll_rdp();
	run_ucode();
}

void init_ucode() {
    uint32_t ucode_code_size = (uint32_t) &tri3d_ucode_data_start - (uint32_t) &tri3d_ucode_start;
    uint32_t ucode_data_size = (uint32_t) &tri3d_ucode_end - (uint32_t) &tri3d_ucode_data_start;

    load_ucode((void *) &tri3d_ucode_start, ucode_code_size);
    load_data((void *) &tri3d_ucode_data_start, ucode_data_size);
}

void run_frame_setup(void *color_image, void *z_image, void *texture, void *palette) {
	set_xbus();

	volatile uint32_t *setup_commands = SP_DMEM + SETUP_BUFFER_OFFSET / sizeof(uint32_t);

	setup_commands[15] = (uint32_t) color_image;
	setup_commands[5] = (uint32_t) z_image;
	setup_commands[7] = (uint32_t) z_image;
	
	setup_commands[25] = (uint32_t) palette;
	setup_commands[33] = (uint32_t) texture;

	SP_DMEM[0] = SETUP_BUFFER_OFFSET;
	SP_DMEM[1] = (uint32_t) &tri3d_ucode_end - (uint32_t) &tri3d_ucode_data_start;

	profiler_stop(&cpu_profiler);

	run_blocking();
	
	profiler_start(&cpu_profiler);
    profiler_start(&rdp_profiler);
    rdp_busy = true;

	current_buffer = 0;
	command_pointer = buffer_starts[current_buffer];
}

void swap_command_buffers() {
	SP_DMEM[0] = buffer_starts[current_buffer];
	SP_DMEM[1] = command_pointer;

	profiler_stop(&cpu_profiler);

	run_blocking();

	profiler_start(&cpu_profiler);
	profiler_start(&rdp_profiler);
	rdp_busy = true;

	current_buffer = 1 - current_buffer;
	command_pointer = buffer_starts[current_buffer];
}

void swap_if_full(uint32_t command_size) {
	if (command_pointer - buffer_starts[current_buffer] > COMMAND_BUFFER_SIZE - command_size) {
		swap_command_buffers();
	}
}

void flush_commands() {
    if (command_pointer != buffer_starts[current_buffer]) {
        swap_command_buffers();
    }
}

void load_triangle(TriangleCoeffs coeffs) {
	swap_if_full(176);
	volatile uint32_t *command = SP_DMEM + command_pointer / sizeof(uint32_t);

	command[0] = 0xF000000 | (coeffs.major << 23) | ((uint32_t) coeffs.yl >> 14);
	command[1] = ((coeffs.ym & 0xFFFFC000) << 2) | ((uint32_t) coeffs.yh >> 14);

	command[2] = coeffs.xl;
	command[3] = coeffs.dxldy;

	command[4] = coeffs.xh;
	command[5] = coeffs.dxhdy;

	command[6] = coeffs.xm;
	command[7] = coeffs.dxmdy;

	command += 8;

	command[0] = (coeffs.red & 0xFFFF0000) | ((uint32_t) coeffs.green >> 16);
	command[1] = coeffs.blue & 0xFFFF0000;

	command[2] = (coeffs.drdx & 0xFFFF0000) | ((uint32_t) coeffs.dgdx >> 16);
	command[3] = coeffs.dbdx & 0xFFFF0000;

	command[4] = ((uint32_t) coeffs.red << 16) | ((uint32_t) coeffs.green & 0xFFFF);
	command[5] = (uint32_t) coeffs.blue << 16;

	command[6] = ((uint32_t) coeffs.drdx << 16) | ((uint32_t) coeffs.dgdx & 0xFFFF);
	command[7] = (uint32_t) coeffs.dbdx << 16;

	command[8] = (coeffs.drde & 0xFFFF0000) | ((uint32_t) coeffs.dgde >> 16);
	command[9] = coeffs.dbde & 0xFFFF0000;

	command[10] = (coeffs.drdy & 0xFFFF0000) | ((uint32_t) coeffs.dgdy >> 16);
	command[11] = coeffs.dbdy & 0xFFFF0000;

	command[12] = ((uint32_t) coeffs.drde << 16) | (coeffs.dgde & 0xFFFF);
	command[13] = (uint32_t) coeffs.dbde << 16;

	command[14] = ((uint32_t) coeffs.drdy << 16) | (coeffs.dgdy & 0xFFFF);
	command[15] = (uint32_t) coeffs.dbdy << 16;

	command += 16;

	command[0] = (coeffs.s & 0xFFFF0000) | ((uint32_t) coeffs.t >> 16);
	command[1] = coeffs.w & 0xFFFF0000;

	command[2] = (coeffs.dsdx & 0xFFFF0000) | ((uint32_t) coeffs.dtdx >> 16);
	command[3] = coeffs.dwdx & 0xFFFF0000;

	command[4] = ((uint32_t) coeffs.s << 16) | ((uint32_t) coeffs.t & 0xFFFF);
	command[5] = (uint32_t) coeffs.w << 16;

	command[6] = ((uint32_t) coeffs.dsdx << 16) | ((uint32_t) coeffs.dtdx & 0xFFFF);
	command[7] = (uint32_t) coeffs.dwdx << 16;

	command[8] = (coeffs.dsde & 0xFFFF0000) | ((uint32_t) coeffs.dtde >> 16);
	command[9] = coeffs.dwde & 0xFFFF0000;

	command[10] = (coeffs.dsdy & 0xFFFF0000) | ((uint32_t) coeffs.dtdy >> 16);
	command[11] = coeffs.dwdy & 0xFFFF0000;

	command[12] = ((uint32_t) coeffs.dsde << 16) | (coeffs.dtde & 0xFFFF);
	command[13] = (uint32_t) coeffs.dwde << 16;

	command[14] = ((uint32_t) coeffs.dsdy << 16) | (coeffs.dtdy & 0xFFFF);
	command[15] = (uint32_t) coeffs.dwdy << 16;

	command += 16;

	command[0] = coeffs.z;
	command[1] = coeffs.dzdx;

	command[2] = coeffs.dzde;
	command[3] = coeffs.dzdy;

	command_pointer += 176;
}

void load_color(uint32_t color) {
	swap_if_full(8);
	volatile uint32_t *command = SP_DMEM + command_pointer / sizeof(uint32_t);

	command[0] = 0x39000000;
	command[1] = color;

	command_pointer += 8;
}

void load_sync() {
	swap_if_full(8);
	volatile uint32_t *command = SP_DMEM + command_pointer / sizeof(uint32_t);

	command[0] = 0x27000000;
	command[1] = 0;

	command_pointer += 8;
}