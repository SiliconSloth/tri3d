.macro StoreY, yp_a, y_i, y_f, tmp0, tmp1
    Mul_ifci_i tmp0, const_4, y_i, y_f, tmp1
    Store yp_a, tmp0
.endmacro

.macro DefComputeAttr
    Load v7, 0, 0, 0
    Load v8, 0, 1, 0
    Load v9, 0, 0, 2
    Load v10, 0, 1, 2
    Sub_ifif v11, v12, v9, v10, v7, v8
    Div_ifif v9, v10, v11, v12, v0, v1, v13, v14
    LTE_cond_ii v0, zeros, v11
    Select v9, zeros, v9
    Select v10, zeros, v10
    Store_d s2, v9
    Store_d s3, v10
    Mul_ifif v11, v12, v2, v3, v9, v10
    Add_ifif v13, v14, v7, v8, v11, v12
    Load v11, 0, 0, 1
    Load v12, 0, 1, 1
    Sub_ifif v15, v16, v11, v12, v13, v14
    Div_ifif v11, v12, v15, v16, v4, v5, v13, v14
    Store_d s4, v11
    Store_d s5, v12
    Mul_fif v11, v12, v6, v9, v10
    Sub_ifif v9, v10, v7, v8, v11, v12
    Store_d s0, v9
    Store_d s1, v10
.endmacro

.macro ComputeAttr, a_a, sa_i_a, sa_f_a, dade_i_a, dade_f_a, dadx_i_a, dadx_f_a
    LoadBase a_a
    la s0, sa_i_a
    la s1, sa_f_a
    la s2, dade_i_a
    la s3, dade_f_a
    la s4, dadx_i_a
    la s5, dadx_f_a
    DefComputeAttr
.endmacro

.macro ComputeCoeffs, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, tmp22, tmp23, tmp24, tmp25, tmp26
    Load tmp4, V_x, 0, 0
    Load tmp5, V_x, 1, 0
    Load tmp7, V_x, 0, 1
    Load tmp8, V_x, 1, 1
    Load tmp0, V_x, 0, 2
    Load tmp1, V_x, 1, 2
    Load tmp9, V_y, 0, 0
    Load tmp6, V_y, 1, 0
    Load tmp10, V_y, 0, 1
    Load tmp11, V_y, 1, 1
    Load tmp12, V_y, 0, 2
    Load tmp13, V_y, 1, 2
    StoreY C_yh, tmp9, tmp6, tmp2, tmp3
    Sub_ifif tmp2, tmp3, tmp0, tmp1, tmp7, tmp8
    Sub_ifif tmp14, tmp15, tmp12, tmp13, tmp10, tmp11
    Div_ifif tmp16, tmp17, tmp2, tmp3, tmp14, tmp15, tmp18, tmp19
    LTE_cond_ii tmp14, zeros, tmp2
    Select tmp16, zeros, tmp16
    Select tmp17, zeros, tmp17
    Store C_dxldy_i, tmp16
    Store C_dxldy_f, tmp17
    Sub_ifif tmp14, tmp15, tmp7, tmp8, tmp4, tmp5
    Sub_ifif tmp2, tmp3, tmp10, tmp11, tmp9, tmp6
    Div_ifif tmp18, tmp19, tmp14, tmp15, tmp2, tmp3, tmp20, tmp21
    LTE_cond_ii tmp2, zeros, tmp20
    Select tmp18, zeros, tmp18
    Select tmp19, zeros, tmp19
    Store C_dxmdy_i, tmp18
    Store C_dxmdy_f, tmp19
    Sub_ifif tmp20, tmp21, tmp0, tmp1, tmp4, tmp5
    Sub_ifif tmp0, tmp1, tmp12, tmp13, tmp9, tmp6
    Div_ifif tmp9, tmp22, tmp20, tmp21, tmp0, tmp1, tmp23, tmp24
    LTE_cond_ii tmp0, zeros, tmp23
    Select tmp9, zeros, tmp9
    Select tmp22, zeros, tmp22
    Store C_dxhdy_i, tmp9
    Store C_dxhdy_f, tmp22
    Mul_fif tmp23, tmp24, tmp6, tmp9, tmp22
    Sub_ifif tmp25, tmp26, tmp4, tmp5, tmp23, tmp24
    Store C_xh_i, tmp25
    Store C_xh_f, tmp26
    Mul_fif tmp23, tmp24, tmp6, tmp18, tmp19
    Sub_ifif tmp18, tmp19, tmp4, tmp5, tmp23, tmp24
    Store C_xm_i, tmp18
    Store C_xm_f, tmp19
    Add_ifcf tmp18, tmp19, y_mask, tmp12, tmp13
    StoreY C_yl, tmp18, tmp19, tmp12, tmp13
    Add_ifcf tmp12, tmp13, y_mask, tmp10, tmp11
    StoreY C_ym, tmp12, tmp13, tmp10, tmp18
    BitAnd_c tmp10, y_mask, tmp11
    Sub_cff tmp11, max_gap, tmp10
    Mul_fif tmp10, tmp12, tmp11, tmp16, tmp17
    Add_ifif tmp11, tmp13, tmp7, tmp8, tmp10, tmp12
    Store C_xl_i, tmp11
    Store C_xl_f, tmp13
    Mul_ifcf tmp10, tmp11, const_r4, tmp20, tmp21
    Mul_ifif tmp12, tmp13, tmp10, tmp11, tmp2, tmp3
    Mul_ifcf tmp10, tmp11, const_r4, tmp0, tmp1
    Mul_ifif tmp16, tmp17, tmp10, tmp11, tmp14, tmp15
    LT_cond_ifif tmp16, tmp17, tmp12, tmp13, tmp10
    Select_c tmp10, maj_bit, zeros
    Add_ici tmp10, command, tmp10
    Store C_header, tmp10
    Mul_ifif tmp10, tmp11, tmp2, tmp3, tmp9, tmp22
    Add_ifif tmp9, tmp12, tmp4, tmp5, tmp10, tmp11
    Sub_ifif tmp4, tmp5, tmp7, tmp8, tmp9, tmp12
    ComputeAttr V_r, C_r_i, C_r_f, C_drde_i, C_drde_f, C_drdx_i, C_drdx_f
    ComputeAttr V_g, C_g_i, C_g_f, C_dgde_i, C_dgde_f, C_dgdx_i, C_dgdx_f
    //ComputeAttr V_b, C_b_i, C_b_f, C_dbde_i, C_dbde_f, C_dbdx_i, C_dbdx_f
.endmacro