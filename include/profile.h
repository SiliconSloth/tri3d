#ifndef PROFILE_H
#define PROFILE_H

#include <stdint.h>

#define COUNTS_PER_SECOND (93750000/2)

extern uint64_t start_time;
extern uint64_t cpu_time;
extern uint64_t rdp_time;

extern uint64_t total_cpu_time;
extern uint64_t total_rdp_time;
extern uint64_t num_samples;

extern uint64_t transform_start;
extern uint64_t transform_time;
extern uint64_t load_start;
extern uint64_t load_time;

extern uint64_t prep_start;
extern uint64_t prep_time;
extern uint64_t matrix_start;
extern uint64_t matrix_time;
extern uint64_t vertex_start;
extern uint64_t vertex_time;

#endif