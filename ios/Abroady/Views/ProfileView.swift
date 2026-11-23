import SwiftUI

struct ProfileView: View {
    @Environment(AppModel.self) private var model
    @State private var showAuth = false
    @State private var confirmDelete = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                if let p = model.profile {
                    Section {
                        HStack(spacing: 14) {
                            Avatar(name: p.name, size: 60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.name).font(.title3.bold())
                                if p.verifiedStudent { VerifiedBadge(label: "Verified student") }
                                Text([model.university(p.universityId)?.shortName, p.term].compactMap { $0 }.joined(separator: " · "))
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        NavigationLink("Edit profile") { EditProfileView() }
                    }

                    if p.isAmbassador {
                        Section("Ambassador inbox") {
                            NavigationLink { AmbassadorInboxView() } label: {
                                Label("\(model.inbox.filter { $0.answer == nil }.count) unanswered question(s)", systemImage: "tray")
                            }
                        }
                    } else {
                        Section {
                            NavigationLink { ApplyAmbassadorView() } label: {
                                Label("Become an ambassador", systemImage: "star.bubble")
                            }
                        } footer: {
                            Text("Been abroad or know your campus well? Help the next cohort.")
                        }
                    }

                    Section("Safety") {
                        NavigationLink("Community rules") { CommunityRulesView() }
                        if !model.blocked.isEmpty {
                            Button("Unblock all (\(model.blocked.count))") { Task { try? await model.unblockAll() } }
                        }
                    }
                } else {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Join your cohort").font(.title3.bold())
                            Text("Create a free account to RSVP to events, ask ambassadors questions and chat with students going where you're going.")
                                .font(.subheadline).foregroundStyle(.secondary)
                            Button("Log in or create account") { showAuth = true }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("About") {
                    Link("Privacy policy", destination: AppConfig.privacyURL)
                    Link("Terms of use", destination: AppConfig.termsURL)
                    if let mail = URL(string: "mailto:\(AppConfig.supportEmail)?subject=Abroady%20support") {
                        Link("Contact support", destination: mail)
                    }
                    LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                }

                if model.isSignedIn {
                    Section {
                        Button("Log out") { Task { await model.signOut() } }
                        Button("Delete account", role: .destructive) { confirmDelete = true }
                    } footer: {
                        Text("Deleting your account permanently removes your profile, messages, RSVPs and questions.")
                    }
                }
            }
            .groupedList()
            .navigationTitle("Profile")
            .sheet(isPresented: $showAuth) { AuthView() }
            .confirmationDialog("Delete your account?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete permanently", role: .destructive) {
                    Task { do { try await model.deleteAccount() } catch { self.error = error.localizedDescription } }
                }
            } message: {
                Text("This can't be undone.")
            }
            .errorAlert($error)
        }
    }
}

struct EditProfileView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var term = ""
    @State private var universityId: UUID?
    @State private var error: String?

    var body: some View {
        Form {
            TextField("Full name", text: $name)
            Picker("University", selection: $universityId) {
                Text("Not set").tag(UUID?.none)
                ForEach(model.homeCampuses) { Text($0.name).tag(Optional($0.id)) }
            }
            Picker("Term abroad", selection: $term) {
                ForEach(Terms.upcoming, id: \.self) { Text($0).tag($0) }
            }
            Button("Save") {
                Task {
                    do { try await model.updateProfile(name: name.trimmingCharacters(in: .whitespaces), term: term, universityId: universityId); dismiss() }
                    catch { self.error = error.localizedDescription }
                }
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .navigationTitle("Edit profile")
        .inlineTitle()
        .errorAlert($error)
        .onAppear {
            name = model.profile?.name ?? ""
            universityId = model.profile?.universityId
            let current = model.profile?.term ?? ""
            term = Terms.upcoming.contains(current) ? current : (Terms.upcoming.first ?? "")
        }
    }
}

struct ApplyAmbassadorView: View {
    @Environment(AppModel.self) private var model
    @State private var universityId: UUID?
    @State private var term = ""
    @State private var why = ""
    @State private var sent = false
    @State private var error: String?

    var body: some View {
        Form {
            Section {
                Picker("Where can you help?", selection: $universityId) {
                    Text("Choose…").tag(UUID?.none)
                    ForEach(model.universities) { Text("\($0.flag) \($0.shortName)").tag(Optional($0.id)) }
                }
                TextField("When were you there? (e.g. Spring 2026)", text: $term)
                TextField("Why do you want to help?", text: $why, axis: .vertical).lineLimit(3...8)
            } footer: {
                Text("We verify every ambassador with their university email before they appear in the app.")
            }
            Button("Send application") {
                Task {
                    do { try await model.applyAsAmbassador(universityId: universityId, term: term, why: why); sent = true }
                    catch { self.error = error.localizedDescription }
                }
            }
            .disabled(universityId == nil || why.trimmingCharacters(in: .whitespaces).isEmpty || sent)
            if sent { Label("Application sent. We'll email you.", systemImage: "checkmark.circle").foregroundStyle(Color.success) }
        }
        .navigationTitle("Become an ambassador")
        .inlineTitle()
        .errorAlert($error)
    }
}

struct AmbassadorInboxView: View {
    @Environment(AppModel.self) private var model
    @State private var drafts: [Int: String] = [:]
    @State private var error: String?

    var body: some View {
        List {
            if model.inbox.isEmpty {
                EmptyState(icon: "tray", title: "No questions yet", message: "Students' questions to you show up here.")
            }
            ForEach(model.inbox) { q in
                Section(q.createdAt.formatted(date: .abbreviated, time: .shortened)) {
                    Text(q.body).font(.subheadline.weight(.semibold))
                    if let answer = q.answer {
                        Text(answer)
                    } else {
                        TextField("Your answer", text: Binding(get: { drafts[q.id] ?? "" }, set: { drafts[q.id] = $0 }), axis: .vertical)
                            .lineLimit(2...6)
                        Button("Send answer") {
                            Task {
                                do { try await model.answer(q, drafts[q.id] ?? ""); drafts[q.id] = nil }
                                catch { self.error = error.localizedDescription }
                            }
                        }
                        .disabled((drafts[q.id] ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
        .groupedList()
        .navigationTitle("Inbox")
        .inlineTitle()
        .refreshable { await model.loadAccount() }
        .errorAlert($error)
    }
}
