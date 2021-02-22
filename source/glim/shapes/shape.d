module glim.shapes.shape;

import std.typecons : Nullable;

import glim.math.ray;
import glim.math.aabb;

/// All shapes must inherit
/// from this interface
interface Shape
{
  /// Test if the shape is hit by a ray
  Nullable!Hit testRay(const Ray, Interval) const @safe nothrow;

  /// Create a bounding box holding this shape
  Nullable!AABB makeAABB() const @safe nothrow;
}
