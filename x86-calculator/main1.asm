segment .data
; low, high
a: times 4 dq 0
b: times 4 dq 0
c: times 4 dq 0
_read_output: times 4 dq 0
_mul_input_1: times 4 dq 0
_mul_input_2: times 4 dq 0
_mul_output: times 4 dq 0
_div_input_1: times 4 dq 0
_div_input_2: times 4 dq 0
_quotient: times 4 dq 0
_remainder: times 4 dq 0
zero: times 4 dq 0
one: dq 1, 0, 0, 0
ten: dq 10, 0, 0, 0
_to_be_printed: times 4 dq 0
_print_output: times 800 db 0
_print_int_format: db "%lld\n", 0

segment .text
extern putchar
extern getchar
extern printf
global asm_main

%macro stack_alignment_begin 0
  push rbp
  mov rbp, rsp
  mov rax, rsp
  and rax, 15
  add rsp, rax
%endmacro

%macro stack_alignment_end 0
  mov rsp, rbp
  pop rbp
%endmacro

%macro shift_left_256bit 1
  push rax
  mov rax, [%1]
  shl rax, 1
  mov [%1], rax
  mov rax, [%1+8]
  rcl rax, 1
  mov [%1+8], rax
  mov rax, [%1+16]
  rcl rax, 1
  mov [%1+16], rax
  mov rax, [%1+24]
  rcl rax, 1
  mov [%1+24], rax
  pop rax
%endmacro

%macro shift_right_256bit 1
  push rax
  mov rax, [%1+24]
  shr rax, 1
  mov [%1+24], rax
  mov rax, [%1+16]
  rcr rax, 1
  mov [%1+16], rax
  mov rax, [%1+8]
  rcr rax, 1
  mov [%1+8], rax
  mov rax, [%1]
  rcr rax, 1
  mov [%1], rax
  pop rax
%endmacro

%macro push_256bit 1
  push qword [%1]
  push qword [%1+8]
  push qword [%1+16]
  push qword [%1+24]
%endmacro

%macro pop_256bit 1
  pop qword [%1+24]
  pop qword [%1+16]
  pop qword [%1+8]
  pop qword [%1]
%endmacro

%macro add_256bit 2
  push rax
  push rcx
  mov rax, [%1]
  mov rcx, [%2]
  add rax, rcx
  mov [%1], rax
  mov rax, [%1+8]
  mov rcx, [%2+8]
  adc rax, rcx
  mov [%1+8], rax
  mov rax, [%1+16]
  mov rcx, [%2+16]
  adc rax, rcx
  mov [%1+16], rax
  mov rax, [%1+24]
  mov rcx, [%2+24]
  adc rax, rcx
  mov [%1+24], rax
  pop rcx
  pop rax
%endmacro

%macro memory_move 2
  push r13
  mov r13,[%2]
  mov [%1], r13
  mov r13,[8+%2]
  mov [8+%1],r13
  mov r13,[16+%2]
  mov [16+%1],r13
  mov r13,[24+%2]
  mov [24+%1],r13
  pop r13
%endmacro

%macro negate_256bit 1
  ; two's complement: NOT all bits, then add by one
  push rax
  mov rax, [%1]
  not rax
  mov [%1], rax
  mov rax, [%1+8]
  not rax
  mov [%1+8], rax
  mov rax, [%1+16]
  not rax
  mov [%1+16], rax
  mov rax, [%1+24]
  not rax
  mov [%1+24], rax
  add_256bit %1, one
  pop rax
%endmacro

%macro sub_256bit 2
  negate_256bit %2
  add_256bit %1, %2
  negate_256bit %2
%endmacro

_mul_256bit:
  push rcx
  mov rcx, 256
  mul_loop:
    push rcx
    mov r8, [_mul_input_2]
    and r8, 1
    jz skip

    add_256bit _mul_output, _mul_input_1

    skip:
    shift_right_256bit _mul_input_2
    shift_left_256bit _mul_input_1

    pop rcx
    dec rcx
    jnz mul_loop
  pop rcx
  ret
%macro mul_256bit 3
  push_256bit _mul_input_1
  push_256bit _mul_input_2
  push_256bit _mul_output
  memory_move _mul_input_1, %2
  memory_move _mul_input_2, %3
  call _mul_256bit
  memory_move %1, _mul_output
  pop_256bit _mul_output
  pop_256bit _mul_input_2
  pop_256bit _mul_input_1
%endmacro

_div_256bit:
  memory_move _quotient, zero
  memory_move _remainder, zero
  push r15
  push r14
  push rcx
  push_256bit _div_input_1
  push_256bit _div_input_2

  mov r14, 0
  mov r15, [_div_input_1+24]
  cmp r15, 0
  jge a_not_negative
  negate_256bit _div_input_1
  xor r14, 1
  a_not_negative:
  mov r15, [_div_input_2+24]
  cmp r15, 0
  jge b_not_negative
  negate_256bit _div_input_2
  xor r14, 1
  b_not_negative:

  mov rcx, 255
  divide_loop:
    shift_left_256bit _remainder

    push_256bit _div_input_1
    push rcx
    cmp rcx, 0
    jz end_shift_loop
    shift_loop:
      shift_right_256bit _div_input_1
      dec rcx
      jnz shift_loop
    end_shift_loop:
    mov r15, [_div_input_1]
    and r15, 1
    jz aaaa
    add_256bit _remainder, one
    aaaa:
    pop rcx
    pop_256bit _div_input_1

    sub_256bit _remainder, _div_input_2
    mov r15, [_remainder+24]
    cmp r15, 0
    jl _remainder_smaller_than_b
    sub_256bit _remainder, _div_input_2
    push_256bit c
    memory_move c, one
    mov r15, rcx
    cmp r15, 0
    jz endqshiftloop
    qshiftloop:
      shift_left_256bit c
      dec r15
      jnz qshiftloop
    endqshiftloop:
    add_256bit _quotient, c
    pop_256bit c
    _remainder_smaller_than_b:
    add_256bit _remainder, _div_input_2

    dec rcx
    jns divide_loop

  cmp r14, 1
  jne skip_quotient_negation
    negate_256bit _quotient
  skip_quotient_negation:

  pop_256bit _div_input_2
  pop_256bit _div_input_1

  mov r15, [_div_input_1+24]
  cmp r15, 0
  jge a_not_negative_2
    negate_256bit _remainder
  a_not_negative_2:

  pop rcx
  pop r14
  pop r15
  ret
  
%macro div_256bit 2
  push_256bit _div_input_1
  push_256bit _div_input_2
  memory_move _div_input_1, %1
  memory_move _div_input_2, %2
  call _div_256bit
  pop_256bit _div_input_2
  pop_256bit _div_input_1
%endmacro

print_int:
  sub rsp, 8
  mov rsi, rdi
  mov rdi, _print_int_format
  mov rax, 1 ; setting rax (al) to number of vector inputs
  call printf
  add rsp, 8 ; clearing local variables from stack
  ret

read_char:
  sub rsp, 8
  call getchar
  add rsp, 8 ; clearing local variables from stack
  ret
print_char:
  sub rsp, 8
  call putchar
  add rsp, 8 ; clearing local variables from stack
  ret


_print_256bit_int:
  push r15
  push r14
  push r13

  mov r13, 0
  mov r15, 792

  mov r14, [_to_be_printed+24]
  cmp r14, 0
  jge _print_not_negative
    negate_256bit _to_be_printed
    mov r13, 1
  _print_not_negative:

  digits_loop:
    div_256bit _to_be_printed, ten
    mov rax, [_remainder]
    add rax, '0'
    mov _print_output[r15], rax
    memory_move _to_be_printed, _quotient

    mov r14, [_to_be_printed]
    or r14, [_to_be_printed+8]
    or r14, [_to_be_printed+16]
    or r14, [_to_be_printed+24]
    jz end_digits_loop

    sub r15, 8
    cmp r15, 0
    jge digits_loop
  end_digits_loop:

  cmp r13, 0
  je print_loop
    mov rdi, '-'
    stack_alignment_begin
    call print_char
    stack_alignment_end
  print_loop:
    mov rdi, _print_output[r15]
    stack_alignment_begin
    call print_char
    stack_alignment_end
    add r15, 8
    cmp r15, 800
    jl print_loop

  pop r13
  pop r14
  pop r15
  ret
%macro print_256bit_int 1
  ; mov rdi, [\x+24]
  ; call print_int
  ; mov rdi, [\x+16]
  ; call print_int
  ; mov rdi, [\x+8]
  ; call print_int
  ; mov rdi, [\x]
  ; call print_int
  memory_move _to_be_printed, %1
  call _print_256bit_int
%endmacro


_read_256bit_int:
  push r15
  push_256bit b
  push_256bit c
  mov r15, 0
  memory_move b, one
  input_loop:
    stack_alignment_begin
    call read_char
    stack_alignment_end
    cmp rax, 10
    je end_input_loop
    cmp rax, ' '
    je end_input_loop
    cmp rax, '-'
    jne skip_sign
      mov r15, 1
      jmp input_loop
    skip_sign:

    memory_move c, _read_output
    mul_256bit _read_output, c, ten
    sub rax, '0'
    jz input_loop
    f:
      add_256bit _read_output, one
      dec rax
      jnz f
    jmp input_loop
  end_input_loop:
  cmp r15, 1
  jne skip_negation
  negate_256bit _read_output
  skip_negation:
  pop_256bit c
  pop_256bit b
  pop r15
  ret
%macro read_256bit_int 1
  push_256bit _read_output
  call _read_256bit_int
  memory_move %1, _read_output
  pop_256bit _read_output
%endmacro

%macro print_nl 0
  mov rdi, 10
  call print_char
%endmacro

asm_main:
  main_loop:
    stack_alignment_begin
    call read_char
    stack_alignment_end
    cmp rax, 10
    je main_loop
    cmp rax, ' '
    je main_loop
    cmp rax, 'q'
    je end_main_loop

    cmp rax, '+'
    jne not_add
      call read_char
      read_256bit_int a
      read_256bit_int b
      add_256bit a, b
      print_256bit_int a
      print_nl
      jmp main_loop
    not_add:

    cmp rax, '-'
    jne not_sub
      call read_char
      read_256bit_int a
      read_256bit_int b
      sub_256bit a, b
      print_256bit_int a
      print_nl
      jmp main_loop
    not_sub:

    cmp rax, '*'
    jne not_mul
      call read_char
      read_256bit_int a
      read_256bit_int b
      mul_256bit c, a, b
      print_256bit_int c
      print_nl
      jmp main_loop
    not_mul:

    cmp rax, '/'
    jne not_div
      call read_char
      read_256bit_int a
      read_256bit_int b
      div_256bit a, b
      print_256bit_int _quotient
      print_nl
      jmp main_loop
    not_div:

    cmp rax, '%'
    jne not_rem
      call read_char
      read_256bit_int a
      read_256bit_int b
      div_256bit a, b
      print_256bit_int _remainder
      print_nl
      jmp main_loop
    not_rem:

    jmp main_loop

  end_main_loop:
  ret

