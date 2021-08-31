#include <math.h>

#include "dispatch.h"
#include "matrix.h"

#define LOAD_MATRIX(m, m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33)  \
	(m)[0][0] = FIXED32(m00); (m)[0][1] = FIXED32(m01); (m)[0][2] = FIXED32(m02); (m)[0][3] = FIXED32(m03); \
	(m)[1][0] = FIXED32(m10); (m)[1][1] = FIXED32(m11); (m)[1][2] = FIXED32(m12); (m)[1][3] = FIXED32(m13); \
	(m)[2][0] = FIXED32(m20); (m)[2][1] = FIXED32(m21); (m)[2][2] = FIXED32(m22); (m)[2][3] = FIXED32(m23); \
	(m)[3][0] = FIXED32(m30); (m)[3][1] = FIXED32(m31); (m)[3][2] = FIXED32(m32); (m)[3][3] = FIXED32(m33);

void matrix_mul(Matrix4 *a, Matrix4 *b, Matrix4 *out) {
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			poll_rdp();
			fixed32 sum = FIXED32(0);
			for (int k = 0; k < 4; k++) {
				sum += MUL_FX32(a->m[k][i], b->m[j][k]);
			}
			out->m[j][i] = sum;
		}
	}
}

void matrix_scale(Matrix4 *out, float x, float y, float z) {
    LOAD_MATRIX(out->m,
		x, 0, 0, 0,
		0, y, 0, 0,
		0, 0, z, 0,
		0, 0, 0, 1
	)
}

void matrix_translate(Matrix4 *out, float x, float y, float z) {
    LOAD_MATRIX(out->m,
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		x, y, z, 1
	)
}

void matrix_rotate_x(Matrix4 *out, float angle) {
	float sin = sinf(angle);
	float cos = cosf(angle);

	LOAD_MATRIX(out->m,
		1,    0,   0, 0,
		0,  cos, sin, 0,
		0, -sin, cos, 0,
		0,    0,   0, 1
	)
}

void matrix_rotate_y(Matrix4 *out, float angle) {
	float sin = sinf(angle);
	float cos = cosf(angle);

	LOAD_MATRIX(out->m,
		 cos, 0, sin, 0,
		   0, 1,   0, 0,
		-sin, 0, cos, 0,
		   0, 0,   0, 1
	)
}

void matrix_rotate_z(Matrix4 *out, float angle) {
	float sin = sinf(angle);
	float cos = cosf(angle);

	LOAD_MATRIX(out->m,
		 cos, sin, 0, 0,
		-sin, cos, 0, 0,
		   0,   0, 1, 0,
		   0,   0, 0, 1
	)
}

void matrix_perspective(Matrix4 *out, float fov, float near, float far) {
	float hs = 1.f / tanf(fov / 2);
	LOAD_MATRIX(out->m,
		hs,  0, 					    0, 0,
		 0, hs,        				    0, 0,
		 0,  0,      -near / (far - near), 1,
		 0,  0, far * near / (far - near), 0
	)
}