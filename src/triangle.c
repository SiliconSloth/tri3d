#include <stdbool.h>
#include <stddef.h>

#include "dispatch.h"
#include "profile.h"
#include "triangle.h"

void compute_gradients(fixed32 y1, fixed32 a1,
					   fixed32 y2, fixed32 a2,
					   fixed32 y3, fixed32 a3,
					   fixed32 x2, fixed32 x_mid,
					   fixed32 *dade, fixed32 *dadx) {
	*dade = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(a3 - a1, y3 - y1);

	fixed32 a_mid = a1 + MUL_FX32(y2 - y1, *dade);

	*dadx = (x2 - x_mid < FIXED32(1) && x_mid - x2 < FIXED32(1)) ? 0 : DIV_FX32(a2 - a_mid, x2 - x_mid);
}

void compute_triangle_coefficients(TriangleCoeffs *coeffs, VertexInfo *v1, VertexInfo *v2, VertexInfo *v3) {
	VertexInfo temp;
	
	if (v1->y > v2->y) {
		temp = *v1;
		*v1 = *v2;
		*v2 = temp;
	}
	
	if (v2->y > v3->y) {
		temp = *v2;
		*v2 = *v3;
		*v3 = temp;

		if (v1->y > v2->y) {
			temp = *v1;
			*v1 = *v2;
			*v2 = temp;
		}
	}

	fixed32 x1 = v1->x, y1 = v1->y, z1 = v1->z;
	fixed32 x2 = v2->x, y2 = v2->y, z2 = v2->z;
	fixed32 x3 = v3->x, y3 = v3->y, z3 = v3->z;

	fixed32 dxldy = (y3 - y2 < FIXED32(1)) ? 0 : DIV_FX32(x3 - x2, y3 - y2);
	fixed32 dxmdy = (y2 - y1 < FIXED32(1)) ? 0 : DIV_FX32(x2 - x1, y2 - y1);
	fixed32 dxhdy = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(x3 - x1, y3 - y1);

	fixed32 y1_frac = y1 & 0xFFFF;
	fixed32 xh = x1 - MUL_FX32(y1_frac, dxhdy);
	fixed32 xm = x1 - MUL_FX32(y1_frac, dxmdy);

	fixed32 y2_gap = 0x4000 - (y2 & 0x3FFF);
	fixed32 xl = x2 + MUL_FX32(y2_gap, dxldy);

	bool major = MUL_FX32((x3 - x1), (y2 - y1)) - MUL_FX32((y3 - y1), (x2 - x1)) < 0;

	fixed32 x_mid = x1 + MUL_FX32(y2 - y1, dxhdy);

	fixed32 drde, dgde, dbde;
	fixed32 drdx, dgdx, dbdx;
	compute_gradients(y1, v1->r, y2, v2->r, y3, v3->r, x2, x_mid, &drde, &drdx);
	compute_gradients(y1, v1->g, y2, v2->g, y3, v3->g, x2, x_mid, &dgde, &dgdx);
	compute_gradients(y1, v1->b, y2, v2->b, y3, v3->b, x2, x_mid, &dbde, &dbdx);

	fixed32 iw1 = DIV_FX32(FIXED32(1), v1->w);
	fixed32 iw2 = DIV_FX32(FIXED32(1), v2->w);
	fixed32 iw3 = DIV_FX32(FIXED32(1), v3->w);

	fixed32 dsde, dtde;
	fixed32 dsdx, dtdx;
	fixed32 dwde, dwdx;
	compute_gradients(y1, v1->s, y2, v2->s, y3, v3->s, x2, x_mid, &dsde, &dsdx);
	compute_gradients(y1, v1->t, y2, v2->t, y3, v3->t, x2, x_mid, &dtde, &dtdx);
	compute_gradients(y1, iw1, y2, iw2, y3, iw3, x2, x_mid, &dwde, &dwdx);

	#define DEPTH_MUL 0x7C00

	fixed32 dzde, dzdx;
	compute_gradients(y1, z1, y2, z2, y3, z3, x2, x_mid, &dzde, &dzdx);

	fixed32 z = z1 - MUL_FX32(y1_frac, dzde);
	dzde *= DEPTH_MUL;
	dzdx *= DEPTH_MUL;

	fixed32 w = iw1 - MUL_FX32(y1_frac, dwde);
	dwde *= DEPTH_MUL;
	dwdx *= DEPTH_MUL;

	coeffs->major = major;

	// Round up to next subpixel
	coeffs->yl = (y3 + 0x3FFF);
	coeffs->ym = (y2 + 0x3FFF);
	coeffs->yh = y1;

	coeffs->xl = xl;
	coeffs->dxldy = dxldy;

	coeffs->xh = xh;
	coeffs->dxhdy = dxhdy;

	coeffs->xm = xm;
	coeffs->dxmdy = dxmdy;

	coeffs->red   = v1->r - MUL_FX32(y1_frac, drde);
	coeffs->green = v1->g - MUL_FX32(y1_frac, dgde);
	coeffs->blue  = v1->b - MUL_FX32(y1_frac, dbde);

	coeffs->drdx = drdx;
	coeffs->dgdx = dgdx;
	coeffs->dbdx = dbdx;

	coeffs->drde = drde;
	coeffs->dgde = dgde;
	coeffs->dbde = dbde;

	coeffs->s = v1->s - MUL_FX32(y1_frac, dsde);
	coeffs->t = v1->t - MUL_FX32(y1_frac, dtde);
	coeffs->w = w * DEPTH_MUL;

	coeffs->dsdx = dsdx;
	coeffs->dtdx = dtdx;
	coeffs->dwdx = dwdx;

	coeffs->dsde = dsde;
	coeffs->dtde = dtde;
	coeffs->dwde = dwde;

	coeffs->z = z * DEPTH_MUL;
	coeffs->dzdx = dzdx;
	coeffs->dzde = dzde;
}

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3) {
	TriangleCoeffs coeffs;
	PROFILE_START(PS_COEFFS, 0);
	compute_triangle_coefficients(&coeffs, &v1, &v2, &v3);
	PROFILE_STOP(PS_COEFFS, 0);
	load_triangle(coeffs, v1, v2, v3);
}

void normalize_vertex(VertexInfo *v) {
	v->x = DIV_FX32(v->x, v->w);
	v->y = DIV_FX32(v->y, v->w);
	v->z = DIV_FX32(v->z, v->w);

	v->s = DIV_FX32(v->s, v->w);
	v->t = DIV_FX32(v->t, v->w);
}

fixed32 interpolate(fixed32 a, fixed32 b, fixed32 p) {
	return a + MUL_FX32(b - a, p);
}

VertexInfo interpolate_vertices(VertexInfo v1, VertexInfo v2, fixed32 p) {
	VertexInfo out = {
		interpolate(v1.x, v2.x, p), interpolate(v1.y, v2.y, p), interpolate(v1.z, v2.z, p), interpolate(v1.w, v2.w, p),
		interpolate(v1.r, v2.r, p), interpolate(v1.g, v2.g, p), interpolate(v1.b, v2.b, p), interpolate(v1.b, v2.a, p),
		interpolate(v1.s, v2.s, p), interpolate(v1.t, v2.t, p)
	};
	return out;
}

#define UPWARD 0
#define DOWNWARD 1
#define FLAT_ABOVE 2
#define FLAT_BELOW 3

uint8_t intersect_1d(fixed32 x1, fixed32 w1, fixed32 x2, fixed32 w2, fixed32 intersect_x, fixed32 *p) {
	fixed32 d1 = x1 - MUL_FX32(w1, intersect_x);
	fixed32 d2 = x2 - MUL_FX32(w2, intersect_x);

	if (d1 - d2 < 0x10 && d2 - d1 < 0x10) {
		return d1 > 0? FLAT_ABOVE : FLAT_BELOW;
	}

	*p = DIV_FX32(d1, d1 - d2);
	return d2 > d1? UPWARD : DOWNWARD;
}

void clip_axis(fixed32 x1, fixed32 w1, fixed32 x2, fixed32 w2, fixed32 clip_x, bool keep_greater, fixed32 *p1, fixed32 *p2) {
	fixed32 p;
	uint8_t direction = intersect_1d(x1, w1, x2, w2, clip_x, &p);

	if (direction == FLAT_ABOVE || direction == FLAT_BELOW) {
		if ((direction == FLAT_ABOVE) != keep_greater) {
			*p1 = 2;
			*p2 = -1;
		}
	} else if ((direction == UPWARD) != keep_greater) {
		if (p < *p2) {
			*p2 = p;
		}
	} else if (p > *p1) {
		*p1 = p;
	}
}

void clip_line(VertexInfo v1, VertexInfo v2, Box box, fixed32 *p1, fixed32 *p2) {
	*p1 = FIXED32(0);
	*p2 = FIXED32(1);

	// TODO: Must add intersections with edges of clip box to support multi-axis clipping

	// clip_axis(v1.x, v1.w, v2.x, v2.w, box.min_x, true, p1, p2);
	// clip_axis(v1.x, v1.w, v2.x, v2.w, box.max_x, false, p1, p2);

	// clip_axis(v1.y, v1.w, v2.y, v2.w, box.min_y, true, p1, p2);
	// clip_axis(v1.y, v1.w, v2.y, v2.w, box.max_y, false, p1, p2);

	clip_axis(v1.z, v1.w, v2.z, v2.w, box.min_z, true, p1, p2);
	clip_axis(v1.z, v1.w, v2.z, v2.w, box.max_z, false, p1, p2);
}

void clip_edge(VertexInfo v1, VertexInfo v2, Box box, VertexInfo *out_verts, size_t *out_count, bool keep_1, bool keep_2, bool *kept_1, bool *kept_2) {
	fixed32 p1, p2;
	clip_line(v1, v2, box, &p1, &p2);

	*kept_1 = false;
	*kept_2 = false;
	if (p1 < p2) {
		if (p1 == FIXED32(0)) {
			if (keep_1) {
				out_verts[(*out_count)++] = v1;
				*kept_1 = true;
			}
		} else {
			out_verts[(*out_count)++] = interpolate_vertices(v1, v2, p1);
		}

		if (p2 == FIXED32(1)) {
			if (keep_2) {
				out_verts[(*out_count)++] = v2;
				*kept_2 = true;
			}
		} else {
			out_verts[(*out_count)++] = interpolate_vertices(v1, v2, p2);
		}
	}
}

size_t clip_triangle(VertexInfo v1, VertexInfo v2, VertexInfo v3, Box box, VertexInfo *out_verts) {
	size_t out_count = 0;
	bool kept_v1, kept_last, kept_dummy;

	clip_edge(v1, v2, box, out_verts, &out_count, true,       true,     &kept_v1,    &kept_last);
	clip_edge(v2, v3, box, out_verts, &out_count, !kept_last, true,     &kept_dummy, &kept_last);
	clip_edge(v3, v1, box, out_verts, &out_count, !kept_last, !kept_v1, &kept_dummy, &kept_dummy);

	return out_count;
}

void load_triangle_clipped(VertexInfo v1, VertexInfo v2, VertexInfo v3, Box box) {
	PROFILE_START(PS_CLIP, 0);
	VertexInfo clipped_verts[16];
	size_t num_clipped = clip_triangle(v1, v2, v3, box, clipped_verts);
	
	for (int i = 0; i < num_clipped; i++) {
		normalize_vertex(clipped_verts + i);
	}

	PROFILE_STOP(PS_CLIP, 0);
	if (num_clipped >= 3) {
		for (int i = 1; i < num_clipped - 1; i++) {
			load_triangle_verts(clipped_verts[0], clipped_verts[i], clipped_verts[i + 1]);
		}
	}
}

Vector3 sub_vectors(Vector3 a, Vector3 b) {
	Vector3 out = {
		a.x - b.x,
		a.y - b.y,
		a.z - b.z
	};
	return out;
}

Vector3 cross_product(Vector3 a, Vector3 b) {
	Vector3 out = {
		MUL_FX32(a.y, b.z) - MUL_FX32(a.z, b.y),
		MUL_FX32(a.z, b.x) - MUL_FX32(a.x, b.z),
		MUL_FX32(a.x, b.y) - MUL_FX32(a.y, b.x)
	};
	return out;
}

fixed32 dot_product(Vector3 a, Vector3 b) {
	return MUL_FX32(a.x, b.x) + MUL_FX32(a.y, b.y) + MUL_FX32(a.z, b.z);
}

bool reject_point_axis(fixed32 x, fixed32 w, fixed32 cull_x, bool keep_greater) {
	fixed32 d = x - MUL_FX32(w, cull_x);
	if (d == 0) {
		return false;
	} else {
		return (d > 0) != keep_greater;
	}
}

bool reject_triangle_axis(fixed32 x1, fixed32 w1, fixed32 x2, fixed32 w2, fixed32 x3, fixed32 w3, fixed32 cull_x, bool keep_greater) {
	return reject_point_axis(x1, w1, cull_x, keep_greater) && reject_point_axis(x2, w2, cull_x, keep_greater) && reject_point_axis(x3, w3, cull_x, keep_greater);
}

bool reject_triangle(VertexInfo v1, VertexInfo v2, VertexInfo v3, Box box) {
	return reject_triangle_axis(v1.x, v1.w, v2.x, v2.w, v3.x, v3.w, box.min_x, true) ||
		   reject_triangle_axis(v1.x, v1.w, v2.x, v2.w, v3.x, v3.w, box.max_x, false) ||
		   reject_triangle_axis(v1.y, v1.w, v2.y, v2.w, v3.y, v3.w, box.min_y, true) ||
		   reject_triangle_axis(v1.y, v1.w, v2.y, v2.w, v3.y, v3.w, box.max_y, false) ||
		   reject_triangle_axis(v1.z, v1.w, v2.z, v2.w, v3.z, v3.w, box.min_z, true) ||
		   reject_triangle_axis(v1.z, v1.w, v2.z, v2.w, v3.z, v3.w, box.max_z, false);
}

void load_triangle_culled(VertexInfo v1, VertexInfo v2, VertexInfo v3, Box box, fixed32 camera_z) {
	PROFILE_START(PS_FRUSTUM, 0);
	if (reject_triangle(v1, v2, v3, box)) {
		PROFILE_STOP(PS_FRUSTUM, 0);
		return;
	}
	PROFILE_STOP(PS_FRUSTUM, 0);
	PROFILE_START(PS_BACKFACE, 0);

	#define CULL_DIV 128

	Vector3 p1 = {v1.x / CULL_DIV, v1.y / CULL_DIV, v1.z / CULL_DIV};
	Vector3 p2 = {v2.x / CULL_DIV, v2.y / CULL_DIV, v2.z / CULL_DIV};
	Vector3 p3 = {v3.x / CULL_DIV, v3.y / CULL_DIV, v3.z / CULL_DIV};

	Vector3 normal = cross_product(sub_vectors(p2, p1), sub_vectors(p3, p1));
	p1.z -= camera_z / CULL_DIV;
	fixed32 dp = dot_product(p1, normal);

	PROFILE_STOP(PS_BACKFACE, 0);
	if (dp <= FIXED32(0)) {
		load_triangle_clipped(v1, v2, v3, box);
	}
}