//
//  LevelManager.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import Foundation
import SwiftUI
import UIKit

/// Manages loading and storing tangram levels
final class LevelManager: ObservableObject {
    @Published var levels: [TangramLevel] = []
    @Published var userCreatedLevels: [TangramLevel] = []
    
    private let userLevelsKey = "TangramUserLevels"
    
    // Dynamic screen dimensions based on actual device screen size
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    private var screenCenterX: CGFloat {
        screenWidth / 2
    }
    
    private var screenCenterY: CGFloat {
        screenHeight / 2
    }
    
    init() {
        logScreenInfo()
        loadLevels()
        loadUserCreatedLevels()
    }
    
    /// Logs current screen information for debugging
    private func logScreenInfo() {
        let deviceModel = UIDevice.current.model
        let screenBounds = UIScreen.main.bounds
        print("📱 Device: \(deviceModel)")
        print("📐 Screen: \(Int(screenWidth))x\(Int(screenHeight)) (w x h)")
        print("🎯 Center: (\(Int(screenCenterX)), \(Int(screenCenterY)))")
        print("📏 Scale: \(UIScreen.main.scale)x")
    }
    
    // MARK: - Coordinate System Helpers
    
    /// Converts percentage-based coordinates (0-100) to screen space coordinates
    /// - Parameters:
    ///   - x: X position as percentage (0-100, where 50 = center)
    ///   - y: Y position as percentage (0-100, where 50 = center) 
    /// - Returns: CGPoint with actual screen coordinates
    func coordinatesFromPercentage(x: CGFloat, y: CGFloat) -> CGPoint {
        let screenX = (x / 100.0) * screenWidth
        let screenY = (y / 100.0) * screenHeight
        print("🎯 Converting coordinates: (\(x)%, \(y)%) -> (\(screenX), \(screenY)) on \(Int(screenWidth))x\(Int(screenHeight)) screen")
        return CGPoint(x: screenX, y: screenY)
    }
    
    /// Converts screen coordinates back to percentage values (useful for debugging)
    /// - Parameter point: Screen coordinate point
    /// - Returns: Tuple with x and y percentages
    func percentageFromCoordinates(_ point: CGPoint) -> (x: CGFloat, y: CGFloat) {
        let xPercent = (point.x / screenWidth) * 100.0
        let yPercent = (point.y / screenHeight) * 100.0
        return (x: xPercent, y: yPercent)
    }
    
    /// Gets the screen aspect ratio for adaptive layouts
    /// - Returns: Width/Height ratio (e.g., 0.75 for 3:4, 1.77 for 16:9)
    func getScreenAspectRatio() -> CGFloat {
        return screenWidth / screenHeight
    }
    
    /// Checks if the device is in portrait orientation
    /// - Returns: True if height > width
    var isPortrait: Bool {
        return screenHeight > screenWidth
    }
    
    /// Gets current screen size information
    /// - Returns: Tuple with width, height, and aspect ratio
    func getScreenInfo() -> (width: CGFloat, height: CGFloat, aspectRatio: CGFloat) {
        return (width: screenWidth, height: screenHeight, aspectRatio: getScreenAspectRatio())
    }
    
    /// Gets the SpriteKit scene dimensions used by TangramGameScene
    /// These should match the values used in TangramGameScene initialization
    /// - Returns: Tuple with scene width and height
    func getSceneDimensions() -> (width: CGFloat, height: CGFloat) {
        // These values should match TangramGameScene's size initialization
        // TODO: Consider making this dynamic based on screen size in the future
        return (width: screenWidth, height: screenHeight)
    }
    
    // MARK: - User Level Management
    
    /// Loads user-created levels from persistent storage
    private func loadUserCreatedLevels() {
        if let data = UserDefaults.standard.data(forKey: userLevelsKey),
           let decodedLevels = try? JSONDecoder().decode([TangramLevel].self, from: data) {
            userCreatedLevels = decodedLevels
            print("📱 Loaded \(userCreatedLevels.count) user-created levels")
        } else {
            userCreatedLevels = []
            print("📱 No user-created levels found")
        }
    }
    
    /// Saves user-created levels to persistent storage
    private func saveUserCreatedLevels() {
        if let data = try? JSONEncoder().encode(userCreatedLevels) {
            UserDefaults.standard.set(data, forKey: userLevelsKey)
            print("💾 Saved \(userCreatedLevels.count) user-created levels")
        } else {
            print("❌ Failed to save user-created levels")
        }
    }
    
    /// Deletes a user-created level by ID
    /// - Parameter levelId: The UUID of the level to delete
    func deleteUserLevel(_ levelId: UUID) {
        if let index = userCreatedLevels.firstIndex(where: { $0.id == levelId }) {
            let deletedLevel = userCreatedLevels.remove(at: index)
            saveUserCreatedLevels()
            print("🗑️ Deleted user level: \(deletedLevel.name)")
        } else {
            print("❌ Failed to find user level with ID: \(levelId)")
        }
    }
    
    /// Checks if a level is user-created (not built-in)
    /// - Parameter levelId: The UUID of the level to check
    /// - Returns: True if the level is user-created, false otherwise
    func isUserCreatedLevel(_ levelId: UUID) -> Bool {
        return userCreatedLevels.contains { $0.id == levelId }
    }
    
    /// Generates a random 5-letter level name
    private func generateRandomLevelName() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let randomName = String((0..<5).map { _ in letters.randomElement()! })
        print("🎲 Generated random level name: \(randomName)")
        return randomName
    }
    
    /// Creates a new level from percentage-based coordinates and saves it (PREFERRED METHOD)
    /// This method ensures cross-device compatibility by using percentage-based positioning
    /// - Parameter percentageTargets: Array of tuples with shape info and percentage coordinates
    func saveLevelFromPercentages(percentageTargets: [(type: ShapeType, xPercent: CGFloat, yPercent: CGFloat, rotation: CGFloat)]) {
        let levelName = generateRandomLevelName()
        
        // Convert percentage coordinates to actual screen coordinates using the same method as built-in levels
        var targetShapes: [ShapeTarget] = []
        for target in percentageTargets {
            let screenPosition = coordinatesFromPercentage(x: target.xPercent, y: target.yPercent)
            let shapeTarget = ShapeTarget(
                type: target.type,
                position: screenPosition,
                rotation: target.rotation,
                flipped: false
            )
            targetShapes.append(shapeTarget)
        }
        
        // Create starting pieces scattered around edges using percentage coordinates
        let pieces = [
            TangramPiece(type: .largeTriangle1, startPosition: coordinatesFromPercentage(x: 15, y: 20), rotation: 0, color: "red"),
            TangramPiece(type: .largeTriangle2, startPosition: coordinatesFromPercentage(x: 85, y: 20), rotation: 0, color: "blue"),
            TangramPiece(type: .mediumTriangle, startPosition: coordinatesFromPercentage(x: 20, y: 85), rotation: 0, color: "green"),
            TangramPiece(type: .smallTriangle1, startPosition: coordinatesFromPercentage(x: 15, y: 50), rotation: 0, color: "yellow"),
            TangramPiece(type: .smallTriangle2, startPosition: coordinatesFromPercentage(x: 80, y: 85), rotation: 0, color: "orange"),
            TangramPiece(type: .square, startPosition: coordinatesFromPercentage(x: 85, y: 50), rotation: 0, color: "purple"),
            TangramPiece(type: .parallelogram, startPosition: coordinatesFromPercentage(x: 50, y: 90), rotation: 0, color: "pink")
        ]
        
        let newLevel = TangramLevel(
            name: levelName,
            difficulty: .easy,
            targetShapes: targetShapes,
            initialPieces: pieces
        )
        
        userCreatedLevels.append(newLevel)
        saveUserCreatedLevels()
        
        // Debug log with percentage values
        print("🎨 Level \"\(levelName)\" created with percentage-based targets:")
        for target in percentageTargets {
            print("🎯 \(target.type): (\(String(format: "%.1f", target.xPercent))%, \(String(format: "%.1f", target.yPercent))%) rotation: \(Int(target.rotation))°")
        }
        
        print("✅ Level \"\(levelName)\" saved successfully with cross-device compatibility!")
    }
    
    /// Creates a new level from target shapes and saves it (LEGACY METHOD)
    /// - Parameter targetShapes: Array of ShapeTarget representing the solution
    /// NOTE: This method uses absolute coordinates and may not work properly across different screen sizes.
    /// Use saveLevelFromPercentages() instead for new levels.
    func saveLevel(targetShapes: [ShapeTarget]) {
        let levelName = generateRandomLevelName()
        
        // Create starting pieces scattered around edges
        let pieces = [
            TangramPiece(type: .largeTriangle1, startPosition: coordinatesFromPercentage(x: 15, y: 20), rotation: 0, color: "red"),
            TangramPiece(type: .largeTriangle2, startPosition: coordinatesFromPercentage(x: 85, y: 20), rotation: 0, color: "blue"),
            TangramPiece(type: .mediumTriangle, startPosition: coordinatesFromPercentage(x: 20, y: 85), rotation: 0, color: "green"),
            TangramPiece(type: .smallTriangle1, startPosition: coordinatesFromPercentage(x: 15, y: 50), rotation: 0, color: "yellow"),
            TangramPiece(type: .smallTriangle2, startPosition: coordinatesFromPercentage(x: 80, y: 85), rotation: 0, color: "orange"),
            TangramPiece(type: .square, startPosition: coordinatesFromPercentage(x: 85, y: 50), rotation: 0, color: "purple"),
            TangramPiece(type: .parallelogram, startPosition: coordinatesFromPercentage(x: 50, y: 90), rotation: 0, color: "pink")
        ]
        
        let newLevel = TangramLevel(
            name: levelName,
            difficulty: .easy,
            targetShapes: targetShapes,
            initialPieces: pieces
        )
        
        userCreatedLevels.append(newLevel)
        saveUserCreatedLevels()
        
        // Debug log exactly as requested
        print("🎨 Level \"\(levelName)\" created with targets:")
        for target in targetShapes {
            let percentCoords = percentageFromCoordinates(target.position)
            print("🎯 \(target.type): (\(String(format: "%.1f", percentCoords.x))%, \(String(format: "%.1f", percentCoords.y))%) rotation: \(Int(target.rotation))°")
        }
        
        print("⚠️ Level \"\(levelName)\" saved with absolute coordinates - may not work properly on different screen sizes!")
    }
    
    /// Deletes a user-created level
    /// - Parameter level: The level to delete
    func deleteUserLevel(_ level: TangramLevel) {
        if let index = userCreatedLevels.firstIndex(where: { $0.name == level.name }) {
            let deletedName = userCreatedLevels[index].name
            userCreatedLevels.remove(at: index)
            saveUserCreatedLevels()
            print("🗑️ Deleted user level: \(deletedName)")
        }
    }
    
    /// Gets all levels (built-in + user-created) for display
    var allLevels: [TangramLevel] {
        return levels + userCreatedLevels
    }
    
    /// Load levels from bundled data or create sample levels
    private func loadLevels() {
        // For now, we create the levels programmatically.
        // In a production app, you might load these from a JSON file
        // to make adding new levels easier.
        levels = [
            createDesignerLevel(), // Designer level always first
            createBirdLevel(),
            createRocketLevel(),
            createHouseLevel(),
            // Adding a classic Cat puzzle for fun
            createCatLevel(),
            // Example level using percentage-based coordinates
            createSimpleShapeLevel()
        ]
        
        print("📚 Loaded \(levels.count) levels")
    }
    
    // MARK: - Level Creation
    // The following functions create the specific tangram puzzles.
    // The previous implementation used the screen center as the anchor point for layout.
    // However, because the puzzles are asymmetrical, this resulted in them appearing visually off-center.
    // We fix this by calculating the geometric center of the puzzle's bounding box
    // and adjusting the anchor point (centerX, centerY) so that the geometric center
    // aligns with the screen center.
    
    /// Creates the special "Designer" level for creating custom puzzles
    private func createDesignerLevel() -> TangramLevel {
        print("🎨 Creating Designer level")
        
        // Empty target shapes - user will create these
        let targets: [ShapeTarget] = []
        
        // Starting pieces in center area for easy access
        let pieces = [
            TangramPiece(type: .largeTriangle1, startPosition: coordinatesFromPercentage(x: 40, y: 45), rotation: 0, color: "red"),
            TangramPiece(type: .largeTriangle2, startPosition: coordinatesFromPercentage(x: 60, y: 45), rotation: 0, color: "blue"),
            TangramPiece(type: .mediumTriangle, startPosition: coordinatesFromPercentage(x: 50, y: 55), rotation: 0, color: "green"),
            TangramPiece(type: .smallTriangle1, startPosition: coordinatesFromPercentage(x: 35, y: 55), rotation: 0, color: "yellow"),
            TangramPiece(type: .smallTriangle2, startPosition: coordinatesFromPercentage(x: 65, y: 55), rotation: 0, color: "orange"),
            TangramPiece(type: .square, startPosition: coordinatesFromPercentage(x: 45, y: 35), rotation: 0, color: "purple"),
            TangramPiece(type: .parallelogram, startPosition: coordinatesFromPercentage(x: 55, y: 35), rotation: 0, color: "pink")
        ]
        
        return TangramLevel(
            name: "Designer",
            difficulty: .easy,
            targetShapes: targets,
            initialPieces: pieces
        )
    }

    /// Creates the "Bird" puzzle to match the provided bird image.
    /// Uses percentage-based coordinates for dynamic screen adaptation.
    private func createBirdLevel() -> TangramLevel {
        print("🐦 Creating bird level with percentage-based coordinates")
        
        // Bird layout based on the provided image:
        // - Head/beak on the left (orange triangle)
        // - Body in center (pink triangle, green square)
        // - Wing extending up and right (yellow triangle)  
        // - Tail curving down (blue parallelogram)
        // - Additional body parts (purple triangle, red medium triangle)
        
        let targets = [
            // Head/Beak (Orange Small Triangle) - Left side, pointing right
            ShapeTarget(type: .smallTriangle1, 
                       position: coordinatesFromPercentage(x: 30, y: 40), 
                       rotation: 0),
            
            // Neck (Purple Small Triangle) - Between head and body
            ShapeTarget(type: .smallTriangle2, 
                       position: coordinatesFromPercentage(x: 38, y: 47), 
                       rotation: 315),
            
            // Upper Body (Pink Large Triangle) - Main body piece
            ShapeTarget(type: .largeTriangle1, 
                       position: coordinatesFromPercentage(x: 45, y: 50), 
                       rotation: 225),
            
            // Lower Body (Green Square) - Center bottom of body
            ShapeTarget(type: .square, 
                       position: coordinatesFromPercentage(x: 50, y: 58), 
                       rotation: 45),
            
            // Wing (Yellow Large Triangle) - Upper right, extending upward
            ShapeTarget(type: .largeTriangle2, 
                       position: coordinatesFromPercentage(x: 60, y: 35), 
                       rotation: 45),
            
            // Tail (Blue Parallelogram) - Lower right, curving down
            ShapeTarget(type: .parallelogram, 
                       position: coordinatesFromPercentage(x: 65, y: 65), 
                       rotation: 45, flipped: false),
            
            // Leg/Support (Red Medium Triangle) - Bottom support
            ShapeTarget(type: .mediumTriangle, 
                       position: coordinatesFromPercentage(x: 42, y: 65), 
                       rotation: 270)
        ]

        // Starting positions scattered around the edges using percentage coordinates
        let pieces = [
            TangramPiece(type: .largeTriangle1, 
                        startPosition: coordinatesFromPercentage(x: 15, y: 20), 
                        rotation: 0, color: "pink"),
            TangramPiece(type: .largeTriangle2, 
                        startPosition: coordinatesFromPercentage(x: 85, y: 20), 
                        rotation: 0, color: "yellow"),
            TangramPiece(type: .mediumTriangle, 
                        startPosition: coordinatesFromPercentage(x: 20, y: 85), 
                        rotation: 0, color: "red"),
            TangramPiece(type: .smallTriangle1, 
                        startPosition: coordinatesFromPercentage(x: 15, y: 50), 
                        rotation: 0, color: "orange"),
            TangramPiece(type: .smallTriangle2, 
                        startPosition: coordinatesFromPercentage(x: 80, y: 85), 
                        rotation: 0, color: "purple"),
            TangramPiece(type: .square, 
                        startPosition: coordinatesFromPercentage(x: 85, y: 50), 
                        rotation: 0, color: "green"),
            TangramPiece(type: .parallelogram, 
                        startPosition: coordinatesFromPercentage(x: 50, y: 90), 
                        rotation: 0, color: "blue")
        ]
        
        return TangramLevel(
            name: "Bird",
            difficulty: .easy,
            targetShapes: targets,
            initialPieces: pieces
        )
    }

    /// Creates the "Rocket" puzzle.
    /// The layout is corrected to match "Screenshot 2025-08-03 at 2.19.39 PM.png".
    private func createRocketLevel() -> TangramLevel {
        let unit = CGFloat(50)
        
        // Bounding box analysis:
        // X range: [-2u (Left Fin), 1.5u (Right Fin)]. Center X offset: (-2 + 1.5)/2 = -0.25u.
        // Y range: [-3u (Nose Cone), 1.5u (Right Fin)]. Center Y offset: (-3 + 1.5)/2 = -0.75u.
        // The geometric center is left and up from the anchor.
        // To center the puzzle, shift the anchor right and down.
        // We use the actual screen center (512) instead of the previously used 480.
        let centerX = screenCenterX + (0.25 * unit) // Shift right (384 + 12.5)
        let centerY = screenCenterY + (0.75 * unit) // Shift down (512 + 37.5)


        // These target positions and rotations have been completely recalculated.
        let targets = [
            // Nose Cone (Purple Small Triangle)
            ShapeTarget(type: .smallTriangle1, position: CGPoint(x: centerX, y: centerY - unit * 3), rotation: 0),
            // Upper Body (Blue Medium Triangle)
            ShapeTarget(type: .mediumTriangle, position: CGPoint(x: centerX, y: centerY - unit * 1.5), rotation: 180),
            // Left Body (Orange Large Triangle)
            ShapeTarget(type: .largeTriangle1, position: CGPoint(x: centerX - unit, y: centerY), rotation: 270),
            // Right Body (Red Large Triangle)
            ShapeTarget(type: .largeTriangle2, position: CGPoint(x: centerX + unit, y: centerY), rotation: 90),
            // Lower Body (Pink Small Triangle)
            ShapeTarget(type: .smallTriangle2, position: CGPoint(x: centerX, y: centerY + unit), rotation: 180),
            // Left Fin (Green Square)
            ShapeTarget(type: .square, position: CGPoint(x: centerX - unit * 2, y: centerY + unit), rotation: 45),
            // Right Fin (Yellow Parallelogram)
            ShapeTarget(type: .parallelogram, position: CGPoint(x: centerX + unit * 1.5, y: centerY + unit * 1.5), rotation: 315, flipped: false)
        ]
        
        // The initial piece colors are now matched to the puzzle's solution.
        let pieces = [
            TangramPiece(type: .largeTriangle1, startPosition: CGPoint(x: 100, y: 150), rotation: 0, color: "orange"),
            TangramPiece(type: .largeTriangle2, startPosition: CGPoint(x: 650, y: 150), rotation: 0, color: "red"),
            TangramPiece(type: .mediumTriangle, startPosition: CGPoint(x: 384, y: 850), rotation: 0, color: "blue"),
            TangramPiece(type: .smallTriangle1, startPosition: CGPoint(x: 550, y: 850), rotation: 0, color: "purple"),
            TangramPiece(type: .smallTriangle2, startPosition: CGPoint(x: 100, y: 450), rotation: 0, color: "pink"),
            TangramPiece(type: .square, startPosition: CGPoint(x: 200, y: 850), rotation: 0, color: "green"),
            TangramPiece(type: .parallelogram, startPosition: CGPoint(x: 650, y: 450), rotation: 0, color: "yellow")
        ]
        
        return TangramLevel(
            name: "Rocket",
            difficulty: .medium,
            targetShapes: targets,
            initialPieces: pieces
        )
    }
    
    /// Creates the "House" puzzle.
    /// The layout is corrected to match "Screenshot 2025-08-03 at 2.19.44 PM.png".
    private func createHouseLevel() -> TangramLevel {
        let unit = CGFloat(70)
        
        // Bounding box analysis:
        // X range: [-1u (Left Wall/Roof), 1.5u (Chimney)]. Center X offset: (-1 + 1.5)/2 = 0.25u.
        // Y range: [-1.5u (Chimney), 1.5u (Foundation 1)]. Center Y offset: 0.
        // The geometric center is to the right of the anchor (due to the chimney).
        // To center the puzzle, shift the anchor left.
        let centerX = screenCenterX - (0.25 * unit) // Shift left (384 - 17.5)
        let centerY = screenCenterY
        
        let targets = [
            // Left Roof (Red Large Triangle)
            ShapeTarget(type: .largeTriangle1, position: CGPoint(x: centerX - unit, y: centerY - unit), rotation: 225),
            // Right Roof (Orange Large Triangle)
            ShapeTarget(type: .largeTriangle2, position: CGPoint(x: centerX + unit, y: centerY - unit), rotation: 315),
            // Chimney (Yellow Parallelogram)
            ShapeTarget(type: .parallelogram, position: CGPoint(x: centerX + unit * 1.5, y: centerY - unit * 1.5), rotation: 0, flipped: true),
            // Left Wall (Green Small Triangle)
            ShapeTarget(type: .smallTriangle1, position: CGPoint(x: centerX - unit, y: centerY + unit), rotation: 270),
            // Right Wall (Purple Square)
            ShapeTarget(type: .square, position: CGPoint(x: centerX + unit, y: centerY + unit), rotation: 0),
            // Foundation 1 (Blue Medium Triangle)
            ShapeTarget(type: .mediumTriangle, position: CGPoint(x: centerX, y: centerY + unit * 1.5), rotation: 180),
            // Foundation 2 (Pink Small Triangle)
            ShapeTarget(type: .smallTriangle2, position: CGPoint(x: centerX, y: centerY + unit), rotation: 90)
        ]
        
        let pieces = [
            TangramPiece(type: .largeTriangle1, startPosition: CGPoint(x: 100, y: 150), rotation: 45, color: "red"),
            TangramPiece(type: .largeTriangle2, startPosition: CGPoint(x: 650, y: 150), rotation: -45, color: "orange"),
            TangramPiece(type: .mediumTriangle, startPosition: CGPoint(x: 200, y: 850), rotation: 90, color: "blue"),
            TangramPiece(type: .smallTriangle1, startPosition: CGPoint(x: 100, y: 450), rotation: 0, color: "green"),
            TangramPiece(type: .smallTriangle2, startPosition: CGPoint(x: 550, y: 850), rotation: 180, color: "pink"),
            TangramPiece(type: .square, startPosition: CGPoint(x: 650, y: 450), rotation: 45, color: "purple"),
            TangramPiece(type: .parallelogram, startPosition: CGPoint(x: 384, y: 950), rotation: 0, color: "yellow")
        ]
        
        return TangramLevel(
            name: "House",
            difficulty: .medium,
            targetShapes: targets,
            initialPieces: pieces
        )
    }
    
    /// Create a classic cat-shaped puzzle.
    private func createCatLevel() -> TangramLevel {
        let unit = CGFloat(50)
        
        // Bounding box analysis:
        // X range: [-3u (Ear), 3u (Tail)]. Center X offset: 0.
        // Y range: [-3u (Ears), 2u (Legs)]. Center Y offset: (-3 + 2)/2 = -0.5u.
        // The geometric center is above the anchor.
        // To center the puzzle, shift the anchor down.
        let centerX = screenCenterX
        let centerY = screenCenterY + (0.5 * unit) // Shift down (512 + 25)

        let targets = [
            // Body (Two Large Triangles)
            ShapeTarget(type: .largeTriangle1, position: CGPoint(x: centerX - unit, y: centerY), rotation: 135),
            ShapeTarget(type: .largeTriangle2, position: CGPoint(x: centerX + unit, y: centerY), rotation: 45),
            // Head (Medium Triangle)
            ShapeTarget(type: .mediumTriangle, position: CGPoint(x: centerX - unit * 2.5, y: centerY - unit * 1.5), rotation: 270),
            // Ears (Two Small Triangles)
            ShapeTarget(type: .smallTriangle1, position: CGPoint(x: centerX - unit * 3, y: centerY - unit * 3), rotation: 270),
            ShapeTarget(type: .smallTriangle2, position: CGPoint(x: centerX - unit * 2, y: centerY - unit * 3), rotation: 180),
            // Tail (Parallelogram)
            ShapeTarget(type: .parallelogram, position: CGPoint(x: centerX + unit * 3, y: centerY), rotation: 135),
            // Legs (Square)
            ShapeTarget(type: .square, position: CGPoint(x: centerX, y: centerY + unit * 2), rotation: 45)
        ]
        
        let pieces = [
            TangramPiece(type: .largeTriangle1, startPosition: CGPoint(x: 80, y: 100), rotation: 135, color: "red"),
            TangramPiece(type: .largeTriangle2, startPosition: CGPoint(x: 680, y: 100), rotation: 225, color: "blue"),
            TangramPiece(type: .mediumTriangle, startPosition: CGPoint(x: 150, y: 900), rotation: 45, color: "green"),
            TangramPiece(type: .smallTriangle1, startPosition: CGPoint(x: 600, y: 900), rotation: 315, color: "yellow"),
            TangramPiece(type: .smallTriangle2, startPosition: CGPoint(x: 80, y: 500), rotation: 90, color: "orange"),
            TangramPiece(type: .square, startPosition: CGPoint(x: 680, y: 500), rotation: 0, color: "purple"),
            TangramPiece(type: .parallelogram, startPosition: CGPoint(x: 384, y: 850), rotation: 180, color: "pink")
        ]
        
        return TangramLevel(
            name: "Cat",
            difficulty: .hard,
            targetShapes: targets,
            initialPieces: pieces
        )
    }
    
    /// Example level demonstrating percentage-based coordinate system
    /// This is much easier to create and understand than absolute coordinates!
    private func createSimpleShapeLevel() -> TangramLevel {
        print("🎨 Creating simple shape level with percentage coordinates on \(Int(screenWidth))x\(Int(screenHeight)) screen")
        
        // Using percentage-based positioning (0-100%)
        // 50% = center, 0% = top/left edge, 100% = bottom/right edge
        let targets = [
            // Center square at 50%, 50% (dead center of screen)
            ShapeTarget(type: .square, 
                       position: coordinatesFromPercentage(x: 50, y: 50), 
                       rotation: 45),
            // Left triangle at 25%, 40%  
            ShapeTarget(type: .largeTriangle1, 
                       position: coordinatesFromPercentage(x: 25, y: 40), 
                       rotation: 90),
            // Right triangle at 75%, 40%
            ShapeTarget(type: .largeTriangle2, 
                       position: coordinatesFromPercentage(x: 75, y: 40), 
                       rotation: 270),
            // Top triangle at 50%, 25%
            ShapeTarget(type: .mediumTriangle, 
                       position: coordinatesFromPercentage(x: 50, y: 25), 
                       rotation: 180),
            // Bottom triangles
            ShapeTarget(type: .smallTriangle1, 
                       position: coordinatesFromPercentage(x: 40, y: 65), 
                       rotation: 45),
            ShapeTarget(type: .smallTriangle2, 
                       position: coordinatesFromPercentage(x: 60, y: 65), 
                       rotation: 135),
            // Parallelogram at bottom
            ShapeTarget(type: .parallelogram, 
                       position: coordinatesFromPercentage(x: 50, y: 80), 
                       rotation: 0)
        ]
        
        // Starting positions using percentage coordinates (scattered around edges)
        let pieces = [
            TangramPiece(type: .largeTriangle1, 
                        startPosition: coordinatesFromPercentage(x: 15, y: 15), 
                        rotation: 0, color: "red"),
            TangramPiece(type: .largeTriangle2, 
                        startPosition: coordinatesFromPercentage(x: 85, y: 15), 
                        rotation: 0, color: "blue"),
            TangramPiece(type: .mediumTriangle, 
                        startPosition: coordinatesFromPercentage(x: 15, y: 85), 
                        rotation: 0, color: "green"),
            TangramPiece(type: .smallTriangle1, 
                        startPosition: coordinatesFromPercentage(x: 50, y: 90), 
                        rotation: 0, color: "yellow"),
            TangramPiece(type: .smallTriangle2, 
                        startPosition: coordinatesFromPercentage(x: 85, y: 85), 
                        rotation: 0, color: "orange"),
            TangramPiece(type: .square, 
                        startPosition: coordinatesFromPercentage(x: 10, y: 50), 
                        rotation: 0, color: "purple"),
            TangramPiece(type: .parallelogram, 
                        startPosition: coordinatesFromPercentage(x: 90, y: 50), 
                        rotation: 0, color: "pink")
        ]
        
        return TangramLevel(
            name: "Simple Shape",
            difficulty: .easy,
            targetShapes: targets,
            initialPieces: pieces
        )
    }
}