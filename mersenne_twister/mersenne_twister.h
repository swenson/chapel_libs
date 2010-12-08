#include <stdint.h>

typedef struct mt_state_s {
  uint32_t MT[624];
  int index;
} mt_state_s;

typedef mt_state_s mt_state_t[1];

void mt_init(mt_state_t state, int seed);
uint32_t mt_get_uint32(mt_state_t state);
uint64_t mt_get_uint64(mt_state_t state);
double mt_get_double(mt_state_t state);
float mt_get_float(mt_state_t state);

