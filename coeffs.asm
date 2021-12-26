.macro StoreY, yp_a, y_i, y_f, tmp0, tmp1
    yp equ tmp0
    Mul_ifci_i const_4, y_i, y_f, yp, tmp1
    Store yp_a, yp
.endmacro

.macro ComputeCoeffs, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, tmp22, tmp23, tmp24, tmp25, tmp26
    x1_i equ tmp0
    Load V_x, 0, 0, x1_i
    x1_f equ tmp1
    Load V_x, 1, 0, x1_f
    x2_i equ tmp2
    Load V_x, 0, 1, x2_i
    x2_f equ tmp3
    Load V_x, 1, 1, x2_f
    x3_i equ tmp4
    Load V_x, 0, 2, x3_i
    x3_f equ tmp5
    Load V_x, 1, 2, x3_f
    y1_i equ tmp6
    Load V_y, 0, 0, y1_i
    y1_f equ tmp7
    Load V_y, 1, 0, y1_f
    y2_i equ tmp8
    Load V_y, 0, 1, y2_i
    y2_f equ tmp9
    Load V_y, 1, 1, y2_f
    y3_i equ tmp10
    Load V_y, 0, 2, y3_i
    y3_f equ tmp11
    Load V_y, 1, 2, y3_f
    StoreY C_yh, y1_i, y1_f, tmp12, tmp13
.endmacro