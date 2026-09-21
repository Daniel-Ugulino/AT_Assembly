/* conversao.s — inteiro positivo → ASCII com '\0' */

    .text
    .align  2

/*
 * ascii
 *   x0 = valor (rejeita negativo)
 *   x1 = buffer
 *   x2 = capacidade (>= 2)
 *   volta x0 = tamanho, ou -1
 */
    .global ascii
ascii:
    cbz     x1, erro
    cmp     x2, #2
    b.lo    erro
    tbnz    x0, #63, erro

    mov     x3, x1
    mov     x4, x2
    mov     x5, x0

    cbnz    x5, digitos
    mov     w6, #'0'
    strb    w6, [x3]
    strb    wzr, [x3, #1]
    mov     x0, #1
    ret

digitos:
    sub     sp, sp, #32
    mov     x6, #0
    mov     x7, #10
divide:
    cbz     x5, inverte
    add     x8, x6, #1
    sub     x9, x4, #1
    cmp     x8, x9
    b.hi    cheio
    udiv    x10, x5, x7
    msub    x11, x10, x7, x5
    add     w11, w11, #'0'
    strb    w11, [sp, x6]
    add     x6, x6, #1
    mov     x5, x10
    b       divide

inverte:
    mov     x8, #0
copia:
    cmp     x8, x6
    b.eq    fim
    sub     x9, x6, x8
    sub     x9, x9, #1
    ldrb    w10, [sp, x9]
    strb    w10, [x3, x8]
    add     x8, x8, #1
    b       copia
fim:
    strb    wzr, [x3, x6]
    mov     x0, x6
    add     sp, sp, #32
    ret
cheio:
    add     sp, sp, #32
erro:
    mov     x0, #-1
    ret
