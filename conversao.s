/* conversao.s — inteiro positivo → ASCII com '\0' */

    .text
    .align  2

/* ascii  x0=valor  x1=buffer  →  x0=tamanho */
    .global ascii
ascii:
    mov     x3, x1
    mov     x4, x0
    mov     x5, #0
    mov     x6, #10
    sub     sp, sp, #32
1:
    udiv    x7, x4, x6
    msub    x8, x7, x6, x4
    add     w8, w8, #'0'
    strb    w8, [sp, x5]
    add     x5, x5, #1
    mov     x4, x7
    cbnz    x4, 1b

    mov     x7, #0
2:
    sub     x8, x5, x7
    sub     x8, x8, #1
    ldrb    w9, [sp, x8]
    strb    w9, [x3, x7]
    add     x7, x7, #1
    cmp     x7, x5
    b.lo    2b

    strb    wzr, [x3, x5]
    mov     x0, x5
    add     sp, sp, #32
    ret
