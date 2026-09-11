//
//  SettingsView.swift
//  Solian Watch App
//
//  Client-side settings and about information.
//

import SwiftUI
import WatchKit
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: SettingsStore
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingPurgeConfirmation = false
    @State private var purgeMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Background Image

                SectionHeader(title: L10n.settingsBackgroundImage)

                BackgroundImagePreview(
                    imageData: settings.backgroundImageData,
                    onSelect: { image in settings.setBackgroundImage(image) },
                    onClear: { settings.clearBackgroundImage() }
                )

                // MARK: - Client Settings

                SectionHeader(title: L10n.settingsClient)

                SettingToggle(
                    label: L10n.settingsHapticFeedback,
                    isOn: $settings.hapticFeedback
                )

                SettingToggle(
                    label: L10n.settingsShowTimestamps,
                    isOn: $settings.showTimestamps
                )

                SettingToggle(
                    label: L10n.settingsAutoRefresh,
                    isOn: $settings.autoRefresh
                )

                // MARK: - Language

                SectionHeader(title: L10n.settingsLanguage)

                LanguagePicker(selection: $settings.languageCode)

                // MARK: - Accent Color

                SectionHeader(title: L10n.settingsAccentColor)

                AccentColorPicker(selection: $settings.accentColorName)

                // MARK: - About

                SectionHeader(title: L10n.settingsAbout)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Solian")
                                .font(.headline)
                            Text(L10n.settingsWatchApp)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    AboutRow(label: L10n.settingsVersion, value: settings.appVersion)
                    AboutRow(label: L10n.settingsBuild, value: settings.buildNumber)

                    if let serverUrl = appState.serverUrl {
                        AboutRow(label: L10n.settingsServer, value: URL(string: serverUrl)?.host ?? serverUrl)
                    }

                    AboutRow(label: L10n.settingsBundleId, value: settings.bundleId)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(settings.tintColor(opacity: 0.12))
                )

                // MARK: - Local Data

                SectionHeader(title: L10n.settingsLocalData)

                Button(role: .destructive) {
                    WKInterfaceDevice.current().play(.click)
                    showingPurgeConfirmation = true
                } label: {
                    Label(L10n.settingsClearLocalData, systemImage: "trash")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .accessibilityLabel(L10n.settingsClearLocalData)

                if let purgeMessage {
                    Text(purgeMessage)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // MARK: - Sign Out

                if appState.standaloneAuth.hasStoredSession {
                    Button(role: .destructive) {
                        appState.signOutStandalone()
                    } label: {
                        Label(L10n.accountSignOut, systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .accessibilityLabel(L10n.accountSignOutAccessibility)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(L10n.settingsTitle)
        .confirmationDialog(
            L10n.settingsClearLocalData,
            isPresented: $showingPurgeConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.settingsClearLocalDataButton, role: .destructive) {
                appState.purgeLocalData()
                purgeMessage = L10n.settingsClearLocalDataDone
                WKInterfaceDevice.current().play(.success)
            }
            Button(L10n.accountCancel, role: .cancel) {}
        } message: {
            Text(L10n.settingsClearLocalDataMessage)
        }
    }
}

// MARK: - Background Image

/// Shows a preview of the current background with pick / clear actions.
private struct BackgroundImagePreview: View {
    let imageData: Data?
    let onSelect: (UIImage) -> Void
    let onClear: () -> Void

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            // Preview
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 80)

                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                        Text(L10n.settingsBackgroundNone)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Actions
            HStack(spacing: 8) {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    Label(L10n.settingsBackgroundChoose, systemImage: "photo.on.rectangle")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .onChange(of: selectedItem) { _, item in
                    guard let item else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            onSelect(image)
                        }
                        selectedItem = nil
                    }
                }

                if imageData != nil {
                    Button {
                        onClear()
                    } label: {
                        Label(L10n.settingsBackgroundClear, systemImage: "xmark.circle")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
    }
}

// MARK: - Sub-views

/// A reusable settings toggle row — label fills the width, toggle on the right.
private struct SettingToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .lineLimit(1)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.accentColor)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

/// Section header matching the sidebar tile style.
private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.leading, 4)
    }
}

/// A key-value row for the About section.
private struct AboutRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

/// Language selection picker with system default, English, and Chinese options.
private struct LanguagePicker: View {
    @Binding var selection: String

    private struct LangOption: Identifiable {
        let id: String
        let label: String
    }

    private let options: [LangOption] = [
        LangOption(id: "system", label: L10n.settingsLanguageSystem),
        LangOption(id: "en", label: "English"),
        LangOption(id: "zh-Hans", label: "简体中文"),
        LangOption(id: "zh-Hant", label: "繁體中文"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options) { option in
                Button {
                    selection = option.id
                } label: {
                    HStack {
                        Text(option.label)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        if selection == option.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(selection == option.id
                                  ? Color.accentColor.opacity(0.12)
                                  : Color.clear)
                    )
                }
                .buttonStyle(.plain)

                if option.id != options.last?.id {
                    Divider()
                        .padding(.leading, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

/// A grid of color circles for selecting the accent color.
private struct AccentColorPicker: View {
    @Binding var selection: String

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(SettingsStore.accentColorOptions) { option in
                    Button {
                        selection = option.id
                    } label: {
                        ZStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            selection == option.id
                                                ? Color.white
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            if selection == option.id {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(SettingsStore.accentColorOptions
                .first(where: { $0.id == selection })?.label ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(SettingsStore.shared)
}
