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
    // t*t*dot(Dir, Dir) + 2*t*dot(Dir, O - C) + dot(O - C, O - C) - R*R = 0
    immutable a = ray.direction.dot(ray.direction);
    immutable b = 2 * ray.direction.dot(ray.origin - _center);
    immutable c = (ray.origin - _center).dot(ray.origin - _center) - pow(_radius, 2);

    immutable discriminant = pow(b, 2) - 4.0 * a * c;
    return discriminant > 0;
  }

  @safe nothrow unittest
  {
    auto unit = new Sphere;
    auto ray = Ray.originTo(Vec3.unit());
    assert(unit.isHitBy(ray));

    auto sphr = new Sphere;
  }
}
