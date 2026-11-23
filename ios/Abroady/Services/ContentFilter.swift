import Foundation

/// Client-side filter for user-generated text (App Store guideline 1.2 asks for
/// "a method for filtering objectionable material"). The server adds reports,
/// blocks and auto-hiding on top of this.
enum ContentFilter {
    enum FilterError: LocalizedError {
        case empty, tooLong(Int), blocked
        var errorDescription: String? {
            switch self {
            case .empty: return "Write something first."
            case .tooLong(let limit): return "Keep it under \(limit) characters."
            case .blocked: return "This message breaks the community rules. Please rephrase it."
            }
        }
    }

    /// Slurs and explicit terms in EN / PT / ES. Kept short on purpose; extend as reports come in.
    private static let blockedTerms: [String] = [
        "nigger", "nigga", "faggot", "retard", "tranny", "chink", "spic", "kike",
        "viado", "macaco", "puta", "caralho", "porra",
        "maricón", "sudaca", "mierda", "cabrón",
        "nudes", "onlyfans", "send pics",
    ]
    private static let scamPatterns = ["venmo me", "cashapp", "western union", "gift card", "crypto investment", "wire me"]

    static func validate(_ raw: String, limit: Int = 1000) throws -> String {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw FilterError.empty }
        guard text.count <= limit else { throw FilterError.tooLong(limit) }
        let normalized = text.lowercased().folding(options: .diacriticInsensitive, locale: nil)
        let words = Set(normalized.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty })
        for term in blockedTerms {
            let folded = term.folding(options: .diacriticInsensitive, locale: nil)
            if folded.contains(" ") ? normalized.contains(folded) : words.contains(folded) { throw FilterError.blocked }
        }
        if scamPatterns.contains(where: normalized.contains) { throw FilterError.blocked }
        return text
    }
}
