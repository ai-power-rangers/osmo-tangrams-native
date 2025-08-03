//
//  WinOverlay.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI

/// Overlay view shown when a puzzle is completed
struct WinOverlay: View {
    let levelName: String
    let onContinue: () -> Void
    
    @State private var showStars = false
    @State private var bounce = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { } // Prevent tap through
            
            // Win content
            VStack(spacing: 30) {
                // Stars animation
                HStack(spacing: 20) {
                    ForEach(0..<3) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .scaleEffect(showStars ? 1.0 : 0.1)
                            .opacity(showStars ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6)
                                .delay(Double(index) * 0.2),
                                value: showStars
                            )
                    }
                }
                
                // Congratulations text
                Text("Puzzle Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .scaleEffect(bounce ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: bounce
                    )
                
                Text("You solved \(levelName)")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.green)
                        )
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.blue.gradient)
            )
            .shadow(radius: 20)
        }
        .onAppear {
            showStars = true
            bounce = true
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
            print("🎉 Win overlay displayed")
        }
    }
}