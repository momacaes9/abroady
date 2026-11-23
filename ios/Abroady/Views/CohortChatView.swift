import SwiftUI

/// Decides what to show before the chat: log in, accept the community rules, then join.
struct CohortGate: View {
    @Environment(AppModel.self) private var model
    let destination: University
    let term: String
    @State private var showAuth = false

    var body: some View {
        Group {
            if !model.isSignedIn {
                VStack(spacing: 16) {
                    EmptyState(icon: "bubble.left.and.bubble.right", title: "Meet your \(destination.shortName) cohort",
                               message: "Log in to chat with everyone going to \(destination.shortName) in \(term).")
                    Button("Log in or create account") { showAuth = true }.buttonStyle(.borderedProminent)
                }
            } else if model.profile?.hasAcceptedTerms != true {
                CommunityRulesView(requireAgreement: true)
            } else {
                CohortChatView(destination: destination, term: term)
            }
        }
        .navigationTitle("\(destination.shortName) · \(term)")
        .inlineTitle()
        .sheet(isPresented: $showAuth) { AuthView() }
    }
}

struct CohortChatView: View {
    @Environment(AppModel.self) private var model
    let destination: University
    let term: String

    @State private var cohortId: UUID?
    @State private var members = 0
    @State private var messages: [ChatMessage] = []
    @State private var draft = ""
    @State private var error: String?
    @State private var reporting: ChatMessage?
    @State private var confirmBlock: ChatMessage?

    var body: some View {
        VStack(spacing: 0) {
            DemoBanner()
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("\(members) student\(members == 1 ? "" : "s") in this cohort · be kind, no personal data")
                            .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                        if messages.isEmpty && cohortId != nil {
                            EmptyState(icon: "hand.wave", title: "Say hi first", message: "Introduce yourself: where you're from and what you study.")
                        }
                        ForEach(messages) { m in bubble(m).id(m.id) }
                    }
                    .padding()
                }
                .onChange(of: messages.last?.id) { _, last in
                    if let last { withAnimation { proxy.scrollTo(last, anchor: .bottom) } }
                }
            }
            composer
        }
        .task(id: "\(destination.id)-\(term)") { await run() }
        .sheet(item: $reporting) { ReportSheet(message: $0, userId: $0.userId) }
        .confirmationDialog("Block \(confirmBlock?.displayName ?? "")?", isPresented: Binding(get: { confirmBlock != nil }, set: { if !$0 { confirmBlock = nil } }),
                            titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                if let m = confirmBlock { Task { try? await model.block(m.userId); await refresh() } }
            }
        } message: {
            Text("You won't see their messages anymore. They aren't told you blocked them.")
        }
        .errorAlert($error)
    }

    private func bubble(_ m: ChatMessage) -> some View {
        let mine = m.userId == model.profile?.id
        return HStack {
            if mine { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 3) {
                if !mine {
                    HStack(spacing: 4) {
                        Text(m.displayName).font(.caption.weight(.semibold))
                        if m.verified { Image(systemName: "checkmark.seal.fill").font(.caption2).foregroundStyle(Color.brandInk) }
                    }
                }
                Text(m.body)
                Text(m.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.secondary)
            }
            .padding(10)
            .background(mine ? Color.brand.opacity(0.18) : Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            .contextMenu {
                if mine {
                    Button("Delete message", systemImage: "trash", role: .destructive) {
                        Task { try? await model.deleteMessage(m); await refresh() }
                    }
                } else {
                    Button("Report message", systemImage: "flag") { reporting = m }
                    Button("Block \(m.displayName)", systemImage: "hand.raised") { confirmBlock = m }
                }
            }
            if !mine { Spacer(minLength: 40) }
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom) {
            TextField("Message your cohort", text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.roundedBorder)
            Button {
                Task { await send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill").font(.title)
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cohortId == nil)
            .accessibilityLabel("Send")
        }
        .padding()
        .background(.bar)
    }

    /// Join, then poll for new messages while the screen is visible.
    private func run() async {
        do {
            let id = try await model.joinCohort(destination: destination.id, term: term)
            cohortId = id
            members = await model.cohortSize(id)
            while !Task.isCancelled {
                await refresh()
                try await Task.sleep(for: .seconds(6))
            }
        } catch is CancellationError {
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func refresh() async {
        guard let cohortId else { return }
        if let list = try? await model.messages(in: cohortId) { messages = list }
    }

    private func send() async {
        guard let cohortId else { return }
        let text = draft
        do {
            try await model.send(text, to: cohortId)
            draft = ""
            await refresh()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct ReportSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let message: ChatMessage?
    let userId: UUID?
    @State private var reason: ReportReason = .spam
    @State private var details = ""
    @State private var alsoBlock = true
    @State private var done = false

    var body: some View {
        NavigationStack {
            Form {
                if let message { Section("Message") { Text(message.body).foregroundStyle(.secondary) } }
                Section("Why are you reporting this?") {
                    Picker("Reason", selection: $reason) {
                        ForEach(ReportReason.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section("Details (optional)") { TextField("What happened?", text: $details, axis: .vertical).lineLimit(2...5) }
                if userId != nil { Toggle("Also block this person", isOn: $alsoBlock) }
                Section {
                    Text("Our team reviews reports within 24 hours and removes content that breaks the rules. If someone is in immediate danger, call local emergency services.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Report")
            .inlineTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task {
                            try? await model.report(message: message, userId: userId, reason: reason, details: details)
                            if alsoBlock, let userId { try? await model.block(userId) }
                            done = true
                        }
                    }
                }
            }
            .alert("Thanks for reporting", isPresented: $done) {
                Button("OK") { dismiss() }
            } message: {
                Text("We'll review it within 24 hours.")
            }
        }
    }
}
