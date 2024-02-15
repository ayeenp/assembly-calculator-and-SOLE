# r6 r7 r8 r9 r10 r13

# r2 = *A[%1][%2]
# MACRO get_index &1, &2    
#       changes r2, r13
    # larl    13, n
    # l       13, 0(13)
    # lay     13, 1(13)
    # mr      12, 6
    # ar      13, 7
    # mhi     13, 8
    # larl    2, A
    # ar      2, 13
# MEND

    # larl    13, n       # get_value r6, r7
    # l       13, 0(13)
    # lay     13, 1(13)
    # mr      12, 6
    # ar      13, 7
    # mhi     13, 8
    # larl    2, A
    # ar      2, 13
    # ld      1, 0(2)     # f1 = get_value j, i

.data
    int_format:         .asciz "%d"
    int_format1:         .asciz "%d"
    int_format2:         .asciz "%d"
    int_format3:         .asciz "%d"
    int_format4:         .asciz "%d"
    int_format5:         .asciz "%d"
    int_format6:         .asciz "%d"
    int_format7:         .asciz "%d"
    double_format:      .asciz "%lf"
    double_format1:      .asciz "%lf"
    double_format2:      .asciz "%lf"
    double_format3:      .asciz "%lf"
    double_format4:      .asciz "%lf"
    double_format5:      .asciz "%lf"
    double_format6:      .asciz "%lf"
    double_format7:      .asciz "%lf"
    double_print_format:    .asciz "%lf "
    double_print_format1:    .asciz "%lf"
    double_print_format2:    .asciz "%lf"
    double_print_format3:    .asciz "%lf"
    double_print_format4:    .asciz "%lf"
    double_print_format5:    .asciz "%lf"
    double_print_format6:    .asciz "%lf"
    double_print_format7:    .asciz "%lf"
    A:                  .zero 8008000
    x:                  .zero 8000
    n:                  .zero 4
    n1:                  .zero 4
    n2:                  .zero 4
    n3:                  .zero 4
    n4:                  .zero 4
    n5:                  .zero 4
    n6:                  .zero 4
    n7:                  .zero 4
    epsilon:            .double 0.0000001
    string:             .asciz  "Impossible"
    string1:             .string  "Impossible"
    string2:             .string  "Impossible"
    string3:             .string  "Impossible"
    string4:             .string  "Impossible"
    string5:             .string  "Impossible"
    string6:             .string  "Impossible"
    string7:             .string  "Impossible"
    foundnz:            .zero 4
    foundnz1:            .zero 4


.text
.globl asm_main


partial_pivot:
    stmg    11, 15, -40(15)
    lay     15, -200(15)

    larl    13, n
    l       10, 0(13)   # n
    xr      6, 6        # i
    

    l11:
        cr      6, 10
        jnl     el11

        larl    13, foundnz
        xr      9, 9
        st      9, 0(13)    # foundnz = 0
        lr      9, 6        # pivotRow = i

        lr      7, 6        # j
        l12:
            cr      7, 10
            jnl     el12
            larl    13, n       # get_value j, i
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 7
            ar      13, 6
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      1, 0(2)     # f1 = get_value j, i
            lpdfr   1, 1
            ldr     0, 1
            # brasl   14, print_double
            larl    13, epsilon
            kdb     1, 0(13)
            jl      zero
            larl    13, foundnz
            lhi     8, 1
            st      8, 0(13)    # foundnz = 1
            zero:
            larl    13, n
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 9
            ar      13, 6
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      2, 0(2)     # f1 = get_value pivotRow, i
            lpdfr   2, 2
            kdbr    1, 2
            jl      less
            lr      9, 7        # pivotRow = j
            less:
            lay     7, 1(7)
            j       l12
        el12:
    
        larl    13, foundnz
        l       13, 0(13)    # foundnz
        xr      7, 7
        cr      13, 7
        je      solution_not_found
        cr      6, 9
        je      dont_swap
        # swap A[i][.] with A[pivotRow][.]
        lr      7, 6        # j
        l21:
            cr      7, 10
            jh      dont_swap

            larl    13, n       # get_value r6, r7
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 6
            ar      13, 7
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      3, 0(2)     # f3 = get_value i, j

            larl    13, n       # get_value r9, r7
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 9
            ar      13, 7
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      2, 0(2)     # f2 = get_value pivot_row, j

            larl    13, n
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 6
            ar      13, 7
            mhi     13, 8
            larl    2, A
            ar      2, 13
            std     2, 0(2)     # A[i][j] = A[pivotRow][j];

            larl    13, n       # get_value r9, r7
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 9
            ar      13, 7
            mhi     13, 8
            larl    2, A
            ar      2, 13
            std     3, 0(2)     # A[pivotRow][j] = f3;            

            lay     7, 1(7)
            j       l21
        dont_swap:

        lay    7, 1(6)
        l31:
            cr      7, 10
            jnl     el31
            
            larl    13, n       # get_value r7, r6
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 7
            ar      13, 6
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      2, 0(2)     # f2 = get_value j, i

            larl    13, n       # get_value r6, r6
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 6
            ar      13, 6
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      1, 0(2)     # f1 = get_value i, i

            ddbr    2, 1        # factor = A[j][i] / A[i][i];
            lr      8, 6        # k
            l32:
                cr      8, 10
                jh      el32
                
                larl    13, n       # get_value r6, r8
                l       13, 0(13)
                lay     13, 1(13)
                mr      12, 6
                ar      13, 8
                mhi     13, 8
                larl    2, A
                ar      2, 13
                ld      1, 0(2)     # f1 = get_value i, k

                mdbr    1, 2        # factor * A[i][k]

                larl    13, n       # get_value r7, r8
                l       13, 0(13)
                lay     13, 1(13)
                mr      12, 7
                ar      13, 8
                mhi     13, 8
                larl    2, A
                ar      2, 13
                ld      3, 0(2)     # f3 = get_value j, k

                sdbr    3, 1        # A[j][k] - factor * A[i][k]

                larl    13, n       # get_value r7, r8
                l       13, 0(13)
                lay     13, 1(13)
                mr      12, 7
                ar      13, 8
                mhi     13, 8
                larl    2, A
                ar      2, 13
                std     3, 0(2)     # A[j][k] = f3;

                lay     8, 1(8)
                j       l32
            el32:

            lay     7, 1(7)
            j       l31
        el31:

        lay     6, 1(6)
        j       l11
    el11:

    xr     2, 2
    j      solution_found
    solution_not_found:
    lhi    2, 1
    solution_found:

    lay     15, 200(15)
    lmg     11, 15, -40(15)
    br      14


back_substitute:
    stmg    11, 15, -40(15)
    lay     15, -200(15)

    larl    13, n
    l       10, 0(13)
    lay     6, -1(10)

    l41:
        chi     6, 0
        jl      el41

        lzdr    3   # sum = 0
        lay     7, 1(6)
        l42:
            cr      7, 10
            jnl     el42

            larl    13, n       # get_value r6, r7
            l       13, 0(13)
            lay     13, 1(13)
            mr      12, 6
            ar      13, 7
            mhi     13, 8
            larl    2, A
            ar      2, 13
            ld      2, 0(2)     # f2 = get_value i, j

            lr      9, 7
            mhi     9, 8
            larl    13, x
            ar      13, 9
            ld      1, 0(13)
            mdbr    1, 2
            adbr    3, 1        # sum += A[i][j] * x[j];

            
            lay     7, 1(7)
            j       l42
        el42: 

        larl    13, n       # get_index r6, r10
        l       13, 0(13)
        lay     13, 1(13)
        mr      12, 6
        ar      13, 10
        mhi     13, 8
        larl    2, A
        ar      2, 13
        # ld      4, 0(2)


        sdb     3, 0(2)      
        lcdfr   3, 3        # A[i][n] - sum

        larl    13, n       # get_value r6, r6
        l       13, 0(13)
        lay     13, 1(13)
        mr      12, 6
        ar      13, 6
        mhi     13, 8
        larl    2, A
        ar      2, 13
        ld      2, 0(2)     # f2 = get_value i, i

        ddbr    3, 2        # (A[i][n] - sum) / A[i][i]    

        lr      9, 6
        mhi     9, 8
        larl    13, x
        ar      13, 9
        std     3, 0(13)

        lay     6, -1(6)
        j       l41
    el41:

    lay     15, 200(15)
    lmg     11, 15, -40(15)
    br      14


asm_main:
    stmg    11, 15, -40(15)
    lay     15, -200(15)
	

    brasl   14, read_int 
    larl    13, n
    st      2, 0(13)
    lay     7, 1(2)
    mr      6, 2
    lr      10, 7   # n(n+1)
    xr      6, 6    # counter
    larl    13, A   # ptr to A
    l1:
        cr      6, 10
        jnl     el1
        brasl   14, read_double
        std     0, 0(13)
        lay     13, 8(13)
        lay     6, 1(6)
        j       l1
    el1:

    brasl   14, partial_pivot
#    brasl   14, print_int
#
#    # print A
#    xr      6, 6
#    larl    13, n
#    l       9, 0(13)
#    lay     9, 1(9)
#    l       13, 0(13)
#    mr      8, 13
#    lr      10, 9
#    larl    7, A
#    l2:
#        cr      6, 10
#        jnl     el2
#        ld      0, 0(7)
#        brasl   14, print_double
#        lay     6, 1(6)
#        lay     7, 8(7)
#        j       l2
#    el2:


    chi     2, 1
    je      impossible

    brasl   14, back_substitute

    # print x
    xr      6, 6
    larl    13, n
    l       10, 0(13)
    l3:
        cr      6, 10
        jnl     l3end

        lr      9, 6
        mhi     9, 8
        larl    13, x
        ar      13, 9
        ld      0, 0(13)
        brasl   14, print_double
        
        lay     6, 1(6)
        j       l3
    l3end:
    j terminate

    impossible:
    larl    2, string1
    brasl   14, print_string
    terminate:


    lay     15, 200(15)
    lmg     11, 15, -40(15)
    br      14


read_double: # moves double to f0
    stg     14, -8(15)
    lay     15, -168(15)
    larl    2, double_format
    brasl   14, scanf
    lay     15, 168(15)
    lg      14, -8(15)
    br      14

print_double:   # print double in f0
    stg     14, -8(15)
    lay     15, -168(15)
    larl    2,  double_print_format
    brasl   14, printf
    lay     15, 168(15)
    lg      14, -8(15)
    br      14

print_int:
	stg     14, -8(15)
    lay     15, -168(15)
    lr      3,  2
    larl    2,  int_format
    brasl   14, printf
	lay     15, 168(15)
	lg      14, -8(15)
    br      14

print_nl:
	stg     14, -8(15)
    lay     15, -168(15)
	la      2,  10
    brasl   14, putchar
	lay     15, 168(15)
	lg      14, -8(15)
    br      14

debug:
	stg     14, -8(15)
    lay     15, -168(15)
	la      2,  65
    brasl   14, putchar
	lay     15, 168(15)
	lg      14, -8(15)
    br      14

print_string:
	stg     14, -8(15)
    lay     15, -168(15)
    brasl   14, puts
	lay     15, 168(15)
	lg      14, -8(15)
    br      14

read_int:
	stg     14, -8(15)
    lay     15, -168(15)
    lay     3,  0(15)
    larl    2,  int_format
    brasl   14, scanf
	l       2,  0(15)
	lay     15, 168(15)
	lg      14, -8(15)
    br      14
