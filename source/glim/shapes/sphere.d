module glim.shapes.sphere;

import std.math : pow;

import glim.math.ray;
import glim.math.vector;
import glim.shapes.shape;

/// A simple sphere
class Sphere : Shape
{
  private Vec3 _center;
  private double _radius;

  /// Unit sphere
  this() @safe nothrow
  {
    _center = Vec3.zero;
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
  override bool testRay(const Ray ray, Interval interval, out Hit hit) const @safe nothrow
  {
    import std.math : sqrt;

    // t*t*dot(Dir, Dir) + t*dot(Dir, O - C) + dot(O - C, O - C) - R*R = 0
    immutable a = pow(ray.direction.length, 2);
    immutable b = ray.direction.dot(ray.origin - _center);
    immutable c = pow((ray.origin - _center).length, 2) - pow(_radius, 2);

    immutable discriminant = pow(b, 2) - a * c;

    if (discriminant < 0)
    {
      return false;
    }

    hit.t = (-b - sqrt(discriminant)) / a;

    if (interval.min < hit.t && hit.t < interval.max)
    {
      hit.position = ray.positionAt(hit.t);
      hit.normal = (hit.position - _center).normalized;
      return true;
    }

    if (discriminant == 0)
    {
      return false;
    }

    hit.t = (-b + sqrt(discriminant)) / a;

    if (interval.min < hit.t && hit.t < interval.max)
    {
      hit.position = ray.positionAt(hit.t);
      hit.normal = (hit.position - _center).normalized;
      return true;
    }

    return false;
  }

  @safe nothrow unittest
  {
    auto unit = new Sphere;
    auto ray = Ray.originTo(Vec3.unit);
    assert(unit.isHitBy(ray));
    auto sphr = new Sphere;
  }
}
