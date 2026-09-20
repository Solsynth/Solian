//
//  OverrideBundle.swift
//  Solian Watch App
//
//  A Bundle subclass that redirects `NSLocalizedString` (and other
//  bundle-mediated lookups) to the user-selected language's `.lproj`
//  directory, enabling in-app language switching.
//
//  Usage:
//    1. Call `OverrideBundle.setLanguage(_:)` BEFORE any `Bundle.main` access.
//    2. Replace `Bundle.main` with `OverrideBundle.main` in the @main App.
//

import Foundation

final class OverrideBundle: Bundle, @unchecked Sendable {
    /// The resolved `.lproj` bundle for the current language override, or
    /// `nil` when using the system default.
    private static var languageBundle: Bundle?

    /// The overridden language code, or `nil` for system default.
    private(set) static var currentLanguage: String?

    /// Call once at app startup, before any view or localization access.
    static func setLanguage(_ code: String?) {
        currentLanguage = code
        if let code, code != "system" {
            // Write through to AppleLanguages so any framework-level
            // NSLocalizedString also picks up the override.
            UserDefaults.standard.set([code], forKey: "AppleLanguages")
            languageBundle = Self.loadBundle(for: code)
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            languageBundle = nil
        }
    }

    // MARK: - Bundle subclass

    /// The real bundle path, captured once before any swap.
    private static let originalBundlePath = Bundle.main.bundlePath

    /// Install this bundle as the process-wide main bundle using the
    /// ObjC runtime. Call once from `WatchRunnerApp.init`.
    static func installAsMainBundle() {
        let override = OverrideBundle(path: originalBundlePath)!
        // +[NSBundle setMainBundle:] is private but stable across OS versions.
        let sel = NSSelectorFromString("setMainBundle:")
        if Bundle.main.responds(to: sel) {
            Bundle.main.perform(sel, with: override)
        }
    }

    override func object(forInfoDictionaryKey key: String) -> Any? {
        Self.languageBundle?.object(forInfoDictionaryKey: key)
            ?? super.object(forInfoDictionaryKey: key)
    }

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        Self.languageBundle?.localizedString(forKey: key, value: value, table: tableName)
            ?? super.localizedString(forKey: key, value: value, table: tableName)
    }

    override func path(forResource name: String?, ofType ext: String?) -> String? {
        Self.languageBundle?.path(forResource: name, ofType: ext)
            ?? super.path(forResource: name, ofType: ext)
    }

    override func path(forResource name: String?, ofType ext: String?, inDirectory directory: String?) -> String? {
        Self.languageBundle?.path(forResource: name, ofType: ext, inDirectory: directory)
            ?? super.path(forResource: name, ofType: ext, inDirectory: directory)
    }

    override func url(forResource name: String?, withExtension ext: String?) -> URL? {
        Self.languageBundle?.url(forResource: name, withExtension: ext)
            ?? super.url(forResource: name, withExtension: ext)
    }

    override func urls(forResourcesWithExtension ext: String?, subdirectory dir: String?) -> [URL]? {
        Self.languageBundle?.urls(forResourcesWithExtension: ext, subdirectory: dir)
            ?? super.urls(forResourcesWithExtension: ext, subdirectory: dir)
    }

    // MARK: - Helpers

    private static func loadBundle(for languageCode: String) -> Bundle? {
        let bundleURL = URL(fileURLWithPath: originalBundlePath)
        let candidates = [languageCode, String(languageCode.prefix(2))]
        for code in candidates {
            let url = bundleURL.appendingPathComponent("\(code).lproj")
            if let bundle = Bundle(url: url) {
                return bundle
            }
        }
        return nil
    }
}

// MARK: - Convenience on SettingsStore

extension SettingsStore {
    /// Apply the stored language preference to the override bundle.
    /// Call from `WatchRunnerApp.init`, before any views are created.
    static func applyLanguageOverride() {
        let code = Self.readStoredLanguageCode()
        OverrideBundle.setLanguage(code)
    }

    /// The raw language code stored in UserDefaults, or `nil` for system.
    static func readStoredLanguageCode() -> String? {
        let raw = UserDefaults.standard.string(forKey: "settings.languageCode") ?? "system"
        return raw == "system" ? nil : raw
    }
}
