#include "textflag.h"

// func calculateRotatedDimensions(width, height int, cosAngle, sinAngle float64) (newWidth, newHeight int)
TEXT ·calculateRotatedDimensions(SB), NOSPLIT, $0-40
    // params
    MOVQ width+0(FP), AX // width
    MOVQ height+8(FP), BX // height
    MOVSD cosAngle+16(FP), X0 // cosAngle
    MOVSD sinAngle+24(FP), X1 // sinAngle
    
    // convert to float64
    CVTSQ2SD AX, X2 // width
    CVTSQ2SD BX, X3 // height

    // abs implementation, compare if more than 0, if not 0 - that value
    // absCos = abs(cosAngle)
    MOVSD X0, X4 // cosAngle
    XORPD X6, X6 // 0
    COMISD X6, X4 // compare with 0
    JCC abs_cos_done // if >= 0, skip, https://www.felixcloutier.com/x86/jcc
    XORPD X7, X7 // x7 = 0
    SUBSD X4, X7 // x7 = 0 - cosAngle
    MOVSD X7, X4 // x5 = -cosAngle

abs_cos_done:
    // absSin = abs(sinAngle)
    MOVSD X1, X5 // sinAngle
    XORPD X6, X6 // 0
    COMISD X6, X5 // compare 0
    JCC abs_sin_done // if >= 0, skip
    XORPD X7, X7 // x7 = 0
    SUBSD X5, X7 // x7 = 0 - sinAngle
    MOVSD X7, X5 // x5 = -sinAngle

abs_sin_done:
    // newWidth = ceil(width * absCos + height * absSin)
    MOVSD X2, X6 // x6 = width
    MULSD X4, X6 // x6 = width * absCos
    MOVSD X3, X7 // x7 = height
    MULSD X5, X7 // x7 = height * absSin
    ADDSD X7, X6 // x6 = width * absCos + height * absSin
    
    // ceil
    ROUNDSD $0x02, X6, X6 // https://www.felixcloutier.com/x86/roundsd
    CVTTSD2SQ X6, CX // cx = convert newWidth to int
    
    // newHeight = ceil(width * absSin + height * absCos)
    MOVSD X2, X6 // x6 = width
    MULSD X5, X6 // x6 = width * absSin
    MOVSD X3, X7 // x7 = height
    MULSD X4, X7 // x7 = height * absCos
    ADDSD X7, X6 // x6 = width * absSin + height * absCos
    
    // ceil
    ROUNDSD $0x02, X6, X6 // same
    CVTTSD2SQ X6, DX // dx = newHeight
    
    // store results
    MOVQ CX, newWidth+32(FP) // newWidth
    MOVQ DX, newHeight+40(FP) // newHeight
    
    RET

// func rotateImage(dstPix, srcPix []byte, dstStride, srcStride int, dstWidth, dstHeight int, srcWidth, srcHeight int, cosAngle, sinAngle float64, centerX, centerY float64, newCenterX, newCenterY float64)
TEXT ·rotateImage(SB), NOSPLIT, $0-152
    // params,
    MOVQ dstPix_data+0(FP), AX // dest pixel
    MOVQ srcPix_data+24(FP), BX // src pixel
    MOVQ dstStride+48(FP), R8 // dest stride
    MOVQ srcStride+56(FP), R9 // src stride
    MOVQ dstWidth+64(FP), R10 // dest width
    MOVQ dstHeight+72(FP), R11 // dest height
    MOVQ srcWidth+80(FP), R12 // src width
    MOVQ srcHeight+88(FP), R13 // src height
    
    MOVSD cosAngle+96(FP), X0  // cos(angle)
    MOVSD sinAngle+104(FP), X1 // sin(angle)
    MOVSD centerX+112(FP), X2 // src center x
    MOVSD centerY+120(FP), X3 // src center y
    MOVSD newCenterX+128(FP), X4 // dest center x
    MOVSD newCenterY+136(FP), X5 // dest center y
    
    // 0 check
    CMPQ R10, $0
    JE done
    CMPQ R11, $0
    JE done
    
    // init y loop counter
    XORQ R14, R14 // y = 0
    
y_loop:
    CMPQ R14, R11 // compare y with dstHeight
    JGE done
    
    // x loop counter
    XORQ R15, R15 // x = 0
    
x_loop:
    CMPQ R15, R10 // compare x with dstWidth
    JGE y_loop_next
    
    // convert current pixel to float
    CVTSQ2SD R15, X6 // x6 = x
    CVTSQ2SD R14, X7 // x7 = y
    
    // translate
    SUBSD X4, X6 // x6 = x - newCenterX
    SUBSD X5, X7 // x7 = y - newCenterY
    
    // inverse rotation matrix
    // srcX = x * cos + y * sin + centerX
    // srcY = -x * sin + y * cos + centerY
    MOVSD X6, X8 // x8 = x_new
    MOVSD X7, X9 // x9 = y_new
    
    MULSD X0, X8 // x8 = x_new * cos
    MOVSD X9, X10 // x10 = y_new
    MULSD X1, X10 // x10 = y_new * sin
    ADDSD X10, X8 // x8 = x_new * cos + y_new * sin
    ADDSD X2, X8 // x8 = srcX (x_new * cos + y_new * sin + centerX)
    
    MOVSD X6, X9 // x9 = x_new
    MULSD X1, X9 // x9 = x_new * sin
    MOVSD X7, X10 // x10 = y_new
    MULSD X0, X10 // x10 = y_new * cos
    SUBSD X9, X10 // x10 = y_new * cos - x_new * sin
    ADDSD X3, X10 // x10 = srcY (y_new * cos - x_new * sin + centerY)
    
    // convert to ints
    CVTTSD2SQ X8, SI // srcX
    CVTTSD2SQ X10, DI // srcY
    
    // bounds check
    CMPQ SI, $0
    JL fill_black
    CMPQ DI, $0
    JL fill_black
    CMPQ SI, R12
    JGE check_x_bound
    CMPQ DI, R13
    JGE fill_black
    JMP in_bounds
    
check_x_bound:
    DECQ SI // https://www.felixcloutier.com/x86/dec
    CMPQ SI, R12
    JGE fill_black // jump greater equal
    
in_bounds:
    // calculate offset
    // srcY * srcStride + srcX * 4
    MOVQ DI, CX // cx = srcY
    IMULQ R9, CX // cx = srcY * srcStride signed mul: https://www.felixcloutier.com/x86/imul
    MOVQ SI, DX // dx = srcX
    SHLQ $2, DX // dx = srcX * 4 (rgba = 4 bytes) https://www.felixcloutier.com/x86/sal:sar:shl:shr
    ADDQ DX, CX // cx = offset in src
    
    // load rgba pixel
    MOVL (BX)(CX*1), DX // 4 bytes
    
    // dest offset
    // dstY * dstStride + dstX * 4
    MOVQ R14, CX // cx = y (dstY)
    IMULQ R8, CX // cx = dstY * dstStride use signed mul
    MOVQ R15, SI // si = x (dstX)
    SHLQ $2, SI // si = dstX * 4
    ADDQ SI, CX // cx = offset in dest
    
    // save
    MOVL DX, (AX)(CX*1) // rgba 4 byets, use movl
    JMP x_loop_next
    
fill_black:
    // 0x00 00 00 00 black transparet
    MOVQ R14, CX // cx = y (dstY)
    IMULQ R8, CX // cx = dstY * dstStride use signed mul
    MOVQ R15, SI // si = x (dstX)
    SHLQ $2, SI // si = dstX * 4
    ADDQ SI, CX // cx = offset in dest
    
    MOVL $0, (AX)(CX*1) // save 0x00 00 00 00
    
x_loop_next:
    INCQ R15 // x++
    JMP x_loop
    
y_loop_next:
    INCQ R14 // y++
    JMP y_loop
    
done:
    RET
