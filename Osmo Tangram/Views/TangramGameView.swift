//
//  TangramGameView.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI
import SpriteKit

/// SwiftUI view wrapper for the SpriteKit tangram game
struct TangramGameView: View {
    let level: TangramLevel
    let levelManager: LevelManager?
    let isDesignerMode: Bool
    let onPiecePositionChanged: ((ShapeType, CGPoint, CGFloat) -> Void)?
    
    @State private var showWinOverlay = false
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    // Create the scene once
    private let gameScene: SKScene
    
    init(level: TangramLevel, levelManager: LevelManager? = nil, isDesignerMode: Bool = false, onPiecePositionChanged: ((ShapeType, CGPoint, CGFloat) -> Void)? = nil) {
        self.level = level
        self.levelManager = levelManager
        self.isDesignerMode = isDesignerMode
        self.onPiecePositionChanged = onPiecePositionChanged
        
        // Create the actual game scene
        let tangramScene = TangramGameScene(level: level, isDesignerMode: isDesignerMode)
        tangramScene.scaleMode = .resizeFill
        
        // Set up designer mode callbacks if needed
        if isDesignerMode, let callback = onPiecePositionChanged {
            tangramScene.onPiecePositionChanged = callback
        }
        
        self.gameScene = tangramScene
        
        // Debug logging
        let mode = isDesignerMode ? "DESIGNER" : "GAME"
        print("🎬 Initializing TangramGameView for level: \(level.name) in \(mode) mode")
    }
    
    var body: some View {
        ZStack {
            // SpriteKit Scene
            SpriteView(scene: gameScene, debugOptions: [.showsFPS, .showsNodeCount])
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray) // Add background to debug
            
            // Win overlay
            if showWinOverlay {
                WinOverlay(levelName: level.name) {
                    dismiss()
                }
            }
            
            // Reset confirmation overlay
            if showResetConfirmation {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { showResetConfirmation = false }
                
                VStack(spacing: 20) {
                    Text("Reset Level?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("This will restart the current level and clear all progress.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button("Cancel") {
                            showResetConfirmation = false
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(Color.gray)
                        .cornerRadius(12)
                        
                        Button("Reset") {
                            resetLevel()
                            showResetConfirmation = false
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.gradient)
                )
                .shadow(radius: 20)
            }
            
            // Navigation controls overlay
            VStack {
                HStack {
                    // Back button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Level name
                    Text(level.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.5)))
                    
                    Spacer()
                    
                    // Reset button
                    Button(action: { showResetConfirmation = true }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(.trailing, 10)
                    
                    // Help button (future feature)
                    Button(action: showHelp) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(.trailing)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🎮 TangramGameView appeared for level: \(level.name)")
            
            // Set up the win callback
            if let tangramScene = gameScene as? TangramGameScene {
                tangramScene.onWinCallback = {
                    withAnimation(.spring()) {
                        showWinOverlay = true
                    }
                }
                print("✅ Win callback configured")
            }
        }
    }
    
    private func showHelp() {
        // TODO: Implement help/hint system
        print("ℹ️ Help requested")
    }
    
    private func resetLevel() {
        print("🔄 Reset level requested")
        showWinOverlay = false // Hide win overlay if showing
        
        if let tangramScene = gameScene as? TangramGameScene {
            tangramScene.resetLevel()
            print("✅ Level reset completed")
        }
    }
}