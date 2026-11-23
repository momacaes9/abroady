import Foundation
import Security

/// Minimal Supabase client over plain URLSession (Auth + PostgREST + RPC).
/// No third-party packages: smaller app, nothing extra for App Review to scan.
actor SupabaseClient {
    struct Session: Codable {
        let accessToken: String
        let refreshToken: String
        let expiresAt: Double
        let user: AuthUser
    }
    struct AuthUser: Codable { let id: UUID; let email: String? }

    enum APIError: LocalizedError {
        case http(Int, String)
        case notSignedIn
        var errorDescription: String? {
            switch self {
            case .notSignedIn: return "Please log in first."
            case .http(_, let message): return message
            }
        }
    }

    private let baseURL: URL
    private let anonKey: String
    private(set) var session: Session?

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            if let date = parseDate(raw) { return date }
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Bad date \(raw)"))
        }
        return d
    }()

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    /// Postgres returns "2026-11-22T21:04:47.032863+00:00" (6 fractional digits) or no fraction.
    static func parseDate(_ raw: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        if let d = withFraction.date(from: raw) ?? plain.date(from: raw) { return d }
        // Trim microseconds to milliseconds, which ISO8601DateFormatter understands
        if let dot = raw.firstIndex(of: "."),
           let zone = raw[dot...].firstIndex(where: { $0 == "+" || $0 == "-" || $0 == "Z" }) {
            let fraction = raw[raw.index(after: dot)..<zone].prefix(3)
            return withFraction.date(from: String(raw[..<dot]) + "." + fraction + raw[zone...])
        }
        return nil
    }

    init(url: String, anonKey: String) {
        self.baseURL = URL(string: url)!
        self.anonKey = anonKey
        self.session = Keychain.load()
    }

    var userId: UUID? { session?.user.id }

    // MARK: - Auth

    /// Returns true when the account still needs email confirmation.
    func signUp(email: String, password: String, metadata: [String: String]) async throws -> Bool {
        let body: [String: Any] = ["email": email, "password": password, "data": metadata]
        let data = try await send("auth/v1/signup", method: "POST", json: body, authorized: false)
        if let session = try? Self.decoder.decode(Session.self, from: data) {
            store(session)
            return false
        }
        return true
    }

    func signIn(email: String, password: String) async throws {
        let data = try await send("auth/v1/token?grant_type=password", method: "POST",
                                  json: ["email": email, "password": password], authorized: false)
        store(try Self.decoder.decode(Session.self, from: data))
    }

    func signOut() async {
        if session != nil { _ = try? await send("auth/v1/logout", method: "POST", json: [:]) }
        store(nil)
    }

    private func refreshIfNeeded() async throws {
        guard let current = session, current.expiresAt - 60 < Date().timeIntervalSince1970 else { return }
        do {
            let data = try await send("auth/v1/token?grant_type=refresh_token", method: "POST",
                                      json: ["refresh_token": current.refreshToken], authorized: false)
            store(try Self.decoder.decode(Session.self, from: data))
        } catch {
            store(nil)
            throw APIError.notSignedIn
        }
    }

    private func store(_ newSession: Session?) {
        session = newSession
        Keychain.save(newSession)
    }

    // MARK: - Database

    func select<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        try Self.decoder.decode(T.self, from: try await send("rest/v1/" + path, method: "GET"))
    }

    func insert<T: Encodable>(_ table: String, _ row: T) async throws {
        _ = try await send("rest/v1/" + table, method: "POST", body: try Self.encoder.encode(row),
                           headers: ["Prefer": "return=minimal"])
    }

    func update<T: Encodable>(_ path: String, _ fields: T) async throws {
        _ = try await send("rest/v1/" + path, method: "PATCH", body: try Self.encoder.encode(fields),
                           headers: ["Prefer": "return=minimal"])
    }

    func upsert<T: Encodable>(_ table: String, _ row: T) async throws {
        _ = try await send("rest/v1/" + table, method: "POST", body: try Self.encoder.encode(row),
                           headers: ["Prefer": "resolution=merge-duplicates,return=minimal"])
    }

    func delete(_ path: String) async throws {
        _ = try await send("rest/v1/" + path, method: "DELETE")
    }

    func rpc<T: Decodable>(_ function: String, _ params: [String: String] = [:], as type: T.Type = T.self) async throws -> T {
        let data = try await send("rest/v1/rpc/" + function, method: "POST", json: params)
        return try Self.decoder.decode(T.self, from: data.isEmpty ? Data("null".utf8) : data)
    }

    // MARK: - Transport

    private func send(_ path: String, method: String, json: [String: Any], authorized: Bool = true) async throws -> Data {
        try await send(path, method: method, body: try JSONSerialization.data(withJSONObject: json), authorized: authorized)
    }

    private func send(_ path: String, method: String, body: Data? = nil,
                      headers: [String: String] = [:], authorized: Bool = true) async throws -> Data {
        if authorized { try await refreshIfNeeded() }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.http(0, "Bad URL") }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 20
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = authorized ? (session?.accessToken ?? anonKey) : anonKey
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            let message = (object?["msg"] ?? object?["message"] ?? object?["error_description"] ?? object?["error"]) as? String
            throw APIError.http(status, message ?? "Something went wrong (\(status)). Please try again.")
        }
        return data
    }
}

/// Stores the auth session in the Keychain (never in UserDefaults).
enum Keychain {
    private static let service = "app.abroady.session"

    static func save(_ session: SupabaseClient.Session?) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service]
        SecItemDelete(query as CFDictionary)
        guard let session, let data = try? JSONEncoder().encode(session) else { return }
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(add as CFDictionary, nil)
    }

    static func load() -> SupabaseClient.Session? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
                                    kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(SupabaseClient.Session.self, from: data)
    }
}
