.ifndef MACROS_INC
.equ    MACROS_INC, 1

.equ    N,           8
.equ    BIT_ALARME,  2
.equ    BIT_BATERIA, 3

.macro  adr64 dest, sim
    adrp    \dest, \sim
    add     \dest, \dest, :lo12:\sim
.endm

.macro  MSG nome, texto
\nome:
    .ascii  "\texto"
    .equ    \nome\()_len, . - \nome
.endm

.macro  print buf, len
    mov     x8, #64
    mov     x0, #1
    adr64   x1, \buf
    mov     x2, \len
    svc     #0
.endm

.macro  printx ptr, len
    mov     x2, \len
    mov     x1, \ptr
    mov     x0, #1
    mov     x8, #64
    svc     #0
.endm

.macro  printz nome
    print   \nome, \nome\()_len
.endm

.macro  linha txt, reg
    printz  \txt
    mov     x0, \reg
    bl      mostra
    printz  msg_nl
.endm

.macro  sair code
    mov     x0, \code
    mov     x8, #93
    svc     #0
.endm

.endif
