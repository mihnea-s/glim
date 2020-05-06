module glim.shapes.shape;

import std.typecons : Tuple;

import glim.math.ray;

/// All shapes must inherit
/// from this interface
interface Shape
{
  alias Interval = Tuple!(double, "min", double, "max");

  /// Test if the shape is hit by a ray
  bool testRay(const Ray, Interval, out Hit) const @safe nothrow;
}
