.macro StoreY, yp_a, y_i, y_f, tmp0, tmp1
    Mul_ifci_i tmp0, const_4, y_i, y_f, tmp1
    Store yp_a, tmp0
.endmacro

.macro ComputeAttr, a_a, sa_i_a, sa_f_a, dade_i_a, dade_f_a, dadx_i_a, dadx_f_a, dy31_i, dy31_f, dy21_i, dy21_f, mid_width_i, mid_width_f, y1_frac, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9
    Load tmp0, a_a, 0, 0
    Load tmp1, a_a, 1, 0
    Load tmp2, a_a, 0, 2
    Load tmp3, a_a, 1, 2
    Sub_ifif tmp4, tmp5, tmp2, tmp3, tmp0, tmp1
    Div_ifif tmp2, tmp3, tmp4, tmp5, dy31_i, dy31_f, tmp6, tmp7
    LTE_cond_ii dy31_i, zeros, tmp4
    Select tmp2, zeros, tmp2
    Select tmp3, zeros, tmp3
    Store dade_i_a, tmp2
    Store dade_f_a, tmp3
    Mul_ifif tmp4, tmp5, dy21_i, dy21_f, tmp2, tmp3
    Add_ifif tmp6, tmp7, tmp0, tmp1, tmp4, tmp5
    Load tmp4, a_a, 0, 1
    Load tmp5, a_a, 1, 1
    Sub_ifif tmp8, tmp9, tmp4, tmp5, tmp6, tmp7
    Div_ifif tmp4, tmp5, tmp8, tmp9, mid_width_i, mid_width_f, tmp6, tmp7
    Store dadx_i_a, tmp4
    Store dadx_f_a, tmp5
    Mul_fif tmp4, tmp5, y1_frac, tmp2, tmp3
    Sub_ifif tmp2, tmp3, tmp0, tmp1, tmp4, tmp5
    Store sa_i_a, tmp2
    Store sa_f_a, tmp3
.endmacro

.macro ComputeCoeffs, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, tmp22, tmp23, tmp24, tmp25, tmp26
    Load tmp0, V_x, 0, 0
    Load tmp1, V_x, 1, 0
    Load tmp2, V_x, 0, 1
    Load tmp3, V_x, 1, 1
    Load tmp4, V_x, 0, 2
    Load tmp5, V_x, 1, 2
    Load tmp6, V_y, 0, 0
    Load tmp7, V_y, 1, 0
    Load tmp8, V_y, 0, 1
    Load tmp9, V_y, 1, 1
    Load tmp10, V_y, 0, 2
    Load tmp11, V_y, 1, 2
    StoreY C_yh, tmp6, tmp7, tmp12, tmp13
    Sub_ifif tmp12, tmp13, tmp4, tmp5, tmp2, tmp3
    Sub_ifif tmp14, tmp15, tmp10, tmp11, tmp8, tmp9
    Div_ifif tmp16, tmp17, tmp12, tmp13, tmp14, tmp15, tmp18, tmp19
    LTE_cond_ii tmp14, zeros, tmp12
    Select tmp16, zeros, tmp16
    Select tmp17, zeros, tmp17
    Store C_dxldy_i, tmp16
    Store C_dxldy_f, tmp17
    Sub_ifif tmp12, tmp13, tmp2, tmp3, tmp0, tmp1
    Sub_ifif tmp14, tmp15, tmp8, tmp9, tmp6, tmp7
    Div_ifif tmp18, tmp19, tmp12, tmp13, tmp14, tmp15, tmp20, tmp21
    LTE_cond_ii tmp14, zeros, tmp20
    Select tmp18, zeros, tmp18
    Select tmp19, zeros, tmp19
    Store C_dxmdy_i, tmp18
    Store C_dxmdy_f, tmp19
    Sub_ifif tmp20, tmp21, tmp4, tmp5, tmp0, tmp1
    Sub_ifif tmp4, tmp5, tmp10, tmp11, tmp6, tmp7
    Div_ifif tmp6, tmp22, tmp20, tmp21, tmp4, tmp5, tmp23, tmp24
    LTE_cond_ii tmp4, zeros, tmp23
    Select tmp6, zeros, tmp6
    Select tmp22, zeros, tmp22
    Store C_dxhdy_i, tmp6
    Store C_dxhdy_f, tmp22
    Mul_fif tmp23, tmp24, tmp7, tmp6, tmp22
    Sub_ifif tmp25, tmp26, tmp0, tmp1, tmp23, tmp24
    Store C_xh_i, tmp25
    Store C_xh_f, tmp26
    Mul_fif tmp23, tmp24, tmp7, tmp18, tmp19
    Sub_ifif tmp18, tmp19, tmp0, tmp1, tmp23, tmp24
    Store C_xm_i, tmp18
    Store C_xm_f, tmp19
    Add_ifcf tmp18, tmp19, y_mask, tmp10, tmp11
    StoreY C_yl, tmp18, tmp19, tmp10, tmp11
    Add_ifcf tmp10, tmp11, y_mask, tmp8, tmp9
    StoreY C_ym, tmp10, tmp11, tmp8, tmp18
    BitAnd_c tmp8, y_mask, tmp9
    Sub_cff tmp9, max_gap, tmp8
    Mul_fif tmp8, tmp10, tmp9, tmp16, tmp17
    Add_ifif tmp9, tmp11, tmp2, tmp3, tmp8, tmp10
    Store C_xl_i, tmp9
    Store C_xl_f, tmp11
    Mul_ifcf tmp8, tmp9, const_r4, tmp20, tmp21
    Mul_ifif tmp10, tmp11, tmp8, tmp9, tmp14, tmp15
    Mul_ifcf tmp8, tmp9, const_r4, tmp4, tmp5
    Mul_ifif tmp16, tmp17, tmp8, tmp9, tmp12, tmp13
    LT_cond_ifif tmp16, tmp17, tmp10, tmp11, tmp8
    Select_c tmp8, maj_bit, zeros
    Add_ici tmp8, command, tmp8
    Store C_header, tmp8
    Mul_ifif tmp8, tmp9, tmp14, tmp15, tmp6, tmp22
    Add_ifif tmp6, tmp10, tmp0, tmp1, tmp8, tmp9
    Sub_ifif tmp0, tmp1, tmp2, tmp3, tmp6, tmp10
    ComputeAttr V_r, C_r_i, C_r_f, C_drde_i, C_drde_f, C_drdx_i, C_drdx_f, tmp4, tmp5, tmp14, tmp15, tmp0, tmp1, tmp7, tmp2, tmp3, tmp6, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp16
    ComputeAttr V_g, C_g_i, C_g_f, C_dgde_i, C_dgde_f, C_dgdx_i, C_dgdx_f, tmp4, tmp5, tmp14, tmp15, tmp0, tmp1, tmp7, tmp2, tmp3, tmp6, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp16
    ComputeAttr V_b, C_b_i, C_b_f, C_dbde_i, C_dbde_f, C_dbdx_i, C_dbdx_f, tmp4, tmp5, tmp14, tmp15, tmp0, tmp1, tmp7, tmp2, tmp3, tmp6, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp16
.endmacro