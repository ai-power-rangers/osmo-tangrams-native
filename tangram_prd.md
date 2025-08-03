🧩 TECHNICAL PRD — Tangram Game (SwiftUI + SpriteKit)
🎯 GOAL
Build a 2D interactive tangram puzzle game where kids can drag, rotate, and place tangram pieces into puzzle outlines. Built using SpriteKit (for game interaction) and SwiftUI (for UI, menus, etc).

🏗️ ARCHITECTURE OVERVIEW
mathematica
Copy
Edit
[ SwiftUI App ]
    |
    ├── Menu / Level Select View (SwiftUI)
    └── TangramGameView (SwiftUI)
             └── Embedded SpriteKit Scene (TangramGameScene.swift)
SwiftUI: Handles navigation, menus, and UI overlays

SpriteKit: Handles drag, drop, rotation, snapping, win detection

🧱 CORE COMPONENTS
1. TangramGameView.swift (SwiftUI)
A SwiftUI wrapper view with a SpriteView embedded

Passes level config to the scene

Displays win state UI when puzzle is solved

swift
Copy
Edit
SpriteView(scene: TangramGameScene(level: selectedLevel))
    .ignoresSafeArea()
2. TangramGameScene.swift (SpriteKit)
Responsible for:

Rendering tangram pieces and target outlines

Handling dragging, rotating, and snapping

Detecting win condition

Structure:

swift
Copy
Edit
class TangramGameScene: SKScene {
    var level: TangramLevel
    var pieces: [TangramPieceNode]
    var targets: [ShapeTargetNode]

    override func didMove(to view: SKView) {
        setupLevel()
    }

    func setupLevel()
    func checkForSnap()
    func checkForWin()
}
3. TangramPieceNode.swift
Subclass of SKShapeNode or SKSpriteNode

Supports:

Dragging (touchesMoved)

Rotation (via buttons or multitouch)

Snap detection

4. ShapeTargetNode.swift
Passive nodes representing where shapes should be placed

Includes:

Position

Shape type

Rotation

5. Level Data Model
swift
Copy
Edit
struct TangramLevel {
    let id: UUID
    let targetShapes: [ShapeTarget]
    let initialPieces: [TangramPiece]
}

struct ShapeTarget {
    let type: ShapeType
    let position: CGPoint
    let rotation: CGFloat
}

struct TangramPiece {
    let type: ShapeType
    let startPosition: CGPoint
    let rotation: CGFloat
}
Store this as JSON or structs in Swift.

🖱️ INTERACTION SPECS
Action	Behavior
Drag tangram piece	Piece follows user’s finger
Rotate piece	Rotate button or two-finger twist
Snap to target	If near correct target (within threshold), snap in
Win state	All pieces matched → trigger success animation/alert

📦 SNAP DETECTION LOGIC
On drag end:

Check proximity to each ShapeTargetNode

If same type + close enough (position + rotation), snap

Else, stay where dropped

swift
Copy
Edit
let positionThreshold: CGFloat = 20
let rotationThreshold: CGFloat = 10 // degrees
🧪 PUZZLE COMPLETION LOGIC
Loop through all targets:

swift
Copy
Edit
for target in targets {
    guard let match = pieceNearby(target),
          match.type == target.type,
          isCloseEnough(position, rotation)
    else {
        return
    }
}
triggerWin()
🧩 OPTIONAL ENHANCEMENTS
Feature	How to Implement
Visual feedback	Glow on hover near correct spot
Sound effects	run(SKAction.playSoundFileNamed:)
Rotation gestures	Add rotation buttons or multitouch
Puzzle builder	UI to drag pieces → export as JSON
Piece snapping animation	run(SKAction.move(to:duration:))

🧪 DEBUGGING TOOLS
Show target outlines with low opacity

Log position + rotation deltas for each snap

Enable touch debug in SceneKit: view.showsNodeCount = true

🛠️ TECH STACK
Feature	Tech
UI / Menus	SwiftUI
Game rendering	SpriteKit (SKScene, SKShapeNode)
Drag interaction	Touch events in SKScene
Embedding SKScene	SpriteView(scene:) in SwiftUI
Animation / Sound	SpriteKit Actions

📂 FILE STRUCTURE
Copy
Edit
TangramGame/
├── SwiftUI/
│   ├── TangramGameView.swift
│   ├── MainMenuView.swift
│   └── WinOverlay.swift
├── SpriteKit/
│   ├── TangramGameScene.swift
│   ├── TangramPieceNode.swift
│   ├── ShapeTargetNode.swift
├── Models/
│   └── TangramLevel.swift
├── Assets/
│   └── Sounds, Images
✅ DELIVERABLES
 Working prototype with 1 puzzle

 Draggable + rotatable tangram pieces

 Snap detection + win logic

 Embedded scene inside SwiftUI

 JSON-based level definition system

Would you like me to generate:

The full TangramGameScene.swift implementation?

A working Level JSON + parser?

SpriteKit touch handling code with snap logic?

Let me know how deep to go next.








You said:
You didn't include how to generate the tangrams in this PRD nor specify their geometric constraints relative to each other


ChatGPT said:
You're right — I skipped over the geometric structure of the tangram set and how to programmatically generate them. These are core to both rendering and puzzle validation.

Let’s fix that.

✨ Tangram Geometry & Generation Addendum (for SpriteKit or SwiftUI)
🧩 Tangram Set — Standard Pieces
A classic 7-piece tangram puzzle contains:

Name	Count	Shape	Notes
Large Triangle	2	Right triangle	Hypotenuse = full square length
Medium Triangle	1	Right triangle	Half size of large triangle
Small Triangle	2	Right triangle	Half size of medium triangle
Square	1	Square	Sides = same as small triangle's legs
Parallelogram	1	Rhomboid	Same area as square, flipped

📏 Standard layout fits in a 1x1 square
Use a unit square (1x1) or scaled square (e.g. 200x200) as the canvas.

📐 Tangram Geometry: Piece Definitions
We'll define each shape in terms of unit size and point offsets.

1. Large Triangle (x2)
swift
Copy
Edit
// Points for right triangle with hypotenuse length = 1
[
    CGPoint(x: 0, y: 0),
    CGPoint(x: 1, y: 0),
    CGPoint(x: 0, y: 1)
]
Area = 0.5

Sides = 1, 1, √2

2. Medium Triangle (x1)
swift
Copy
Edit
[
    CGPoint(x: 0, y: 0),
    CGPoint(x: 0.5, y: 0),
    CGPoint(x: 0, y: 0.5)
]
3. Small Triangle (x2)
swift
Copy
Edit
[
    CGPoint(x: 0, y: 0),
    CGPoint(x: 0.5, y: 0),
    CGPoint(x: 0, y: 0.5)
]
Same as medium triangle but rotated and reused.

4. Square (x1)
swift
Copy
Edit
[
    CGPoint(x: 0, y: 0),
    CGPoint(x: 0.5, y: 0),
    CGPoint(x: 0.5, y: 0.5),
    CGPoint(x: 0, y: 0.5)
]
5. Parallelogram (x1)
swift
Copy
Edit
[
    CGPoint(x: 0, y: 0),
    CGPoint(x: 0.5, y: 0),
    CGPoint(x: 0.75, y: 0.5),
    CGPoint(x: 0.25, y: 0.5)
]
Note: this shape can’t be matched by just rotation — it needs flipping to match mirror images.

🛠 How to Generate Tangram Shapes in Code (SpriteKit)
Here’s a generic function for creating a shape node:

swift
Copy
Edit
func createTangramPiece(points: [CGPoint], size: CGFloat, color: UIColor) -> SKShapeNode {
    let path = CGMutablePath()
    let scaledPoints = points.map { CGPoint(x: $0.x * size, y: $0.y * size) }

    path.move(to: scaledPoints[0])
    for pt in scaledPoints.dropFirst() {
        path.addLine(to: pt)
    }
    path.closeSubpath()

    let shape = SKShapeNode(path: path)
    shape.fillColor = color
    shape.strokeColor = .black
    shape.lineWidth = 1
    shape.name = "tangram_piece"
    return shape
}
You can now call:

swift
Copy
Edit
let triangle = createTangramPiece(points: [
    CGPoint(x: 0, y: 0),
    CGPoint(x: 1, y: 0),
    CGPoint(x: 0, y: 1)
], size: 100, color: .red)
🧠 Geometric Constraints
To ensure pieces "fit together" when solving a puzzle:

All pieces must lie inside a shared 1x1 space

Snapping must check:

Shape type

Position delta (within ε pixels)

Rotation (within ε degrees)

Optional: Flipping detection (for parallelogram)

You may want to store reference positions and rotations in level definitions:

swift
Copy
Edit
struct ShapeTarget {
    let type: ShapeType
    let origin: CGPoint
    let rotation: CGFloat
    let flipped: Bool
}
🗂 Level Authoring Format
json
Copy
Edit
{
  "id": "cat",
  "targets": [
    {
      "type": "largeTriangle",
      "origin": [100, 200],
      "rotation": 45
    },
    ...
  ]
}
🔁 Reusability
Each of the 7 pieces can be reused across puzzles — store their base geometry once, and move/rotate/flip based on each level's layout.

✅ Action Items for Your Implementation
Task	Status
Define 7 tangram piece geometries in code	✅
Create SKShapeNodes using CGPath	✅
Add these nodes to TangramGameScene	⬜️
Parse level file with target shape data	⬜️
Snap matching logic based on position/angle	⬜️
Validate all 7 pieces are correctly placed	⬜️