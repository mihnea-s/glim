module glim.math.ray;

import glim.math.vector;

/// The refractive index of air
static immutable AIR_REFRACTIVE_INDEX = 1.0;

/// A raycast hit
struct Hit
{
  /// Name of object that was hit
  string name;

  /// Coordinates of the hit
  Vec3 position;

  /// Surface normal of where the
  /// ray hit
  Vec3 normal;

  /// The point at which the ray
  /// hits
  double t;
}

/// A single ray
struct Ray
{
  /// Ray's origin and direction
  Vec3 origin, direction;

  /// The refractive index of the ray's medium
  double refractiveIndex;

  /// Creates a ray starting at the
  /// origin with the given direction
  /// in air
  static Ray originTo(Vec3 dir) @safe nothrow
  {
    return Ray(Vec3.zero, dir, AIR_REFRACTIVE_INDEX);
  }

  /// Create a new ray in the same medium
  auto copyMedium(Vec3 new_origin, Vec3 new_direction) @safe const nothrow
  {
    return Ray(new_origin, new_direction, this.refractiveIndex);
  }

  /// The ray's position at some
  /// point in time (t)
  auto positionAt(double t) @safe const nothrow
  {
    return origin + direction * t;
  }
}
