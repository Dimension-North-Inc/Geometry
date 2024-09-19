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
    func frames<ID>(_ value: Binding<[ID: CGRect]>) -> some View where ID: Hashable {
        readFrames { value.wrappedValue = $0 }
    }

    func writeFrame<ID>(id: ID, coordinates: CoordinateSpace) -> some View where ID: Hashable {
        self.modifier(FrameListModifier<ID>.writer(id: id, coordinates: coordinates))
    }

    func readFrames<ID>(onChange: @escaping ([ID: CGRect])-> ()) -> some View where ID: Hashable {
        self.modifier(FrameListModifier<ID>.reader(onChange: onChange))
    }
}
