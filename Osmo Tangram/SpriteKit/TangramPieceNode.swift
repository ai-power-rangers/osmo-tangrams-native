//
//  TangramPieceNode.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SpriteKit
import UIKit

/// SpriteKit node representing a draggable tangram piece
class TangramPieceNode: SKShapeNode {
    
    // MARK: - Properties
    let pieceType: ShapeType
    let pieceId: UUID
    var originalPosition: CGPoint = .zero
    var isSnapped: Bool = false
    var snappedToTarget: ShapeTargetNode?
    
    // Touch handling
    private var touchStartPosition: CGPoint = .zero
    private var nodeStartPosition: CGPoint = .zero
    
    // MARK: - Initialization
    init(piece: TangramPiece, scale: CGFloat) {
        self.pieceType = piece.type
        self.pieceId = piece.id
        
        super.init()
        
        setupPiece(piece: piece, scale: scale)
        
        // Debug log
        print("🧩 TangramPieceNode created: \(pieceType.debugDescription)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupPiece(piece: TangramPiece, scale: CGFloat) {
        // Create path from geometry
        let points = TangramGeometry.points(for: piece.type)
        self.path = TangramGeometry.createPath(from: points, scale: scale)
        
        // Configure appearance
        self.fillColor = colorFromString(piece.color)
        self.strokeColor = .black
        self.lineWidth = 2
        self.name = "piece_\(piece.type.rawValue)"
        
        // Set position and rotation
        self.position = piece.startPosition
        self.originalPosition = piece.startPosition
        self.zRotation = piece.rotation * .pi / 180 // Convert degrees to radians
        
        // Enable user interaction
        self.isUserInteractionEnabled = true
        
        // Add physics body for better interaction
        self.physicsBody = SKPhysicsBody(polygonFrom: self.path!)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parent = self.parent else { return }
        
        // Double-tap rotates piece 45°
        if touch.tapCount == 2 {
            rotate(by: .pi / 4)
            return
        }
        
        touchStartPosition = touch.location(in: parent)
        nodeStartPosition = self.position
        
        // Bring to front
        self.zPosition = 100
        
        // Visual feedback
        self.run(SKAction.scale(to: 1.1, duration: 0.1))
        
        // Unsnap if currently snapped
        if isSnapped {
            isSnapped = false
            snappedToTarget?.isOccupied = false
            snappedToTarget = nil
            print("🔓 Unsnapped piece: \(pieceType.debugDescription)")
        }
        
        print("👆 Touch began on piece: \(pieceType.debugDescription)")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parent = self.parent else { return }
        
        let touchLocation = touch.location(in: parent)
        let deltaX = touchLocation.x - touchStartPosition.x
        let deltaY = touchLocation.y - touchStartPosition.y
        
        self.position = CGPoint(x: nodeStartPosition.x + deltaX, y: nodeStartPosition.y + deltaY)
        
        // Apply magnetism in designer mode during dragging
        if let gameScene = self.scene as? TangramGameScene, gameScene.isDesignerMode {
            gameScene.applyMagnetism(to: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset visual feedback
        self.run(SKAction.scale(to: 1.0, duration: 0.1))
        self.zPosition = 10
        
        // Check for snap or notify designer mode
        if let gameScene = self.scene as? TangramGameScene {
            if gameScene.isDesignerMode {
                // Final magnetism check when touch ends
                gameScene.applyMagnetism(to: self)
                
                // In designer mode, notify about piece position changes
                let rotationDegrees = zRotation * 180 / .pi
                gameScene.onPiecePositionChanged?(pieceType, position, rotationDegrees)
                print("🎨 Designer mode: \(pieceType.debugDescription) moved to \(position) rotation: \(rotationDegrees)°")
                
                // Clear snap indicators after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    gameScene.clearSnapIndicators()
                }
            } else {
                // In game mode, check for snapping
                gameScene.checkForSnap(piece: self)
            }
        }
        
        print("👆 Touch ended on piece: \(pieceType.debugDescription) at position: \(position)")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // MARK: - Rotation
    func rotate(by angle: CGFloat) {
        let rotateAction = SKAction.rotate(byAngle: angle, duration: 0.2)
        self.run(rotateAction) {
            // Apply magnetism after rotation in designer mode
            if let gameScene = self.scene as? TangramGameScene, gameScene.isDesignerMode {
                gameScene.applyMagnetism(to: self)
                
                // Notify designer mode about rotation change
                let rotationDegrees = self.zRotation * 180 / .pi
                gameScene.onPiecePositionChanged?(self.pieceType, self.position, rotationDegrees)
                print("🔄 Designer mode: \(self.pieceType.debugDescription) rotated to \(rotationDegrees)° at \(self.position)")
                
                // Clear snap indicators after rotation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    gameScene.clearSnapIndicators()
                }
            }
        }
        
        print("🔄 Rotated piece: \(pieceType.debugDescription) by \(angle * 180 / .pi)°")
    }
    
    // MARK: - Helpers
    private func colorFromString(_ colorName: String) -> UIColor {
        switch colorName.lowercased() {
        case "red": return .systemRed
        case "blue": return .systemBlue
        case "green": return .systemGreen
        case "yellow": return .systemYellow
        case "orange": return .systemOrange
        case "purple": return .systemPurple
        case "pink": return .systemPink
        default: return .systemRed
        }
    }
}