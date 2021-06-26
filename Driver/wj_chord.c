/*
 * No copyright is granted
 */


/******************************************************************************
 * @file     wj_chord.c
 * @brief    Source File for CHORD Driver
 * @version  V1.0
 * @date     25. June 2021
 ******************************************************************************/

#include <drv_chord.h>

#define CHORD_IN_ADDR  0x40010004
#define CHORD_OUT_ADDR 0x40010004
#define CHORD_SIG_ADDR 0x40010000
#define CHORD_BUFFER_SIZE 512

void chord_cos_sin_v(int16_t *deg, int16_t *c_cos, int16_t *c_sin, int length) {
  for (int i = 0; i < length; i = i + 1) {
    *(volatile uint32_t *)CHORD_IN_ADDR =
        ((uint32_t) * (deg + i)) & (0x0000FFFF);
  }
  uint32_t sig = 0;
  while (!sig)
    sig = *(volatile uint32_t *)CHORD_SIG_ADDR;
  uint32_t tmp;
  for (int i = 0; i < length; i = i + 1) {
    tmp = *(volatile uint32_t *)CHORD_OUT_ADDR;
    *(c_cos + i) = (int16_t)(tmp & 0xFFFF);
    *(c_sin + i) = (int16_t)((tmp >> 16) & 0xFFFF);
  }
}

void chord_arctan_v(int16_t *arctan, int16_t *deg, int length) {
  for (int i = 0; i < length; i = i + 1) {
    *(volatile uint32_t *)CHORD_IN_ADDR =
        (((uint32_t) * (arctan + i)) & (0x0000FFFF)) | 0x00010000;
  }
  uint32_t sig = 0;
  while (!sig)
    sig = *(volatile uint32_t *)CHORD_SIG_ADDR;
  uint32_t tmp;
  for (int i = 0; i < length; i = i + 1) {
    tmp = *(volatile uint32_t *)CHORD_OUT_ADDR;
    *(deg + i) = (int16_t)(tmp & 0xFFFF);
  }
}

int16_t chord_sin(int16_t deg) {
  *(volatile uint32_t *)CHORD_IN_ADDR = ((uint32_t)deg) & (0x0000FFFF);
  uint32_t sig = 0;
  while (!sig)
    sig = *(volatile uint32_t *)CHORD_SIG_ADDR;
  uint32_t cos_sin = *(volatile uint32_t *)CHORD_OUT_ADDR;
  int16_t sin_deg = (int16_t)((cos_sin >> 16) & 0xffff);
  return sin_deg;
}

int16_t chord_cos(int16_t deg) {
  *(volatile uint32_t *)CHORD_IN_ADDR = ((uint32_t)deg) & (0x0000FFFF);
  uint32_t sig = 0;
  while (!sig)
    sig = *(volatile uint32_t *)CHORD_SIG_ADDR;
  uint32_t cos_sin = *(volatile uint32_t *)CHORD_OUT_ADDR;
  int16_t cos_deg = (int16_t)(cos_sin & 0xffff);
  return cos_deg;
}

int16_t chord_arctan(int16_t tan) {
  *(volatile uint32_t *)CHORD_IN_ADDR =
      ((((uint32_t)tan) & (0x0000FFFF)) | (0x00010000));
  uint32_t sig = 0;
  while (!sig)
    sig = *(volatile uint32_t *)CHORD_SIG_ADDR;
  int16_t arctan = (int16_t)((*(volatile uint32_t *)CHORD_OUT_ADDR) & 0xFFFF);
  return arctan;
}
