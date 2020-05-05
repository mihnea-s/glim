module glimmer.shapes.shape;

import glimmer.math.ray;

/// All shapes must inherit
/// from this interface
interface Shape
{
  /// Test if the shape is hit by a ray
  bool isHitBy(const ref Ray) const @safe nothrow;
}
