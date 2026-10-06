import Foundation

/// Resolves the language used by the app's UI.
///
/// The list of languages comes from the bundle's localizations, so adding a
/// translation to `Localizable.xcstrings` is all it takes for it to show up in
/// the language picker.
class LanguageManager {
  /// Stored value meaning "follow the system language".
  static let systemLanguage = ""

  static var availableLanguages: [String] {
    Bundle.main.localizations
      .filter { $0 != "Base" }
      .sorted { displayName(for: $0).localizedCaseInsensitiveCompare(displayName(for: $1)) == .orderedAscending }
  }

  static var selectedLanguage: String {
    UserDefaults.standard.string(forKey: PreferenceKey.appLanguage.rawValue) ?? systemLanguage
  }

  /// The language's own name for itself, e.g. "Português (Brasil)".
  static func displayName(for language: String) -> String {
    let name = Locale(identifier: language).localizedString(forIdentifier: language) ?? language
    return name.prefix(1).uppercased() + name.dropFirst()
  }

  /// Maps a stored selection to a language the bundle actually ships, falling
  /// back to the best match for the system languages.
  static func resolvedLanguage(for selection: String) -> String {
    let available = availableLanguages
    if available.contains(selection) { return selection }
    return Bundle.preferredLocalizations(from: available, forPreferences: Locale.preferredLanguages).first
      ?? Bundle.main.developmentLocalization
      ?? "en"
  }

  static func locale(for selection: String) -> Locale {
    Locale(identifier: resolvedLanguage(for: selection))
  }

  /// For strings that don't go through SwiftUI's `Text`, which follows the
  /// environment locale on its own (AppKit titles, messages built in code).
  static func localized(_ key: String, selection: String = selectedLanguage) -> String {
    let language = resolvedLanguage(for: selection)
    let bundle = Bundle.main.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
    return bundle.localizedString(forKey: key, value: key, table: nil)
  }
}
