//
//  AppInfoHeader.swift
//  Runner
//
//  Created by LittleSheep on 2025/10/30.
//

import SwiftUI

struct AppInfoHeaderView : View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text("Solian").font(.headline)
                    Text("for Apple Watch").font(.system(size: 11))
                }
            }
        }
    }
}
