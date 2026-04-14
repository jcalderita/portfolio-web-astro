import Foundation
import ImageIO

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

    public func run() throws {
        try FileManager.default.createDirectory(at: config.outputDir, withIntermediateDirectories: true)

        let images = try pngFiles(in: config.inputDir)
        var processed = 0
        var skipped = 0

        for file in images {
            switch processImage(file) {
            case .processed(let message):
                print("  \(message)")
                processed += 1
            case .skipped:
                skipped += 1
            case .failed(let name):
                print("  Failed to read: \(name)")
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
        quality: 0.95
    )
}

// MARK: - ResultEnum

enum ResultEnum {
    case processed(String)
    case skipped
    case failed(String)
}

// MARK: - Helpers

extension ImageOptimizer {

    // MARK: Pipeline

    func processImage(_ file: URL) -> ResultEnum {
        let name = file.deletingPathExtension().lastPathComponent
        let dest = config.outputDir.appendingPathComponent("\(name).avif")

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

        writeAVIF(thumbnail, to: dest)
        return .processed("\(file.lastPathComponent) -> \(name).avif (\(fileSize(dest)))")
    }

    // MARK: File discovery

    func pngFiles(in directory: URL) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    // MARK: Timestamp comparison

    func isUpToDate(source: URL, destination: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: destination.path),
            let srcDate = modificationDate(of: source),
            let dstDate = modificationDate(of: destination)
        else { return false }

        return dstDate >= srcDate
    }

    func modificationDate(of url: URL) -> Date? {
        try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date
    }

    // MARK: AVIF writing

    func writeAVIF(_ image: CGImage, to url: URL) {
        try? FileManager.default.removeItem(at: url)

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            "public.avif" as CFString,
            1,
            nil
        ) else {
            print("  Failed to create destination: \(url.lastPathComponent)")
            return
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: config.quality
        ]

        CGImageDestinationAddImage(destination, image, options as CFDictionary)

        if !CGImageDestinationFinalize(destination) {
            print("  Failed to write: \(url.lastPathComponent)")
        }
    }

    // MARK: Helpers

    func fileSize(_ url: URL) -> String {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
            let size = attrs[.size] as? UInt64
        else { return "?" }

        if size < 1024 { return "\(size) B" }
        if size < 1_048_576 { return "\(size / 1024) KB" }
        return String(format: "%.1f MB", Double(size) / 1_048_576)
    }
}
