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
#define RDP_DMA 0x100

extern const void tri3d_ucode_start;
extern const void tri3d_ucode_data_start;
extern const void tri3d_ucode_end;

extern uint16_t *__safe_buffer[];

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

	fixed32 red;
	fixed32 green;
	fixed32 blue;

	fixed32 drdx;
	fixed32 dgdx;
	fixed32 dbdx;

	fixed32 drde;
	fixed32 dgde;
	fixed32 dbde;

	fixed32 drdy;
	fixed32 dgdy;
	fixed32 dbdy;

	fixed32 z;
	fixed32 dzdx;
	fixed32 dzde;
	fixed32 dzdy;
} TriangleCoeffs;

typedef struct {
	fixed32 x;
	fixed32 y;
	fixed32 z;

	fixed32 r;
	fixed32 g;
	fixed32 b;
} VertexInfo;

static uint16_t z_buffer[320 * 240];// __attribute__ ((aligned (8)));

#define SETUP_BUFFER_SIZE 200
#define COMMAND_BUFFER_SIZE 1800

static uint32_t buffer_starts[] = {SETUP_BUFFER_SIZE, SETUP_BUFFER_SIZE + COMMAND_BUFFER_SIZE};
static int current_buffer = 0;
static uint32_t command_pointer;

#define COUNTS_PER_SECOND (93750000/2)

static uint64_t start_time = 0;
static uint64_t cpu_time = 0;
static uint64_t rdp_time = 0;
static bool rdp_busy = false;

static uint64_t total_cpu_time = 0;
static uint64_t total_rdp_time = 0;
static uint64_t num_samples = 0;

static uint64_t transform_start;
static uint64_t transform_time;
static uint64_t load_start;
static uint64_t load_time;

static uint64_t prep_start;
static uint64_t prep_time;
static uint64_t matrix_start;
static uint64_t matrix_time;
static uint64_t vertex_start;
static uint64_t vertex_time;

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
	volatile uint32_t *command = SP_DMEM + command_pointer / sizeof(uint32_t);

	command[0] = 0xD000000 | (coeffs.major << 23) | ((uint32_t) coeffs.yl >> 14);
	command[1] = ((coeffs.ym & 0xFFFFC000) << 2) | ((uint32_t) coeffs.yh >> 14);

	command[2] = coeffs.xl;
	command[3] = coeffs.dxldy;

	command[4] = coeffs.xh;
	command[5] = coeffs.dxhdy;

	command[6] = coeffs.xm;
	command[7] = coeffs.dxmdy;

	command += 8;

	command[0] = (coeffs.red & 0xFFFF0000) | (coeffs.green >> 16);
	command[1] = coeffs.blue & 0xFFFF0000;

	command[2] = (coeffs.drdx & 0xFFFF0000) | (coeffs.dgdx >> 16);
	command[3] = coeffs.dbdx & 0xFFFF0000;

	command[4] = (coeffs.red << 16) | (coeffs.green & 0xFFFF);
	command[5] = coeffs.blue << 16;

	command[6] = (coeffs.drdx << 16) | (coeffs.dgdx & 0xFFFF);
	command[7] = coeffs.dbdx << 16;

	command[8] = (coeffs.drde & 0xFFFF0000) | (coeffs.dgde >> 16);
	command[9] = coeffs.dbde & 0xFFFF0000;

	command[10] = (coeffs.drdy & 0xFFFF0000) | (coeffs.dgdy >> 16);
	command[11] = coeffs.dbdy & 0xFFFF0000;

	command[12] = (coeffs.drde << 16) | (coeffs.dgde & 0xFFFF);
	command[13] = coeffs.dbde << 16;

	command[14] = (coeffs.drdy << 16) | (coeffs.dgdy & 0xFFFF);
	command[15] = coeffs.dbdy << 16;

	command += 16;

	command[0] = coeffs.z;
	command[1] = coeffs.dzdx;

	command[2] = coeffs.dzde;
	command[3] = coeffs.dzdy;

	command_pointer += 112;
}

void load_color(uint32_t color) {
	volatile uint32_t *command = SP_DMEM + command_pointer / sizeof(uint32_t);

	command[0] = 0x39000000;
	command[1] = color;

	command_pointer += 8;
}

void load_sync() {
	volatile uint32_t *command = SP_DMEM + command_pointer / sizeof(uint32_t);

	command[0] = 0x27000000;
	command[1] = 0;

	command_pointer += 8;
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

	fixed32 dzde = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(z3 - z1, y3 - y1);

	fixed32 x_mid = x1 + MUL_FX32(y2 - y1, dxhdy);
	fixed32 z_mid = z1 + MUL_FX32(y2 - y1, dzde);

	fixed32 dzdx = (x2 - x_mid < FIXED32(1) && x_mid - x2 < FIXED32(1)) ? 0 : DIV_FX32(z2 - z_mid, x2 - x_mid);

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

	coeffs->red   = v1.r;
	coeffs->green = v1.g;
	coeffs->blue  = v1.b;

	coeffs->drdx = FIXED32(0);
	coeffs->dgdx = FIXED32(16);
	coeffs->dbdx = FIXED32(8);

	coeffs->drde = FIXED32(0);
	coeffs->dgde = FIXED32(16);
	coeffs->dbde = FIXED32(8);

	coeffs->drdy = FIXED32(0);
	coeffs->dgdy = FIXED32(0);
	coeffs->dbdy = FIXED32(8);

	coeffs->z = z1;
	coeffs->dzdx = dzdx;
	coeffs->dzde = dzde;
	coeffs->dzdy = 0;
}

void load_triangle_verts(fixed32 x1, fixed32 y1, fixed32 z1,
						 fixed32 x2, fixed32 y2, fixed32 z2,
						 fixed32 x3, fixed32 y3, fixed32 z3) {
	VertexInfo v1 = {x1, y1, z1, FIXED32(256), FIXED32(0), FIXED32(0)};
	VertexInfo v2 = {x2, y2, z2, FIXED32(0), FIXED32(256), FIXED32(0)};
	VertexInfo v3 = {x3, y3, z3, FIXED32(0), FIXED32(0), FIXED32(256)};

	TriangleCoeffs coeffs;
	compute_triangle_coefficients(&coeffs, v1, v2, v3);
	load_triangle(coeffs);
}

void poll_rdp() {
	if (rdp_busy && (DPC_STATUS_REG & RDP_DMA) == 0) {
		rdp_time = timer_ticks() - start_time;
		rdp_busy = false;
	}
}

#define RADIUS 100

#define PERSP_SCALE (1.0 / tanf(40.0 * M_PI / 360))

#define FAR 128.0
#define NEAR -128.0

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

static fixed32 transformed_vertices[4][3];

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

		// if (i % 2 == 0) {
		// 	load_sync();
		// // 	load_color(colors[i / 2]);
		// }

		load_triangle_verts(transformed_vertices[i1][0] + FIXED32(160), transformed_vertices[i1][1] + FIXED32(120), transformed_vertices[i1][2],
							transformed_vertices[i2][0] + FIXED32(160), transformed_vertices[i2][1] + FIXED32(120), transformed_vertices[i2][2],
							transformed_vertices[i3][0] + FIXED32(160), transformed_vertices[i3][1] + FIXED32(120), transformed_vertices[i3][2]);
	}

	load_time = timer_ticks() - load_start;
}

void run_blocking() {
	while ((DPC_STATUS_REG & RDP_DMA) != 0);
	run_ucode();
}

void run_frame_setup(void *color_image, void *z_image) {
	set_xbus();

	SP_DMEM[17] = (uint32_t) color_image;
	SP_DMEM[7] = (uint32_t) z_image;
	SP_DMEM[9] = (uint32_t) z_image;

	SP_DMEM[0] = 8;
	SP_DMEM[1] = 104;

	run_blocking();

	current_buffer = 0;
	command_pointer = buffer_starts[current_buffer];
}

void swap_command_buffers() {
	SP_DMEM[0] = buffer_starts[current_buffer];
	SP_DMEM[1] = command_pointer;

	cpu_time = timer_ticks() - start_time;
	run_blocking();
	poll_rdp();
	total_cpu_time += cpu_time;
	total_rdp_time += rdp_time;
	num_samples++;
	start_time = timer_ticks();
	rdp_busy = true;

	current_buffer = 1 - current_buffer;
	command_pointer = buffer_starts[current_buffer];
}

int main(void){
	static display_context_t disp = 0;

	init_interrupts();

	set_tv_type(TV_TYPE_PAL);
	display_init(RESOLUTION_320x240, DEPTH_16_BPP, 2, GAMMA_NONE, ANTIALIAS_RESAMPLE);
	controller_init();
	rsp_init();
	timer_init();
	
    unsigned long ucode_code_size = &tri3d_ucode_data_start - &tri3d_ucode_start;
    unsigned long ucode_data_size = &tri3d_ucode_end - &tri3d_ucode_data_start;

    load_ucode((void*)&tri3d_ucode_start, ucode_code_size);
    load_data((void*)&tri3d_ucode_data_start, ucode_data_size);
	
	fixed32 perspective[4][4] = {
		{FIXED32(PERSP_SCALE), FIXED32(0), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(PERSP_SCALE), FIXED32(0), FIXED32(0)},
		{FIXED32(0), FIXED32(0), 0x7FFFFFFF / 512, FIXED32(1.0 / 160)},
		{FIXED32(0), FIXED32(0), 0x3FFFFFFF, FIXED32(PERSP_SCALE - NEAR / 160)}
	};

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
		matrix_mul(perspective, transformation1, transformation2);

		run_frame_setup(__safe_buffer[disp-1], &z_buffer);
		// run_frame_setup(&z_buffer, __safe_buffer[disp-1]);
		
		total_cpu_time = 0;
		total_rdp_time = 0;
		num_samples = 0;
		start_time = timer_ticks();
		rdp_busy = true;

		for (int z = 0; z < 4; z++) {
			for (int y = 0; y < 4; y++) {
				for (int x = 0; x < 4; x++) {
					load_cube(x * 80 - 120, y * 80 - 120, z * 80 - 120, transformation2);
					swap_command_buffers();
				}
			}
		}
		
		// for (size_t i = 0; i < 320 * 240; i++) {
		// 	__safe_buffer[disp - 1][i] = __safe_buffer[disp - 1][i] & 0xF800;
		// }

		graphics_printf(disp, 20, 20, "%u", COUNTS_PER_SECOND / total_cpu_time);
		graphics_printf(disp, 20, 40, "%8lu", cpu_time);
		graphics_printf(disp, 20, 50, "%8lu", rdp_time);
		graphics_printf(disp, 20, 70, "%8lu", total_cpu_time);
		graphics_printf(disp, 20, 80, "%8lu", total_rdp_time);
		graphics_printf(disp, 20, 100, "%8lu", transform_time);
		graphics_printf(disp, 20, 110, "%8lu", load_time);
		graphics_printf(disp, 20, 130, "%8lu", prep_time);
		graphics_printf(disp, 20, 140, "%8lu", matrix_time);
		graphics_printf(disp, 20, 150, "%8lu", vertex_time);
		display_show(disp);
	}
}
