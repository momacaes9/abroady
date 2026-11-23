import SwiftUI

/// Brand colors shared with the website (styles.css).
extension Color {
    static let brand = Color(red: 0.294, green: 0.612, blue: 0.827)      // #4B9CD3 Carolina Blue
    static let brandInk = Color(red: 0.110, green: 0.416, blue: 0.639)   // #1C6AA3
    static let navy = Color(red: 0.075, green: 0.161, blue: 0.294)       // #13294B
    static let success = Color(red: 0.231, green: 0.667, blue: 0.431)    // #3BAA6E
    static let amber = Color(red: 0.718, green: 0.475, blue: 0.122)      // #B7791F
}

struct Pill: View {
    let text: String
    var color: Color = .brandInk
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
    }
}

struct VerifiedBadge: View {
    var label = "Verified"
    var body: some View {
        Label(label, systemImage: "checkmark.seal.fill")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.brandInk)
            .accessibilityLabel(label)
    }
}

struct Avatar: View {
    let name: String
    var size: CGFloat = 44
    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
    private var hue: Double { Double(name.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 360) / 360 }
    var body: some View {
        Text(initials.isEmpty ? "?" : initials)
            .font(.system(size: size * 0.38, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Color(hue: hue, saturation: 0.45, brightness: 0.75), in: Circle())
            .accessibilityHidden(true)
    }
}

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.largeTitle).foregroundStyle(Color.brand)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

/// Banner shown in demo mode so nobody mistakes sample data for real students.
struct DemoBanner: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        if model.isDemo {
            Label("Demo mode: sample data, not real students", systemImage: "flask")
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(8)
                .foregroundStyle(Color.amber)
                .background(Color.amber.opacity(0.12))
        }
    }
}

// MARK: - iOS-only modifiers (kept here so the code also type-checks on macOS)

extension View {
    func inlineTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    func emailField() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.never).keyboardType(.emailAddress).autocorrectionDisabled()
        #else
        autocorrectionDisabled()
        #endif
    }

    func groupedList() -> some View {
        #if os(iOS)
        listStyle(.insetGrouped)
        #else
        listStyle(.inset)
        #endif
    }

    func errorAlert(_ message: Binding<String?>) -> some View {
        alert("Something went wrong", isPresented: Binding(get: { message.wrappedValue != nil },
                                                           set: { if !$0 { message.wrappedValue = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}

extension Date {
    var eventDay: String { formatted(.dateTime.weekday(.wide).month(.abbreviated).day()) }
    var eventTime: String { formatted(date: .omitted, time: .shortened) }
}
