//
//  CoreGraphics.swift
//  Geometry
//
//  Created by Mark Onyschuk on 09/02/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import CoreGraphics

/// A 2D vector description of Core Graphics types
public protocol CGVectorType {
    var dx: CGFloat { get set }
    var dy: CGFloat { get set }
    
    init(_ dx: CGFloat, _ dy: CGFloat)
}

extension CGVectorType {
    /// Vector type conversion
    public init(_ other: CGVectorType) {
        self.init(other.dx, other.dy)
    }
    
    /// Vector length
    public var length: CGFloat {
        hypot(dx, dy)
    }

    /// Vector length squared
    public var length2: CGFloat {
        dx * dx + dy * dy
    }

    /// Unit representation of the type.
    public static var unit: Self {
        Self(1, 1)
    }
    
    // scalar operators
    public static func +(lhs: Self, rhs: CGFloat) -> Self {
        Self(lhs.dx + rhs, lhs.dy + rhs)
    }
    public static func -(lhs: Self, rhs: CGFloat) -> Self {
        Self(lhs.dx - rhs, lhs.dy - rhs)
    }
    public static func *(lhs: Self, rhs: CGFloat) -> Self {
        Self(lhs.dx * rhs, lhs.dy * rhs)
    }
    public static func /(lhs: Self, rhs: CGFloat) -> Self {
        Self(lhs.dx / rhs, lhs.dy / rhs)
    }

    // vector operators
    public static func +(lhs: Self, rhs: CGVectorType) -> Self {
        Self(lhs.dx + rhs.dx, lhs.dy + rhs.dy)
    }
    public static func -(lhs: Self, rhs: CGVectorType) -> Self {
        Self(lhs.dx - rhs.dx, lhs.dy - rhs.dy)
    }
    public static func *(lhs: Self, rhs: CGVectorType) -> Self {
        Self(lhs.dx * rhs.dx, lhs.dy * rhs.dy)
    }
    public static func /(lhs: Self, rhs: CGVectorType) -> Self {
        Self(lhs.dx / rhs.dx, lhs.dy / rhs.dy)
    }

    // vector-like tuple operators
    public static func +(lhs: Self, rhs: (CGFloat, CGFloat)) -> Self {
        Self(lhs.dx + rhs.0, lhs.dy + rhs.1)
    }
    public static func -(lhs: Self, rhs: (CGFloat, CGFloat)) -> Self {
        Self(lhs.dx - rhs.0, lhs.dy - rhs.1)
    }
    public static func *(lhs: Self, rhs: (CGFloat, CGFloat)) -> Self {
        Self(lhs.dx * rhs.0, lhs.dy * rhs.1)
    }
    public static func /(lhs: Self, rhs: (CGFloat, CGFloat)) -> Self {
        Self(lhs.dx / rhs.0, lhs.dy / rhs.1)
    }
    
    public static func +(lhs: (CGFloat, CGFloat), rhs: Self) -> Self {
        Self(lhs.0 + rhs.dx, lhs.1 + rhs.dy)
    }
    public static func -(lhs: (CGFloat, CGFloat), rhs: Self) -> Self {
        Self(lhs.0 - rhs.dx, lhs.1 - rhs.dy)
    }
    public static func *(lhs: (CGFloat, CGFloat), rhs: Self) -> Self {
        Self(lhs.0 * rhs.dx, lhs.1 * rhs.dy)
    }
    public static func /(lhs: (CGFloat, CGFloat), rhs: Self) -> Self {
        Self(lhs.0 / rhs.dx, lhs.1 / rhs.dy)
    }
}

public func +(lhs: (CGFloat, CGFloat), rhs: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
    (lhs.0 + rhs.0, lhs.1 + rhs.1)
}
public func -(lhs: (CGFloat, CGFloat), rhs: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
    (lhs.0 - rhs.0, lhs.1 - rhs.1)
}
public func *(lhs: (CGFloat, CGFloat), rhs: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
    (lhs.0 * rhs.0, lhs.1 * rhs.1)
}
public func /(lhs: (CGFloat, CGFloat), rhs: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
    (lhs.0 / rhs.0, lhs.1 / rhs.1)
}


extension CGPoint: CGVectorType {
    public var dx: CGFloat {
        get { x }
        set { x = newValue }
    }
    public var dy: CGFloat {
        get { y }
        set { y = newValue }
    }
    
    public init(_ dx: CGFloat, _ dy: CGFloat) {
        self.init(x: dx, y: dy)
    }
}

extension CGSize: CGVectorType {
    public var dx: CGFloat {
        get { width }
        set { width = newValue }
    }
    public var dy: CGFloat {
        get { height }
        set { height = newValue }
    }

    public init(_ dx: CGFloat, _ dy: CGFloat) {
        self.init(width: dx, height: dy)
    }
}

extension CGVector: CGVectorType {
    public init(_ dx: CGFloat, _ dy: CGFloat) {
        self.init(dx: dx, dy: dy)
    }
}

extension CGRect {
    /// Initializes a `CGRect` from one or more points
    /// - Parameter points: a list of one or more points
    public init(_ points: CGVectorType...) {
        self.init(points)
    }
    
    public init(_ points: [CGVectorType]) {
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
