//
//  ColorTheme.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI

/// Color theme for consistent app styling
struct ColorTheme {
    // Piece colors
    static let pieceColors: [String: Color] = [
        "red": .red,
        "blue": .blue,
        "green": .green,
        "yellow": .yellow,
        "orange": .orange,
        "purple": .purple,
        "pink": .pink
    ]
    
    // UI colors
    static let primaryBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)
    static let shadowColor = Color.black.opacity(0.1)
    
    // Game colors
    static let targetFillColor = Color.gray.opacity(0.2)
    static let targetStrokeColor = Color.gray.opacity(0.5)
    static let successColor = Color.green.opacity(0.3)
    
    /// Get a consistent color set for all pieces
    static func colorsForPieces() -> [Color] {
        return [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    }
}