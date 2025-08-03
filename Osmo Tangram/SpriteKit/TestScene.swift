//
//  TestScene.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SpriteKit

/// Simple test scene to verify SpriteKit is working
class TestScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Set background
        backgroundColor = .blue
        
        // Add a simple shape
        let circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = .red
        circle.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(circle)
        
        // Add label
        let label = SKLabelNode(text: "SpriteKit is working!")
        label.fontSize = 30
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        addChild(label)
        
        print("✅ TestScene loaded successfully")
        print("   - Scene size: \(size)")
        print("   - Frame: \(frame)")
        print("   - Children count: \(children.count)")
    }
}