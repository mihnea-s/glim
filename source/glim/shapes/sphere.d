module glim.shapes.sphere;

import std.math : pow;
import std.typecons;

import glim.math.ray;
import glim.math.vector;
import glim.math.aabb;
import glim.shapes.shape;

/// A simple sphere
class Sphere : Shape
{
    private Vec3 _center;
    private double _radius;

    /// Unit sphere
    @safe @nogc this() nothrow
    {
        _center = Vec3.zero;
        _radius = 1.0;
    }

    /// Create a sphere situated at `center`
    /// with radius `radius`
    @safe @nogc this(Vec3 center, double radius) nothrow
    {
        _center = center;
        _radius = radius;
    }

    /// Test sphere hit
    @safe override Nullable!Hit testRay(const Ray ray, const Interval interval) const nothrow
    {
        import std.math : sqrt;

        // t*t*dot(Dir, Dir) + t*dot(Dir, O - C) + dot(O - C, O - C) - R*R = 0
        immutable a = pow(ray.direction.length, 2);
        immutable b = ray.direction.dot(ray.origin - _center);
        immutable c = pow((ray.origin - _center).length, 2) - pow(_radius, 2);

        immutable discriminant = pow(b, 2) - a * c;

        if (discriminant < 0)
        {
            return Nullable!Hit.init;
        }

        auto hit = Hit.init;
        hit.t = (-b - sqrt(discriminant)) / a;

        if (interval.min < hit.t && hit.t < interval.max)
        {
            hit.position = ray.positionAt(hit.t);
            hit.normal = (hit.position - _center).normalized;
            return hit.nullable;
        }

        if (discriminant == 0)
        {
            return Nullable!Hit.init;
        }

        hit.t = (-b + sqrt(discriminant)) / a;

        if (interval.min < hit.t && hit.t < interval.max)
        {
            hit.position = ray.positionAt(hit.t);
            hit.normal = (hit.position - _center).normalized;
            return hit.nullable;
        }

        return Nullable!Hit.init;
    }

    /// Make bounding box for Sphere
    @safe @nogc override final Nullable!AABB makeAABB() const nothrow
    {
        return AABB(_center - Vec3.same(_radius), _center + Vec3.same(_radius)).nullable;
    }
}
