// Profiling code provided by rasky
#ifndef PROFILE_H
#define PROFILE_H

// Global enable/disable of libdragon profiler.
//
// You can force this to 0 at compile-time if you want
// to keep PROFILE() calls in your code but remove references
// everywhere.
#define LIBDRAGON_PROFILE     1

#include <stdint.h>
#include <stdarg.h>
#include <libdragon.h>

typedef enum {
	PS_FRAME,
	PS_CUBE,
	PS_TRANSFORM,
	PS_TRIANGLE,
	PS_COLLATE,
	PS_FRUSTUM,
	PS_BACKFACE,
	PS_CLIP,
	PS_COEFFS,
	PS_PACK,
	PS_LOAD,
	PS_NULL,

	PS_NUM_SLOTS
} ProfileSlot;

// Internal data structures, exposed here to allow inlining of profile_record
extern uint64_t slot_frame_cur[PS_NUM_SLOTS];

void profile_init(void);
void profile_next_frame(void);
void profile_dump(display_context_t disp);
static inline void profile_record(ProfileSlot slot, int32_t len) {
	// High part: profile record
	// Low part: number of occurrences
	slot_frame_cur[slot] += ((int64_t)len << 32) + 1;
}

#if LIBDRAGON_PROFILE
	#define PROFILE_START(slot, n) \
		uint32_t __prof_start_##slot##_##n = TICKS_READ(); \

	#define PROFILE_STOP(slot, n) \
		uint32_t __prof_stop_##slot##_##n = TICKS_READ(); \
		profile_record(slot, TICKS_DISTANCE(__prof_start_##slot##_##n, __prof_stop_##slot##_##n));
#else
	#define PROFILE_START(slot, n)  ({ })
	#define PROFILE_STOP(slot, n)   ({ })

#endif /* LIBDRAGON_PROFILE */

#endif /* PROFILE_H */
