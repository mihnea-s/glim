module glim.math.ray;

import std.math;

import glim.math.vector;

/// An interval
struct Interval
{
    /// Bounds of interval
    double min, max;

    /// The length of the interval
    auto length() const @safe nothrow
    {
        return (max - min).abs;
    }
}

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
}

/// A single ray
struct Ray
{
    /// Ray's origin and direction
    Vec3 origin, direction;

    /// Creates a ray starting at the
    /// origin with the given direction
    /// in air
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
