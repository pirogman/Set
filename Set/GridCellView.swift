//
//  GridCellView.swift
//  Set
//
//  Created by Alex Pirog on 17.05.2020.
//  Copyright © 2020 Alex Pirog. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath(arcCenter: bounds.center, radius: bounds.radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        UIColor.blue.setFill()
        path.fill()
    }

}
