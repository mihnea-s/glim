module glimmer.math.ray;

import glimmer.math.vector;

/// A single ray
struct Ray
{
  /// Ray's origin and direction
  Vec3 origin, direction;

  /// Creates a ray starting at the
  /// origin with the given direction
  static Ray originTo(Vec3 dir) @safe nothrow
  {
    return Ray(Vec3.zero(), dir);
  }

  /// The ray's position at some
  /// point in time (t)
  auto positionAt(double t) @safe const nothrow
  {
    return origin + direction * t;
  }
}
