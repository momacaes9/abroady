import Foundation

/// Demo data for development and previews only (used when AppConfig has no Supabase keys).
/// Every person and event here is fictional and marked "Demo". Never ship this to App Review.
enum SampleData {
    private static func uni(_ id: String, _ name: String, _ short: String, _ city: String, _ country: String, _ code: String, _ kind: String) -> University {
        University(id: UUID(uuidString: id)!, name: name, shortName: short, city: city, country: country, countryCode: code, kind: kind)
    }

    static let unc = uni("00000000-0000-0000-0000-000000000001", "University of North Carolina at Chapel Hill", "UNC", "Chapel Hill", "United States", "US", "home")
    static let unsw = uni("00000000-0000-0000-0000-000000000002", "UNSW Sydney", "UNSW", "Sydney", "Australia", "AU", "partner")

    static let universities: [University] = [
        unc, unsw,
        uni("00000000-0000-0000-0000-000000000003", "Korea University", "Korea U", "Seoul", "South Korea", "KR", "partner"),
        uni("00000000-0000-0000-0000-000000000004", "University of Granada", "UGR", "Granada", "Spain", "ES", "partner"),
        uni("00000000-0000-0000-0000-000000000005", "University of Limerick", "UL", "Limerick", "Ireland", "IE", "partner"),
        uni("00000000-0000-0000-0000-000000000006", "University of Stirling", "Stirling", "Stirling", "United Kingdom", "GB", "partner"),
        uni("00000000-0000-0000-0000-000000000007", "Veritas University", "Veritas", "San José", "Costa Rica", "CR", "partner"),
    ]

    private static func day(_ offset: Int, _ hour: Int) -> Date {
        let start = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .hour, value: offset * 24 + hour, to: start)!
    }

    static let events: [CampusEvent] = [
        CampusEvent(id: UUID(), universityId: unc.id, title: "Demo · International Welcome Mixer",
                    description: "Meet other international and first-year students. Snacks, music and a quick intro to campus life.",
                    startsAt: day(2, 18), endsAt: day(2, 20), location: "Student Union, Room 3411", hostName: "Demo Global Office",
                    hostType: "university", url: nil, audience: "international"),
        CampusEvent(id: UUID(), universityId: unc.id, title: "Demo · Study Abroad Fair",
                    description: "Talk to advisors and returning students about semester, summer and first-year programs.",
                    startsAt: day(5, 11), endsAt: day(5, 15), location: "Great Hall", hostName: "Demo Study Abroad Office",
                    hostType: "university", url: nil, audience: "study_abroad"),
        CampusEvent(id: UUID(), universityId: unc.id, title: "Demo · Brazilian Student Association Game Night",
                    description: "Board games, brigadeiro and Portuguese practice. Everyone welcome.",
                    startsAt: day(6, 19), endsAt: day(6, 22), location: "Davis Library, Group Room", hostName: "Demo BRASA chapter",
                    hostType: "club", url: nil, audience: "all"),
        CampusEvent(id: UUID(), universityId: unsw.id, title: "Demo · Arrivals Coffee Meetup",
                    description: "First week in Sydney? Meet your cohort and an ambassador who did the program last year.",
                    startsAt: day(9, 10), endsAt: day(9, 12), location: "Main Library Café", hostName: "Demo Ambassador",
                    hostType: "ambassador", url: nil, audience: "study_abroad"),
    ]

    static let ambassadors: [Ambassador] = [
        Ambassador(id: UUID(), userId: UUID(), name: "Demo Ana", universityId: unsw.id, homeUniversityId: unc.id,
                   term: "Spring 2026", major: "Economics", languages: ["English", "Portuguese"],
                   bio: "Did Spring Forward at UNSW. Ask me about housing, courses that transfer and weekend trips.", verified: true),
        Ambassador(id: UUID(), userId: UUID(), name: "Demo Diego", universityId: unc.id, homeUniversityId: unc.id,
                   term: nil, major: "Computer Science", languages: ["English", "Spanish"],
                   bio: "International student from Mexico. Happy to help with I-94, SSN and finding your first clubs.", verified: true),
    ]

    static func messages(_ cohort: UUID) -> [ChatMessage] {
        let other = UUID()
        return [
            ChatMessage(id: 1, cohortId: cohort, userId: other, displayName: "Demo Lucas", verified: true,
                        body: "Hi everyone! Anyone figured out housing yet?", createdAt: Date().addingTimeInterval(-7200)),
            ChatMessage(id: 2, cohortId: cohort, userId: UUID(), displayName: "Demo Aisha", verified: true,
                        body: "Not yet, the ambassador said the on-campus option fills fast. Let's apply the same week.", createdAt: Date().addingTimeInterval(-3600)),
        ]
    }
}
