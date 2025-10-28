//
//  CustomPreviews.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

#Preview {
    NavigationStack {
        ActivityListView(filter: "Preview", mockActivities: SnActivity.mock)
            .environmentObject(AppState())
    }
}
