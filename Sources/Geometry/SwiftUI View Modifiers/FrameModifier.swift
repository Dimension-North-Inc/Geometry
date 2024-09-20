//
//  FrameReader.swift
//  Geometry
//
//  Created by Mark Onyschuk on 12/04/23.
//  Copyright © 2023 Dimension North Inc. All rights reserved.
//

import SwiftUI

private struct FrameModifier: ViewModifier {
    struct Frame: PreferenceKey {
        static var defaultValue: CGRect = .zero
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
    }

    var onChange: (CGRect) -> ()
    var coordinates: CoordinateSpaceProtocol

    init(coordinates: CoordinateSpaceProtocol, onChange: @escaping (CGRect) -> ()) {
        self.onChange = onChange
        self.coordinates = coordinates
    }

    public func body(content: Content) -> some View {
        content.overlay(GeometryReader {
            geom in
            Color.clear.preference(
                key: Frame.self,
                value: geom.frame(in: coordinates)
            )
        })
        .onPreferenceChange(Frame.self, perform: onChange)
    }
}

extension View {
    
    /// A modifier whose  `value` tracks the enclosed view's bounding rectangle in `coordinates`
    /// - Parameters:
    ///   - value: a `CGRect` binding
    ///   - coordinates: a coordinate space
    /// - Returns: a modified view
    public func rect(_ value: Binding<CGRect>, in coordinates: CoordinateSpaceProtocol = .global) -> some View {
        self.modifier(FrameModifier(coordinates: coordinates) {
            value.wrappedValue = $0
        })
    }

    /// A modifier  whose  `value` tracks the enclosed view's size in `coordinates`
    /// - Parameters:
    ///   - value: a `CGSize` binding
    ///   - coordinates: a coordinate space
    /// - Returns: a modified view
    public func size(_ value: Binding<CGSize>, in coordinates: CoordinateSpaceProtocol = .global) -> some View {
        self.modifier(FrameModifier(coordinates: coordinates) {
            value.wrappedValue = $0.size
        })
    }

    /// A modifier  whose  `value` tracks the enclosed view's origin in `coordinates`
    /// - Parameters:
    ///   - value: a `CGPoint` binding
    ///   - coordinates: a coordinate space
    /// - Returns: a modified view
    public func origin(_ value: Binding<CGPoint>, in coordinates: CoordinateSpaceProtocol = .global) -> some View {
        self.modifier(FrameModifier(coordinates: coordinates) {
            value.wrappedValue = $0.origin
        })
    }
}

