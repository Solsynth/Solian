//
//  AccountQrView.swift
//  Solian Watch App
//
//  Shows the account's Solarpass QR code — the watch equivalent of the
//  Flutter `account_qr` screen's profile section. The QR encodes the public
//  profile URL (`https://solian.app/accounts/<name>`); a small circular
//  avatar sits in the centre, protected by high error correction.
//

import SwiftUI
import CoreGraphics
import UIKit
// Vendored pure-Swift QR encoder (fwcd/swift-qrcode-generator, MIT)
// Types live in the same module (Utils/QRGen/); no separate import needed.
// Rendering lives in Utils/QRCodeImage.swift.

struct AccountQrView: View {
    @EnvironmentObject var appState: AppState

    /// The loaded account. Passed by the caller (AccountView) so this screen
    /// never re-fetches the profile.
    let user: SnAccount

    @StateObject private var profileImageLoader = ImageLoader()
    @State private var qrImage: UIImage?

    private let qrSize: CGFloat = 180

    /// The public profile link encoded into the QR (matches the phone app).
    private var profileUrl: String { "https://solian.app/accounts/\(user.name)" }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                identityCard
                shareLink
            }
            .padding()
        }
        .navigationTitle(L10n.accountQrTitle)
        .task(id: user.profile?.picture?.id) {
            loadProfileImage()
        }
        .task {
            qrImage = makeQRImage(text: profileUrl, dimension: qrSize)
        }
    }

    // MARK: - Identity card

    private var identityCard: some View {
        VStack(spacing: 14) {
            if let qrImage {
                ZStack {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: qrSize, height: qrSize)
                    avatarOverlay
                }
                .frame(width: qrSize, height: qrSize)
            } else {
                ProgressView()
                    .frame(width: qrSize, height: qrSize)
            }

            HStack(spacing: 10) {
                profileAvatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.nick)
                        .font(.headline)
                        .lineLimit(1)
                    Text("@\(user.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }

            Text(profileUrl)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.gray.opacity(0.12)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(user.nick), @\(user.name). \(profileUrl)")
    }

    /// The circular avatar floated over the centre of the QR. A white disc
    /// behind it masks the modules so the code stays legible (with `H`
    /// correction the covered region is within tolerance).
    @ViewBuilder
    private var avatarOverlay: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 44, height: 44)
            Group {
                if let image = profileImageLoader.image {
                    image
                        .resizable()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else if profileImageLoader.errorMessage != nil {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 36, height: 36)
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var profileAvatar: some View {
        Group {
            if profileImageLoader.isLoading {
                ProgressView()
            } else if let image = profileImageLoader.image {
                image
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else if profileImageLoader.errorMessage != nil {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.red)
                            .padding(10)
                    )
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .padding(8)
                    )
            }
        }
    }

    private var shareLink: some View {
        ShareLink(item: URL(string: profileUrl) ?? URL(string: "https://solian.app")!) {
            Label(L10n.accountQrShare, systemImage: "square.and.arrow.up")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.accentColor)
        .accessibilityLabel(L10n.accountQrShare)
    }

    // MARK: - Image loading

    private func loadProfileImage() {
        guard let serverUrl = appState.serverUrl,
              let pictureId = user.profile?.picture?.id,
              let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl),
              let token = appState.token else { return }
        Task {
            await profileImageLoader.loadImage(from: imageUrl, token: token)
        }
    }
}

#Preview {
    // `SnAccount` has a custom `init(from:)` (no memberwise init), so build a
    // minimal preview account by decoding a tiny JSON payload.
    let preview = try! JSONDecoder().decode(
        SnAccount.self,
        from: Data(#"{"id":"preview","name":"littlesheep","nick":"LittleSheep"}"#.utf8)
    )
    return AccountQrView(user: preview)
        .environmentObject(AppState())
}
