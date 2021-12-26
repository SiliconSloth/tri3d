.macro StoreY, yp_a, y_i, y_f, tmp0, tmp1
    yp equ tmp0
    Mul_ifci_i const_4, y_i, y_f, yp, tmp1
    Store yp_a, yp
.endmacro