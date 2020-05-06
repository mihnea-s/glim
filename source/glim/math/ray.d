module glim.math.ray;

import glim.math.vector;

/// A raycast hit
struct Hit
{
  /// Coordinates of the hit
  Vec3 position;

  /// Surface normal of where the
  /// ray hit
  Vec3 normal;

  /// The point at which the ray
  /// hits
  double t;

  /// Did the ray hit the front
  /// or the back of a face
  bool frontHit;
}

/// A single ray
struct Ray
{
  /// Ray's origin and direction
  Vec3 origin, direction;

  /// Creates a ray starting at the
  /// origin with the given direction
  static Ray originTo(Vec3 dir) @safe nothrow
  {
    return Ray(Vec3.zero, dir);
  }

  /// The ray's position at some
  /// point in time (t)
  auto positionAt(double t) @safe const nothrow
  {
    return origin + direction * t;
  }
}
