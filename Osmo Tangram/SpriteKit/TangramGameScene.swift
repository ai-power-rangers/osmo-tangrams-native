//
//  TangramGameScene.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SpriteKit
import SwiftUI

/// Main SpriteKit scene for the tangram game
class TangramGameScene: SKScene {
    
    // MARK: - Properties
    let level: TangramLevel
    let isDesignerMode: Bool
    var pieces: [TangramPieceNode] = []
    var targets: [ShapeTargetNode] = []
    var onWinCallback: (() -> Void)?
    var onResetCallback: (() -> Void)?
    var onPiecePositionChanged: ((ShapeType, CGPoint, CGFloat) -> Void)?
    
    // UI Elements
    var rotateButton: SKSpriteNode?
    var selectedPiece: TangramPieceNode?
    
    // MARK: - Magnetism System (Designer Mode Only)
    var magnetismSettings = MagnetismSettings()
    var snapIndicators: [SKShapeNode] = []
    
    /// Configuration for magnetism behavior in designer mode
    struct MagnetismSettings {
        var enabled: Bool = true
        var snapDistance: CGFloat = 25.0
        var angleSnapThreshold: CGFloat = 15.0 // degrees
        var showSnapIndicators: Bool = true
        var preventOverlap: Bool = true
        var edgeMagnetism: Bool = true
        var cornerMagnetism: Bool = true
        var angleMagnetism: Bool = true
    }
    
    /// Represents a potential snap point for magnetism
    struct SnapPoint {
        let position: CGPoint
        let rotation: CGFloat?
        let type: SnapType
        let targetPiece: TangramPieceNode?
        let strength: CGFloat
        
        enum SnapType {
            case edge, corner, center
        }
    }
    
    /// Edge information for magnetism calculations
    struct EdgeInfo {
        let start: CGPoint
        let end: CGPoint
        let midpoint: CGPoint
        let angle: CGFloat
        let length: CGFloat
        
        init(start: CGPoint, end: CGPoint) {
            self.start = start
            self.end = end
            self.midpoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
            self.angle = atan2(end.y - start.y, end.x - start.x)
            self.length = hypot(end.x - start.x, end.y - start.y)
        }
    }
    
    // MARK: - Configuration
    let positionSnapThreshold: CGFloat = 50 // Increased for easier snapping
    let rotationSnapThreshold: CGFloat = 30 // Increased for easier snapping (degrees)
    let pieceScale: CGFloat = 100 // Scale factor for pieces
    
    // MARK: - Initialization
    init(level: TangramLevel, isDesignerMode: Bool = false) {
        self.level = level
        self.isDesignerMode = isDesignerMode
        super.init(size: CGSize(width: 768, height: 1024)) // iPad size
        
        self.scaleMode = .resizeFill
        self.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Light gray background
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Center anchor for consistent positioning
        
        let mode = isDesignerMode ? "DESIGNER" : "GAME"
        print("🎮 TangramGameScene initialized with level: \(level.name) in \(mode) mode")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        print("📱 Scene moved to view")
        print("   - Scene size: \(size)")
        print("   - View size: \(view.frame.size)")
        print("   - Scene position: \(position)")
        print("   - Anchor point: \(anchorPoint)")
        
        setupLevel()
        setupUI()
        
        // Add debug logs
        print("🎯 Scene setup complete - Children count: \(children.count)")
    }
    
    // MARK: - Level Setup
    private func setupLevel() {
        // Clear any existing nodes
        pieces.forEach { $0.removeFromParent() }
        targets.forEach { $0.removeFromParent() }
        pieces.removeAll()
        targets.removeAll()
        
        // Create target shapes
        func centered(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x - size.width/2, y: p.y - size.height/2) }
        for target in level.targetShapes {
            let targetNode = ShapeTargetNode(target: target, scale: pieceScale)
            targetNode.position = centered(target.position)
            targets.append(targetNode)
            addChild(targetNode)
        }
        
        // Create puzzle pieces
        for (index, piece) in level.initialPieces.enumerated() {
            let pieceNode = TangramPieceNode(piece: piece, scale: pieceScale)
            pieceNode.zPosition = CGFloat(index + 10) // Ensure pieces are above targets
            pieces.append(pieceNode)
            addChild(pieceNode)
        }
        
        // Layout pieces neatly in tray area
        layoutPiecesInTray()
        
        print("✅ Level setup complete: \(targets.count) targets, \(pieces.count) pieces")
    }
    
    // MARK: - Piece Tray Layout
    /// Lay out pieces in a tidy grid along the bottom of the screen so they are always visible and easy to grab.
    private func layoutPiecesInTray() {
        let trayHeight: CGFloat = size.height * 0.25
        let trayOriginY: CGFloat = -size.height/2 + 10 // bottom padding with center anchor
        let columns = 4
        let cellWidth = size.width / CGFloat(columns)
        let cellHeight = trayHeight / 2
        var index = 0
        for piece in pieces {
            let row = index / columns
            let column = index % columns
            let posX = -size.width/2 + cellWidth * CGFloat(column) + cellWidth / 2
            let posY = trayOriginY + CGFloat(row) * cellHeight + cellHeight / 2
            piece.position = CGPoint(x: posX, y: posY)
            piece.zRotation = 0 // Reset rotation so orientation predictable
            index += 1
            print("🧩 Placed \(piece.pieceType.debugDescription) in tray at (\(Int(posX)), \(Int(posY)))")
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add rotate button
        let rotateButtonNode = SKShapeNode(circleOfRadius: 30)
        rotateButtonNode.fillColor = .systemBlue
        rotateButtonNode.strokeColor = .white
        rotateButtonNode.lineWidth = 2
        // Position relative to top-right corner with center anchor
        rotateButtonNode.position = CGPoint(x: size.width/2 - 80, y: size.height/2 - 80)
        rotateButtonNode.name = "rotateButton"
        
        // Add rotate icon (simple arrow)
        let arrowLabel = SKLabelNode(text: "↻")
        arrowLabel.fontSize = 30
        arrowLabel.fontName = "System"
        arrowLabel.verticalAlignmentMode = .center
        rotateButtonNode.addChild(arrowLabel)
        
        addChild(rotateButtonNode)
        
        print("🎨 UI setup complete")
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // Check if rotate button was touched
        if touchedNode.name == "rotateButton" || touchedNode.parent?.name == "rotateButton" {
            rotateSelectedPiece()
            return
        }
        
        // Check if a piece was touched
        if let piece = touchedNode as? TangramPieceNode {
            selectedPiece = piece
            print("🎯 Selected piece: \(piece.pieceType.debugDescription)")
        }
    }
    
    // MARK: - Piece Manipulation
    private func rotateSelectedPiece() {
        guard let piece = selectedPiece else {
            print("⚠️ No piece selected for rotation")
            return
        }
        
        piece.rotate(by: .pi / 4) // Rotate by 45 degrees
    }
    
    // MARK: - Snap Detection
    func checkForSnap(piece: TangramPieceNode) {
        var didSnap = false
        
        print("🔍 Checking snap for \(piece.pieceType.debugDescription) at position (\(Int(piece.position.x)), \(Int(piece.position.y))) rotation: \(Int(piece.zRotation * 180 / .pi))°")
        
        for (index, target) in targets.enumerated() {
            let distance = hypot(piece.position.x - target.position.x, piece.position.y - target.position.y)
            let rotationDiff = abs(piece.zRotation - target.targetRotation) * 180 / .pi
            let normalizedRotationDiff = rotationDiff.truncatingRemainder(dividingBy: 360)
            let minRotationDiff = min(normalizedRotationDiff, 360 - normalizedRotationDiff)
            
            print("🎯 Target[\(index)] \(target.targetType.debugDescription): distance=\(Int(distance)), rotation_diff=\(Int(minRotationDiff))°, occupied=\(target.isOccupied)")
            
            if target.canSnap(piece: piece, positionThreshold: positionSnapThreshold, rotationThreshold: rotationSnapThreshold) {
                // Snap the piece to target
                snapPiece(piece, to: target)
                didSnap = true
                break
            }
        }
        
        if !didSnap {
            print("❌ No valid snap position found for \(piece.pieceType.debugDescription)")
            print("   • Position threshold: \(positionSnapThreshold)")
            print("   • Rotation threshold: \(rotationSnapThreshold)°")
        }
        
        // Check for win condition after each snap attempt
        checkForWin()
    }
    
    private func snapPiece(_ piece: TangramPieceNode, to target: ShapeTargetNode) {
        // Animate snap
        let snapAction = SKAction.group([
            SKAction.move(to: target.position, duration: 0.2),
            SKAction.rotate(toAngle: target.targetRotation, duration: 0.2)
        ])
        
        piece.run(snapAction) {
            // Update state after animation
            piece.isSnapped = true
            piece.snappedToTarget = target
            target.isOccupied = true
            target.showSuccessFeedback()
            
            print("🧲 Snapped \(piece.pieceType.debugDescription) to target")
        }
        
        // Play snap sound (if available)
        // run(SKAction.playSoundFileNamed("snap.wav", waitForCompletion: false))
    }
    
    // MARK: - Win Detection
    private func checkForWin() {
        // Check if all targets are occupied
        let occupiedTargets = targets.filter { $0.isOccupied }
        let allTargetsOccupied = targets.allSatisfy { $0.isOccupied }
        
        print("📊 Win Check: \(occupiedTargets.count)/\(targets.count) targets occupied")
        for (index, target) in targets.enumerated() {
            print("   Target[\(index)] \(target.targetType.debugDescription): \(target.isOccupied ? "✅ Occupied" : "❌ Empty")")
        }
        
        if allTargetsOccupied {
            print("🎉 PUZZLE COMPLETE! All \(targets.count) targets are occupied!")
            triggerWin()
        } else {
            print("📊 Progress: \(occupiedTargets.count)/\(targets.count) pieces placed correctly")
        }
    }
    
    private func triggerWin() {
        // Visual celebration
        for piece in pieces {
            let celebrateAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            piece.run(celebrateAction)
        }
        
        // Add simple confetti effect using colored squares
        for _ in 0..<20 {
            let confetti = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
            confetti.fillColor = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.orange].randomElement()!
            confetti.position = CGPoint(x: size.width / 2, y: size.height / 2)
            confetti.zPosition = 200
            addChild(confetti)
            
            // Animate confetti
            let randomX = CGFloat.random(in: -200...200)
            let randomY = CGFloat.random(in: -100...300)
            let moveAction = SKAction.moveBy(x: randomX, y: randomY, duration: 1.5)
            let fadeAction = SKAction.fadeOut(withDuration: 1.5)
            let rotateAction = SKAction.rotate(byAngle: .pi * 4, duration: 1.5)
            let groupAction = SKAction.group([moveAction, fadeAction, rotateAction])
            
            confetti.run(SKAction.sequence([
                groupAction,
                SKAction.removeFromParent()
            ]))
        }
        
        // Notify SwiftUI view
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.onWinCallback?()
        }
    }
    
    // MARK: - Magnetism Helper Functions (Designer Mode Only)
    
    /// Gets the world-space vertices of a piece considering its current position and rotation
    private func getWorldVertices(for piece: TangramPieceNode) -> [CGPoint] {
        let localPoints = TangramGeometry.points(for: piece.pieceType)
        let scaledPoints = TangramGeometry.scalePoints(localPoints, by: pieceScale)
        
        // Apply rotation and translation to get world coordinates
        return scaledPoints.map { point in
            let rotatedX = point.x * cos(piece.zRotation) - point.y * sin(piece.zRotation)
            let rotatedY = point.x * sin(piece.zRotation) + point.y * cos(piece.zRotation)
            return CGPoint(x: rotatedX + piece.position.x, y: rotatedY + piece.position.y)
        }
    }
    
    /// Gets all edges of a piece in world coordinates
    private func getEdges(for piece: TangramPieceNode) -> [EdgeInfo] {
        let vertices = getWorldVertices(for: piece)
        var edges: [EdgeInfo] = []
        
        for i in 0..<vertices.count {
            let nextIndex = (i + 1) % vertices.count
            edges.append(EdgeInfo(start: vertices[i], end: vertices[nextIndex]))
        }
        
        return edges
    }
    
    /// Find potential snap points for a piece based on magnetism settings
    private func findSnapPoints(for piece: TangramPieceNode) -> [SnapPoint] {
        guard isDesignerMode && magnetismSettings.enabled else { return [] }
        
        var snapPoints: [SnapPoint] = []
        let pieceVertices = getWorldVertices(for: piece)
        let pieceEdges = getEdges(for: piece)
        
        // Check against all other pieces
        for otherPiece in pieces {
            guard otherPiece != piece else { continue }
            
            let otherVertices = getWorldVertices(for: otherPiece)
            let otherEdges = getEdges(for: otherPiece)
            
            // Corner magnetism - piece corners to other piece corners
            if magnetismSettings.cornerMagnetism {
                for vertex in pieceVertices {
                    for otherVertex in otherVertices {
                        let distance = hypot(vertex.x - otherVertex.x, vertex.y - otherVertex.y)
                        if distance <= magnetismSettings.snapDistance {
                            let offset = CGPoint(x: otherVertex.x - vertex.x, y: otherVertex.y - vertex.y)
                            let snapPosition = CGPoint(x: piece.position.x + offset.x, y: piece.position.y + offset.y)
                            let strength = 1.0 - (distance / magnetismSettings.snapDistance)
                            
                            snapPoints.append(SnapPoint(
                                position: snapPosition,
                                rotation: nil,
                                type: .corner,
                                targetPiece: otherPiece,
                                strength: strength
                            ))
                        }
                    }
                }
            }
            
            // Edge magnetism - piece edges to other piece edges
            if magnetismSettings.edgeMagnetism {
                for edge in pieceEdges {
                    for otherEdge in otherEdges {
                        let distance = distanceBetweenEdges(edge, otherEdge)
                        if distance <= magnetismSettings.snapDistance {
                            if let snapResult = calculateEdgeSnapPosition(piece: piece, edge: edge, targetEdge: otherEdge) {
                                let strength = 1.0 - (distance / magnetismSettings.snapDistance)
                                
                                snapPoints.append(SnapPoint(
                                    position: snapResult.position,
                                    rotation: magnetismSettings.angleMagnetism ? snapResult.rotation : nil,
                                    type: .edge,
                                    targetPiece: otherPiece,
                                    strength: strength
                                ))
                            }
                        }
                    }
                }
            }
        }
        
        // Sort by strength (strongest first)
        return snapPoints.sorted { $0.strength > $1.strength }
    }
    
    /// Calculate the minimum distance between two edges
    private func distanceBetweenEdges(_ edge1: EdgeInfo, _ edge2: EdgeInfo) -> CGFloat {
        // Simplified distance calculation using edge midpoints
        return hypot(edge1.midpoint.x - edge2.midpoint.x, edge1.midpoint.y - edge2.midpoint.y)
    }
    
    /// Calculate snap position and rotation for edge alignment
    private func calculateEdgeSnapPosition(piece: TangramPieceNode, edge: EdgeInfo, targetEdge: EdgeInfo) -> (position: CGPoint, rotation: CGFloat)? {
        // Calculate the offset needed to align edge midpoints
        let offsetX = targetEdge.midpoint.x - edge.midpoint.x
        let offsetY = targetEdge.midpoint.y - edge.midpoint.y
        let newPosition = CGPoint(x: piece.position.x + offsetX, y: piece.position.y + offsetY)
        
        // Calculate rotation needed to align edges (if angle magnetism is enabled)
        var newRotation = piece.zRotation
        if magnetismSettings.angleMagnetism {
            let angleDiff = targetEdge.angle - edge.angle
            let normalizedAngleDiff = atan2(sin(angleDiff), cos(angleDiff))
            
            // Check if the angle difference is within threshold
            let angleDiffDegrees = abs(normalizedAngleDiff * 180 / .pi)
            if angleDiffDegrees <= magnetismSettings.angleSnapThreshold || 
               abs(angleDiffDegrees - 180) <= magnetismSettings.angleSnapThreshold {
                newRotation = piece.zRotation + normalizedAngleDiff
            }
        }
        
        return (position: newPosition, rotation: newRotation)
    }
    
    /// Check for collisions with other pieces
    private func wouldCollide(piece: TangramPieceNode, at position: CGPoint, rotation: CGFloat) -> Bool {
        guard magnetismSettings.preventOverlap else { return false }
        
        // Create temporary vertices for the piece at the proposed position/rotation
        let localPoints = TangramGeometry.points(for: piece.pieceType)
        let scaledPoints = TangramGeometry.scalePoints(localPoints, by: pieceScale)
        
        let proposedVertices = scaledPoints.map { point in
            let rotatedX = point.x * cos(rotation) - point.y * sin(rotation)
            let rotatedY = point.x * sin(rotation) + point.y * cos(rotation)
            return CGPoint(x: rotatedX + position.x, y: rotatedY + position.y)
        }
        
        // Check against all other pieces
        for otherPiece in pieces {
            guard otherPiece != piece else { continue }
            
            let otherVertices = getWorldVertices(for: otherPiece)
            
            // Simple polygon overlap detection using separating axis theorem (simplified)
            if polygonsOverlap(proposedVertices, otherVertices) {
                return true
            }
        }
        
        return false
    }
    
    /// Simplified polygon overlap detection
    private func polygonsOverlap(_ poly1: [CGPoint], _ poly2: [CGPoint]) -> Bool {
        // Simplified overlap check using bounding rectangles for performance
        let bounds1 = boundingRect(for: poly1)
        let bounds2 = boundingRect(for: poly2)
        
        return bounds1.intersects(bounds2)
    }
    
    /// Calculate bounding rectangle for a set of points
    private func boundingRect(for points: [CGPoint]) -> CGRect {
        guard !points.isEmpty else { return .zero }
        
        let minX = points.map { $0.x }.min()!
        let maxX = points.map { $0.x }.max()!
        let minY = points.map { $0.y }.min()!
        let maxY = points.map { $0.y }.max()!
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    /// Apply magnetism to a piece during dragging (called from TangramPieceNode)
    func applyMagnetism(to piece: TangramPieceNode) {
        guard isDesignerMode && magnetismSettings.enabled else { return }
        
        let snapPoints = findSnapPoints(for: piece)
        clearSnapIndicators()
        
        if let bestSnap = snapPoints.first, bestSnap.strength > 0.7 {
            // Check for collision before applying snap
            let targetRotation = bestSnap.rotation ?? piece.zRotation
            if !wouldCollide(piece: piece, at: bestSnap.position, rotation: targetRotation) {
                // Apply the snap
                piece.position = bestSnap.position
                if let rotation = bestSnap.rotation {
                    piece.zRotation = rotation
                }
                
                // Show visual feedback
                if magnetismSettings.showSnapIndicators {
                    showSnapIndicator(at: bestSnap.position, type: bestSnap.type)
                }
                
                print("🧲 Applied \(bestSnap.type) magnetism to \(piece.pieceType.debugDescription) (strength: \(String(format: "%.2f", bestSnap.strength)))")
            }
        } else if magnetismSettings.showSnapIndicators && !snapPoints.isEmpty {
            // Show potential snap points
            for snapPoint in snapPoints.prefix(3) { // Show top 3 potential snaps
                showSnapIndicator(at: snapPoint.position, type: snapPoint.type, potential: true)
            }
        }
    }
    
    /// Show visual indicator for snap points
    private func showSnapIndicator(at position: CGPoint, type: SnapPoint.SnapType, potential: Bool = false) {
        let indicator = SKShapeNode(circleOfRadius: potential ? 8 : 12)
        indicator.position = position
        indicator.fillColor = potential ? .systemYellow.withAlphaComponent(0.5) : .systemGreen
        indicator.strokeColor = .white
        indicator.lineWidth = 2
        indicator.zPosition = 200
        indicator.name = "snapIndicator"
        
        // Add type-specific visual cues
        switch type {
        case .corner:
            indicator.fillColor = potential ? .systemBlue.withAlphaComponent(0.5) : .systemBlue
        case .edge:
            indicator.fillColor = potential ? .systemOrange.withAlphaComponent(0.5) : .systemOrange
        case .center:
            indicator.fillColor = potential ? .systemPurple.withAlphaComponent(0.5) : .systemPurple
        }
        
        snapIndicators.append(indicator)
        addChild(indicator)
        
        // Auto-remove after a short time
        indicator.run(SKAction.sequence([
            SKAction.wait(forDuration: potential ? 0.5 : 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    /// Clear all snap indicators
    func clearSnapIndicators() {
        snapIndicators.forEach { $0.removeFromParent() }
        snapIndicators.removeAll()
    }
    
    // MARK: - Reset Functionality
    
    /// Resets the level to its initial state
    func resetLevel() {
        print("🔄 Resetting level: \(level.name)")
        
        // Clear magnetism indicators
        clearSnapIndicators()
        
        // Clear existing pieces and targets
        pieces.forEach { $0.removeFromParent() }
        targets.forEach { $0.removeFromParent() }
        pieces.removeAll()
        targets.removeAll()
        
        // Recreate the level
        setupLevel()
        
        // Reset selected piece
        selectedPiece = nil
        
        print("✅ Level reset complete")
    }
}