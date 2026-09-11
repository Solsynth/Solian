//
//  QRCodeImage.swift
//  Solian Watch App
//
//  Renders a vendored `QRCode` matrix to a `UIImage`. Shared by the account,
//  wallet and device-approval QR screens — it previously lived as a private
//  copy in each of them.
//

import CoreGraphics
import UIKit

/// Renders `qr` to a `UIImage` of `dimension` × `dimension` points, filling
/// each module as a solid square on a white background.
///
/// `UIImage` (rather than `CGImage`) so SwiftUI's `Image(uiImage:)` can take
/// the result. Scale the returned image with `.interpolation(.none)` — anything
/// smooth turns the modules into an unscannable grey mush.
func renderQRImage(from qr: QRCode, dimension: CGFloat) -> UIImage? {
    let modules = qr.size
    guard modules > 0 else { return nil }
    let modulePx = dimension / CGFloat(modules)
    let size = CGSize(width: dimension, height: dimension)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    guard let ctx = CGContext(
        data: nil,
        width: Int(dimension),
        height: Int(dimension),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
    ) else { return nil }

    // White background
    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fill(CGRect(origin: .zero, size: size))

    // Draw modules
    for y in 0..<modules {
        for x in 0..<modules {
            if qr.getModule(x: x, y: y) {
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(CGRect(
                    x: CGFloat(x) * modulePx,
                    y: CGFloat(y) * modulePx,
                    width: modulePx,
                    height: modulePx
                ))
            }
        }
    }

    guard let cgImage = ctx.makeImage() else { return nil }
    return UIImage(cgImage: cgImage)
}

/// Encodes `text` and renders it as a QR image, or `nil` when the payload does
/// not fit — the error-correction level is boosted automatically by the
/// encoder, so a failure means the text is too long for any version.
func makeQRImage(text: String, dimension: CGFloat, ecl: QRCodeECC = .high) -> UIImage? {
    guard !text.isEmpty, let qr = try? QRCode.encode(text: text, ecl: ecl) else { return nil }
    return renderQRImage(from: qr, dimension: dimension)
}
