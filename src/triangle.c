#include <stdbool.h>

#include "dispatch.h"
#include "triangle.h"

int32_t debug_xs[4096];
int32_t debug_ys[4096];
uint32_t num_debug = 0;

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

void load_triangle_verts(VertexInfo v1, VertexInfo v2, VertexInfo v3) {
	TriangleCoeffs coeffs;
	debug_xs[num_debug] = v1.x / 65536;
	debug_ys[num_debug] = v1.y / 65536;
	num_debug++;
	debug_xs[num_debug] = v2.x / 65536;
	debug_ys[num_debug] = v2.y / 65536;
	num_debug++;
	debug_xs[num_debug] = v3.x / 65536;
	debug_ys[num_debug] = v3.y / 65536;
	num_debug++;
	compute_triangle_coefficients(&coeffs, v1, v2, v3);
	load_triangle(coeffs);
}