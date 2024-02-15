; xmm0 = A[%1][%2]
%macro get_value 2
    push rax
    mov rax, [n]
    inc rax
    imul rax, %1
    add rax, %2
    movsd xmm0, A[8*rax]
    pop rax
%endmacro

; rax = *A[%1][%2]
%macro get_index 2
    mov rax, [n]
    inc rax
    imul rax, %1
    add rax, %2
%endmacro

%macro absd 1
    xorpd xmm7, xmm7
    subpd xmm7, %1
    maxpd %1, xmm7
%endmacro

segment .data
int_format: db    "%ld", 0
double_format: db  "%lf", 0
double_print_format: db  "%0.3lf ", 0
A: times 1001000 dq 0
x: times 1000 dq 0
n: dw 0 ; input n
epsilon: dq 0.0000001
string: db "Impossible", 0


segment .text

extern puts
extern putchar
extern scanf
extern printf
global asm_main

; returns 1 if impossible, 0 O.W.
partial_pivot:
    push rbp
    push rbx        ;n
    push r12
    push r13        ;l3 counter
    push r14        ;l2 counter
    push r15        ;l1 counter
    sub rsp, 8

    movsd xmm6, [epsilon] ;xmm6 = 1e-6
    mov rbx, [n]    ;rbx = n
    xor r15, r15    ;r15 = i
    l11:
        cmp r15, rbx
        jge el11

        mov r12, r15    ;pivotrow = i
        xor r13, r13    ;foundnz
        mov r14, r15    ;j = i
        l12:
            cmp r14, rbx
            jge el12

            get_value r14, r15
            movsd xmm2, xmm0
            absd xmm2
            comisd xmm2, xmm6   ;if (fabs(A[j][i]) > 1e-6 )
            jb zero
            lea r13, [1]
            zero:
            get_value r12, r15
            movq xmm1, xmm0
            absd xmm1
            comisd xmm2, xmm1   ;if (fabs(A[j][i]) > fabs(A[pivotRow][i]))
            jb less
            mov r12, r14    ;pivotrow = j
            less:

            inc r14     ;j++
            jmp l12
        el12:

        cmp r13, 0
        je solution_not_found   ;return 1
        cmp r12, r15
        je dont_swap
        ;swap A[i][.] with A[pivotRow][.]
        mov r14, r15 ;j = i
        l21:
            cmp r14, rbx
            jg el21

            get_value r15, r14    ;temp = A[i][j]
            movq xmm3, xmm0
            get_value r12, r14
            movq xmm1, xmm0
            get_index r15, r14
            movq A[8*rax], xmm1         ;A[i][j] = A[pivotRow][j];
            get_index r12, r14
            movq A[8*rax], xmm3         ;A[pivotRow][j] = temp;

            inc r14 ;j++
            jmp l21
        el21:
        dont_swap:

        lea r14, 1[r15] ;j = i + 1
        l31:
            cmp r14, rbx
            jge el31

            get_value r14, r15
            movq xmm2, xmm0
            get_value r15, r15
            movq xmm1, xmm0
            divsd xmm2, xmm1    ;factor = A[j][i] / A[i][i];
            mov r13, r15        ;k = i
            l32:
                cmp r13, rbx
                jg el32

                get_value r14, r13
                movq xmm4, xmm0
                get_value r15, r13
                movq xmm3, xmm0
                mulsd xmm3, xmm2    ;factor * A[i][k]
                subsd xmm4, xmm3    ;xmm4 -= factor * A[i][k]
                get_index r14, r13
                movq A[8*rax], xmm4 ;A[j][k] -= factor * A[i][k];

                inc r13         ;k++
                jmp l32
            el32:

            inc r14 ;j++
            jmp l31
        el31:

        inc r15         ;i++
        jmp l11
    el11:
    
    xor rax, rax
    jmp solution_found  ;return 0
    solution_not_found:
    lea rax, [1]        ;return 1
    solution_found:

    add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


back_substitute:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov rbx, [n]    ;rbx = n
    lea r15, -1[rbx]    ;i = n-1
    l41:
        ; xor r12, r12 ;0
        cmp r15, 0
        jl el41

        xorpd xmm5, xmm5 ;sum = 0
        lea r14, 1[r15] ;j = i + 1
        l42:
            cmp r14, rbx
            jge el42

            get_value r15, r14
            movq xmm1, xmm0
            movsd xmm2, x[8*r14]
            mulsd xmm1, xmm2    ;A[i][j] * x[j];
            addsd xmm5, xmm1    ;sum += A[i][j] * x[j];

            inc r14 ;j++
            jmp l42
        el42:

        get_value r15, rbx
        movsd xmm1, xmm0
        subsd xmm1, xmm5    ;A[i][n] - sum
        get_value r15, r15
        movsd xmm2, xmm0
        divsd xmm1, xmm2    ;(A[i][n] - sum) / A[i][i]
        movsd x[8*r15], xmm1 ;x[i] = (A[i][n] - sum) / A[i][i]

        dec r15
        jmp l41
    el41:

    add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp
    ret

asm_main:
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    call read_int
    lea r15, 1[rax] ;end condition
    mov [n], rax
    imul rax, r15
    mov r15, rax ; r15 = n * (n+1)
    xor r14, r14 ;outer loop counter and index
    l1:
        cmp r14, r15
        jge l1end
        call read_double
        movq A[8*r14], xmm0
        inc r14
        jmp l1
    l1end:

    call partial_pivot

    ; ; print A
    ; xor r14, r14 ;outer loop counter and index
    ; l2:
    ;     cmp r14, r15
    ;     jge l2end
    ;     movq xmm0, A[8*r14]
    ;     call print_double
    ;     inc r14
    ;     jmp l2
    ; l2end:

    cmp rax, 1
    je impossible ;if no answer, print Impossible and terminate


    call back_substitute

    ;print x
    xor r14, r14 ;outer loop counter and index
    mov r15, [n]
    l3:
        cmp r14, r15
        jge l3end
        movsd xmm0, x[8*r14]
        call print_double
        inc r14
        jmp l3
    l3end:
    jmp terminate

    impossible:
    call print_string
    terminate:

    add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


print_int:
    sub rsp, 8

    mov rsi, rdi

    mov rdi, int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call printf
    
    add rsp, 8 ; clearing local variables from stack

    ret


read_int:
    sub rsp, 8

    mov rsi, rsp
    mov rdi, int_format
    mov rax, 1 ; setting rax (al) to number of vector inputs
    call scanf

    mov rax, [rsp]

    add rsp, 8 ; clearing local variables from stack
    ret


read_double:
    sub rsp, 8 ; allocate 8 bytes on the stack for the double

    mov rdi, double_format ; first argument is the format string
    mov rsi, rsp ; second argument is the address of the double
    xor rax, rax ; rax should be set to the number of vector registers used
    call scanf

    movsd xmm0, [rsp] ; move the value from the stack to xmm0

    add rsp, 8 ; clean up the stack
    ret

print_double:
    sub rsp, 8 ; allocate 8 bytes on the stack for the double
    movsd [rsp], xmm0 ; move the value from xmm0 to the stack

    mov rdi, double_print_format ; first argument is the format string
    mov rsi, rsp ; second argument is the address of the double
    mov rax, 1 ; rax should be set to the number of vector registers used
    call printf

    add rsp, 8 ; clean up the stack
    ret

print_nl:
    sub rsp, 8

    mov rdi, 10
    call putchar
    
    add rsp, 8 ; clearing local variables from stack

    ret

print_string:
    sub rsp, 8

    lea rdi, [rel string] ; load the address of the string into rdi
    call puts ; call puts

    add rsp, 8 ; clearing local variables from stack

    ret
