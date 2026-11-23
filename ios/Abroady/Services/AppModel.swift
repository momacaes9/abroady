import Foundation
import Observation

/// App-wide state. Talks to Supabase when configured, otherwise runs on labeled demo data.
@MainActor
@Observable
final class AppModel {
    let api: SupabaseClient?
    var isDemo: Bool { api == nil }

    var profile: Profile?
    var universities: [University] = []
    var events: [CampusEvent] = []
    var going: [UUID: Int] = [:]
    var rsvps: Set<UUID> = []
    var ambassadors: [Ambassador] = []
    var myQuestions: [AmbassadorQuestion] = []
    var inbox: [AmbassadorQuestion] = []
    var blocked: Set<UUID> = []
    var checklistDone: Set<String>
    var campusId: UUID? { didSet { UserDefaults.standard.set(campusId?.uuidString, forKey: Keys.campus) } }
    var isLoading = false
    var errorMessage: String?

    private var demoMessages: [UUID: [ChatMessage]] = [:]
    private enum Keys { static let checklist = "checklist.done", campus = "campus.id" }

    init() {
        api = AppConfig.isConfigured ? SupabaseClient(url: AppConfig.supabaseURL, anonKey: AppConfig.supabaseAnonKey) : nil
        checklistDone = Set(UserDefaults.standard.stringArray(forKey: Keys.checklist) ?? [])
        campusId = UserDefaults.standard.string(forKey: Keys.campus).flatMap(UUID.init(uuidString:))
    }

    var isSignedIn: Bool { profile != nil }
    var homeCampuses: [University] { universities.filter { !$0.isPartner || $0.kind == "both" } }
    var destinations: [University] { universities.filter(\.isPartner) }
    var campus: University? { universities.first { $0.id == campusId } ?? homeCampuses.first }
    func university(_ id: UUID?) -> University? { universities.first { $0.id == id } }

    // MARK: - Loading

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }
        guard let api else { loadDemo(); return }
        do {
            async let unis: [University] = api.select("universities?select=id,name,short_name,city,country,country_code,kind&order=name")
            async let evs: [CampusEvent] = api.select("events?select=*&verified=eq.true&starts_at=gte.\(Self.iso(Date().addingTimeInterval(-86_400)))&order=starts_at.asc&limit=300")
            async let counts: [EventGoing] = api.select("event_going?select=event_id,going")
            async let ambs: [Ambassador] = api.select("ambassadors?select=id,user_id,name,university_id,home_university_id,term,major,languages,bio,verified&order=name")
            universities = try await unis
            events = try await evs
            going = Dictionary(uniqueKeysWithValues: try await counts.map { ($0.eventId, $0.going) })
            ambassadors = try await ambs
            if campusId == nil { campusId = homeCampuses.first?.id }
            await loadAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadAccount() async {
        guard let api, let uid = await api.userId else { profile = nil; return }
        do {
            let rows: [Profile] = try await api.select("profiles?id=eq.\(uid)&select=id,name,country,year,term,international,university_id,destination_id,role,verified_student,terms_accepted_at")
            profile = rows.first
            if let home = profile?.universityId { campusId = home }
            async let r: [RSVP] = api.select("event_rsvps?select=event_id")
            async let b: [Block] = api.select("blocks?select=blocked_id")
            async let q: [AmbassadorQuestion] = api.select("ambassador_questions?select=*&order=created_at.desc")
            rsvps = Set(try await r.map(\.eventId))
            blocked = Set(try await b.map(\.blockedId))
            let questions = try await q
            myQuestions = questions.filter { $0.askerId == uid }
            inbox = questions.filter { $0.askerId != uid }
            await syncChecklist(pullFirst: true)
        } catch {
            if case SupabaseClient.APIError.notSignedIn = error { profile = nil } else { errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Auth

    /// Returns true when the user must confirm their email before logging in.
    func signUp(name: String, email: String, password: String, universityId: UUID?, term: String,
                international: Bool, acceptedTerms: Bool) async throws -> Bool {
        guard let api else { profile = Self.demoProfile(name: name); return false }
        var meta = ["name": name, "term": term, "international": String(international),
                    "terms_accepted": String(acceptedTerms), "language": Locale.current.language.languageCode?.identifier ?? "en"]
        if let universityId { meta["university_id"] = universityId.uuidString }
        let needsConfirmation = try await api.signUp(email: email, password: password, metadata: meta)
        if !needsConfirmation { await loadAccount() }
        return needsConfirmation
    }

    func signIn(email: String, password: String) async throws {
        guard let api else { profile = Self.demoProfile(name: "Demo Student"); return }
        try await api.signIn(email: email, password: password)
        await loadAccount()
    }

    func signOut() async {
        await api?.signOut()
        profile = nil; rsvps = []; blocked = []; myQuestions = []; inbox = []
    }

    /// App Store guideline 5.1.1(v): accounts can be deleted from inside the app.
    func deleteAccount() async throws {
        if let api { let _: String? = try await api.rpc("delete_my_account") }
        checklistDone = []
        UserDefaults.standard.removeObject(forKey: Keys.checklist)
        await signOut()
    }

    func updateProfile(name: String, term: String, universityId: UUID?) async throws {
        guard var p = profile else { return }
        p.name = name; p.term = term; p.universityId = universityId
        if let api {
            struct Fields: Encodable { let name: String; let term: String; let universityId: UUID?; let updatedAt: Date }
            try await api.update("profiles?id=eq.\(p.id)", Fields(name: name, term: term, universityId: universityId, updatedAt: Date()))
        }
        profile = p
        if let universityId { campusId = universityId }
    }

    /// Community rules (guideline 1.2) must be accepted before posting.
    func acceptTerms() async throws {
        guard var p = profile else { return }
        let now = Date()
        if let api {
            struct Fields: Encodable { let termsAcceptedAt: Date }
            try await api.update("profiles?id=eq.\(p.id)", Fields(termsAcceptedAt: now))
        }
        p.termsAcceptedAt = now
        profile = p
    }

    // MARK: - Events

    func toggleRSVP(_ event: CampusEvent) async {
        let wasGoing = rsvps.contains(event.id)
        if wasGoing { rsvps.remove(event.id) } else { rsvps.insert(event.id) }
        going[event.id, default: 0] += wasGoing ? -1 : 1
        guard let api else { return }
        do {
            if wasGoing { try await api.delete("event_rsvps?event_id=eq.\(event.id)") }
            else { try await api.insert("event_rsvps", ["event_id": event.id.uuidString]) }
        } catch {
            if wasGoing { rsvps.insert(event.id) } else { rsvps.remove(event.id) }
            going[event.id, default: 0] += wasGoing ? 1 : -1
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Ambassadors

    func ask(_ ambassador: Ambassador, _ body: String) async throws {
        let text = try ContentFilter.validate(body)
        guard let uid = profile?.id else { throw SupabaseClient.APIError.notSignedIn }
        if let api {
            try await api.insert("ambassador_questions", ["ambassador_id": ambassador.id.uuidString, "body": text])
            await loadAccount()
        } else {
            myQuestions.insert(AmbassadorQuestion(id: Int.random(in: 1...999_999), ambassadorId: ambassador.id, askerId: uid,
                                                  body: text, answer: nil, answeredAt: nil, createdAt: Date()), at: 0)
        }
    }

    func answer(_ question: AmbassadorQuestion, _ text: String) async throws {
        let clean = try ContentFilter.validate(text, limit: 2000)
        if let api {
            struct Fields: Encodable { let answer: String; let answeredAt: Date }
            try await api.update("ambassador_questions?id=eq.\(question.id)", Fields(answer: clean, answeredAt: Date()))
        }
        if let i = inbox.firstIndex(of: question) { inbox[i].answer = clean; inbox[i].answeredAt = Date() }
    }

    func applyAsAmbassador(universityId: UUID?, term: String, why: String) async throws {
        let text = try ContentFilter.validate(why)
        guard let api else { return }
        struct Row: Encodable { let universityId: UUID?; let term: String; let why: String }
        try await api.insert("ambassador_applications", Row(universityId: universityId, term: term, why: text))
    }

    // MARK: - Cohort chat

    func joinCohort(destination: UUID, term: String) async throws -> UUID {
        guard let api else { return Self.demoCohortId(destination, term) }
        let id: UUID = try await api.rpc("join_cohort", ["p_destination": destination.uuidString, "p_term": term])
        profile?.destinationId = destination
        profile?.term = term
        return id
    }

    func cohortSize(_ cohort: UUID) async -> Int {
        guard let api else { return 6 }
        return (try? await api.rpc("cohort_size", ["p_cohort": cohort.uuidString], as: Int.self)) ?? 0
    }

    func messages(in cohort: UUID) async throws -> [ChatMessage] {
        let all: [ChatMessage]
        if let api {
            all = try await api.select("messages?cohort_id=eq.\(cohort)&select=id,cohort_id,user_id,display_name,verified,body,created_at&order=created_at.desc&limit=150")
                .reversed()
        } else {
            all = demoMessages[cohort] ?? SampleData.messages(cohort)
        }
        return all.filter { !blocked.contains($0.userId) }
    }

    func send(_ body: String, to cohort: UUID) async throws {
        let text = try ContentFilter.validate(body)
        if let api {
            try await api.insert("messages", ["cohort_id": cohort.uuidString, "body": text])
        } else if let p = profile {
            var list = demoMessages[cohort] ?? SampleData.messages(cohort)
            list.append(ChatMessage(id: Int.random(in: 1...999_999), cohortId: cohort, userId: p.id,
                                    displayName: p.firstName, verified: p.verifiedStudent, body: text, createdAt: Date()))
            demoMessages[cohort] = list
        }
    }

    func deleteMessage(_ message: ChatMessage) async throws {
        if let api { try await api.delete("messages?id=eq.\(message.id)") }
        demoMessages[message.cohortId]?.removeAll { $0.id == message.id }
    }

    func report(message: ChatMessage?, userId: UUID?, reason: ReportReason, details: String) async throws {
        guard let api else { return }
        struct Row: Encodable { let messageId: Int?; let reportedUserId: UUID?; let reason: String; let details: String? }
        try await api.insert("reports", Row(messageId: message?.id, reportedUserId: userId ?? message?.userId,
                                            reason: reason.rawValue, details: details.isEmpty ? nil : String(details.prefix(1000))))
    }

    func block(_ userId: UUID) async throws {
        blocked.insert(userId)
        if let api { try await api.insert("blocks", ["blocked_id": userId.uuidString]) }
    }

    func unblockAll() async throws {
        if let api, let uid = profile?.id { try await api.delete("blocks?blocker_id=eq.\(uid)") }
        blocked = []
    }

    // MARK: - Checklist

    func toggle(_ task: ChecklistTask) {
        if checklistDone.contains(task.id) { checklistDone.remove(task.id) } else { checklistDone.insert(task.id) }
        UserDefaults.standard.set(Array(checklistDone), forKey: Keys.checklist)
        Task { await syncChecklist(pullFirst: false) }
    }

    /// Same `user_progress` row the website uses, so progress follows the student across devices.
    private func syncChecklist(pullFirst: Bool) async {
        guard let api, let uid = profile?.id else { return }
        struct Progress: Codable { let userId: UUID; let checklist: [String] }
        if pullFirst, let rows: [Progress] = try? await api.select("user_progress?user_id=eq.\(uid)&select=user_id,checklist") {
            checklistDone.formUnion(rows.first?.checklist ?? [])
            UserDefaults.standard.set(Array(checklistDone), forKey: Keys.checklist)
        }
        try? await api.upsert("user_progress", Progress(userId: uid, checklist: Array(checklistDone).sorted()))
    }

    // MARK: - Demo mode

    private func loadDemo() {
        universities = SampleData.universities
        events = SampleData.events
        going = Dictionary(uniqueKeysWithValues: events.map { ($0.id, Int.random(in: 4...40)) })
        ambassadors = SampleData.ambassadors
        if campusId == nil { campusId = homeCampuses.first?.id }
    }

    private static func demoProfile(name: String) -> Profile {
        Profile(id: UUID(), name: name, country: nil, year: "1", term: Terms.upcoming.first, international: true,
                universityId: SampleData.unc.id, destinationId: nil, role: "student", verifiedStudent: true, termsAcceptedAt: nil)
    }

    private static func demoCohortId(_ destination: UUID, _ term: String) -> UUID { destination }

    static func iso(_ date: Date) -> String { ISO8601DateFormatter().string(from: date) }
}
