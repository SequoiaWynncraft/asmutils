// +build arm64

#include "textflag.h"

// func andBytes(dst, a, b []byte)
TEXT ·andBytes(SB), NOSPLIT, $0-72
    MOVD dst_data+0(FP), R0
    MOVD a_data+24(FP), R1
    MOVD b_data+48(FP), R2
    MOVD a_len+32(FP), R3

    CBZ R3, done_and
    MOVD R3, R4      // R4 = remaining
    MOVD $0, R5      // R5 = offset

loop_and_qword:
    CMP R4, $8
    BLT loop_and_byte
    LDR R6, [R1, R5]
    LDR R7, [R2, R5]
    AND R6, R7, R8
    STR R8, [R0, R5]
    ADD $8, R5, R5
    SUB $8, R4, R4
    B   loop_and_qword

loop_and_byte:
    CBZ R4, done_and
    LDRB R6, [R1, R5]
    LDRB R7, [R2, R5]
    AND R6, R7, R8
    STRB R8, [R0, R5]
    ADD $1, R5, R5
    SUB $1, R4, R4
    B   loop_and_byte

done_and:
    RET

// func orBytes(dst, a, b []byte)
TEXT ·orBytes(SB), NOSPLIT, $0-72
    MOVD dst_data+0(FP), R0
    MOVD a_data+24(FP), R1
    MOVD b_data+48(FP), R2
    MOVD a_len+32(FP), R3

    CBZ R3, done_or
    MOVD R3, R4
    MOVD $0, R5

loop_or_qword:
    CMP R4, $8
    BLT loop_or_byte
    LDR R6, [R1, R5]
    LDR R7, [R2, R5]
    ORR R6, R7, R8
    STR R8, [R0, R5]
    ADD $8, R5, R5
    SUB $8, R4, R4
    B   loop_or_qword

loop_or_byte:
    CBZ R4, done_or
    LDRB R6, [R1, R5]
    LDRB R7, [R2, R5]
    ORR R6, R7, R8
    STRB R8, [R0, R5]
    ADD $1, R5, R5
    SUB $1, R4, R4
    B   loop_or_byte

done_or:
    RET

// func xorBytes(dst, a, b []byte)
TEXT ·xorBytes(SB), NOSPLIT, $0-72
    MOVD dst_data+0(FP), R0
    MOVD a_data+24(FP), R1
    MOVD b_data+48(FP), R2
    MOVD a_len+32(FP), R3

    CBZ R3, done_xor
    MOVD R3, R4
    MOVD $0, R5

loop_xor_qword:
    CMP R4, $8
    BLT loop_xor_byte
    LDR R6, [R1, R5]
    LDR R7, [R2, R5]
    EOR R6, R7, R8
    STR R8, [R0, R5]
    ADD $8, R5, R5
    SUB $8, R4, R4
    B   loop_xor_qword

loop_xor_byte:
    CBZ R4, done_xor
    LDRB R6, [R1, R5]
    LDRB R7, [R2, R5]
    EOR R6, R7, R8
    STRB R8, [R0, R5]
    ADD $1, R5, R5
    SUB $1, R4, R4
    B   loop_xor_byte

done_xor:
    RET

// func notBytes(dst, a []byte)
TEXT ·notBytes(SB), NOSPLIT, $0-48
    MOVD dst_data+0(FP), R0
    MOVD a_data+24(FP), R1
    MOVD a_len+32(FP), R2

    CBZ R2, done_not
    MOVD R2, R3
    MOVD $0, R4

loop_not_qword:
    CMP R3, $8
    BLT loop_not_byte
    LDR R5, [R1, R4]
    MVN R5, R5
    STR R5, [R0, R4]
    ADD $8, R4, R4
    SUB $8, R3, R3
    B   loop_not_qword

loop_not_byte:
    CBZ R3, done_not
    LDRB R5, [R1, R4]
    MVN R5, R5
    STRB R5, [R0, R4]
    ADD $1, R4, R4
    SUB $1, R3, R3
    B   loop_not_byte

done_not:
    RET
