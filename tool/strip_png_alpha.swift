import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count > 1 else {
  fputs("Usage: strip_png_alpha.swift <png> [png ...]\n", stderr)
  exit(64)
}

for path in CommandLine.arguments.dropFirst() {
  let url = URL(fileURLWithPath: path)
  guard
    let source = CGImageSourceCreateWithURL(url as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
  else {
    fputs("Could not read \(path)\n", stderr)
    exit(65)
  }

  let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
  let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue |
    CGImageAlphaInfo.noneSkipLast.rawValue
  guard
    let context = CGContext(
      data: nil,
      width: image.width,
      height: image.height,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: bitmapInfo
    )
  else {
    fputs("Could not create RGB context for \(path)\n", stderr)
    exit(66)
  }

  context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
  context.fill(CGRect(x: 0, y: 0, width: image.width, height: image.height))
  context.draw(
    image,
    in: CGRect(x: 0, y: 0, width: image.width, height: image.height)
  )

  guard let opaqueImage = context.makeImage() else {
    fputs("Could not flatten \(path)\n", stderr)
    exit(67)
  }

  let temporaryURL = url.deletingLastPathComponent().appendingPathComponent(
    ".\(url.lastPathComponent).opaque"
  )
  guard
    let destination = CGImageDestinationCreateWithURL(
      temporaryURL as CFURL,
      UTType.png.identifier as CFString,
      1,
      nil
    )
  else {
    fputs("Could not create output for \(path)\n", stderr)
    exit(68)
  }

  CGImageDestinationAddImage(destination, opaqueImage, nil)
  guard CGImageDestinationFinalize(destination) else {
    fputs("Could not encode \(path)\n", stderr)
    exit(69)
  }

  do {
    _ = try FileManager.default.replaceItemAt(url, withItemAt: temporaryURL)
  } catch {
    fputs("Could not replace \(path): \(error)\n", stderr)
    exit(70)
  }
}
