//
//  TangramLevel.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import Foundation

/// Model representing a complete tangram puzzle level
struct TangramLevel: Codable, Identifiable {
    let id: UUID
    let name: String
    let difficulty: Difficulty
    let targetShapes: [ShapeTarget]
    let initialPieces: [TangramPiece]
    let thumbnailName: String? // Optional puzzle thumbnail
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    init(id: UUID = UUID(), name: String, difficulty: Difficulty, targetShapes: [ShapeTarget], initialPieces: [TangramPiece], thumbnailName: String? = nil) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.targetShapes = targetShapes
        self.initialPieces = initialPieces
        self.thumbnailName = thumbnailName
        
        // Debug log for level creation
        print("🎮 Created TangramLevel: \(name) (\(difficulty.rawValue)) with \(targetShapes.count) targets and \(initialPieces.count) pieces")
    }
}