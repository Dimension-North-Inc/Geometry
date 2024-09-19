//
//  RoundedPath.swift
//  Three-Column-Layout
//
//  Created by Mark Onyschuk on 10/11/23.
//

import SwiftUI

extension Path {
    
    /// Creates a path from the union of `rects` and rounds its edges with a radius of up to `roundness` pixels.
    ///
    /// Since the path is formed from the union of `rects`, abutting rectangles are grouped into a single rectangle.
    /// - Parameters:
    ///   - rects: a collection of rects to round
    ///   - roundness: a maximum roundness in pixels
    /// - Returns: a `Path`
    public static func rects(
        _ rects: some Collection<CGRect>, roundness: CGFloat
    ) -> Self? {
        let rects = rects.filter { !$0.isEmpty }
        
        if let first = rects.first {
            let union = rects.dropFirst().reduce(CGPath(rect: first, transform: nil)) {
                path, next in path.union(CGPath(rect: next, transform: nil))
            }
            
            var polys: [[CGPoint]] = []
            
            union.applyWithBlock {
                let elt = $0.pointee
                
                switch elt.type {
                case .moveToPoint:
                    polys = polys.dropLast()
                    polys.append([elt.points[0]])
                case .addLineToPoint:
                    polys[polys.count - 1].append(elt.points[0])
                case .closeSubpath:
                    polys.append([.zero])
                    
                default:
                    break
                }
            }
            
            return Path {
                path in for pts in polys {
                    var first: CGPoint? = nil
                    for i in 1...pts.count {
                        // fetch three points - the control point, its predecessor and successor points
                        let cp   = pts[i % pts.count]

                        let prev = pts[i-1]
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
                        
                        // quad-curve from start and end points, with `cp` as the control point
                        path.addQuadCurve(to: p2, control: cp)
                    }
                    
                    if first != nil {
                        path.closeSubpath()
                    }
                }
            }
        } else {
            return nil
        }
    }
}

