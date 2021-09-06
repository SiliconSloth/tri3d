// Profiling code provided by rasky
#include <memory.h>
#include <stdio.h>

#include "profile.h"

#define SCALE_RESULTS  2048

uint64_t slot_total[PS_NUM_SLOTS];
uint64_t slot_total_count[PS_NUM_SLOTS];
uint64_t total_time;
uint64_t last_frame;
uint64_t slot_frame_cur[PS_NUM_SLOTS];
int frames;

void profile_init(void) {
	memset(slot_total, 0, sizeof(slot_total));
	memset(slot_total_count, 0, sizeof(slot_total_count));
	memset(slot_frame_cur, 0, sizeof(slot_frame_cur));
	frames = 0;

	total_time = 0;
	last_frame = TICKS_READ();
}

void profile_next_frame(void) {
	for (int i=0;i<PS_NUM_SLOTS;i++) {
		// Extract and save the total time for this frame.
		slot_total[i] += slot_frame_cur[i] >> 32;
		slot_total_count[i] += slot_frame_cur[i] & 0xFFFFFFFF;
		slot_frame_cur[i] = 0;
	}
	frames++;

	// Increment total profile time. Make sure to handle overflow of the
	// hardware profile counter, as it happens frequently.
	uint64_t count = TICKS_READ();
	total_time += TICKS_DISTANCE(last_frame, count);
	last_frame = count;
}

static void stats(ProfileSlot slot, uint64_t frame_avg, uint32_t *mean, float *partial) {
	*mean = slot_total[slot]/frames;
	*partial = (float)*mean * 100.0 / (float)frame_avg;
}

void profile_dump(display_context_t disp) {
	printf("%-14s %4s %6s %6s", "Slot", "Cnt", "Avg", "Cum");
	fprintf(stderr, "----------------------------------\n");
	fprintf(stderr, "----------------------------------\n");

	uint64_t frame_avg = total_time / frames;
	char buf[64];

#define DUMP_SLOT(slot, name) { \
	uint32_t mean; float partial; \
	stats(slot, frame_avg, &mean, &partial); \
	sprintf(buf, "%2.1f", partial); \
	fprintf(stderr, "%-14s %4llu %6ld %5s%%\n", name, \
		 slot_total_count[slot] / frames, \
		 mean/SCALE_RESULTS, \
		 buf); \
}

	DUMP_SLOT(PS_FRAME,     "Frame");
	DUMP_SLOT(PS_CUBE,      " Cube");
	DUMP_SLOT(PS_TRANSFORM, "  Transform");
	DUMP_SLOT(PS_TRIANGLE,  "  Triangle");
	DUMP_SLOT(PS_COLLATE,   "   Collate");
	DUMP_SLOT(PS_FRUSTUM,   "   Frustum");
	DUMP_SLOT(PS_BACKFACE,  "   Backface");
	DUMP_SLOT(PS_CLIP,      "   Clip");
	DUMP_SLOT(PS_COEFFS,    "   Coeffs");
	DUMP_SLOT(PS_PACK,      "   Pack");
	DUMP_SLOT(PS_LOAD,      "   Load");
	DUMP_SLOT(PS_NULL,      "   Null");

	fprintf(stderr, "----------------------------------\n");
	fprintf(stderr, "Profiled frames:      %4d\n", frames);
	fprintf(stderr, "Frames per second:    %4.1f\n", (float)TICKS_PER_SECOND/(float)frame_avg);
	fprintf(stderr, "Average frame time:   %4lld\n", frame_avg/SCALE_RESULTS);
	fprintf(stderr, "Target frame time:    %4d\n", TICKS_PER_SECOND/24/SCALE_RESULTS);
}
