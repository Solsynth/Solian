//
//  WalletQrView.swift
//  Solian Watch App
//
//  Displays the wallet's public transfer ID as a QR code. The QR encodes a
//  Solian deep link (`solian://wallet/transfer/<publicId>`) so the phone app
//  can parse it directly.
//

import SwiftUI

struct WalletQrView: View {
    let wallet: SnWatchWallet

    @State private var qrImage: UIImage?

    private let qrSize: CGFloat = 150

    /// The QR payload: the wallet's public transfer link (matches the phone
    /// app's `buildWalletTransferQrData`).
    private var qrPayload: String {
        guard let publicId = wallet.publicId else { return "" }
        var components = URLComponents()
        components.scheme = "solian"
        components.host = "wallet"
        components.path = "/transfer"
        components.queryItems = [
            URLQueryItem(name: "publicId", value: publicId),
        ]
        return components.url?.absoluteString ?? ""
    }

    private var displayId: String {
        wallet.publicId ?? "N/A"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // QR code
                if let qrImage {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: qrSize, height: qrSize)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                        )
                } else if wallet.publicId == nil {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.slash")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(L10n.walletQrPublicIdNotEnabled)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(L10n.walletQrPublicIdNotEnabledHint)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ProgressView()
                        .frame(width: qrSize, height: qrSize)
                }

                // Public ID display
                VStack(spacing: 4) {
                    Text(L10n.walletQrPublicIdLabel)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(displayId)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                // Wallet name
                HStack(spacing: 6) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(wallet.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Share button
                if wallet.publicId != nil {
                    ShareLink(item: URL(string: qrPayload) ?? URL(string: "https://solian.app")!) {
                        Label(L10n.walletQrCopyLink, systemImage: "square.and.arrow.up")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }
            }
            .padding()
        }
        .navigationTitle(L10n.walletQrTitle)
        .task {
            generateQr()
        }
    }

    private func generateQr() {
        qrImage = makeQRImage(text: qrPayload, dimension: qrSize)
    }
}
