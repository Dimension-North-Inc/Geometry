//
//  CGPathExt.swift
//  Geometry
//
//  Created by Mark Onyschuk on 9/19/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI
import CoreGraphics

extension CGPath {
    public typealias Polygon = [CGPoint]
    
    public var polygons: [Polygon] {
        var isCurved = false
        var polygons: [[CGPoint]] = []
        
        applyWithBlock {
            let elt = $0.pointee
            
            switch elt.type {
            case .moveToPoint:
                polygons = polygons.dropLast()
                polygons.append([elt.points[0]])
            case .addLineToPoint:
                polygons[polygons.count - 1].append(elt.points[0])
            case .closeSubpath:
                polygons.append([.zero])
                
            default:
                isCurved = true
            }
        }

        return isCurved ? [] : polygons
    }

    public static func path(polygons: [Polygon], roundness: CGFloat) -> CGPath {
        let path = CGMutablePath()
        
        for pts in polygons {
            var first: CGPoint? = nil
            for i in 1...pts.count {
                // fetch three points - the control point, its predecessor and successor points
                let cp   = pts[i % pts.count]
                
                let prev = pts[i - 1]
                let next = pts[(i + 1) % pts.count]
                
                // get normals between `cp` and both predecessor and successor points
                let n1 = (cp - prev).normal
                let n2 = (next - cp).normal
                
                // get half-lengths between `cp` and both predecessor and successor points
                let l1 = (cp - prev).length / 2
                let l2 = (next - cp).length / 2
                
                // calculate a rounding radius no greater than the half-lengths
                let r  = min(roundness, l1, l2)
                
                // project start and end points along normals from `cp`
                let p1 = cp - (n1 * r)
                let p2 = cp + (n2 * r)
                
                if first == nil {
                    first = p1
                    path.move(to: p1)
                } else {
                    path.addLine(to: p1)
                }
                
                // if rounding, quad-curve from start and end points, with `cp` as the control point
                if r != 0 {
                    path.addQuadCurve(to: p2, control: cp)
                }
            }
            
            if first != nil {
                path.closeSubpath()
            }
        }
        
        return path
    }
}

