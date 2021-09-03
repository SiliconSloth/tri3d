#include <stdbool.h>

#include "dispatch.h"
#include "triangle.h"

int32_t debug_xs[4096];
int32_t debug_ys[4096];
uint32_t num_debug = 0;

fixed32 min_v;
fixed32 max_v;

void compute_gradients(fixed32 y1, fixed32 a1,
					   fixed32 y2, fixed32 a2,
					   fixed32 y3, fixed32 a3,
					   fixed32 x2, fixed32 x_mid,
					   fixed32 *dade, fixed32 *dadx) {
	*dade = (y3 - y1 < FIXED32(1)) ? 0 : DIV_FX32(a3 - a1, y3 - y1);

	fixed32 a_mid = a1 + MUL_FX32(y2 - y1, *dade);

	*dadx = (x2 - x_mid < FIXED32(1) && x_mid - x2 < FIXED32(1)) ? 0 : DIV_FX32(a2 - a_mid, x2 - x_mid);
}

void compute_triangle_coefficients(TriangleCoeffs *coeffs, VertexInfo v1, VertexInfo v2, VertexInfo v3) {
	VertexInfo temp;
	
	if (v1.y > v2.y) {
		temp = v1;
		v1 = v2;
		v2 = temp;
	}
	
	if (v2.y > v3.y) {
		temp = v2;
		v2 = v3;
		v3 = temp;

		if (v1.y > v2.y) {
			temp = v1;
			v1 = v2;
			v2 = temp;
		}
	}

	fixed32 x1 = v1.x, y1 = v1.y, z1 = v1.z;
	fixed32 x2 = v2.x, y2 = v2.y, z2 = v2.z;
	fixed32 x3 = v3.x, y3 = v3.y, z3 = v3.z;

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
	compute_gradients(y1, v1.r, y2, v2.r, y3, v3.r, x2, x_mid, &drde, &drdx);
	compute_gradients(y1, v1.g, y2, v2.g, y3, v3.g, x2, x_mid, &dgde, &dgdx);
	compute_gradients(y1, v1.b, y2, v2.b, y3, v3.b, x2, x_mid, &dbde, &dbdx);

	fixed32 dsde, dtde;
	fixed32 dsdx, dtdx;
	compute_gradients(y1, v1.s, y2, v2.s, y3, v3.s, x2, x_mid, &dsde, &dsdx);
	compute_gradients(y1, v1.t, y2, v2.t, y3, v3.t, x2, x_mid, &dtde, &dtdx);

	#define DEPTH_MUL 0x7C00

	fixed32 dzde, dzdx;
	compute_gradients(y1, z1, y2, z2, y3, z3, x2, x_mid, &dzde, &dzdx);

	fixed32 z = z1 - MUL_FX32(y1_frac, dzde);
	dzde *= DEPTH_MUL;
	dzdx *= DEPTH_MUL;

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

	coeffs->red   = v1.r - MUL_FX32(y1_frac, drde);
	coeffs->green = v1.g - MUL_FX32(y1_frac, dgde);
	coeffs->blue  = v1.b - MUL_FX32(y1_frac, dbde);

	coeffs->drdx = drdx;
	coeffs->dgdx = dgdx;
	coeffs->dbdx = dbdx;

	coeffs->drde = drde;
	coeffs->dgde = dgde;
	coeffs->dbde = dbde;

	coeffs->drdy = 0;
	coeffs->dgdy = 0;
	coeffs->dbdy = 0;

	coeffs->s = v1.s - MUL_FX32(y1_frac, dsde);
	coeffs->t = v1.t - MUL_FX32(y1_frac, dtde);
	coeffs->w = z * DEPTH_MUL;

	coeffs->dsdx = dsdx;
	coeffs->dtdx = dtdx;
	coeffs->dwdx = dzdx;

	coeffs->dsde = dsde;
	coeffs->dtde = dtde;
	coeffs->dwde = dzde;

	coeffs->dsdy = 0;
	coeffs->dtdy = 0;
	coeffs->dwdy = 0;

	coeffs->z = (FIXED32(1) - z) * DEPTH_MUL;
	coeffs->dzdx = -dzdx;
	coeffs->dzde = -dzde;
	coeffs->dzdy = 0;
}

void normalize_vertex(VertexInfo *v) {
	v->x = DIV_FX32(v->x, v->w);
	v->y = DIV_FX32(v->y, v->w);
	v->z = DIV_FX32(v->z, v->w);

	v->s = MUL_FX32(v->s, v->z);
	v->t = MUL_FX32(v->t, v->z);
}

fixed32 intersect_1d(fixed32 x1, fixed32 w1, fixed32 x2, fixed32 w2, fixed32 intersect_x, bool *upward) {
	fixed32 d1 = x1 - MUL_FX32(w1, intersect_x);
	fixed32 d2 = x2 - MUL_FX32(w2, intersect_x);

	*upward = d2 > d1;

	if (d1 == d2) {
		return d1 > 0? FIXED32(2) : FIXED32(-1);
	}

	return DIV_FX32(d1, d1 - d2);
}

void clip_axis(fixed32 x1, fixed32 w1, fixed32 x2, fixed32 w2, fixed32 clip_x, bool keep_greater, fixed32 *p1, fixed32 *p2) {
	bool upward;
	fixed32 p = intersect_1d(x1, w1, x2, w2, clip_x, &upward);
	if (upward != keep_greater) {
		if (p < *p2) {
			*p2 = p;
		}
	} else if (p > *p1) {
		*p1 = p;
	}
}

void clip_line(VertexInfo v1, VertexInfo v2, fixed32 *p1, fixed32 *p2,
		fixed32 min_x, fixed32 max_x, fixed32 min_y, fixed32 max_y, fixed32 min_z, fixed32 max_z) {
	*p1 = FIXED32(0);
	*p2 = FIXED32(1);

	clip_axis(v1.x, v1.w, v2.x, v2.w, min_x, true, p1, p2);
	clip_axis(v1.x, v1.w, v2.x, v2.w, max_x, false, p1, p2);

	clip_axis(v1.y, v1.w, v2.y, v2.w, min_y, true, p1, p2);
	clip_axis(v1.y, v1.w, v2.y, v2.w, max_y, false, p1, p2);

	clip_axis(v1.z, v1.w, v2.z, v2.w, min_z, true, p1, p2);
	clip_axis(v1.z, v1.w, v2.z, v2.w, max_z, false, p1, p2);
}

fixed32 interpolate(fixed32 a, fixed32 b, fixed32 p) {
	return a + MUL_FX32(b - a, p);
}

VertexInfo interpolate_vertices(VertexInfo v1, VertexInfo v2, fixed32 p) {
	VertexInfo out = {
		interpolate(v1.x, v2.x, p), interpolate(v1.y, v2.y, p), interpolate(v1.z, v2.z, p), interpolate(v1.w, v2.w, p),
		interpolate(v1.r, v2.r, p), interpolate(v1.g, v2.g, p), interpolate(v1.b, v2.b, p),
		interpolate(v1.s, v2.s, p), interpolate(v1.t, v2.t, p)
	};
	return out;
}

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3) {
	TriangleCoeffs coeffs;
	compute_triangle_coefficients(&coeffs, v1, v2, v3);
	load_triangle(coeffs);
}

void load_triangle_clipped(VertexInfo v1, VertexInfo v2, VertexInfo v3,
		fixed32 min_x, fixed32 max_x, fixed32 min_y, fixed32 max_y, fixed32 min_z, fixed32 max_z) {
	fixed32 p1, p2;
	clip_line(v1, v2, &p1, &p2, min_x, max_x, min_y, max_y, min_z, max_z);

	if (p2 > p1) {
		VertexInfo c1 = interpolate_vertices(v1, v2, p1);
		VertexInfo c2 = interpolate_vertices(v1, v2, p2);

		normalize_vertex(&c1);
		normalize_vertex(&c2);

		fixed32 val = p1;
		if (val < min_v) {
			min_v = val;
		}
		if (val > max_v) {
			max_v = val;
		}

		debug_xs[num_debug] = c1.x / 65536;
		debug_ys[num_debug] = c1.y / 65536;
		num_debug++;
		debug_xs[num_debug] = c2.x / 65536;
		debug_ys[num_debug] = c2.y / 65536;
		num_debug++;
	}

	normalize_vertex(&v1);
	normalize_vertex(&v2);
	normalize_vertex(&v3);

	load_triangle_verts(v1, v2, v3);
}