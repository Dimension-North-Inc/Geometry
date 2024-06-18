# Geometry
A repository of common geometric algorithms, `SwiftUI` and `CoreGraphics` type extensions.

## Algorithms
At present, the package contains no algorithms.

##  `SwiftUI` Extensions
Geometry defines a `FrameReader` extension used to more easily gather geometry
from a SwiftUI view hierarchy.

## `CoreGraphics` Extensions
Geometry defines `CGVectorType` a protocol unifying the various 2D CoreGraphics
types including `CGPoint`, `CGSize`, and `CGVector`. The type provides support for
easy conversion among types.

The type also allows for a concise definition of standard operators for addition, 
subtraction, multiplication, and division involving `CGVectorType` types.

Finally, the package includes several extensions to `CGRect`:

```swift
// fetch point at min X, mid Y
let midLeft = rect.at(.min, .mid)

// fetch the midpoint
let bottomRight = rect.at(.max, .max)
```
