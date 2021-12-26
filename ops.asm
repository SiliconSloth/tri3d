.macro Mul_ifci_i, res, ci, op_i, op_f, tmp
  vmudn tmp, op_f, consts[ci]
  vmadh res, op_i, consts[ci]
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
