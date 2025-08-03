//
//  ShapeTargetNode.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SpriteKit

/// SpriteKit node representing a target position where a piece should be placed
class ShapeTargetNode: SKShapeNode {
    
    // MARK: - Properties
    let targetType: ShapeType
    let targetId: UUID
    var isOccupied: Bool = false
    let targetRotation: CGFloat // In radians
    let isFlipped: Bool
    
    // MARK: - Initialization
    init(target: ShapeTarget, scale: CGFloat) {
        self.targetType = target.type
        self.targetId = target.id
        self.targetRotation = target.rotation * .pi / 180 // Convert to radians
        self.isFlipped = target.flipped
        
        super.init()
        
        setupTarget(target: target, scale: scale)
        
        // Debug log
        print("🎯 ShapeTargetNode created: \(targetType.debugDescription) at \(target.position)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupTarget(target: ShapeTarget, scale: CGFloat) {
        // Create path from geometry
        var points = TangramGeometry.points(for: target.type)
        
        // Apply flipping if needed (for parallelogram)
        if target.flipped && target.type == .parallelogram {
            points = points.map { CGPoint(x: -$0.x, y: $0.y) }
        }
        
        self.path = TangramGeometry.createPath(from: points, scale: scale)
        
        // Configure appearance - faint outline only
        self.fillColor = UIColor.clear
        self.strokeColor = UIColor.gray.withAlphaComponent(0.4)
        self.lineWidth = 2
        self.name = "target_\(target.type.rawValue)"
        
        // Set position and rotation
        self.position = target.position
        self.zRotation = targetRotation
        
        // Lower z-position so pieces appear on top
        self.zPosition = -1
        
        // Disable user interaction
        self.isUserInteractionEnabled = false
    }
    
    // MARK: - Snap Detection
    /// Check if a piece can snap to this target
    /// - Parameters:
    ///   - piece: The piece to check
    ///   - positionThreshold: Maximum distance for snapping
    ///   - rotationThreshold: Maximum rotation difference in degrees
    /// - Returns: True if the piece can snap to this target
    func canSnap(piece: TangramPieceNode, positionThreshold: CGFloat = 30, rotationThreshold: CGFloat = 15) -> Bool {
        // Check if already occupied
        if isOccupied {
            print("❌ Target \(targetType.debugDescription) already occupied")
            return false
        }
        
        // Check piece type matches
        if piece.pieceType != targetType {
            print("❌ Type mismatch: piece=\(piece.pieceType.debugDescription), target=\(targetType.debugDescription)")
            return false
        }
        
        // Check position distance
        let distance = hypot(piece.position.x - position.x, piece.position.y - position.y)
        if distance > positionThreshold {
            print("❌ Distance too far: \(Int(distance)) > \(Int(positionThreshold))")
            return false
        }
        
        // Check rotation difference
        let rotationDiff = abs(piece.zRotation - targetRotation) * 180 / .pi
        let normalizedDiff = rotationDiff.truncatingRemainder(dividingBy: 360)
        let minDiff = min(normalizedDiff, 360 - normalizedDiff)
        
        if minDiff > rotationThreshold {
            print("❌ Rotation too far: \(Int(minDiff))° > \(Int(rotationThreshold))°")
            print("   • Piece rotation: \(Int(piece.zRotation * 180 / .pi))°")
            print("   • Target rotation: \(Int(targetRotation * 180 / .pi))°")
            return false
        }
        
        print("✅ Piece \(piece.pieceType.debugDescription) can snap to target!")
        print("   • Distance: \(Int(distance))/\(Int(positionThreshold))")
        print("   • Rotation diff: \(Int(minDiff))°/\(Int(rotationThreshold))°")
        return true
    }
    
    // MARK: - Visual Feedback
    /// Show visual feedback when a piece is near
    func showSnapFeedback() {
        let glowAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.2),
            SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        ])
        self.run(glowAction)
    }
    
    /// Show success feedback when a piece snaps
    func showSuccessFeedback() {
        self.fillColor = UIColor.systemGreen.withAlphaComponent(0.3)
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        self.run(pulseAction)
    }
}