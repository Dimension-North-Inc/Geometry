# Geometry
A repository of common geometric algorithms and `CoreGraphics` type extensions.

## Algorithms
At present, the package contains no algorithms.

## `CoreGraphics` Extensions
Geometry defines `CGVectorType` a protocol unifying the various 2D CoreGraphics
types including `CGPoint`, `CGSize`, and `CGVector`. The type provides support for
easy conversion among types.

The type also allows for a concise definition of standard operators for addition, 
subtraction, multiplication, and division involving `CGVectorType` types.

Finally, the package includes several extensions to `CGRect`.
