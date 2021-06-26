/*
 * No copyright is granted
 */

/******************************************************************************
 * @file     main.c
 * @brief    CHORD test
 * @version  V1.0
 * @date     25. Jan 2021
 ******************************************************************************/

#include "drv_chord.h"
#include <stdio.h>
#include <stdlib.h>

void print_int16_t(int16_t x) {
  uint16_t sign_x = (x < 0);
  uint16_t uint_x = sign_x ? 65536 - ((uint16_t)x) : x;
  if (sign_x)
    printf("-");
  printf("%d", (uint_x >> 8) & 0xFF);
  printf(".");
  uint_x = uint_x & 0xFF;
  for (int i = 0; i < 4; i = i + 1) {
    uint_x = uint_x * 10;
    printf("%d", (uint_x & 0x0F00) >> 8);
    uint_x = uint_x & 0xFF;
  }
}

int main(void) {
  int16_t deg[181];
  int16_t arctan[101];
  int16_t c_cos[181];
  int16_t c_sin[181];
  int16_t arctan_deg[101];
  for (int i = 0; i < 181; i = i + 1)
    deg[i] = (i - 90) << 8;
  for (int i = 0; i < 101; i = i + 1)
    arctan[i] = (i - 50) << 6;
  printf("Begin CHORD test...\n");
  printf("Test I: non continuous sin/cos evaluation\n");
  for (int i = 0; i < 181; i = i + 1)
    c_cos[i] = chord_cos(deg[i]);
  for (int i = 0; i < 181; i = i + 1)
    c_sin[i] = chord_sin(deg[i]);
  for (int i = 0; i < 181; i = i + 1) {
    printf("cos, sin %d: ", deg[i] >> 8);
    print_int16_t(c_cos[i]);
    printf(", ");
    print_int16_t(c_sin[i]);
    printf("\n");
  }

  printf("Test II: continuous sin/cos evaluation\n");
  for (int i = 0; i < 181; i = i + 1)
    c_cos[i] = 0;
  for (int i = 0; i < 181; i = i + 1)
    c_sin[i] = 0;
  chord_cos_sin_v(deg, c_cos, c_sin, 181);
  for (int i = 0; i < 181; i = i + 1) {
    printf("cos, sin %d: ", deg[i] >> 8);
    print_int16_t(c_cos[i]);
    printf(", ");
    print_int16_t(c_sin[i]);
    printf("\n");
  }

  printf("Test III: non continuous arctan evaluation\n");
  for (int i = 0; i < 101; i = i + 1)
    arctan_deg[i] = chord_arctan(arctan[i]);
  for (int i = 0; i < 101; i = i + 1) {
    printf("arctan ");
    print_int16_t(arctan[i]);
    printf(": ");
    print_int16_t(arctan_deg[i]);
    printf("\n");
  }

  printf("Test IV: continuous arctan evaluation\n");
  chord_arctan_v(arctan, arctan_deg, 101);
  for (int i = 0; i < 101; i = i + 1) {
    printf("arctan ");
    print_int16_t(arctan[i]);
    printf(": ");
    print_int16_t(arctan_deg[i]);
    printf("\n");
  }
}
