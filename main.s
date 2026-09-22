
.include "macros.inc"

.data
.balign 16
.global valores
valores:
    .word   10, 20, 30, 40, 50, 60, 70, 80

.global status
status:
    .byte   0x01, 0x01, 0x05, 0x01, 0x09, 0x01, 0x00, 0x01

.balign 16
.global lut
lut:
    .word   100, 200, 300, 400, 500, 600, 700, 800

MSG     msg_validas, "Amostras validas : "
MSG     msg_soma,    "Soma: "
MSG     msg_media,   "Media inteira: "
MSG     msg_alarme,  "Alarmes: "
MSG     msg_bat,     "Bateria baixa: "
MSG     msg_lut,     "Valores LUT: "
MSG     msg_simd,    "Soma SIMD (4): "
MSG     msg_norm,    "Normalizacao SIMD: "
MSG     msg_nl,      "\n"
MSG     msg_sp,      " "
MSG     msg_dot,     "0."

.bss
.balign 16
.global lut_saida
lut_saida:

.skip   32
.global norm_saida

norm_saida:
    .skip   16
    
num_buf:
    .skip   16

.text
.align  2
.global _start
_start:
    stp     x29, x30, [sp, #-80]!
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]

    adr64   x0, status
    mov     x1, N
    bl      validas
    mov     x19, x0

    adr64   x0, valores
    adr64   x1, status
    mov     x2, N
    bl      soma
    mov     x20, x0

    mov     x0, x20
    mov     x1, x19
    bl      media
    mov     x21, x0

    .global ponto

ponto:
    nop

    /* 2. bits */
    adr64   x0, status
    mov     x1, N
    mov     x2, BIT_ALARME
    bl      bits
    mov     x22, x0

    adr64   x0, status
    mov     x1, N
    mov     x2, BIT_BATERIA
    bl      bits
    mov     x23, x0

    /* 3. LUT */
    adr64   x0, valores
    adr64   x1, status
    mov     x2, N
    adr64   x3, lut
    adr64   x4, lut_saida
    bl      aplica_lut
    mov     x25, x0

    /* 4. NEON */
    adr64   x0, valores
    bl      soma4
    mov     x26, x0

    adr64   x0, lut_saida
    adr64   x1, norm_saida
    bl      normaliza

    /* 5. relatorio */
    linha   msg_validas, x19
    linha   msg_soma,    x20
    linha   msg_media,   x21
    linha   msg_alarme,  x22
    linha   msg_bat,     x23

    printz  msg_lut
    adr64   x0, lut_saida
    mov     x1, x25
    bl      lista
    printz  msg_nl

    linha   msg_simd, x26

    printz  msg_norm
    bl      lista_norm
    printz  msg_nl

    sair    #0

/* mostra: x0 = inteiro → stdout */
mostra:
    stp     x29, x30, [sp, #-16]!
    adr64   x1, num_buf
    mov     x2, #16
    bl      ascii
    adr64   x1, num_buf
    printx  x1, x0
    ldp     x29, x30, [sp], #16
    ret

/* lista: x0 = vetor .word  x1 = n */
lista:
    stp     x29, x30, [sp, #-48]!
    stp     x19, x20, [sp, #16]
    stp     x21, xzr, [sp, #32]
    mov     x19, x0
    mov     x20, x1
    mov     x21, #0
1:
    cmp     x21, x20
    b.hs    2f
    ldr     w0, [x19, x21, lsl #2]
    bl      mostra
    add     x21, x21, #1
    cmp     x21, x20
    b.hs    2f
    printz  msg_sp
    b       1b
2:
    ldp     x21, xzr, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret

/* lista_norm: 4 floats de norm_saida como 0.xxx */
lista_norm:
    stp     x29, x30, [sp, #-32]!
    stp     x20, x21, [sp, #16]
    mov     x21, #0
1:
    cmp     x21, #4
    b.hs    2f
    adr64   x9, norm_saida
    ldr     s0, [x9, x21, lsl #2]
    mov     w1, #1000
    ucvtf   s1, w1
    fmul    s0, s0, s1
    fcvtns  w20, s0
    printz  msg_dot
    mov     x0, x20
    bl      mostra
    add     x21, x21, #1
    cmp     x21, #4
    b.hs    2f
    printz  msg_sp
    b       1b
2:
    ldp     x20, x21, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
