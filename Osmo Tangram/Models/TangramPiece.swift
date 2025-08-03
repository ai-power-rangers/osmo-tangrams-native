//
//  TangramPiece.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import Foundation
import CoreGraphics

/// Model representing a tangram piece with its initial configuration
struct TangramPiece: Codable {
    let id: UUID
    let type: ShapeType
    let startPosition: CGPoint
    let rotation: CGFloat // In degrees
    let color: String // Color name as string for Codable
    
    init(id: UUID = UUID(), type: ShapeType, startPosition: CGPoint, rotation: CGFloat = 0, color: String = "red") {
        self.id = id
        self.type = type
        self.startPosition = startPosition
        self.rotation = rotation
        self.color = color
        
        // Debug log for piece creation
        print("🧩 Created TangramPiece: \(type.debugDescription) at position: \(startPosition), rotation: \(rotation)°")
    }
}

/// Model representing a target shape where a piece should be placed
struct ShapeTarget: Codable {
    let id: UUID
    let type: ShapeType
    let position: CGPoint
    let rotation: CGFloat // In degrees
    let flipped: Bool // For parallelogram only
    
    init(id: UUID = UUID(), type: ShapeType, position: CGPoint, rotation: CGFloat = 0, flipped: Bool = false) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.flipped = flipped
        
        // Debug log for target creation
        print("🎯 Created ShapeTarget: \(type.debugDescription) at position: \(position), rotation: \(rotation)°, flipped: \(flipped)")
    }
}