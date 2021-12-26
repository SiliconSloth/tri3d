.macro StoreY, yp_a, y_i, y_f, tmp0, tmp1
    Mul_ifci_i tmp0, const_4, y_i, y_f, tmp1
    Store yp_a, tmp0
.endmacro

.macro ComputeCoeffs, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, tmp22, tmp23, tmp24, tmp25, tmp26
    x1_i equ tmp0
    Load x1_i, V_x, 0, 0
    x1_f equ tmp1
    Load x1_f, V_x, 1, 0
    x2_i equ tmp2
    Load x2_i, V_x, 0, 1
    x2_f equ tmp3
    Load x2_f, V_x, 1, 1
    x3_i equ tmp4
    Load x3_i, V_x, 0, 2
    x3_f equ tmp5
    Load x3_f, V_x, 1, 2
    y1_i equ tmp6
    Load y1_i, V_y, 0, 0
    y1_f equ tmp7
    Load y1_f, V_y, 1, 0
    y2_i equ tmp8
    Load y2_i, V_y, 0, 1
    y2_f equ tmp9
    Load y2_f, V_y, 1, 1
    y3_i equ tmp10
    Load y3_i, V_y, 0, 2
    y3_f equ tmp11
    Load y3_f, V_y, 1, 2
    StoreY C_yh, y1_i, y1_f, tmp12, tmp13
    dx32_i equ tmp12
    dx32_f equ tmp13
    Sub_ifif dx32_i, dx32_f, x3_i, x3_f, x2_i, x2_f
    dy32_i equ tmp14
    dy32_f equ tmp15
    Sub_ifif dy32_i, dy32_f, y3_i, y3_f, y2_i, y2_f
    dxldy_i equ tmp16
    dxldy_f equ tmp17
    Div_ifif dxldy_i, dxldy_f, dx32_i, dx32_f, dy32_i, dy32_f, tmp18, tmp19
    LTE_cond_ii dy32_i, zeros, tmp12
    Select dxldy_i, zeros, dxldy_i
    Select dxldy_f, zeros, dxldy_f
    Store C_dxldy_i, dxldy_i
    Store C_dxldy_f, dxldy_f
    dx21_i equ tmp12
    dx21_f equ tmp13
    Sub_ifif dx21_i, dx21_f, x2_i, x2_f, x1_i, x1_f
    dy21_i equ tmp14
    dy21_f equ tmp15
    Sub_ifif dy21_i, dy21_f, y2_i, y2_f, y1_i, y1_f
    dxmdy_i equ tmp18
    dxmdy_f equ tmp19
    Div_ifif dxmdy_i, dxmdy_f, dx21_i, dx21_f, dy21_i, dy21_f, tmp20, tmp21
    LTE_cond_ii dy21_i, zeros, tmp20
    Select dxmdy_i, zeros, dxmdy_i
    Select dxmdy_f, zeros, dxmdy_f
    Store C_dxmdy_i, dxmdy_i
    Store C_dxmdy_f, dxmdy_f
    dx31_i equ tmp20
    dx31_f equ tmp21
    Sub_ifif dx31_i, dx31_f, x3_i, x3_f, x1_i, x1_f
    dy31_i equ tmp4
    dy31_f equ tmp5
    Sub_ifif dy31_i, dy31_f, y3_i, y3_f, y1_i, y1_f
    dxhdy_i equ tmp6
    dxhdy_f equ tmp22
    Div_ifif dxhdy_i, dxhdy_f, dx31_i, dx31_f, dy31_i, dy31_f, tmp23, tmp24
    LTE_cond_ii dy31_i, zeros, tmp23
    Select dxhdy_i, zeros, dxhdy_i
    Select dxhdy_f, zeros, dxhdy_f
    Store C_dxhdy_i, dxhdy_i
    Store C_dxhdy_f, dxhdy_f
    oxh_i equ tmp23
    oxh_f equ tmp24
    Mul_fif oxh_i, oxh_f, y1_f, dxhdy_i, dxhdy_f
    xh_i equ tmp25
    xh_f equ tmp26
    Sub_ifif xh_i, xh_f, x1_i, x1_f, oxh_i, oxh_f
    Store C_xh_i, xh_i
    Store C_xh_f, xh_f
    oxm_i equ tmp23
    oxm_f equ tmp24
    Mul_fif oxm_i, oxm_f, y1_f, dxmdy_i, dxmdy_f
    xm_i equ tmp18
    xm_f equ tmp19
    Sub_ifif xm_i, xm_f, x1_i, x1_f, oxm_i, oxm_f
    Store C_xm_i, xm_i
    Store C_xm_f, xm_f
    yl_i equ tmp18
    yl_f equ tmp19
    Add_ifcf yl_i, yl_f, y_mask, y3_i, y3_f
    StoreY C_yl, yl_i, yl_f, tmp10, tmp11
    ym_i equ tmp10
    ym_f equ tmp11
    Add_ifcf ym_i, ym_f, y_mask, y2_i, y2_f
    StoreY C_ym, ym_i, ym_f, tmp8, tmp18
    y2gn equ tmp8
    BitAnd_c y2gn, y_mask, y2_f
    y2_gap equ tmp9
    Sub_cff y2_gap, max_gap, y2gn
    oxl_i equ tmp8
    oxl_f equ tmp10
    Mul_fif oxl_i, oxl_f, y2_gap, dxldy_i, dxldy_f
    xl_i equ tmp9
    xl_f equ tmp11
    Add_ifif xl_i, xl_f, x2_i, x2_f, oxl_i, oxl_f
    Store C_xl_i, xl_i
    Store C_xl_f, xl_f
    dx31dy21_i equ tmp8
    dx31dy21_f equ tmp9
    Mul_ifif dx31dy21_i, dx31dy21_f, dx31_i, dx31_f, dy21_i, dy21_f
    dy31dx21_i equ tmp10
    dy31dx21_f equ tmp11
    Mul_ifif dy31dx21_i, dy31dx21_f, dy31_i, dy31_f, dx21_i, dx21_f
    LT_cond_ifif dy31dx21_i, dy31dx21_f, dx31dy21_i, dx31dy21_f, tmp12
    header equ tmp8
    Select_c header, maj_bit, zeros
    Add_ici header, command, header
    Store C_header, header

    sqv header[0],  32(r0)
.endmacro