//
//  FrameListReader.swift
//  Geometry
//
//  Created by Mark Onyschuk on 9/18/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import SwiftUI

private struct FrameList<ID>: PreferenceKey where ID: Hashable {
    static var defaultValue: [ID: CGRect] {
        [:]
    }
    static func reduce(value: inout [ID: CGRect], nextValue: () -> [ID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { old, new in new })
    }
}

private enum FrameListModifier<ID>: ViewModifier where ID: Hashable {
    case reader(onChange: ([ID: CGRect])-> ())
    case writer(id: ID, coordinates: CoordinateSpace)
    
    public func body(content: Content) -> some View {
        switch self {
        case let .reader(onChange):
            content.onPreferenceChange(FrameList<ID>.self, perform: onChange)
        case let .writer(id, coordinates):
            content.overlay(GeometryReader {
                geom in Color.clear.preference(
                    key: FrameList<ID>.self,
                    value: [id: geom.frame(in: coordinates)]
                )
            })
        }
    }
}

extension View {
    
    /// A modifier which observes changes to view frames with corresponding IDs
    /// - Parameter value: a binding to a dictionary of IDs to frame rectangle
    /// - Returns: a View
    public func frames<ID>(_ value: Binding<[ID: CGRect]>) -> some View where ID: Hashable {
        readFrames { value.wrappedValue = $0 }
    }

    /// A modifier which writes changes to the current view's frame with corresponding `id`
    /// - Parameter id: the current view's corresponding ID
    /// - Parameter coordinates: the coordinate space in which the frame is expressed
    /// - Returns: a View
    public func writeFrame<ID>(id: ID, coordinates: CoordinateSpace) -> some View where ID: Hashable {
        self.modifier(FrameListModifier<ID>.writer(id: id, coordinates: coordinates))
    }

    /// A modifier which reads changes to view frames with corresponding IDs
    /// - Parameter value: a binding to a dictionary of IDs to frame rectangle
    /// - Returns: a View
    public func readFrames<ID>(onChange: @escaping ([ID: CGRect])-> ()) -> some View where ID: Hashable {
        self.modifier(FrameListModifier<ID>.reader(onChange: onChange))
    }
}
