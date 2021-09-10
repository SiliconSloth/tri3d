#include <stdbool.h>
#include <libdragon.h>

#include "dispatch.h"
#include "profile.h"

static volatile struct SP_regs_s * const SP_regs = (struct SP_regs_s *)0xa4040000;

#define SP_DMA_DMEM 0x04000000

/** @brief SP DMA busy */
#define SP_STATUS_DMA_BUSY              ( 1 << 2 )
/** @brief SP IO busy */
#define SP_STATUS_IO_BUSY               ( 1 << 4 )

#define DPC_START_REG  (*((volatile uint32_t *)0xA4100000))
#define DPC_END_REG    (*((volatile uint32_t *)0xA4100004))
#define DPC_STATUS_REG (*((volatile uint32_t *)0xA410000C))
#define SP_DMEM ((volatile uint32_t *) 0xA4000000)

#define CLR_XBS 1
#define SET_XBS 2
#define RDP_DMA 0x100

/**
 * @brief Register definition for the SP interface
 * @ingroup lowlevel
 */
typedef struct SP_regs_s {
    /** @brief RSP memory address (IMEM/DMEM) */
    volatile void * RSP_addr;
    /** @brief RDRAM memory address */
    volatile void * DRAM_addr;
    /** @brief RDRAM->RSP DMA length */
    uint32_t rsp_read_length;
    /** @brief RDP->RDRAM DMA length */
    uint32_t rsp_write_length;
    /** @brief RSP status */
    uint32_t status;
    /** @brief RSP DMA full */
    uint32_t rsp_dma_full;
    /** @brief RSP DMA busy */
    uint32_t rsp_dma_busy;
    /** @brief RSP Semaphore */
    uint32_t rsp_semaphore;
} SP_regs_t;

extern const void tri3d_ucode_start;
extern const void tri3d_ucode_data_start;
extern const void tri3d_ucode_end;

#define RSP_DATA_SIZE 136
#define COMMAND_BUFFER_SIZE 1776

static uint32_t buffer_starts[] = {RSP_DATA_SIZE, RSP_DATA_SIZE + COMMAND_BUFFER_SIZE};
static int current_buffer = 0;
static uint32_t command_pointer;

static bool rdp_busy = false;

void set_xbus(bool enable) {
	DPC_STATUS_REG = enable? SET_XBS : CLR_XBS;
}

/**
 * @brief Wait until the SI is finished with a DMA request
 */
static void __SP_DMA_wait(void) {
    while (SP_regs->status & (SP_STATUS_DMA_BUSY | SP_STATUS_IO_BUSY));
}

void dma_to_dmem(volatile void *source, uint32_t dest, unsigned long size) {
	data_cache_hit_writeback(source, size);
    disable_interrupts();
    __SP_DMA_wait();
 
    SP_regs->DRAM_addr = source;
    MEMORY_BARRIER();
    SP_regs->RSP_addr = (void *) (SP_DMA_DMEM + dest);
    MEMORY_BARRIER();
    SP_regs->rsp_read_length = size - 1;
    MEMORY_BARRIER();

    __SP_DMA_wait();
    enable_interrupts();
    return;
}

void poll_rdp() {
	if (rdp_busy && (DPC_STATUS_REG & RDP_DMA) == 0) {
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
    load_ucode((void *) &tri3d_ucode_start, ucode_code_size);
}

void run_frame_setup(void *color_image, void *z_image, void *texture, void *palette) {
	volatile uint32_t *setup_commands = (uint32_t *) &tri3d_ucode_data_start;

	setup_commands[15] = (uint32_t) color_image;
	setup_commands[5] = (uint32_t) z_image;
	setup_commands[7] = (uint32_t) z_image;
	
	setup_commands[25] = (uint32_t) palette;
	setup_commands[33] = (uint32_t) texture;

	data_cache_hit_writeback(&tri3d_ucode_data_start, (uint32_t) &tri3d_ucode_end - (uint32_t) &tri3d_ucode_data_start);

	set_xbus(false);
	DPC_START_REG = (uint32_t) &tri3d_ucode_data_start;
	DPC_END_REG = (uint32_t) &tri3d_ucode_end;
	set_xbus(true);
    rdp_busy = true;

	current_buffer = 0;
	command_pointer = buffer_starts[current_buffer];
}

void swap_command_buffers() {
	SP_DMEM[0] = buffer_starts[current_buffer];
	SP_DMEM[1] = command_pointer;

	run_blocking();
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

#define COMMAND_SIZE 44

void load_triangle(TriangleCoeffs coeffs) {
	// swap_if_full(176);

	PROFILE_START(PS_PACK, 0);
	uint32_t command[COMMAND_SIZE];
	uint32_t *cp = command;

	// cp[0] = 0xF000000 | (coeffs.major << 23) | ((uint32_t) coeffs.yl >> 14);
	// cp[1] = ((coeffs.ym & 0xFFFFC000) << 2) | ((uint32_t) coeffs.yh >> 14);

	// cp[2] = coeffs.xl;
	// cp[3] = coeffs.dxldy;

	// cp[4] = coeffs.xh;
	// cp[5] = coeffs.dxhdy;

	// cp[6] = coeffs.xm;
	// cp[7] = coeffs.dxmdy;

	cp += 8;

	cp[0] = (coeffs.red & 0xFFFF0000) | ((uint32_t) coeffs.green >> 16);
	cp[1] = coeffs.blue & 0xFFFF0000;

	cp[2] = (coeffs.drdx & 0xFFFF0000) | ((uint32_t) coeffs.dgdx >> 16);
	cp[3] = coeffs.dbdx & 0xFFFF0000;

	cp[4] = ((uint32_t) coeffs.red << 16) | ((uint32_t) coeffs.green & 0xFFFF);
	cp[5] = (uint32_t) coeffs.blue << 16;

	cp[6] = ((uint32_t) coeffs.drdx << 16) | ((uint32_t) coeffs.dgdx & 0xFFFF);
	cp[7] = (uint32_t) coeffs.dbdx << 16;

	cp[8] = (coeffs.drde & 0xFFFF0000) | ((uint32_t) coeffs.dgde >> 16);
	cp[9] = coeffs.dbde & 0xFFFF0000;

	cp[10] = 0;
	cp[11] = 0;

	cp[12] = ((uint32_t) coeffs.drde << 16) | (coeffs.dgde & 0xFFFF);
	cp[13] = (uint32_t) coeffs.dbde << 16;

	cp[14] = 0;
	cp[15] = 0;

	cp += 16;

	cp[0] = (coeffs.s & 0xFFFF0000) | ((uint32_t) coeffs.t >> 16);
	cp[1] = coeffs.w & 0xFFFF0000;

	cp[2] = (coeffs.dsdx & 0xFFFF0000) | ((uint32_t) coeffs.dtdx >> 16);
	cp[3] = coeffs.dwdx & 0xFFFF0000;

	cp[4] = ((uint32_t) coeffs.s << 16) | ((uint32_t) coeffs.t & 0xFFFF);
	cp[5] = (uint32_t) coeffs.w << 16;

	cp[6] = ((uint32_t) coeffs.dsdx << 16) | ((uint32_t) coeffs.dtdx & 0xFFFF);
	cp[7] = (uint32_t) coeffs.dwdx << 16;

	cp[8] = (coeffs.dsde & 0xFFFF0000) | ((uint32_t) coeffs.dtde >> 16);
	cp[9] = coeffs.dwde & 0xFFFF0000;

	cp[10] = 0;
	cp[11] = 0;

	cp[12] = ((uint32_t) coeffs.dsde << 16) | (coeffs.dtde & 0xFFFF);
	cp[13] = (uint32_t) coeffs.dwde << 16;

	cp[14] = 0;
	cp[15] = 0;

	cp += 16;

	cp[0] = coeffs.z;
	cp[1] = coeffs.dzdx;

	cp[2] = coeffs.dzde;
	cp[3] = 0;

	PROFILE_STOP(PS_PACK, 0);
	
	PROFILE_START(PS_LOAD, 0);
	dma_to_dmem(&coeffs, 8, 128);
	dma_to_dmem(command, command_pointer, COMMAND_SIZE * sizeof(uint32_t));

	command_pointer += COMMAND_SIZE * 4;
	swap_command_buffers();
	fprintf(stderr, "%lX    %lX\n", *(SP_DMEM + 1 + command_pointer / 4), command[1]);
	PROFILE_STOP(PS_LOAD, 0);
}