module glimmer.shapes.sphere;

import std.math : pow;

import glimmer.math.ray;
import glimmer.math.vector;
import glimmer.shapes.shape;

/// A simple sphere
class Sphere : Shape
{
  private Vec3 _center;
  private double _radius;

  /// Unit sphere
  this() @safe nothrow
  {
    _center = Vec3.zero();
    _radius = 1.0;
  }

  /// Create a sphere situated at `center`
  /// with radius `radius`
  this(Vec3 center, double radius) @safe nothrow
  {
    _center = center;
    _radius = radius;
  }

  /// Test sphere hit
  bool isHitBy(const ref Ray ray) const @safe nothrow
  {
    // t*t*dot(B, B) + 2*t*dot(B,A-C) + dot(A-C, A-C) - R*R = 0
    immutable a = ray.direction.dot(ray.direction);
    immutable b = ray.direction.dot(ray.origin - _center);
    immutable c = (ray.origin - _center).dot(ray.origin - _center) - pow(_radius, 2);

    immutable delta = pow(b, 2) - 4.0 * a * c;
    return delta >= 0;
  }

  @safe nothrow unittest
  {
    auto unit = new Sphere;
    auto ray = Ray.originTo(Vec3.unit());
    assert(unit.isHitBy(ray));

    auto sphr = new Sphere;
  }
}
