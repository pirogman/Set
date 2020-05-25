//
//  Card.swift
//  Set
//
//  Created by Alex Pirog on 05.05.2020.
//  Copyright © 2020 Alex Pirog. All rights reserved.
//

import Foundation

struct Card: Equatable, CustomStringConvertible {
    
    let color: Color
    let number: Number
    let shape: Shape
    let shading: Shading
    
    var description: String { return "\(number) \(shading) \(color) \(shape)" }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.color == rhs.color
            && lhs.number == rhs.number
            && lhs.shape == rhs.shape
            && lhs.shading == rhs.shading
    }
    
    static func match(_ a: Card, _ b: Card, _ c: Card) -> Bool {
        let color = (a.color == b.color && b.color == c.color)
            || (a.color != b.color && a.color != c.color && b.color != c.color)
        let number = (a.number == b.number && b.number == c.number)
            || (a.number != b.number && a.number != c.number && b.number != c.number)
        let shape = (a.shape == b.shape && b.shape == c.shape)
            || (a.shape != b.shape && a.shape != c.shape && b.shape != c.shape)
        let shading = (a.shading == b.shading && b.shading == c.shading)
            || (a.shading != b.shading && a.shading != c.shading && b.shading != c.shading)
        
        return color && number && shape && shading
    }
    
    enum Color: String, CustomStringConvertible {
        case red = "red"
        case green = "green"
        case blue = "blue"
        
        var description: String { return self.rawValue }
        
        static var all = [Color.red, .green, .blue]
    }
    
    enum Number: Int, CustomStringConvertible {
        case single = 1
        case double = 2
        case triple = 3
        
        var description: String { return "\(self.rawValue)" }
        
        static var all = [Number.single, .double, .triple]
    }
    
    enum Shape: String, CustomStringConvertible {
        case circle = "●"
        case triangle = "▲"
        case square = "■"
        
        var description: String {
            switch self {
            case .circle: return "circle"
            case .triangle: return "triangle"
            case .square: return "square"
            }
        }
        
        static var all = [Shape.circle, .triangle, .square]
    }
    
    enum Shading: Double, CustomStringConvertible {
        case outline
        case striped
        case filled
        
        var description: String {
            switch self {
            case .outline: return "outlined"
            case .striped: return "stripped"
            case .filled: return "filled"
            }
        }
        
        static var all = [Shading.outline, .striped, .filled]
    }
    
}

extension Card: Hashable {
    
    //
    
}
