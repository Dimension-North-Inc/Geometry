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
    /// Path rounding styles
    public enum RoundingStyle: Sendable {
        /// strict geometric rounding
        case strict
        /// more natural rounding
        case natural
        /// artistic, freehand rounding
        case freestyle
        
        public static var `default` = Self.natural
    }

    /// Creates and returns a new CGPath with rounded corners based on
    /// `style` and `radius`. The function handles multiple closed subpaths
    /// within the CGPath.
    ///
    /// - Parameters:
    ///   - radius: rounded corner radius
    ///   - style: rounded corner style
    ///   - threshold: threshold for path flattening
    ///   - minSegmentLength: minimum segment length to round
    /// - Returns: a CGPath whose sharp corners are rounded
    public func rounded(
        _ radius: CGFloat,
        
        style: RoundingStyle = .default,
        
        threshold: CGFloat = 0.6,
        minSegmentLength: CGFloat = 1.0
    ) -> CGPath {
            
        guard radius > 0 else { return self }
        
        // Step 1: Flatten the path using the existing 'flattened(threshold:)' method
        let flattenedPath = self.flattened(threshold: threshold)
        
        // Step 2: Extract points from the flattened path, separated by subpaths
        let allSubpaths = extractPoints(from: flattenedPath)
        
        // Prepare a new mutable path to accumulate rounded subpaths
        let roundedPath = CGMutablePath()
        
        // Step 3: Iterate over each subpath and apply rounding
        for subpathPoints in allSubpaths {
            // Step 3a: Remove consecutive duplicate points
            var points = removeConsecutiveDuplicates(from: subpathPoints)
            
            // Step 3b: Remove points that result in segments smaller than minSegmentLength
            points = removeSmallSegments(from: points, minSegmentLength: minSegmentLength)
            
            // Ensure the subpath is closed
            if points.first != points.last {
                points.append(points.first!)
            }
            
            // Step 3c: Apply the rounding logic to the points
            let roundedSubpath = createRoundedPath(
                from: points,
                radius: radius,
                style: style
            )
            
            // Step 3d: Add the rounded subpath to the accumulated path
            roundedPath.addPath(roundedSubpath)
        }
        
        return roundedPath
    }
}

// MARK: - Helper Functions

/// Creates a CGVector from two CGPoints.
/// - Parameters:
///   - from: The starting CGPoint.
///   - to: The ending CGPoint.
/// - Returns: A CGVector representing the vector from `from` to `to`.
private func vec(from: CGPoint, to: CGPoint) -> CGVector {
    return CGVector(to - from)
}

/// Extracts an array of arrays of CGPoints from a flattened CGPath, separating each subpath.
/// - Parameter path: The flattened CGPath to extract points from.
/// - Returns: An array where each element is an array of CGPoints representing a subpath.
private func extractPoints(from path: CGPath) -> [[CGPoint]] {
    var subpaths: [[CGPoint]] = []
    var currentSubpath: [CGPoint] = []
    var currentPoint: CGPoint = .zero
    var subpathStartPoint: CGPoint = .zero
    
    path.applyWithBlock { element in
        switch element.pointee.type {
        case .moveToPoint:
            // If there's an existing subpath, append it before starting a new one
            if !currentSubpath.isEmpty {
                subpaths.append(currentSubpath)
                currentSubpath = []
            }
            currentPoint = element.pointee.points[0]
            subpathStartPoint = currentPoint
            currentSubpath.append(currentPoint)
        case .addLineToPoint:
            currentPoint = element.pointee.points[0]
            currentSubpath.append(currentPoint)
        case .closeSubpath:
            // Ensure the subpath is closed by appending the start point
            if currentSubpath.last != subpathStartPoint {
                currentSubpath.append(subpathStartPoint)
            }
            subpaths.append(currentSubpath)
            currentSubpath = []
        default:
            break // Should not occur in flattened path
        }
    }
    
    // Append any remaining subpath that wasn't closed
    if !currentSubpath.isEmpty {
        subpaths.append(currentSubpath)
    }
    
    return subpaths
}

/// Removes consecutive duplicate points from an array of CGPoints.
/// - Parameter points: The array of CGPoints to process.
/// - Returns: A new array of CGPoints without consecutive duplicates.
private func removeConsecutiveDuplicates(from points: [CGPoint]) -> [CGPoint] {
    if points.isEmpty { return [] }
    return points.reduce(into: [points[0]]) { result, current in
        if let last = result.last, current != last {
            result.append(current)
        }
    }
}

/// Removes points that result in segments smaller than `minSegmentLength`.
/// - Parameters:
///   - points: The array of CGPoints to filter.
///   - minSegmentLength: The minimum allowable segment length.
/// - Returns: A new array of CGPoints with small segments removed.
private func removeSmallSegments(from points: [CGPoint], minSegmentLength: CGFloat) -> [CGPoint] {
    if points.isEmpty { return [] }
    var filteredPoints: [CGPoint] = [points[0]]
    
    for current in points.dropFirst() {
        let previous = filteredPoints.last!
        let distance = hypot(current.x - previous.x, current.y - previous.y)
        if distance >= minSegmentLength {
            filteredPoints.append(current)
        }
    }
    
    return filteredPoints
}

/// Creates a rounded CGPath from an array of points.
/// - Parameters:
///   - points: The array of CGPoints representing the vertices.
///   - radius: The radius for rounding the corners.
///   - style: The style of rounding.
/// - Returns: A new CGPath with rounded corners.
private func createRoundedPath(
    from points: [CGPoint],
    radius: CGFloat,
    style: CGPath.RoundingStyle
) -> CGPath {
    guard points.count >= 3 else {
        // Not enough points to form a rounded path
        let simplePath = CGMutablePath()
        simplePath.addLines(between: points)
        simplePath.closeSubpath()
        return simplePath
    }
    
    let pathCoords = points.dropLast() // Remove the duplicate last point for processing
    let count = pathCoords.count
    let roundedPath = CGMutablePath()
    
    for i in 0..<count {
        let c1 = pathCoords[i]
        let c2 = pathCoords[(i + 1) % count]
        let c3 = pathCoords[(i + 2) % count]
        
        // Vectors from c2 to c1 and c2 to c3
        let vC1c2 = vec(from: c2, to: c1) // Vector from c2 to c1 (away from c2)
        let vC3c2 = vec(from: c2, to: c3) // Vector from c2 to c3 (away from c2)
        
        // Calculate angle between vectors
        let crossProduct = vC1c2.dx * vC3c2.dy - vC1c2.dy * vC3c2.dx
        let dotProduct = vC1c2.dx * vC3c2.dx + vC1c2.dy * vC3c2.dy
        let angle = abs(atan2(crossProduct, dotProduct))
        
        // Skip if angle is 0 to avoid division by zero
        if angle == 0 {
            continue
        }
        
        // Limit radius to half the shortest edge length
        let cornerLength = min(radius, vC1c2.length / 2, vC3c2.length / 2)
        
        // Calculate control point distance based on style
        let bc = cornerLength
        let bd = cos(angle / 2) * bc
        let fd = sin(angle / 2) * bd
        let bf = cos(angle / 2) * bd
        let ce = fd / (bf / bc)
        let a = ce
        
        let numberOfPointsInCircle = (2 * CGFloat.pi) / (CGFloat.pi - angle)
        var idealControlPointDistance: CGFloat
        
        switch style {
        case .strict:
            // Strictly geometric
            idealControlPointDistance = (4.0 / 3.0) * tan(CGFloat.pi / (2 * numberOfPointsInCircle)) * a
        case .natural:
            // More natural rounding
            idealControlPointDistance = (4.0 / 3.0) * tan(CGFloat.pi / (2 * ((2 * CGFloat.pi) / angle))) * cornerLength * (angle < (CGFloat.pi / 2) ? 1 + cos(angle) : 2 - sin(angle))
        case .freestyle:
            // Hand's free style
            idealControlPointDistance = (4.0 / 3.0) * tan(CGFloat.pi / (2 * ((2 * CGFloat.pi) / angle))) * cornerLength * (2 + sin(angle))
        }
        
        let cpDistance = cornerLength - idealControlPointDistance
        
        // Control Points Positioned Outward Using `.normal`
        let c1c2CurvePoint = c2 + vC1c2.normal * cornerLength
        let c1c2CurveCP = c2 + vC1c2.normal * cpDistance
        
        let c3c2CurvePoint = c2 + vC3c2.normal * cornerLength
        let c3c2CurveCP = c2 + vC3c2.normal * cpDistance
        
        // Limit floating point precision
        let limit = 3
        
        let limitedC1c2CurvePoint = c1c2CurvePoint.limitingPrecision(to: limit)
        let limitedC1c2CurveCP = c1c2CurveCP.limitingPrecision(to: limit)
        let limitedC3c2CurvePoint = c3c2CurvePoint.limitingPrecision(to: limit)
        let limitedC3c2CurveCP = c3c2CurveCP.limitingPrecision(to: limit)
        
        if i == 0 {
            // Move to the starting point at c1c2CurvePoint
            roundedPath.move(to: limitedC1c2CurvePoint)
        }
        
        // Add line to the start of the curve
        roundedPath.addLine(to: limitedC1c2CurvePoint)
        
        // Add cubic Bezier curve to c3c2CurvePoint
        roundedPath.addCurve(
            to: limitedC3c2CurvePoint,
            control1: limitedC1c2CurveCP,
            control2: limitedC3c2CurveCP
        )
    }
    
    roundedPath.closeSubpath()
    return roundedPath
}

// MARK: - Preview

#Preview {
    /// Creates a star-shaped CGPath.
    /// - Parameters:
    ///   - center: The center point of the star.
    ///   - radius: The outer radius of the star.
    ///   - points: The number of points (spikes) the star should have.
    /// - Returns: A CGPath representing the star.
    func createStarPath(center: CGPoint, radius: CGFloat, points: Int) -> CGPath {
        let path = CGMutablePath()
        let angleIncrement = CGFloat.pi * 2 / CGFloat(points * 2)
        var angle = -CGFloat.pi / 2

        let startPoint = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        path.move(to: startPoint)

        for i in 1..<(points * 2) {
            angle += angleIncrement
            let isEven = i % 2 == 0
            let currentRadius = isEven ? radius : radius / 2
            let point = CGPoint(x: center.x + currentRadius * cos(angle), y: center.y + currentRadius * sin(angle))
            path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }

    struct RoundedStarShape: Shape {
        var stars: [CGPoint] // Centers of stars
        var starRadius: CGFloat
        var points: Int

        func path(in rect: CGRect) -> Path {
            let path = CGMutablePath()
            
            for center in stars {
                // Create star path
                let starPath = createStarPath(center: center, radius: starRadius, points: points)
                
                // Add to the accumulated path
                path.addPath(starPath)
            }
            
            return Path(
                path.rounded(10)
            )
        }
    }

    struct MultipleRoundedStarsView: View {
        @State private var progress: CGFloat = 0
        
        var body: some View {
            let shape = RoundedStarShape(
                stars: [
                    CGPoint(x: 100, y: 100),
                    CGPoint(x: 200, y: 200),
                    CGPoint(x: 300, y: 100)
                ],
                starRadius: 50.0,
                points: 5
            )
            
            shape
                .trim(from: 0, to: progress)
                .fill(Color.red)
                .overlay(
                    shape
                        .trim(from: 0, to: progress)
                        .stroke(Color.black, lineWidth: 3)
                )
            .frame(width: 400, height: 300)
            .background(Color.white)

            .onAppear {
                // Animate progress from 0 to 1 over 3 seconds
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    progress = 1.0
                }
            }

        }
    }
    
    return MultipleRoundedStarsView()
        .padding()
        .background(Color.gray.opacity(0.2))
}
