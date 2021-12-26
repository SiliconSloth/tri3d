.macro Add_ifif, res_i, res_f, a_i, a_f, b_i, b_f
  vaddc res_f, a_f, b_f
  vadd  res_i, a_i, b_i
.endmacro


.macro Add_ifcf, res_i, res_f, ci, a_i, a_f
  vaddc res_f, a_f, consts[ci]
  vadd  res_i, a_i, zeros
.endmacro


.macro Sub_cff, res, ci, op
  vadd  res, zeros, consts[ci]
  vsub res, res, op
.endmacro


.macro Sub_ifif, res_i, res_f, a_i, a_f, b_i, b_f
  vsubc res_f, a_f, b_f
  vsub  res_i, a_i, b_i
.endmacro


.macro Mul_ifif, res_i, res_f, a_i, a_f, b_i, b_f
  vmudl res_f, a_f, b_f
  vmadm res_i, a_i, b_f
  vmadn res_f, a_f, b_i
  vmadh res_i, a_i, b_i
.endmacro


.macro Mul_fif, res_i, res_f, a_f, b_i, b_f
  vmudl res_f, a_f, b_f
  vmadn res_f, a_f, b_i
  vmadh res_i, zeros, zeros
.endmacro


.macro Mul_ifci, res_i, res_f, ci, op_i, op_f
  vmudn res_f, op_f, consts[ci]
  vmadh res_i, op_i, consts[ci]
  vmadn res_f, zeros, zeros[0]
.endmacro


.macro Mul_ifci_i, res, ci, op_i, op_f, tmp
  vmudn tmp, op_f, consts[ci]
  vmadh res, op_i, consts[ci]
.endmacro


.macro Rec_ifif, res_i, res_f, op_i, op_f
  vrcph res_i[0], op_i[0]
  vrcpl res_f[0], op_f[0]
  vrcph res_i[0], op_i[1]
  vrcpl res_f[1], op_f[1]
  vrcph res_i[1], op_i[2]
  vrcpl res_f[2], op_f[2]
  vrcph res_i[2], op_i[3]
  vrcpl res_f[3], op_f[3]
  vrcph res_i[3], op_i[4]
  vrcpl res_f[4], op_f[4]
  vrcph res_i[4], op_i[5]
  vrcpl res_f[5], op_f[5]
  vrcph res_i[5], op_i[6]
  vrcpl res_f[6], op_f[6]
  vrcph res_i[6], op_i[7]
  vrcpl res_f[7], op_f[7]
  vrcph res_i[7], op_i[0]

  Mul_ifci res_i, res_f, const_2, res_i, res_f
.endmacro


.macro Div_ifif, res_i, res_f, a_i, a_f, b_i, b_f, tmp0, tmp1
  Rec_ifif tmp0, tmp1, b_i, b_f
  Mul_ifif res_i, res_f, a_i, a_f, tmp0, tmp1
.endmacro


.macro BitAnd_c, res, ci, op
  vand res, op, consts[ci]
.endmacro


.macro LTE_cond_ii, a, b, tmp
  vge tmp, b, a
.endmacro


.macro Select, res, a, b
  vmrg res, a, b
.endmacro


.macro Load, res, addr, part, ind
  lsv res[0],  addr + part * 2 + V_size * (ind - 3)(a0)
  lsv res[2],  addr + part * 2 + V_size * ind(a0)

  lsv res[4],  addr + part * 2 + V_size * (ind - 3)(a1)
  lsv res[6],  addr + part * 2 + V_size * ind(a1)

  lsv res[8],  addr + part * 2 + V_size * (ind - 3)(a2)
  lsv res[10], addr + part * 2 + V_size * ind(a2)

  lsv res[12], addr + part * 2 + V_size * (ind - 3)(a3)
  lsv res[14], addr + part * 2 + V_size * ind(a3)
.endmacro


.macro Store, addr, value
  ssv value[0],  addr(t0)
  ssv value[2],  addr(t1)
  ssv value[4],  addr(t2)
  ssv value[6],  addr(t3)
  ssv value[8],  addr(t4)
  ssv value[10], addr(t5)
  ssv value[12], addr(t6)
  ssv value[14], addr(t7)
.endmacro
