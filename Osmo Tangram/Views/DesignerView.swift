//
//  DesignerView.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI

/// Special view for designing custom tangram levels
struct DesignerView: View {
    @ObservedObject var levelManager: LevelManager
    @Environment(\.dismiss) private var dismiss
    
    // Track piece positions for saving as targets
    @State private var piecePositions: [ShapeType: CGPoint] = [:]
    @State private var pieceRotations: [ShapeType: CGFloat] = [:]
    @State private var showSaveConfirmation = false
    @State private var isDesigning = true
    @State private var showMagnetismSettings = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("Back") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Level Designer")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Magnetism settings button
                    Button(action: {
                        showMagnetismSettings.toggle()
                    }) {
                        Image(systemName: "magnet")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button("Save Level") {
                        saveLevelFromCurrentPositions()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(piecePositions.isEmpty)
                }
                .padding(.horizontal)
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Create Your Puzzle")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Arrange the pieces below to create your target shape")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Magnetism status indicator
                        Image(systemName: "magnet")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Smart Snapping ON")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Design Area - This will contain the TangramGameView
                TangramGameView(
                    level: createDesignerLevelForView(),
                    levelManager: levelManager,
                    isDesignerMode: true,
                    onPiecePositionChanged: { shapeType, position, rotation in
                        // Track piece positions for saving
                        piecePositions[shapeType] = position
                        pieceRotations[shapeType] = rotation
                        print("🎯 \(shapeType) moved to: \(position) rotation: \(rotation)")
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .alert("Level Saved!", isPresented: $showSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your custom level has been saved and is ready to play!")
        }
        .sheet(isPresented: $showMagnetismSettings) {
            MagnetismSettingsView()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a designer level for the view with pieces in center
    private func createDesignerLevelForView() -> TangramLevel {
        // Use the designer level but refresh piece positions
        let designerLevel = levelManager.levels.first { $0.name == "Designer" }!
        return designerLevel
    }
    
    /// Saves the current piece positions as a new level using percentage-based coordinates
    private func saveLevelFromCurrentPositions() {
        print("💾 Saving level from current piece positions...")
        
        // Convert piece positions to percentage values for cross-device compatibility
        var percentageTargets: [(type: ShapeType, xPercent: CGFloat, yPercent: CGFloat, rotation: CGFloat)] = []
        
        for (shapeType, position) in piecePositions {
            let rotation = pieceRotations[shapeType] ?? 0
            
            // Convert SpriteKit coordinates (center-anchored) to UIKit coordinates (top-left anchored)
            // The game scene uses centered() function: CGPoint(x: p.x - size.width/2, y: p.y - size.height/2)
            // So to reverse this: UIKit = SpriteKit + (size.width/2, size.height/2)
            let sceneDimensions = levelManager.getSceneDimensions()
            let uiKitX = position.x + sceneDimensions.width/2  // Add half scene width
            let uiKitY = position.y + sceneDimensions.height/2 // Add half scene height
            let uiKitPosition = CGPoint(x: uiKitX, y: uiKitY)
            
            // Convert UIKit coordinates to percentage values (0-100%)
            let percentCoords = levelManager.percentageFromCoordinates(uiKitPosition)
            
            percentageTargets.append((
                type: shapeType,
                xPercent: percentCoords.x,
                yPercent: percentCoords.y,
                rotation: rotation
            ))
            
            print("🔄 Converting \(shapeType): SpriteKit \(position) -> UIKit \(uiKitPosition) -> (\(String(format: "%.1f", percentCoords.x))%, \(String(format: "%.1f", percentCoords.y))%) [Scene: \(Int(sceneDimensions.width))x\(Int(sceneDimensions.height))]")
        }
        
        // Save the level using percentage values - LevelManager will convert to screen coordinates
        levelManager.saveLevelFromPercentages(percentageTargets: percentageTargets)
        
        // Show confirmation
        showSaveConfirmation = true
        
        print("✅ Designer level saved with \(percentageTargets.count) target shapes using percentage coordinates")
    }
}

/// Settings view for magnetism configuration
struct MagnetismSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "magnet")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Smart Snapping Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Configure how pieces snap together in Designer mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 15) {
                    // Feature descriptions
                    FeatureRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Edge Magnetism",
                        description: "Pieces automatically align when edges are near each other",
                        isEnabled: true
                    )
                    
                    FeatureRow(
                        icon: "point.3.connected.trianglepath.dotted",
                        title: "Corner Magnetism", 
                        description: "Piece corners snap to other piece corners",
                        isEnabled: true
                    )
                    
                    FeatureRow(
                        icon: "rotate.3d",
                        title: "Angle Magnetism",
                        description: "Auto-rotate pieces to align with nearby pieces",
                        isEnabled: true
                    )
                    
                    FeatureRow(
                        icon: "shield.checkered",
                        title: "Collision Prevention",
                        description: "Prevent pieces from overlapping each other",
                        isEnabled: true
                    )
                    
                    FeatureRow(
                        icon: "eye.circle",
                        title: "Visual Hints",
                        description: "Show colored indicators for potential snap points",
                        isEnabled: true
                    )
                }
                .padding()
                
                Spacer()
                
                // Note
                VStack(spacing: 8) {
                    Text("Note")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Smart snapping only works in Designer mode to help you create perfect puzzle layouts. It's disabled during regular gameplay.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Magnetism")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

/// Row showing a magnetism feature
private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEnabled ? .blue : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isEnabled ? .primary : .gray)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
                .font(.title2)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    DesignerView(levelManager: LevelManager())
}