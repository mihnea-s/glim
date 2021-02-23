module glim.shapes.shape;

import std.typecons : Nullable;

import glim.math.ray;
import glim.math.aabb;

/// All shapes must inherit
/// from this interface
interface Shape
{
    /// Test if the shape is hit by a ray
    @safe Nullable!Hit testRay(const Ray, Interval) const nothrow;

    /// Create a bounding box holding this shape
    @safe Nullable!AABB makeAABB() const nothrow;
}
