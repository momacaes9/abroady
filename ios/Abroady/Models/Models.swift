import Foundation

struct University: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let shortName: String
    let city: String?
    let country: String?
    let countryCode: String?
    let kind: String

    var isPartner: Bool { kind == "partner" || kind == "both" }
    var flag: String {
        guard let code = countryCode?.uppercased(), code.count == 2 else { return "🌍" }
        return code.unicodeScalars.compactMap { UnicodeScalar(127397 + $0.value) }.map(String.init).joined()
    }
    var place: String { [city, country].compactMap { $0 }.joined(separator: ", ") }
}

struct Profile: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var country: String?
    var year: String?
    var term: String?
    var international: Bool
    var universityId: UUID?
    var destinationId: UUID?
    var role: String
    var verifiedStudent: Bool
    var termsAcceptedAt: Date?

    var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
    var isAmbassador: Bool { role == "ambassador" || role == "admin" }
    var hasAcceptedTerms: Bool { termsAcceptedAt != nil }
}

struct Ambassador: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID?
    let name: String
    let universityId: UUID
    let homeUniversityId: UUID?
    let term: String?
    let major: String?
    let languages: [String]
    let bio: String?
    let verified: Bool
}

struct AmbassadorQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let ambassadorId: UUID
    let askerId: UUID
    let body: String
    var answer: String?
    var answeredAt: Date?
    let createdAt: Date
}

struct CampusEvent: Codable, Identifiable, Hashable {
    let id: UUID
    let universityId: UUID
    let title: String
    let description: String?
    let startsAt: Date
    let endsAt: Date?
    let location: String?
    let hostName: String?
    let hostType: String
    let url: String?
    let audience: String

    var hostLabel: String {
        switch hostType {
        case "university": return "Official · University"
        case "ambassador": return "Ambassador-led"
        case "abroady": return "Abroady"
        default: return "Student club"
        }
    }
    var audienceLabel: String {
        switch audience {
        case "international": return "International students"
        case "first_year": return "First-years"
        case "study_abroad": return "Study abroad"
        default: return "Everyone"
        }
    }
}

struct EventGoing: Codable { let eventId: UUID; let going: Int }
struct RSVP: Codable { let eventId: UUID }

struct ChatMessage: Codable, Identifiable, Hashable {
    let id: Int
    let cohortId: UUID
    let userId: UUID
    let displayName: String
    let verified: Bool
    let body: String
    let createdAt: Date
}

struct Block: Codable { let blockedId: UUID }

enum ReportReason: String, CaseIterable, Identifiable, Codable {
    case spam, harassment, hate, sexual, scam, safety, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .spam: return "Spam"
        case .harassment: return "Harassment or bullying"
        case .hate: return "Hate speech"
        case .sexual: return "Sexual content"
        case .scam: return "Scam or fraud"
        case .safety: return "Someone may be in danger"
        case .other: return "Something else"
        }
    }
}

struct ChecklistTask: Identifiable, Hashable { let id: String; let label: String; let hint: String }
struct ChecklistGroup: Identifiable, Hashable {
    let icon: String
    let title: String
    let when: String
    let tasks: [ChecklistTask]
    var id: String { title }
}

/// Terms students pick for study abroad: the current term plus the next ~3 years.
enum Terms {
    static var upcoming: [String] {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let starts = [("Spring", 1), ("Summer", 5), ("Fall", 8)]
        let cutoff = now.addingTimeInterval(-120 * 86_400) // keep a term that started in the last ~4 months
        return (year...(year + 3)).flatMap { y in
            starts.compactMap { name, month -> String? in
                guard let start = calendar.date(from: DateComponents(year: y, month: month, day: 1)), start >= cutoff else { return nil }
                return "\(name) \(y)"
            }
        }
    }
}
