#include "textflag.h"

// func andBytes(dst, a, b []byte)
TEXT ·andBytes(SB), NOSPLIT, $0-72
    MOVQ dst_data+0(FP), BX
    MOVQ a_data+24(FP), SI
    MOVQ b_data+48(FP), DI
    MOVQ a_len+32(FP), CX

    CMPQ CX, $0
    JE done_and

    MOVQ CX, R8
    XORQ R9, R9

// 8 bytes at a time
loop_and_qword:
    CMPQ R8, $8
    JL loop_and_byte

    MOVQ (SI)(R9*1), R10
    MOVQ (DI)(R9*1), R11
    ANDQ R11, R10
    MOVQ R10, (BX)(R9*1)
    ADDQ $8, R9
    SUBQ $8, R8
    JMP loop_and_qword

// cant do 8 bytes
loop_and_byte:
    CMPQ R8, $0
    JE done_and

    MOVB (SI)(R9*1), R10B
    MOVB (DI)(R9*1), R11B
    ANDB R10B, R11B
    MOVB R11B, (BX)(R9*1)
    INCQ R9
    DECQ R8
    JMP loop_and_byte

done_and:
    RET

// func orBytes(dst, a, b []byte)
TEXT ·orBytes(SB), NOSPLIT, $0-72
    MOVQ dst_data+0(FP), BX
    MOVQ a_data+24(FP), SI
    MOVQ b_data+48(FP), DI
    MOVQ a_len+32(FP), CX

    CMPQ CX, $0
    JE done_or

    MOVQ CX, R8
    XORQ R9, R9

// 8 bytes at a time
loop_or_qword:
    CMPQ R8, $8
    JL loop_or_byte

    MOVQ (SI)(R9*1), R10
    MOVQ (DI)(R9*1), R11
    ORQ R11, R10 // same as and but with or
    MOVQ R10, (BX)(R9*1)
    ADDQ $8, R9
    SUBQ $8, R8
    JMP loop_or_qword

// cant do 8 bytes
loop_or_byte:
    CMPQ R8, $0
    JE done_or

    MOVB (SI)(R9*1), R10B
    MOVB (DI)(R9*1), R11B
    ORB R10B, R11B
    MOVB R11B, (BX)(R9*1)
    INCQ R9
    DECQ R8
    JMP loop_or_byte

done_or:
    RET

// func xorBytes(dst, a, b []byte)
TEXT ·xorBytes(SB), NOSPLIT, $0-72
    MOVQ dst_data+0(FP), BX
    MOVQ a_data+24(FP), SI
    MOVQ b_data+48(FP), DI
    MOVQ a_len+32(FP), CX

    CMPQ CX, $0
    JE done_xor 

    MOVQ CX, R8
    XORQ R9, R9

// 8 bytes at a time
loop_xor_qword:
    CMPQ R8, $8
    JL loop_xor_byte 

    MOVQ (SI)(R9*1), R10
    MOVQ (DI)(R9*1), R11
    XORQ R11, R10
    MOVQ R10, (BX)(R9*1)
    ADDQ $8, R9
    SUBQ $8, R8
    JMP loop_xor_qword
    

// cant do 8 bytes
loop_xor_byte:
    CMPQ R8, $0
    JE done_xor

    MOVB (SI)(R9*1), R10B
    MOVB (DI)(R9*1), R11B
    XORB R10B, R11B
    MOVB R11B, (BX)(R9*1)
    INCQ R9
    DECQ R8
    JMP loop_xor_byte

done_xor:
    RET

// func notBytes(dst, a []byte)
TEXT ·notBytes(SB), NOSPLIT, $0-48
    MOVQ dst_data+0(FP), BX
    MOVQ a_data+24(FP), SI
    MOVQ a_len+32(FP), CX

    CMPQ CX, $0
    JE done_not

    MOVQ CX, R8
    XORQ R9, R9

// 8 bytes at a time
loop_not_qword:
    CMPQ R8, $8
    JL loop_not_byte

    MOVQ (SI)(R9*1), R10
    NOTQ R10
    MOVQ R10, (BX)(R9*1)
    ADDQ $8, R9
    SUBQ $8, R8
    JMP loop_not_qword

// cant do 8 bytes
loop_not_byte:
    CMPQ R8, $0
    JE done_not

    MOVB (SI)(R9*1), R10B
    NOTB R10B
    MOVB R10B, (BX)(R9*1)
    INCQ R9
    DECQ R8
    JMP loop_not_byte

done_not:
    RET
