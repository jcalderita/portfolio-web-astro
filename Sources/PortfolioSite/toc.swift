import Foundation
import HTML

// MARK: - Heading extraction + ID injection

struct TocEntry {
    let id: String
    let title: String
    let level: Int
}

func extractHeadings(from html: String) -> (entries: [TocEntry], html: String) {
    let matches = html.matches(of: /<(h[234])>(.*?)<\/\1>/)
    var entries: [TocEntry] = []
    var result = html

    for match in matches.reversed() {
        let tag = String(match.output.1)
        let title = String(match.output.2)
        let level = tag.last!.wholeNumberValue!
        let plainTitle = title.replacing(/<[^>]+>/, with: "")
        let id = slugify(plainTitle)

        entries.insert(TocEntry(id: id, title: plainTitle, level: level), at: 0)
        result.replaceSubrange(match.range, with: "<\(tag) id=\"\(id)\">\(title)</\(tag)>")
    }

    return (entries, result)
}

// MARK: - Slugify

private func slugify(_ text: String) -> String {
    text.lowercased()
        .replacing(/[^a-z0-9\s-]/, with: "")
        .replacing(/\s+/, with: "-")
        .trimmingCharacters(in: .init(charactersIn: "-"))
}
