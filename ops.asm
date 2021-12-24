.macro Mul_ici, ci, op, out
  vmudh out, op, consts[ci]
.endmacro


.macro Load, addr, part, ind, out
  lsv out[0],  addr + part * 2 + V_size * (ind - 3)(a0)
  lsv out[2],  addr + part * 2 + V_size * ind(a0)

  lsv out[4],  addr + part * 2 + V_size * (ind - 3)(a1)
  lsv out[6],  addr + part * 2 + V_size * ind(a1)

  lsv out[8],  addr + part * 2 + V_size * (ind - 3)(a2)
  lsv out[10], addr + part * 2 + V_size * ind(a2)

  lsv out[12], addr + part * 2 + V_size * (ind - 3)(a3)
  lsv out[14], addr + part * 2 + V_size * ind(a3)
.endmacro


.macro Store, addr, value
  ssv value[0],  addr - C_size(t0)
  ssv value[2],  addr(t0)
  
  ssv value[4],  addr - C_size(t1)
  ssv value[6],  addr(t1)
  
  ssv value[8],  addr - C_size(t2)
  ssv value[10], addr(t2)
  
  ssv value[12], addr - C_size(t3)
  ssv value[14], addr(t3)
.endmacro
