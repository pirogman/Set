//
//  GridCellView.swift
//  Set
//
//  Created by Alex Pirog on 17.05.2020.
//  Copyright © 2020 Alex Pirog. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    var card: Card? { didSet { setNeedsDisplay() } }
    var isSelected: Bool = false { didSet { setNeedsDisplay() } }
    var isMatched: Bool = false { didSet { setNeedsDisplay() } }
    var isHint: Bool = false { didSet { setNeedsDisplay() } }
    
    private var strokeWidth: CGFloat { return bounds.minSide * 0.05 }
    private var cornerRadius: CGFloat { return bounds.minSide / 5.0 }
    private let selectionColor = UIColor.orange
    private let hintColor = UIColor.cyan
    private let clearColor = UIColor.white
    private var cardColor: UIColor {
        if let color = card?.color {
            switch color {
            case .blue: return UIColor.purple
            case .green: return UIColor.green
            case .red: return UIColor.red
            }
        }
        return UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        if let card = card {
            let bourderPath = UIBezierPath(roundedRect: bounds.zoom(by: 0.95), cornerRadius: cornerRadius)
            bourderPath.lineWidth = strokeWidth * 3
            if isSelected { selectionColor.setStroke() }
            else if isHint {  hintColor.setStroke() }
            else { clearColor.setStroke() }
            bourderPath.stroke()
            (isMatched ? selectionColor : clearColor).setFill()
            bourderPath.fill()
            bourderPath.addClip()
            
            let elementPath = getPath(of: card, in: bounds)
            switch card.shading {
            case .outline:
                // Stroke
                cardColor.setStroke()
                elementPath.lineWidth = strokeWidth
                elementPath.stroke()
            case .filled:
                // Fill
                cardColor.setFill()
                elementPath.fill()
            default:
                // Stripped
                cardColor.setStroke()
                elementPath.lineWidth = strokeWidth
                elementPath.stroke()
                elementPath.addClip()
                let lines = 10
                let additionalPath = UIBezierPath(rect: bounds)
                for count in 1...lines {
                    additionalPath.move(to: CGPoint(
                        x: bounds.width / CGFloat(lines) * CGFloat(count), y: 0))
                    additionalPath.addLine(to: CGPoint(
                        x: 0, y: bounds.height / CGFloat(lines) * CGFloat(count)))
                }
                for count in 1...lines {
                    additionalPath.move(to: CGPoint(
                        x: bounds.width / CGFloat(lines) * CGFloat(count), y: bounds.height))
                    additionalPath.addLine(to: CGPoint(
                        x: bounds.width, y: bounds.height / CGFloat(lines) * CGFloat(count)))
                }
                additionalPath.lineWidth = strokeWidth / 3
                additionalPath.stroke()
            }
        }
    }
    
    private func getPath(of card: Card, in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        for rectPiece in rect.getNumberOfThirds(card.number.rawValue) {
            let elementWidth = rectPiece.width * 0.9
            let elementHeight = rectPiece.height * 0.9
            
            switch card.shape {
            case .square:
                // Dimond (romb)
                path.move(to: rectPiece.center.offsetBy(dx: -elementWidth * 0.45, dy: 0))
                path.addLine(to: rectPiece.center.offsetBy(dx: 0, dy: -elementHeight * 0.45))
                path.addLine(to: rectPiece.center.offsetBy(dx: elementWidth * 0.45, dy: 0))
                path.addLine(to: rectPiece.center.offsetBy(dx: 0, dy: elementHeight * 0.45))
                path.close()
            case .triangle:
                // Wave (cross)
                path.move(to: rectPiece.center.offsetBy(dx: elementWidth * 0.4, dy: -elementHeight * 0.4))
                let p1 = rectPiece.center.offsetBy(dx: elementWidth * 0.1, dy: -elementHeight * 0.35)
                let p2 = rectPiece.center.offsetBy(dx: -elementWidth * 0.3, dy: -elementHeight * 0.35)
                path.addCurve(to: rectPiece.center.offsetBy(dx: -elementWidth * 0.4, dy: elementHeight * 0.4), controlPoint1: p1, controlPoint2: p2)
                let p3 = rectPiece.center.offsetBy(dx: -elementWidth * 0.1, dy: elementHeight * 0.35)
                let p4 = rectPiece.center.offsetBy(dx: elementWidth * 0.3, dy: elementHeight * 0.35)
                path.addCurve(to: rectPiece.center.offsetBy(dx: elementWidth * 0.4, dy: -elementHeight * 0.4), controlPoint1: p3, controlPoint2: p4)
            default:
                // Oval (circle)
                path.append(UIBezierPath(ovalIn: rectPiece.zoom(by: 0.7)))
            }
        }
        
        return path
    }

}

extension CGRect {
    
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
    var radius: CGFloat { return minSide / 2 }
    
    var minSide: CGFloat { return min(width, height) }
    var maxSide: CGFloat { return max(width, height) }
    
    
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    
    func getNumberOfThirds(_ count: Int) -> [CGRect] {
        switch count {
        case 1: // Just take one in the middle
            return [devide(inPieces: 3)[1]]
        case 2: // Reposition
            let side = maxSide / 3
            let xOffset = width > height ? side : 0
            let yOffset = width < height ? side : 0
            let first = devide(inPieces: 3).first!.offsetBy(dx: xOffset / 2, dy: yOffset / 2)
            let second = first.offsetBy(dx: xOffset, dy: yOffset)
            return [first, second]
        case 3: // Take all three
            return devide(inPieces: 3)
        default: return [self]
        }
    }
    
    func devide(inPieces pieces: Int) -> [CGRect] {
        if pieces > 1 {
            let step = maxSide / CGFloat(pieces)
            var result = [CGRect]()
            var currentX = CGFloat(0)
            var currentY = CGFloat(0)
            for _ in 1...pieces {
                if width < height {
                    // Devide verticaly
                    result.append(CGRect(x: currentX, y: currentY, width: width, height: step))
                    currentY += step
                } else {
                    // Devide horizontaly
                    result.append(CGRect(x: currentX, y: currentY, width: step, height: height))
                    currentX += step
                }
            }
            return result
        } else {
            return [self]
        }
    }
    
}

extension CGPoint {
    
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
    
}
