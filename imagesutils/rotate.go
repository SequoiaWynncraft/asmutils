package imagesutils

import (
	"image"
	"math"
)

func RotateDegree(src *image.NRGBA, deg float64) *image.NRGBA {
	if src == nil {
		return nil
	}

	bounds := src.Bounds()
	width := bounds.Dx()
	height := bounds.Dy()

	if width == 0 || height == 0 {
		return src
	}

	// convert degs to rads
	rad := deg * math.Pi / 180.0
	cosAngle := math.Cos(rad)
	sinAngle := math.Sin(rad)

	newWidth, newHeight := calculateRotatedDimensions(width, height, cosAngle, sinAngle)
	// dest image
	dst := image.NewNRGBA(image.Rect(0, 0, newWidth, newHeight))

	// center
	centerX := float64(width) / 2.0
	centerY := float64(height) / 2.0
	newCenterX := float64(newWidth) / 2.0
	newCenterY := float64(newHeight) / 2.0

	rotateImage(dst.Pix, src.Pix, dst.Stride, src.Stride, newWidth, newHeight, width, height, cosAngle, sinAngle, centerX, centerY, newCenterX, newCenterY)

	return dst
}

//go:noescape
func calculateRotatedDimensions(width, height int, cosAngle, sinAngle float64) (newWidth, newHeight int)

//go:noescape
func rotateImage(dstPix, srcPix []byte, dstStride, srcStride int, dstWidth, dstHeight int, srcWidth, srcHeight int, cosAngle, sinAngle float64, centerX, centerY float64, newCenterX, newCenterY float64)
