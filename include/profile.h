#ifndef PROFILE_H
#define PROFILE_H

#include <stdbool.h>
#include <stdint.h>

#define COUNTS_PER_SECOND (93750000/2)

typedef struct {
    bool  running;
	uint32_t start_time;
	uint32_t total_time;
	uint32_t num_samples;
} Profiler;

void profiler_reset(Profiler *profiler);
void profiler_start(Profiler *profiler);
void profiler_stop(Profiler *profiler);
uint32_t profiler_average_time(Profiler *profiler);

extern Profiler frame_profiler;
extern Profiler cpu_profiler;
extern Profiler rdp_profiler;

extern Profiler cube_profiler;

extern Profiler transform_profiler;
extern Profiler triangle_profiler;

extern Profiler collate_profiler;
extern Profiler frustum_profiler;
extern Profiler backface_profiler;
extern Profiler clip_profiler;
extern Profiler coeffs_profiler;
extern Profiler load_profiler;

extern Profiler null_profiler;

#endif