#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "mersenne_twister.h"

//#define MT_MAIN 1

void mt_init(mt_state_t state, int seed)
{
  state->MT[0] = seed;
  state->index = 0;
  int i;
  for (i = 1; i < 624; i++)
  {
    uint32_t temp = (1812433253 * (state->MT[i - 1] ^ (state->MT[i - 1] >> 30))) + i;
    state->MT[i] = temp & 0xffffffff;
  }
}

void mt_generate_numbers(mt_state_t state)
{
  int i;
  int i1 = 1;
  int i397 = 397;
  for (i = 0; i < 624; i++)
  {
    uint32_t y = (state->MT[i] & 0x80000000) + (state->MT[i1] & 0x7fffffff);
    state->MT[i] = state->MT[i397] ^ (y >> 1);
    if ((y & 1) == 1)
    {
      state->MT[i] ^= 2567483615u;
    }
    i1++;
    i397++;
    if (i1 == 624) i1 = 0;
    if (i397 == 624) i397 = 0;
  }
}

uint64_t mt_get_uint64(mt_state_t state)
{
  uint64_t x = mt_get_uint32(state);
  uint64_t y = mt_get_uint32(state);
  //printf("x = %llu, y = %llu\n", x, y);
  return (x << 32) | y;
}

double mt_get_double(mt_state_t state)
{
  return (double) mt_get_uint64(state) / 18446744073709551615.0;
}

float mt_get_float(mt_state_t state)
{
  return (float) mt_get_uint32(state) / 4294967295.0f;
}

uint32_t mt_get_uint32(mt_state_t state)
{
  if (state->index == 0)
  {
    mt_generate_numbers(state);
  }
  
  uint32_t y = state->MT[state->index++];
  y ^= y >> 11;
  y ^= (y << 7) & 2636928640u;
  y ^= (y << 15) & 4022730752u;
  y ^= y >> 18;
  
  if (state->index == 624) state->index = 0;
  return y;
}

#ifdef MT_MAIN
int main(int argc, char **argv)
{
  mt_state_t state;
  mt_init(state, 1);//time(NULL));
  int i;

  for (i = 0; i < 10; i++)
    printf("%f\n", mt_get_double(state));
  return 0;

  while (1)
  {
    uint32_t n = mt_get_uint32(state);
    if (EOF == putchar((n) & 0xff)) break;
    if (EOF == putchar((n >> 8) & 0xff)) break;
    if (EOF == putchar((n >> 16) & 0xff)) break;
    if (EOF == putchar((n >> 24) & 0xff)) break;
  }
 /* 
  int expected = 5000;// * 16;
  int got = 0;
  
  for (i = 0; i < 10000; i++)
  {
    got += __builtin_popcount(mt_get_uint32(state) & 1);
  }
  printf("Error: %.2f%%", (100.0 * (got - expected)) / expected);*/
  return 0;
}
#endif
