import SwiftUI

/// Log in / create account. Browsing never requires an account (guideline 5.1.1);
/// only RSVPs, questions and cohort chat do.
struct AuthView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var creating = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var universityId: UUID?
    @State private var term = Terms.upcoming.first ?? ""
    @State private var international = false
    @State private var agreed = false
    @State private var busy = false
    @State private var error: String?
    @State private var checkInbox = false

    private var valid: Bool {
        let base = email.contains("@") && email.contains(".") && password.count >= 8
        return creating ? base && !name.trimmingCharacters(in: .whitespaces).isEmpty && agreed : base
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("", selection: $creating) {
                    Text("Create account").tag(true)
                    Text("Log in").tag(false)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)

                Section {
                    if creating { TextField("Full name", text: $name).textContentType(.name) }
                    TextField("Email", text: $email).textContentType(.emailAddress).emailField()
                    SecureField("Password (8+ characters)", text: $password)
                        .textContentType(creating ? .newPassword : .password)
                } footer: {
                    if creating { Text("Use your university email to get the Verified badge.") }
                }

                if creating {
                    Section("Your studies") {
                        Picker("University", selection: $universityId) {
                            Text("Choose…").tag(UUID?.none)
                            ForEach(model.homeCampuses) { Text($0.name).tag(Optional($0.id)) }
                        }
                        Picker("Term abroad", selection: $term) {
                            ForEach(Terms.upcoming, id: \.self) { Text($0).tag($0) }
                        }
                        Toggle("I'm an international student", isOn: $international)
                    }
                    Section {
                        Toggle(isOn: $agreed) {
                            Text("I agree to the Terms, the Privacy Policy and the community rules: no harassment, hate, scams or explicit content.")
                                .font(.footnote)
                        }
                        Link("Read the Terms", destination: AppConfig.termsURL).font(.footnote)
                        Link("Read the Privacy Policy", destination: AppConfig.privacyURL).font(.footnote)
                    }
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            Spacer()
                            if busy { ProgressView() } else { Text(creating ? "Create account" : "Log in").bold() }
                            Spacer()
                        }
                    }
                    .disabled(!valid || busy)
                }
            }
            .navigationTitle(creating ? "Join Abroady" : "Welcome back")
            .inlineTitle()
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .errorAlert($error)
            .alert("Check your inbox", isPresented: $checkInbox) {
                Button("OK") { creating = false }
            } message: {
                Text("We sent a confirmation link to \(email). Tap it, then log in here.")
            }
            .onAppear { universityId = universityId ?? model.campus?.id }
        }
    }

    private func submit() async {
        busy = true
        defer { busy = false }
        let mail = email.trimmingCharacters(in: .whitespaces).lowercased()
        do {
            if creating {
                let needsConfirmation = try await model.signUp(
                    name: name.trimmingCharacters(in: .whitespaces), email: mail, password: password,
                    universityId: universityId, term: term, international: international, acceptedTerms: agreed)
                if needsConfirmation { checkInbox = true } else { dismiss() }
            } else {
                try await model.signIn(email: mail, password: password)
                dismiss()
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}

/// Community rules (EULA for user-generated content, guideline 1.2).
struct CommunityRulesView: View {
    @Environment(AppModel.self) private var model
    var requireAgreement = false
    @State private var error: String?

    static let rules: [(String, String)] = [
        ("heart", "Be kind. No harassment, bullying, hate speech or threats."),
        ("eye.slash", "No sexual or explicit content, and nothing involving minors."),
        ("exclamationmark.shield", "No scams, spam, selling, or asking for money or gift cards."),
        ("lock", "Protect privacy: never post passport, visa, I-20, bank or address details."),
        ("flag", "Report anything that breaks these rules. We review reports within 24 hours and remove offending content and users."),
    ]

    var body: some View {
        List {
            Section {
                Text("Abroady has zero tolerance for objectionable content or abusive users.")
                    .font(.headline)
                ForEach(Self.rules, id: \.1) { icon, text in
                    Label(text, systemImage: icon)
                }
            } header: {
                Text("Community rules")
            }
            if requireAgreement {
                Section {
                    Button {
                        Task {
                            do { try await model.acceptTerms() } catch { self.error = error.localizedDescription }
                        }
                    } label: {
                        Text("I agree, take me to the chat").bold().frame(maxWidth: .infinity)
                    }
                }
            }
            Section {
                Link("Terms of use", destination: AppConfig.termsURL)
                Link("Privacy policy", destination: AppConfig.privacyURL)
            }
        }
        .groupedList()
        .errorAlert($error)
    }
}
