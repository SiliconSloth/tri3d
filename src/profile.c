#include <libdragon.h>

#include "profile.h"

Profiler frame_profiler;
Profiler cpu_profiler;
Profiler rdp_profiler;

Profiler cube_profiler;

Profiler transform_profiler;
Profiler triangle_profiler;

Profiler collate_profiler;
Profiler frustum_profiler;
Profiler backface_profiler;
Profiler clip_profiler;
Profiler coeffs_profiler;
Profiler load_profiler;

Profiler null_profiler;

void profiler_reset(Profiler *profiler) {
    profiler->total_time = 0;
    profiler->num_samples = 0;
    profiler->running = false;
}

void profiler_start(Profiler *profiler) {
    profiler->start_time = timer_ticks();
    profiler->running = true;
}

void profiler_stop(Profiler *profiler) {
    if (profiler->running) {
        profiler->total_time += timer_ticks() - profiler->start_time;
        profiler->num_samples++;
        profiler->running = false;
    }
}

uint32_t profiler_average_time(Profiler *profiler) {
    return profiler->total_time / profiler->num_samples;
}