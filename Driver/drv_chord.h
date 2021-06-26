/*
 * No copyright is granted
 */


/******************************************************************************
 * @file     drv_chord.h
 * @brief    header file for CHORD
 * @version  V1.0
 * @date     25. June 2021
 ******************************************************************************/

#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
void chord_cos_sin_v(int16_t *deg, int16_t *c_cos, int16_t *c_sin, int length);
void chord_arctan_v(int16_t *arctan, int16_t *deg, int length);
int16_t chord_sin(int16_t deg);
int16_t chord_cos(int16_t deg);
int16_t chord_arctan(int16_t tan);
#ifdef __cplusplus
}
#endif
