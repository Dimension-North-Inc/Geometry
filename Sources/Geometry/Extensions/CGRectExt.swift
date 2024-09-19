//
//  CGRectExt.swift
//  Geometry
//
//  Created by Mark Onyschuk on 9/19/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import CoreGraphics

extension CGRect {
    /// Initializes a `CGRect` from one or more points
    /// - Parameter points: a list of one or more points
    public init(_ points: CGVectorType...) {
        self.init(points)
    }
    
    public init(_ points: some Collection<CGVectorType>) {
        if points.isEmpty {
            self = .null
            return
        }

        let xs   = points.map(\.dx)
        let ys   = points.map(\.dy)
        
        let xmin = xs.min() ?? xs[0]
        let xmax = xs.max() ?? xs[0]
        let ymin = ys.min() ?? ys[0]
        let ymax = ys.max() ?? ys[0]
        
        self.init(x: xmin, y: ymin, width: xmax - xmin, height: ymax - ymin)
    }
    
    public struct Position: Hashable, Codable {
        let value: CGFloat
        private init(_ value: CGFloat) {
            self.value = value
        }
    
        public static var min: Self = .init(0)
        public static var mid: Self = .init(0.5)
        public static var max: Self = .init(1.0)
        
        public static func pos(_ value: CGFloat) -> Self  {
            .init(value)
        }
    }
    
    public func at(_ x: Position, _ y: Position) -> CGPoint {
        return origin + size * (x.value, y.value)
    }

    public struct Coord: Hashable, Codable {
        public var x, y: Position
        
        public static func at(_ x: Position, _ y: Position) -> Self {
            Self(x: x, y: y)
        }
    }
    
    public func at(_ coord: Coord) -> CGPoint {
        return origin + size * (coord.x.value, coord.y.value)
    }
    
    public static var unit: Self {
        .init(origin: .zero, size: .unit)
    }
    
    public func offset(by vector: some CGVectorType) -> Self {
        Self(origin: origin + vector, size: size)
    }
    public func offset(by vector: (CGFloat, CGFloat)) -> Self {
        Self(origin: origin + vector, size: size)
    }
    
    public func stretchedWide(by amount: CGFloat = 1e12) -> Self {
        return self.insetBy(dx: -amount, dy: 0)
    }
    public func stretchedTall(by amount: CGFloat = 1e12) -> Self {
        return self.insetBy(dx: 0, dy: -amount)
    }
}
