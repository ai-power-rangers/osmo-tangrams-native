# Osmo Tangram

A SwiftUI-based tangram puzzle game featuring an innovative SpriteKit integration, advanced magnetism system, and custom level designer.

## 🏗️ Architecture Overview

### Hybrid SwiftUI + SpriteKit Architecture

**Design Choice**: The app uses a **hybrid architecture** combining SwiftUI for UI/navigation and SpriteKit for game mechanics. This provides native iOS look/feel while leveraging SpriteKit's powerful game interaction capabilities.

```
[ SwiftUI App Layer ]
    ├── Navigation & Menus (SwiftUI)
    ├── TangramGameView (SwiftUI wrapper)
    └── TangramGameScene (SpriteKit game logic)
```

**Why This Architecture**:
- SwiftUI handles navigation, menus, and iOS-native UI components
- SpriteKit manages complex game interactions (drag, rotation, collision detection)
- Clean separation of concerns between UI and game logic
- Leverages strengths of both frameworks

### State Management Strategy

**Observable Pattern**: Uses modern SwiftUI's `@Observable` pattern for reactive state management:
- `LevelManager` as `@ObservableObject` for level data
- Local `@State` for view-specific state
- Callbacks for SpriteKit → SwiftUI communication

## 📁 Codebase Structure

```
Osmo Tangram/
├── Models/                 # Data models and business logic
│   ├── TangramLevel.swift     # Level structure with difficulty system
│   ├── TangramPiece.swift     # Piece & target definitions
│   └── ShapeType.swift        # 7-piece tangram enum system
│
├── Views/                  # SwiftUI view layer
│   ├── ContentView.swift      # App entry point
│   ├── MainMenuView.swift     # Level selection with grid layout
│   ├── TangramGameView.swift  # SwiftUI-SpriteKit bridge
│   ├── DesignerView.swift     # Custom level creation tool
│   └── WinOverlay.swift       # Success state UI
│
├── SpriteKit/             # Game engine layer
│   ├── TangramGameScene.swift # Core game logic & magnetism
│   ├── TangramPieceNode.swift # Interactive piece behavior
│   ├── ShapeTargetNode.swift  # Target rendering
│   └── TestScene.swift        # Development testing
│
├── Data/                  # Data management layer
│   └── LevelManager.swift     # Level loading & screen adaptation
│
├── Utils/                 # Shared utilities
│   ├── TangramGeometry.swift  # Mathematical piece generation
│   └── ColorTheme.swift       # Consistent styling system
│
├── Resources/             # Assets and sounds
└── Persistence.swift     # Core Data setup (future use)
```

## 🔧 Key Architecture Choices

### 1. **Adaptive Screen Coordinate System**
**Challenge**: Supporting different iOS device sizes while maintaining puzzle proportions.

**Solution**: Percentage-based coordinate system in `LevelManager`:
```swift
func coordinatesFromPercentage(x: CGFloat, y: CGFloat) -> CGPoint
```
- Levels store positions as percentages (0-100)
- Runtime conversion to actual screen coordinates
- Maintains puzzle proportions across devices

### 2. **Advanced Magnetism System** (Designer Mode)
**Innovation**: Sophisticated piece-to-piece magnetism with multiple snap types:
```swift
struct MagnetismSettings {
    var snapDistance: CGFloat = 25.0
    var angleSnapThreshold: CGFloat = 15.0
    var edgeMagnetism: Bool = true
    var cornerMagnetism: Bool = true
}
```
- Edge-to-edge alignment
- Corner-to-corner snapping
- Angle-based rotation assistance
- Overlap prevention

### 3. **Dual-Mode Design Pattern**
**Architecture**: Single codebase supporting both gameplay and level creation:
- `TangramGameView` accepts `isDesignerMode` parameter
- `TangramGameScene` adapts behavior based on mode
- Shared components, different interaction patterns

### 4. **Mathematical Precision in Geometry**
**Approach**: Mathematically accurate tangram piece generation:
```swift
// Standard tangram proportions with unit scaling
case .largeTriangle1, .largeTriangle2:
    return [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 1, y: 0),
        CGPoint(x: 0, y: 1)
    ]
```
- Based on classical 7-piece tangram mathematics
- Proportionally accurate piece relationships
- Scalable to any screen size

## 🎯 Core Components

### Level Management (`LevelManager`)
- **Responsibility**: Screen adaptation, level loading, persistence
- **Pattern**: ObservableObject with published properties
- **Key Feature**: Dynamic screen dimension calculation for responsive design

### Game Scene (`TangramGameScene`)
- **Responsibility**: Game logic, interaction handling, win detection
- **Pattern**: SpriteKit scene with delegation to SwiftUI
- **Key Features**: 
  - Advanced magnetism system
  - Precise snap detection
  - Rotation assistance
  - Real-time collision prevention

### Piece Nodes (`TangramPieceNode`)
- **Responsibility**: Individual piece behavior and rendering
- **Pattern**: SKNode subclass with touch handling
- **Key Features**: Drag support, rotation, visual feedback

## 📊 Data Flow

### Game Play Flow
```
User Touch → TangramPieceNode → TangramGameScene → Snap Logic → Win Detection → SwiftUI Callback
```

### Designer Mode Flow  
```
User Manipulation → Magnetism System → Position Tracking → Save to LevelManager → JSON Serialization
```

### Level Loading Flow
```
LevelManager → Screen Calculation → JSON Parsing → Scene Setup → Piece Generation
```

## 🎨 UI Design Patterns

### SwiftUI Best Practices Applied
- **LazyVGrid** for responsive level selection
- **@Environment** for dismissal patterns
- **NavigationView** with proper state management
- **GeometryReader** for adaptive layouts (planned)

### Visual Consistency
- Centralized `ColorTheme` system
- Consistent spacing and typography
- SF Symbols integration (planned)
- iOS-native interaction patterns

## 💾 Persistence Strategy

**Current**: JSON-based level storage with UserDefaults
**Future**: Core Data integration (foundation already laid)
**Choice Rationale**: 
- JSON provides easy level sharing and editing
- Core Data ready for complex game progression features
- UserDefaults for simple user-created level persistence

## 🔍 Debug & Development Features

### Comprehensive Logging System
**Pattern**: Emoji-prefixed debug logs throughout codebase:
```swift
print("🎮 Created TangramLevel: \(name)")
print("📱 Device: \(deviceModel)")
print("🎯 Converting coordinates: (\(x)%, \(y)%)")
```

### Development Tools
- SpriteKit debug options enabled (`showsFPS`, `showsNodeCount`)
- Screen dimension logging for device testing
- Position/rotation tracking for level creation
- Magnetism visualization in designer mode

## 🛠️ Technology Stack

**Core Technologies**:
- **SwiftUI**: UI framework and navigation
- **SpriteKit**: Game engine and physics
- **Core Data**: Persistence layer (prepared)
- **Swift 5.9+**: Language features and concurrency

**Future Integrations** (Architecture Ready):
- **Supabase**: Backend synchronization
- **RevenueCat**: Monetization
- **TelemetryDeck**: Analytics

## 🔄 Build Patterns

### Code Organization Principles
- **Single Responsibility**: Each component has one clear purpose
- **Separation of Concerns**: SwiftUI for UI, SpriteKit for game logic
- **DRY Principle**: Shared utilities and geometry calculations
- **Testability**: Clear interfaces and dependency injection ready

### File Size Management
- **Rule Applied**: No files over 300 lines (largest: LevelManager at ~605 lines - flagged for refactoring)
- **Modularity**: Utils separated into focused, reusable components
- **Clean Architecture**: Clear boundaries between layers

## 🚀 Getting Started

1. **Clone and open** in Xcode 15+
2. **Run** on iOS 17+ device/simulator
3. **Play levels** or use **Designer mode** to create custom puzzles
4. **Debug logs** provide detailed interaction tracking

## 📈 Scaling Considerations

The architecture supports:
- ✅ Multiple screen sizes and orientations
- ✅ Custom level creation and sharing
- ✅ Advanced game mechanics (magnetism, snapping)
- 🔄 Cloud synchronization (Supabase ready)
- 🔄 Analytics integration (TelemetryDeck ready)
- 🔄 Monetization features (RevenueCat ready)

---

**Architecture Philosophy**: *Simple solutions first, with clean extension points for complex features. Every architectural choice optimizes for maintainability and iOS-native user experience.*