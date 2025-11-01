//
//  FlowLayout.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

// MARK: - Custom Layouts

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? 0
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for size in sizes {
            if currentX + size.width > containerWidth {
                // New line
                currentX = 0
                currentY += lineHeight + spacing
                totalHeight = currentY + size.height
                lineHeight = 0
            }

            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        totalHeight = currentY + lineHeight

        return CGSize(width: containerWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let containerWidth = bounds.width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var lineElements: [(offset: Int, size: CGSize)] = []

        func placeLine() {
            let lineWidth = lineElements.map { $0.size.width }.reduce(0, +) + CGFloat(lineElements.count - 1) * spacing
            var startX: CGFloat = 0
            switch alignment {
            case .leading:
                startX = bounds.minX
            case .center:
                startX = bounds.minX + (containerWidth - lineWidth) / 2
            case .trailing:
                startX = bounds.maxX - lineWidth
            default:
                startX = bounds.minX
            }

            var xOffset = startX
            for (offset, size) in lineElements {
                subviews[offset].place(at: CGPoint(x: xOffset, y: bounds.minY + currentY), proposal: ProposedViewSize(size)) // Use bounds.minY + currentY
                xOffset += size.width + spacing
            }
            lineElements.removeAll() // Clear elements for the next line
        }

        for (offset, size) in sizes.enumerated() {
            if currentX + size.width > containerWidth && !lineElements.isEmpty {
                // New line
                placeLine()
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            lineElements.append((offset, size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        placeLine() // Place the last line
    }
}
