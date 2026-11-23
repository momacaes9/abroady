import Foundation

/// Backend settings. Paste the same values as the website's `config.js`
/// (Supabase dashboard → Project Settings → API). The publishable key is safe
/// to ship: Row Level Security in `supabase/migrations` decides what it can do.
///
/// Leave them empty to run in demo mode with clearly labeled sample data.
/// Demo mode is for development only: do NOT submit it to App Review.
enum AppConfig {
    static let supabaseURL = ""
    static let supabaseAnonKey = ""

    static let privacyURL = URL(string: "https://abroady.netlify.app/privacy.html")!
    static let termsURL = URL(string: "https://abroady.netlify.app/terms.html")!
    static let supportEmail = "momacaes@unc.edu"

    static var isConfigured: Bool { !supabaseURL.isEmpty && !supabaseAnonKey.isEmpty }
}
