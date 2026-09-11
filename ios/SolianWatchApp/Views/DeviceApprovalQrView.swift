//
//  DeviceApprovalQrView.swift
//  Solian Watch App
//
//  Presents a device-flow sign-in as a QR code. The user points their iPhone's
//  camera at the watch, the server's verification page opens with the user code
//  already filled in, and the watch's polling loop completes the sign-in — no
//  typing on the watch, and no dependency on Watch Connectivity.
//

import SwiftUI
import WatchKit

struct DeviceApprovalQrView: View {
    /// The in-flight device authorization being approved.
    let device: StandaloneAuthService.DeviceCode

    @Environment(\.dismiss) private var dismiss
    @State private var qrImage: UIImage?

    private let qrSize: CGFloat = 160

    /// Prefer the code-prefilled URI: scanning that lands the user straight on
    /// the approval page with nothing left to enter.
    private var payload: String {
        device.verificationUriComplete ?? device.verificationUri
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let qrImage {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: qrSize, height: qrSize)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                        )
                        .accessibilityLabel(L10n.signInQrAccessibility)
                } else {
                    ProgressView()
                        .frame(width: qrSize, height: qrSize)
                }

                // Still shown so the code can be read out if the camera route
                // is unavailable.
                Text(device.userCode)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .accessibilityLabel(L10n.signInUserCode(device.userCode))

                Text(L10n.signInQrHint)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(L10n.signInQrClose) {
                    WKInterfaceDevice.current().play(.click)
                    dismiss()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .task {
            qrImage = makeQRImage(text: payload, dimension: qrSize)
        }
    }
}
