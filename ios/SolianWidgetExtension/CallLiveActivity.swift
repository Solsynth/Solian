//
//  CallLiveActivity.swift
//  SolianWidgetExtension
//
//  Created by MiMo on 2026/6/20.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct CallActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var roomName: String
        var participantCount: Int
        var isMuted: Bool
        var elapsedSeconds: Int
    }
    
    var roomId: String
    var callerName: String
}

struct CallLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CallActivityAttributes.self) { context in
            // Lock Screen / Banner
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        Text(context.state.roomName)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.participantCount)")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(formattedDuration(context.state.elapsedSeconds))
                        .font(.system(size: 28, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        Label {
                            Text(context.state.isMuted ? "Muted" : "Active")
                        } icon: {
                            Image(systemName: context.state.isMuted ? "mic.slash.fill" : "mic.fill")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(context.state.isMuted ? .red : .green)
                        
                        Spacer()
                        
                        Text("Ongoing Call")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
            } compactTrailing: {
                Text(formattedDuration(context.state.elapsedSeconds))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
            } minimal: {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
            }
        }
    }
    
    private func formattedDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<CallActivityAttributes>
    
    var body: some View {
        HStack {
            // Left: Call icon + room info
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.roomName)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Text("\(context.state.participantCount) participant\(context.state.participantCount == 1 ? "" : "s")")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right: Duration + mute status
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedDuration(context.state.elapsedSeconds))
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: context.state.isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 9))
                    Text(context.state.isMuted ? "Muted" : "Active")
                        .font(.system(size: 10))
                }
                .foregroundColor(context.state.isMuted ? .red : .green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .activityBackgroundTint(Color(UIColor.systemBackground).opacity(0.8))
        .activitySystemActionForegroundColor(.primary)
    }
    
    private func formattedDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}
