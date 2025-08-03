//
//  MainMenuView.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI

/// Main menu view for level selection
struct MainMenuView: View {
    @StateObject private var levelManager = LevelManager()
    @State private var selectedLevel: TangramLevel? = nil
    @State private var showDesigner = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App title
                    Text("Tangram Puzzles")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    // Level grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(levelManager.allLevels) { level in
                            LevelCard(
                                level: level,
                                levelManager: levelManager,
                                onLevelTap: {
                                    if level.name == "Designer" {
                                        showDesigner = true
                                        print("🎨 Opening Designer mode")
                                    } else {
                                        selectedLevel = level
                                        print("📋 Selected level: \(level.name)")
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedLevel) { level in
                TangramGameView(level: level)
                    .background(Color.white) // Ensure there's a background
            }
            .fullScreenCover(isPresented: $showDesigner) {
                DesignerView(levelManager: levelManager)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            print("🏠 Main menu appeared with \(levelManager.allLevels.count) total levels (\(levelManager.levels.count) built-in + \(levelManager.userCreatedLevels.count) user-created)")
        }
    }
}

/// Card view for individual level
struct LevelCard: View {
    let level: TangramLevel
    let levelManager: LevelManager
    let onLevelTap: () -> Void
    
    var body: some View {
        Button(action: onLevelTap) {
            VStack(spacing: 10) {
                // Puzzle preview with overlay for delete button
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.gradient)
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "puzzlepiece.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.8))
                        )
                    
                    // Delete button for user-created levels only
                    if levelManager.isUserCreatedLevel(level.id) {
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    // Delete the level
                                    levelManager.deleteUserLevel(level.id)
                                    print("🗑️ Delete button tapped for level: \(level.name)")
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.red)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                
                // Level info
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(level.difficulty.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Difficulty stars
                        HStack(spacing: 2) {
                            ForEach(0..<difficultyStars(for: level.difficulty), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func difficultyStars(for difficulty: TangramLevel.Difficulty) -> Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}