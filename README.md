# Geometry
A repository of common geometric algorithms, `SwiftUI` and `CoreGraphics` type extensions.

## Algorithms
At present, the package contains no algorithms.

##  `SwiftUI` Extensions
Geometry defines a `FrameReader` extension used to more easily gather geometry
from a SwiftUI view hierarchy.

## `CoreGraphics` Extensions
GCGVectorExt defines `CGVectorType` a protocol unifying the various 2D CoreGraphics
types including `CGPoint`, `CGSize`, and `CGVector`. The type provides support for
easy conversion among types.

The type also allows for a concise definition of standard operators for addition, 
subtraction, multiplication, and division involving `CGVectorType` types.

CGPathExt defines a function used to round corners on CGPaths. The function
understands disjoint subpaths and offers several rounding styles including
a `.strict` style which rounds to proper arcs, a `.natural` style which draws
visually pleasant roundings, and an artistic `.freehand` style.

```swift
let star = CGPath.star(corners: 5, innerRadius: 50, outerRadius: 100)
let rounded = star.rounded(10, style: .default) // default = .natural rounding
```

Finally, CGRectExt includes several extensions to `CGRect`:

```swift
// fetch point at min X, mid Y
let midLeft = rect.at(.min, .mid)

// fetch the midpoint
let bottomRight = rect.at(.max, .max)
```
