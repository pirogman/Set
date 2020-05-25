//
//  GridView.swift
//  Set
//
//  Created by Alex Pirog on 17.05.2020.
//  Copyright © 2020 Alex Pirog. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    func showAspectRatioGrid(of views: [UIView], vertical: Bool) {
        let ratio: CGFloat = vertical ?  5/9 : 9/5 // width / height
        var grid = Grid(layout: .aspectRatio(ratio), frame: bounds)
        grid.cellCount = views.count
        for index in 0..<views.count {
            views[index].removeFromSuperview()
            addSubview(views[index])
            let offset = bounds.minSide / 5 / CGFloat(views.count)
            views[index].frame = grid[index]!.insetBy(dx: offset, dy: offset)
        }
    }
    
}
