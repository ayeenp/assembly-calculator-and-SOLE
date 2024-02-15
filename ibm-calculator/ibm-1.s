.data
print_int_formatt:  .asciz "%09d"
_chera_akhe: .ascii "%09d%" # for alignment
print_int_format:  .asciz "%d"

a: .zero 32 # first input
b: .zero 32 # second input
c: .zero 32 # result
temp1: .zero 32 # temporary
temp2: .zero 32
temp3: .zero 32
temp4: .zero 32
op1: .zero 32
op2: .zero 32
res: .zero 32

_mul_input1: .zero 32
_mul_input2: .zero 32
_mul_output: .zero 32

_div_input1: .zero 32
_div_input2: .zero 32
_quotient: .zero 32
_remainder: .zero 32

readres: .zero 32

writeop: .zero 32
writestack: .zero 36

_mul_reg6: .zero 4
_mul_reg7: .zero 4
_mul_reg8: .zero 4
_mul_reg9: .zero 4
_mul_reg10: .zero 4

_add_reg6: .zero 4
_add_reg7: .zero 4
_add_reg8: .zero 4
_add_reg9: .zero 4
_add_reg10: .zero 4

_neg_reg6: .zero 4
_neg_reg7: .zero 4
_neg_reg8: .zero 4
_neg_reg9: .zero 4
_neg_reg10: .zero 4

_div_reg6: .zero 4
_div_reg7: .zero 4
_div_reg8: .zero 4
_div_reg9: .zero 4
_div_reg10: .zero 4

_sub_reg6: .zero 4
_sub_reg7: .zero 4
_sub_reg8: .zero 4
_sub_reg9: .zero 4
_sub_reg10: .zero 4

_read_reg6: .zero 4
_read_reg7: .zero 4
_read_reg8: .zero 4
_read_reg9: .zero 4
_read_reg10: .zero 4

tempIn1: .zero 32
tempIn2: .zero 32

_move_reg7: .zero 4
_shift_reg7: .zero 4
_shift_reg8: .zero 4

# constants
one: .zero 32
zero:  .zero 32
ten: .zero 32
maxPower: .zero 32
bil: .zero 32

.text
.globl asm_main

shift_left_256bit:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)

  larl 13, _shift_reg7
  st 7, 0(13)
  la 7, 24

  l 10, 28(9)
  l 13, 28(9)
  srl 13, 31
  sll 10, 1
  st 10, 28(9)

  shift_left_loop:
    ar 9, 7
    l 10, 0(9)
    sll 10, 1
    ar 10, 13
    l 13, 0(9)
    srl 13, 31
    st 10, 0(9)
    sr 9, 7
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    chi 7, 0
    jnl shift_left_loop

  larl 13, _shift_reg7
  l 7, 0(13)

  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14


shift_right_256bit:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)

  larl 13, _shift_reg7
  st 7, 0(13)
  larl 13, _shift_reg8
  st 8, 0(13)
  la 7, 28
  la 8, 4

  l 10, 0(9)
  l 13, 0(9)
  sll 13, 31
  srl 10, 1
  st 10, 0(9)

  shift_right_loop:
    ar 9, 8
    l 10, 0(9)
    srl 10, 1
    ar 10, 13
    l 13, 0(9)
    sll 13, 31
    st 10, 0(9)
    sr 7, 8
    chi 7, 0
    jnl shift_right_loop

  larl 13, _shift_reg7
  l 7, 0(13)
  larl 13, _shift_reg8
  l 8, 0(13)

  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

memory_move: # (r9) <- (r10)
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)

  larl 13, _move_reg7
  st 7, 0(13)

  la 7, 28
  movLoop:
    ar 9, 7
    ar 10, 7
    l 13, 0(9)
    st 13, 0(10)
    sr 9, 7
    sr 10, 7
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    chi 7, 0
    jnl movLoop

  larl 13, _move_reg7
  l 7, 0(13)

  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

negate_256bit: # (res) <- -(r9)
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  larl 13, _neg_reg7
  st 7, 0(13)
  larl 13, _neg_reg8
  st 8, 0(13)
  larl 13, _neg_reg9
  st 9, 0(13)
  larl 13, _neg_reg10
  st 10, 0(13)

  larl 9, op1
  larl 10, temp1
  brasl 14, memory_move

  larl 9, op2
  larl 10, temp2
  brasl 14, memory_move

  larl 13, _neg_reg9
  l 9, 0(13)

  la 7, 28
  # invert all bits
  negateLoop:
    ar 9, 7
    l 10, 0(9)
    lcr 10, 10 # two's complement
    bctr 10, 0 # minus one -> not
    st 10, 0(9)
    sr 9, 7
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    chi 7, 0
    jnl negateLoop

  larl 10, op1
  brasl 14, memory_move
  # add one to get two's complement
  larl 9, one
  larl 10, op2
  brasl 14, memory_move
  brasl 14, add_256bit

  larl 9, temp1
  larl 10, op1
  brasl 14, memory_move

  larl 9, temp2
  larl 10, op2
  brasl 14, memory_move

  larl 13, _neg_reg7
  l 7, 0(13)
  larl 13, _neg_reg8
  l 8, 0(13)
  larl 13, _neg_reg9
  l 9, 0(13)
  larl 13, _neg_reg10
  l 10, 0(13)
  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

add_256bit: # res <- op1 + op2
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  larl 13, _add_reg7
  st 7, 0(13)
  larl 13, _add_reg8
  st 8, 0(13)
  larl 13, _add_reg9
  st 9, 0(13)
  larl 13, _add_reg10
  st 10, 0(13)

  # r10 is index
  # r9 is carry
  # r7 & r8 are numbers
  # r13 is temporary
  la 10, 28
  xr 9, 9
  add_loop:
    larl 13, op1
    ar 13, 10
    l 7, 0(13)
    larl 13, op2
    ar 13, 10
    l 8, 0(13)
    xr 13, 13
    cr 9, 13
    je carryZero
    alr 7, 9
    cr 7, 13
    je setCarry11
    alr 7, 8
    jo setCarry1
    cr 7, 13
    je setCarry1
    j clearCarry1
    setCarry11:
      la 9, 1
      alr 7, 8
      j restOfAdd
    setCarry1:
      la 9, 1
      j restOfAdd
    clearCarry1:
      xr 9, 9
      j restOfAdd
    carryZero:
      cr 7, 13
      jne nonz
      cr 8, 13
      jne nonz
      xr 9, 9
      j restOfAdd
      nonz:
      alr 7, 8
      jo setCarry2
      cr 7, 13
      je setCarry2
      j clearCarry2
      setCarry2: 
        la 9, 1
        j restOfAdd
      clearCarry2:
        xr 9, 9
        j restOfAdd
    restOfAdd:
    larl 13, res
    ar 13, 10
    st 7, 0(13)

    bctr 10, 0
    bctr 10, 0
    bctr 10, 0
    bctr 10, 0
    chi 10, 0
    jnl add_loop

  larl 13, _add_reg7
  l 7, 0(13)
  larl 13, _add_reg8
  l 8, 0(13)
  larl 13, _add_reg9
  l 9, 0(13)
  larl 13, _add_reg10
  l 10, 0(13)
  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

mul_256bit:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  larl 13, _mul_reg6
  st 6, 0(13)
  larl 13, _mul_reg7
  st 7, 0(13)
  larl 13, _mul_reg8
  st 8, 0(13)
  larl 13, _mul_reg9
  st 9, 0(13)
  larl 13, _mul_reg10
  st 10, 0(13)

  # entries in _mul_input1, _mul_input2 and result in _mul_output
  # apply changes to op1, op2
  # uses r13, r7, r8, r9, r10, r6 but only apply changes to r13
  # r6 is sign
  xr 6, 6
  larl 13, _mul_input1
  l 7, 0(13)
  srl 7, 31
  chi 7, 0
  je pos
  # larl 9, _mul_input1
  # brasl 14, negate_256bit
  # larl 9, res
  # larl 10, _mul_input1
  # brasl 14, memory_move
  la 6, 1
  pos:
  la 7, 256

  # initialize output to 0
  xr 13, 13
  larl 9, zero
  larl 10, _mul_output
  brasl 14, memory_move

  mulLoop:
    chi 7, 0
    je endLoop

    larl 13, _mul_input1
    l 10, 28(13)
    sll 10, 31
    srl 10, 31
    chi 10, 0
    je continue

    larl 9, _mul_input2
    larl 10, op1
    brasl 14, memory_move

    larl 9, _mul_output
    larl 10, op2
    brasl 14, memory_move

    brasl 14, add_256bit

    larl 9, res
    larl 10, _mul_output
    brasl 14, memory_move

    continue:
    larl 9, _mul_input2
    brasl 14, shift_left_256bit

    larl 9, _mul_input1
    brasl 14, shift_right_256bit

    bctr 7, 0
    j mulLoop
  endLoop:
  # involving sign bit in calculation
  chi 6, 0
  je endMul
  larl 9, _mul_output
  brasl 14, negate_256bit
  larl 9, res
  larl 10, _mul_output
  brasl 14, memory_move

  endMul:
  larl 13, _mul_reg6
  l 6, 0(13)
  larl 13, _mul_reg7
  l 7, 0(13)
  larl 13, _mul_reg8
  l 8, 0(13)
  larl 13, _mul_reg9
  l 9, 0(13)
  larl 13, _mul_reg10
  l 10, 0(13)
  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

sub_256bit:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  larl 13, _sub_reg7
  st 7, 0(13)
  larl 13, _sub_reg8
  st 8, 0(13)
  larl 13, _sub_reg9
  st 9, 0(13)
  larl 13, _sub_reg10
  st 10, 0(13)

  # op1 - op2 = op1 + (-op2)
  larl 9, op2
  brasl 14, negate_256bit
  larl 9, res
  larl 10, op2
  brasl 14, memory_move
  brasl 14, add_256bit

  larl 13, _sub_reg7
  l 7, 0(13)
  larl 13, _sub_reg8
  l 8, 0(13)
  larl 13, _sub_reg9
  l 9, 0(13)
  larl 13, _sub_reg10
  l 10, 0(13)
  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

div_256bit:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  larl 13, _div_reg6
  st 6, 0(13)
  larl 13, _div_reg7
  st 7, 0(13)
  larl 13, _div_reg8
  st 8, 0(13)
  larl 13, _div_reg9
  st 9, 0(13)
  larl 13, _div_reg10
  st 10, 0(13)

  # input in _div_input1, _div_input2 and output in _quotient and _remainder 
  # sign handling
  # r6 is flag
  larl 13, _div_input1
  l 6, 0(13)
  srl 6, 31
  chi 6, 1
  jne Npos

  larl 9, _div_input1
  brasl 14, negate_256bit
  larl 9, res
  larl 10, _div_input1
  brasl 14, memory_move
  Npos:

  larl 13, _div_input2
  l 10, 0(13)
  srl 10, 31
  sll 6, 1
  ar 6, 10
  chi 10, 1
  jne Qpos

  larl 9, _div_input2
  brasl 14, negate_256bit
  larl 9, res
  larl 10, _div_input2
  brasl 14, memory_move
  Qpos:
  # end of sign handling
  la 7, 256
  # R <- 0 , Q <- 0
  larl 9, zero
  larl 10, _quotient
  brasl 14, memory_move
  larl 10,  _remainder 
  brasl 14, memory_move
  # temp4 <- maxPowerOfTwo
  larl 9, maxPower
  larl 10, temp4
  brasl 14, memory_move
  divLoop:
    # i = 256, 255, ..., 1
    xr 13, 13
    cr 7, 13
    je endDivLoop
    # R << 1 and Q << 1
    larl 9,  _remainder 
    brasl 14, shift_left_256bit
    larl 9, _quotient
    brasl 14, shift_left_256bit
    # r10 <- N(i)
    larl 13, _div_input1
    l 10, 0(13)
    srl 10, 31
    # op1 = N(i)
    xr 13, 13
    larl 9, op1
    st 13, 0(9)
    st 13, 4(9)
    st 13, 8(9)
    st 13, 12(9)
    st 13, 16(9)
    st 13, 20(9)
    st 13, 24(9)
    lr 13, 10
    st 13, 28(9)
    # op2 <- R and R = R + N(i)
    larl 9,  _remainder 
    larl 10, op2
    brasl 14, memory_move
    brasl 14, add_256bit
    larl  9, res
    larl 10,  _remainder 
    brasl 14, memory_move
    # res <- R - D
    larl 9,  _remainder  
    larl 10, op1
    brasl 14, memory_move
    larl 9, _div_input2
    larl 10, op2
    brasl 14, memory_move
    brasl 14, sub_256bit
    # temp2 <- res = R - D
    larl 9, res
    larl 10, temp2
    brasl 14, memory_move
    # check if R - D >= 0
    larl 13, res
    l 10, 0(13)
    srl 10, 31
    chi 10, 0
    jne restOfDiv
    # R <- R - D
    larl 9, res
    larl 10,  _remainder 
    brasl 14, memory_move
    # Q <- Q + 1
    larl 9, one
    larl 10, op1
    brasl 14, memory_move
    larl 9, _quotient
    larl 10, op2
    brasl 14, memory_move
    brasl 14, add_256bit
    larl 9, res
    larl 10, _quotient
    brasl 14, memory_move


    restOfDiv:
    # N << 1
    larl 9, _div_input1
    brasl 14, shift_left_256bit

    bctr 7, 0
    j divLoop
  endDivLoop:
  # involving sign bit in calculations
  lr 7, 6
  sll 7, 31
  srl 7, 31
  srl 6, 1
  xr 7, 6

  chi 6, 1
  jne rPos
  larl 9,  _remainder 
  brasl 14, negate_256bit
  larl 9, res
  larl 10,  _remainder 
  brasl 14, memory_move
  rPos:

  chi 7, 1
  jne qPos
  larl 9, _quotient
  brasl 14, negate_256bit
  larl 9, res
  larl 10, _quotient
  brasl 14, memory_move
  qPos:

  
  larl 13, _div_reg6
  l 6, 0(13)
  larl 13, _div_reg7
  l 7, 0(13)
  larl 13, _div_reg8
  l 8, 0(13)
  larl 13, _div_reg9
  l 9, 0(13)
  larl 13, _div_reg10
  l 10, 0(13)
  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

print_256bit_int:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)

  # l 2, 28(9)
  # brasl 14, print_int
  # l 2, 24(9)
  # brasl 14, print_int
  # l 2, 20(9)
  # brasl 14, print_int
  # l 2, 16(9)
  # brasl 14, print_int
  # l 2, 12(9)
  # brasl 14, print_int
  # l 2, 8(9)
  # brasl 14, print_int
  # l 2, 4(9)
  # brasl 14, print_int
  # l 2, 0(9)
  # brasl 14, print_int
  # j endwrite

  larl 13, writeop
  l 10, 0(13)
  srl 10, 31
  chi 10, 1
  jne writePos
  la 2, '-'
  brasl 14, putchar
  larl 9, writeop
  brasl 14, negate_256bit
  larl 9, res
  larl 10, writeop
  brasl 14, memory_move
  writePos:
  la 7, 32
  writeloop1:
    chi 7, 0
    jl writeend1
    # writeop <- writeop / bil and writestack[7] <- remainder
    larl 9, writeop
    larl 10, _div_input1
    brasl 14, memory_move
    larl 9, bil
    larl 10, _div_input2
    brasl 14, memory_move
    brasl 14, div_256bit
    larl 9, _quotient
    larl 10, writeop
    brasl 14, memory_move
    larl 10, writestack
    ar 10, 7
    larl 13,  _remainder 
    l 13, 28(13)
    st 13, 0(10)
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    bctr 7, 0
    j writeloop1

  writeend1:
  xr 7, 7
  xr 6, 6
  writeloop2:
    larl 13, writestack
    ar 13, 7
    l 8, 0(13)
    chi 6, 0
    jne writemod1

    xr 13, 13
    cr 8, 13
    je writeJump
    la 6, 1
    lr 2, 8
    brasl 14, print_int
    j writeJump
    writemod1:
    lr 2, 8
    brasl 14, print_int2
    writeJump:
    la 7, 4(7)
    chi 7, 33
    jl writeloop2
  chi 6, 0
  jne endwrite
  la 2, 0
  brasl 14, print_int
  endwrite:
  la 2, 10
  brasl 14, putchar

  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

read_256bit_int:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  larl 13, _read_reg6
  st 6, 0(13)
  larl 13, _read_reg7
  st 7, 0(13)
  larl 13, _read_reg8
  st 8, 0(13)
  larl 13, _read_reg9
  st 9, 0(13)
  larl 13, _read_reg10
  st 10, 0(13)
  larl 9, zero
  larl 10, readres
  brasl 14, memory_move
  larl 10, temp3
  brasl 14, memory_move

  xr 6, 6

  read_first_char:
    brasl %r14, getchar
    lr 7, 2
    chi 7, '\n'
    je read_first_char
    chi 7, '-'
    jne read_pos
    la 6, 1
    j read_loop
  read_pos:
    la 8, '0'
    sr 7, 8
    larl 13, readres
    st 7, 28(13)

  read_loop:
    brasl 14, getchar
    lr 7, 2
    chi 7, '0'
    jl readend

    chi 7, '9'
    jh readend

    la 8, '0'
    sr 7, 8
    larl 13, temp3
    st 7, 28(13)

    larl 9, ten
    larl 10, _mul_input1
    brasl 14, memory_move

    larl 9, readres
    larl 10, _mul_input2
    brasl 14, memory_move

    brasl 14, mul_256bit

    larl 9, _mul_output
    larl 10, readres
    brasl 14, memory_move

    larl 9, temp3
    larl 10, op1
    brasl 14, memory_move

    larl 9, readres
    larl 10, op2
    brasl 14, memory_move

    brasl 14, add_256bit

    larl 9, res
    larl 10, readres
    brasl 14, memory_move

    j read_loop

  readend:
  chi 6, 1
  jne read_noneg
  larl 9, readres
  brasl 14, negate_256bit
  larl 9, res
  larl 10, readres
  brasl 14, memory_move
  read_noneg:
  larl 13, _read_reg6
  l 6, 0(13)
  larl 13, _read_reg7
  l 7, 0(13)
  larl 13, _read_reg8
  l 8, 0(13)
  larl 13, _read_reg9
  l 9, 0(13)
  larl 13, _read_reg10
  l 10, 0(13)
  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

asm_main:
  stmg     %r11, %r15, -40(%r15)
  lay      %r15, -200(%r15)
  # ---------------------------
  # r6 is input character

  # initialize constants
  la 6, 10
  larl 7, ten
  st 6, 28(7)

  la 6, 1
  larl 7, one
  st 6, 28(7)

  sll 6, 31
  larl 7, maxPower
  st 6, 0(7)

  # a billion (chon ja nemishod!)
  larl 7, bil
  la 6, 953
  sll 6, 12
  la 6, 2762(6)
  sll 6, 8
  st 6, 28(7)


  #   brasl 14, read_256bit_int
  # larl 9, readres
  # brasl 14, negate_256bit
  # larl 9, res
  # larl 10, writeop
  # brasl 14, memory_move
  # brasl 14, print_256bit_int
  # j end_loop

  input_loop:
    brasl %r14, getchar
    lr 6, 2
    la 7, 'q'
    cr 6, 7
    je end_loop
    la 7, '+'
    cr 6, 7
    je addIf
    la 7, '-'
    cr 6, 7
    je subIf
    la 7, '*'
    cr 6, 7
    je mulIf
    la 7, '/'
    cr 6, 7
    je divIf
    la 7, '%'
    cr 6, 7
    je remIf
    j input_loop
  addIf:
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn1
    brasl 14, memory_move

    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn2
    brasl 14, memory_move

    larl 9, tempIn1
    larl 10, op1
    brasl 14, memory_move

    larl 9, tempIn2
    larl 10, op2
    brasl 14, memory_move

    brasl 14, add_256bit
    larl 9, res
    larl 10, writeop
    brasl 14, memory_move
    j printsection
  subIf:
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn1
    brasl 14, memory_move
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn2
    brasl 14, memory_move

    larl 9, tempIn1
    larl 10, op1
    brasl 14, memory_move

    larl 9, tempIn2
    larl 10, op2
    brasl 14, memory_move

    brasl 14, sub_256bit
    larl 9, res
    larl 10, writeop
    brasl 14, memory_move
    j printsection
  mulIf:
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn1
    brasl 14, memory_move
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn2
    brasl 14, memory_move

    larl 9, tempIn1
    larl 10, _mul_input1
    brasl 14, memory_move

    larl 9, tempIn2
    larl 10, _mul_input2
    brasl 14, memory_move

    brasl 14, mul_256bit
    larl 9, _mul_output
    larl 10, writeop
    brasl 14, memory_move
    j printsection
  divIf:
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn1
    brasl 14, memory_move
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn2
    brasl 14, memory_move

    larl 9, tempIn1
    larl 10, _div_input1
    brasl 14, memory_move

    larl 9, tempIn2
    larl 10, _div_input2
    brasl 14, memory_move


    brasl 14, div_256bit
    larl 9, _quotient
    larl 10, writeop
    brasl 14, memory_move
    j printsection
  remIf:
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn1
    brasl 14, memory_move
    brasl 14, read_256bit_int
    larl 9, readres
    larl 10, tempIn2
    brasl 14, memory_move

    larl 9, tempIn1
    larl 10, _div_input1
    brasl 14, memory_move

    larl 9, tempIn2
    larl 10, _div_input2
    brasl 14, memory_move


    brasl 14, div_256bit
    larl 9,  _remainder
    larl 10, writeop
    brasl 14, memory_move
    j printsection
  printsection:
    brasl 14, print_256bit_int
    j input_loop

  end_loop:



  # ---------------------------

  lay     %r15, 200(%r15)
  lmg     %r11, %r15, -40(%r15)
  br      %r14

print_int:
  stg     %r14, -40(%r15)
  lay     %r15, -200(%r15)
  lr      %r3,  %r2
  larl    %r2,  print_int_format
  brasl   %r14, printf
  lay     %r15, 200(%r15)
  lg      %r14, -40(%r15)
  br      %r14
print_int2:
  stg     %r14, -40(%r15)
  lay     %r15, -200(%r15)
  lr      %r3,  %r2
  larl    %r2,  print_int_formatt
  brasl   %r14, printf
  lay     %r15, 200(%r15)
  lg      %r14, -40(%r15)
  br      %r14
