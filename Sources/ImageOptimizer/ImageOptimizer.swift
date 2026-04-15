import CoreGraphics
import Foundation
import ImageIO
import libwebp

// MARK: - ImageOptimizer

public struct ImageOptimizer: Sendable {
    public struct Config: Sendable {
        let inputDir: URL
        let outputDir: URL
        let maxWidth: Int
        let quality: Float
    }

    let config: Config

    public init(config: Config = .blog) {
        self.config = config
    }

    public func run() async throws {
        try FileManager.default.createDirectory(
            at: config.outputDir, withIntermediateDirectories: true)

        let images = try pngFiles(in: config.inputDir)
        let results = await withTaskGroup(of: ProcessResult.self, returning: [ProcessResult].self) {
            for file in images {
                $0.addTask { processImage(file, config: config) }
            }
            var results: [ProcessResult] = []
            for await result in $0 {
                results.append(result)
            }
            return results
        }

        var processed = 0
        var skipped = 0
        for result in results {
            switch result {
            case .processed(let message):
                print("  \(message)")
                processed += 1
            case .skipped:
                skipped += 1
            case .failed(let name):
                print("  Failed: \(name)")
            }
        }

        print("\nDone! Processed: \(processed), Skipped (up-to-date): \(skipped)")
    }
}

// MARK: - Config presets

extension ImageOptimizer.Config {
    public static let blog = Self(
        inputDir: URL(fileURLWithPath: "assets/blog/images"),
        outputDir: URL(fileURLWithPath: "content/static/blog"),
        maxWidth: 800,
        quality: 80
    )
}

// MARK: - ProcessResult

enum ProcessResult: Sendable {
    case processed(String)
    case skipped
    case failed(String)
}

// MARK: - Processing (free functions for Sendable safety)

private func processImage(_ file: URL, config: ImageOptimizer.Config) -> ProcessResult {
    let name = file.deletingPathExtension().lastPathComponent
    let dest = config.outputDir.appendingPathComponent("\(name).webp")

    guard !isUpToDate(source: file, destination: dest) else { return .skipped }

    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: config.maxWidth,
    ]

    guard let source = CGImageSourceCreateWithURL(file as CFURL, nil),
        let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    else {
        return .failed(file.lastPathComponent)
    }

    guard writeWebP(thumbnail, to: dest, quality: config.quality) else {
        return .failed(file.lastPathComponent)
    }

    return .processed("\(file.lastPathComponent) -> \(name).webp (\(fileSize(dest)))")
}

// MARK: - WebP writing via libwebp

private func writeWebP(_ image: CGImage, to url: URL, quality: Float) -> Bool {
    let width = image.width
    let height = image.height
    let bytesPerRow = width * 4

    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )
    else {
        print("  Failed to create CGContext: \(url.lastPathComponent)")
        return false
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let data = context.data else {
        print("  Failed to get pixel data: \(url.lastPathComponent)")
        return false
    }

    let pixels = data.assumingMemoryBound(to: UInt8.self)

    var output: UnsafeMutablePointer<UInt8>?
    let size = WebPEncodeRGBA(
        pixels, Int32(width), Int32(height), Int32(bytesPerRow), quality, &output)

    guard size > 0, let output else {
        print("  Failed to encode WebP: \(url.lastPathComponent)")
        return false
    }

    let webpData = Data(bytes: output, count: size)
    WebPFree(output)

    do {
        try webpData.write(to: url)
        return true
    } catch {
        print("  Failed to write: \(url.lastPathComponent) — \(error)")
        return false
    }
}

// MARK: - File helpers

private func pngFiles(in directory: URL) throws -> [URL] {
    guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
    return try FileManager.default.contentsOfDirectory(
        at: directory, includingPropertiesForKeys: nil
    )
    .filter { $0.pathExtension.lowercased() == "png" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
}

private func isUpToDate(source: URL, destination: URL) -> Bool {
    guard FileManager.default.fileExists(atPath: destination.path),
        let srcDate = modificationDate(of: source),
        let dstDate = modificationDate(of: destination)
    else { return false }

    return dstDate >= srcDate
}

private func modificationDate(of url: URL) -> Date? {
    try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date
}

private func fileSize(_ url: URL) -> String {
    guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
        let size = attrs[.size] as? UInt64
    else { return "?" }

    if size < 1024 { return "\(size) B" }
    if size < 1_048_576 { return "\(size / 1024) KB" }
    return String(format: "%.1f MB", Double(size) / 1_048_576)
}
