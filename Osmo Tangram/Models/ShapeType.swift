//
//  ShapeType.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import Foundation

/// Enum representing all possible tangram piece types
enum ShapeType: String, CaseIterable, Codable {
    case largeTriangle1 = "largeTriangle1"
    case largeTriangle2 = "largeTriangle2"
    case mediumTriangle = "mediumTriangle"
    case smallTriangle1 = "smallTriangle1"
    case smallTriangle2 = "smallTriangle2"
    case square = "square"
    case parallelogram = "parallelogram"
    
    /// Debug description for logging
    var debugDescription: String {
        switch self {
        case .largeTriangle1, .largeTriangle2:
            return "Large Triangle"
        case .mediumTriangle:
            return "Medium Triangle"
        case .smallTriangle1, .smallTriangle2:
            return "Small Triangle"
        case .square:
            return "Square"
        case .parallelogram:
            return "Parallelogram"
        }
    }
}