/* processamento.s */

    .text
    .align  2

/* validas  x0=status  x1=n  →  x0=qtd bit 0 */
    .global validas
validas:
    mov     x2, #0
    mov     x3, #0
1:
    cmp     x3, x1
    b.hs    2f
    ldrb    w4, [x0, x3]
    and     w4, w4, #1
    add     x2, x2, x4
    add     x3, x3, #1
    b       1b
2:
    mov     x0, x2
    ret

/* soma  x0=valores  x1=status  x2=n  →  x0=soma dos validos */
    .global soma
soma:
    mov     x3, #0
    mov     x4, #0
1:
    cmp     x3, x2
    b.hs    2f
    ldrb    w5, [x1, x3]
    tbz     w5, #0, 3f
    ldr     w6, [x0, x3, lsl #2]
    add     x4, x4, w6, sxtw
3:
    add     x3, x3, #1
    b       1b
2:
    mov     x0, x4
    ret

/* media  x0=soma  x1=qtd  →  x0=soma/qtd */
    .global media
media:
    cbz     x1, 1f
    udiv    x0, x0, x1
    ret
1:
    mov     x0, #0
    ret

/* rotacionar  w0=valor  w1=desloc  (sem ROR) */
    .global rotacionar
rotacionar:
    and     w1, w1, #31
    lsr     w2, w0, w1
    mov     w3, #32
    sub     w3, w3, w1
    lsl     w3, w0, w3
    orr     w0, w2, w3
    ret

/* bit  w0=status  w1=indice  →  0 ou 1 */
    .global bit
bit:
    stp     x29, x30, [sp, #-16]!
    bl      rotacionar
    and     w0, w0, #1
    ldp     x29, x30, [sp], #16
    ret

/* bits  x0=status  x1=n  x2=indice  →  qtd */
    .global bits
bits:
    stp     x29, x30, [sp, #-48]!
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    mov     x22, #0
    mov     x3, #0
1:
    cmp     x3, x20
    b.hs    2f
    ldrb    w0, [x19, x3]
    mov     w1, w21
    stp     x3, xzr, [sp, #-16]!
    bl      bit
    ldp     x3, xzr, [sp], #16
    add     x22, x22, x0
    add     x3, x3, #1
    b       1b
2:
    mov     x0, x22
    ldp     x19, x20, [sp, #16]
    ldp     x21, x22, [sp, #32]
    ldp     x29, x30, [sp], #48
    ret

/* empacotar  x0,x1,x2 → bat<<16 | alarme<<8 | validas */
    .global empacotar
empacotar:
    and     w0, w0, #0xFF
    and     w1, w1, #0xFF
    and     w2, w2, #0xFF
    orr     w0, w0, w1, lsl #8
    orr     w0, w0, w2, lsl #16
    ret

/* aplica_lut  saida = lut[i] se status[i] valido
 * (nao pode se chamar lut: esse nome ja e o vetor em .data) */
    .global aplica_lut
aplica_lut:
    mov     x5, #0
    mov     x6, #0
1:
    cmp     x5, x2
    b.hs    3f
    ldrb    w8, [x1, x5]
    tbz     w8, #0, 2f
    ldr     w12, [x3, x5, lsl #2]
    str     w12, [x4, x6, lsl #2]
    add     x6, x6, #1
2:
    add     x5, x5, #1
    b       1b
3:
    mov     x0, x6
    ret

/* soma4  NEON: soma valores[0..3] */
    .global soma4
soma4:
    ld1     {v0.4s}, [x0]
    addv    s1, v0.4s
    fmov    w0, s1
    sxtw    x0, w0
    ret

/* normaliza  NEON: 4 ints → float / 1000.0 em [x1] */
    .global normaliza
normaliza:
    ld1     {v0.4s}, [x0]
    scvtf   v0.4s, v0.4s
    adrp    x2, mil
    add     x2, x2, :lo12:mil
    ld1r    {v1.4s}, [x2]
    fdiv    v0.4s, v0.4s, v1.4s
    st1     {v0.4s}, [x1]
    ret

    .section .rodata
    .balign 16
mil:
    .float  1000.0
