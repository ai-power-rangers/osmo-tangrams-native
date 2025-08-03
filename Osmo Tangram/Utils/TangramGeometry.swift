//
//  TangramGeometry.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import Foundation
import CoreGraphics

/// Helper class for generating tangram piece geometries
struct TangramGeometry {
    
    /// Standard unit size for scaling pieces
    static let unitSize: CGFloat = 100.0
    
    /// Generate points for a tangram piece based on its type
    /// - Parameter type: The type of tangram piece
    /// - Returns: Array of CGPoints representing the piece's vertices
    static func points(for type: ShapeType) -> [CGPoint] {
        switch type {
        case .largeTriangle1, .largeTriangle2:
            // Right triangle with hypotenuse length = 1
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
                CGPoint(x: 0, y: 1)
            ]
            
        case .mediumTriangle:
            // Right triangle, half size of large triangle
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 0.707, y: 0),  // sqrt(2)/2
                CGPoint(x: 0, y: 0.707)
            ]
            
        case .smallTriangle1, .smallTriangle2:
            // Right triangle, half size of medium triangle
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 0.5, y: 0),
                CGPoint(x: 0, y: 0.5)
            ]
            
        case .square:
            // Square with sides matching small triangle's legs
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 0.354, y: 0),  // sqrt(2)/4
                CGPoint(x: 0.354, y: 0.354),
                CGPoint(x: 0, y: 0.354)
            ]
            
        case .parallelogram:
            // Rhomboid with same area as square
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 0.5, y: 0),
                CGPoint(x: 0.354, y: 0.354),  // Adjusted for proper geometry
                CGPoint(x: -0.146, y: 0.354)
            ]
        }
    }
    
    /// Get the center point of a shape for proper rotation
    /// - Parameter type: The type of tangram piece
    /// - Returns: The center point of the shape
    static func centerPoint(for type: ShapeType) -> CGPoint {
        let pts = points(for: type)
        let sumX = pts.reduce(0) { $0 + $1.x }
        let sumY = pts.reduce(0) { $0 + $1.y }
        return CGPoint(x: sumX / CGFloat(pts.count), y: sumY / CGFloat(pts.count))
    }
    
    /// Scale points by a given factor
    /// - Parameters:
    ///   - points: Original points
    ///   - scale: Scale factor
    /// - Returns: Scaled points
    static func scalePoints(_ points: [CGPoint], by scale: CGFloat) -> [CGPoint] {
        return points.map { CGPoint(x: $0.x * scale, y: $0.y * scale) }
    }
    
    /// Create a path from points
    /// - Parameters:
    ///   - points: Array of points
    ///   - scale: Scale factor
    /// - Returns: CGPath for the shape
    static func createPath(from points: [CGPoint], scale: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let scaledPoints = scalePoints(points, by: scale)
        
        guard !scaledPoints.isEmpty else { return path }
        
        path.move(to: scaledPoints[0])
        for point in scaledPoints.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
    }
}