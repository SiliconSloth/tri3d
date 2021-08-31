#ifndef MATRIX_H
#define MATRIX_H

#include "types.h"

void matrix_mul(Matrix4 *a, Matrix4 *b, Matrix4 *out);

void matrix_scale(Matrix4 *out, float x, float y, float z);
void matrix_translate(Matrix4 *out, float x, float y, float z);

void matrix_rotate_x(Matrix4 *out, float angle);
void matrix_rotate_y(Matrix4 *out, float angle);
void matrix_rotate_z(Matrix4 *out, float angle);

void matrix_perspective(Matrix4 *out, float fov, float near, float far);

#endif