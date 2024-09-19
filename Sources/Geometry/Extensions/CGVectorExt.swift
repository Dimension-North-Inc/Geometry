//
//  CGVectorExt.swift
//  Geometry
//
//  Created by Mark Onyschuk on 9/19/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
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

    /// Vector normal
    var normal: Self {
        length != 0 ? self / length : self * 0
    }

    /// A perpendicular vector (rotated 90 degrees).
    var perpendicular: Self {
        Self(-dy, dx)
    }
    
    /// Unit representation of the type.
    public static var unit: Self {
        Self(1, 1)
    }
    
    /// Limits the precision of a CGVectorType to a specified number of decimal places.
    /// - Parameters:
    ///   - decimalPlaces: The number of decimal places to retain.
    /// - Returns: A CGVectorType rounded to the specified number of decimal places.
    public func limitingPrecision(to decimalPlaces: Int) -> Self {
        Self(dx.limitingPrecision(to: decimalPlaces), dy.limitingPrecision(to: decimalPlaces))
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


extension CGFloat {
    /// Limits the precision of a CGFloat to a specified number of decimal places.
    /// - Parameters:
    ///   - decimalPlaces: The number of decimal places to retain.
    /// - Returns: A CGFloat rounded to the specified number of decimal places.
    public func limitingPrecision(to decimalPlaces: Int) -> Self {
        let multiplier = pow(10.0, CGFloat(decimalPlaces))
        return (self * multiplier).rounded() / multiplier
    }
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
