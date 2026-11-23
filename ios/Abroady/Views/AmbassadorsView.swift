import SwiftUI

/// Verified student ambassadors, at home campuses and at study-abroad sites.
struct AmbassadorsView: View {
    @Environment(AppModel.self) private var model
    @State private var search = ""

    private var grouped: [(University, [Ambassador])] {
        let q = search.lowercased()
        let list = model.ambassadors.filter { a in
            q.isEmpty || [a.name, a.major ?? "", a.bio ?? "", a.languages.joined(separator: " "),
                          model.university(a.universityId)?.name ?? ""].joined(separator: " ").lowercased().contains(q)
        }
        let byUni = Dictionary(grouping: list, by: \.universityId)
        return model.universities.compactMap { u in byUni[u.id].map { (u, $0) } }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Real students who've been there. Each one is verified by Abroady before they appear here.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if grouped.isEmpty {
                    EmptyState(icon: "person.2", title: "No ambassadors found", message: "Try another search.")
                }
                ForEach(grouped, id: \.0.id) { uni, people in
                    Section("\(uni.flag) \(uni.name)") {
                        ForEach(people) { a in
                            NavigationLink { AmbassadorDetailView(ambassador: a) } label: { AmbassadorRow(ambassador: a) }
                        }
                    }
                }
            }
            .groupedList()
            .safeAreaInset(edge: .top) { DemoBanner() }
            .searchable(text: $search, prompt: "Language, major, city…")
            .navigationTitle("Ambassadors")
            .refreshable { await model.bootstrap() }
        }
    }
}

struct AmbassadorRow: View {
    @Environment(AppModel.self) private var model
    let ambassador: Ambassador
    var body: some View {
        HStack(spacing: 12) {
            Avatar(name: ambassador.name)
            VStack(alignment: .leading, spacing: 3) {
                HStack { Text(ambassador.name).font(.headline); if ambassador.verified { VerifiedBadge() } }
                Text([ambassador.major, ambassador.term.map { "Abroad \($0)" }].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption).foregroundStyle(.secondary)
                if !ambassador.languages.isEmpty {
                    Text(ambassador.languages.joined(separator: " · ")).font(.caption2).foregroundStyle(Color.brandInk)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct AmbassadorDetailView: View {
    @Environment(AppModel.self) private var model
    let ambassador: Ambassador
    @State private var question = ""
    @State private var sending = false
    @State private var sent = false
    @State private var error: String?
    @State private var showAuth = false
    @State private var showReport = false

    private var myQuestions: [AmbassadorQuestion] { model.myQuestions.filter { $0.ambassadorId == ambassador.id } }

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Avatar(name: ambassador.name, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ambassador.name).font(.title3.bold())
                        if ambassador.verified { VerifiedBadge(label: "Verified ambassador") }
                        if let uni = model.university(ambassador.universityId) {
                            Text("\(uni.flag) \(uni.shortName)\(ambassador.term.map { " · \($0)" } ?? "")")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                if let bio = ambassador.bio { Text(bio) }
                if !ambassador.languages.isEmpty {
                    Label(ambassador.languages.joined(separator: ", "), systemImage: "character.bubble")
                }
                if let home = model.university(ambassador.homeUniversityId) {
                    Label("Home: \(home.name)", systemImage: "house")
                }
            }

            Section {
                if model.isSignedIn {
                    TextField("e.g. Which dorm did you pick and why?", text: $question, axis: .vertical)
                        .lineLimit(3...6)
                    Button {
                        Task { await send() }
                    } label: {
                        if sending { ProgressView() } else { Label("Send question", systemImage: "paperplane.fill") }
                    }
                    .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || sending)
                    if sent { Label("Sent! You'll see the answer here.", systemImage: "checkmark").foregroundStyle(Color.success) }
                } else {
                    Button("Log in to ask \(ambassador.name.split(separator: " ").first.map(String.init) ?? "them") a question") { showAuth = true }
                }
            } header: {
                Text("Ask a question")
            } footer: {
                Text("Questions are private between you and the ambassador. Never share passwords, bank details or visa numbers.")
            }

            if !myQuestions.isEmpty {
                Section("Your questions") {
                    ForEach(myQuestions) { q in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(q.body).font(.subheadline.weight(.semibold))
                            if let a = q.answer { Text(a) } else { Text("Waiting for an answer…").font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                }
            }

            Section {
                Button("Report this ambassador", role: .destructive) { showReport = true }
                    .disabled(!model.isSignedIn)
            }
        }
        .groupedList()
        .navigationTitle(ambassador.name)
        .inlineTitle()
        .sheet(isPresented: $showAuth) { AuthView() }
        .sheet(isPresented: $showReport) { ReportSheet(message: nil, userId: ambassador.userId) }
        .errorAlert($error)
    }

    private func send() async {
        sending = true
        defer { sending = false }
        do { try await model.ask(ambassador, question); question = ""; sent = true }
        catch { self.error = error.localizedDescription }
    }
}
