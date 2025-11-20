package fastbitwise

import (
	"errors"
)

var ErrMismatchedLengths = errors.New("slices must be of the same length")

// wrapper to asm
func AndImpl(a, b []byte) ([]byte, error) {
	if len(a) != len(b) {
		return nil, ErrMismatchedLengths
	}

	result := make([]byte, len(a))
	if len(a) > 0 {
		andBytes(result, a, b)
	}
	return result, nil
}

func OrImpl(a, b []byte) ([]byte, error) {
	if len(a) != len(b) {
		return nil, ErrMismatchedLengths
	}

	result := make([]byte, len(a))
	if len(a) > 0 {
		orBytes(result, a, b)
	}
	return result, nil
}

func XorImpl(a, b []byte) ([]byte, error) {
	if len(a) != len(b) {
		return nil, ErrMismatchedLengths
	}

	result := make([]byte, len(a))
	if len(a) > 0 {
		xorBytes(result, a, b)
	}
	return result, nil
}

func NotImpl(a []byte) ([]byte, error) {
	result := make([]byte, len(a))
	if len(a) > 0 {
		notBytes(result, a)
	}
	return result, nil
}

// stubs for asm impl
// noescape for preventing it from going to the heap

//go:noescape
func andBytes(dst, a, b []byte)

//go:noescape
func orBytes(dst, a, b []byte)

//go:noescape
func xorBytes(dst, a, b []byte)

//go:noescape
func notBytes(dst, a []byte)

// exports
func And(a, b []byte) ([]byte, error) {
	return AndImpl(a, b)
}

func Or(a, b []byte) ([]byte, error) {
	return OrImpl(a, b)
}

func Xor(a, b []byte) ([]byte, error) {
	return XorImpl(a, b)
}

func Not(a []byte) ([]byte, error) {
	return NotImpl(a)
}
