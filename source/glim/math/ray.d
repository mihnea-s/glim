module glim.math.ray;

import std.math;

import glim.math.vector;

/// An interval
struct Interval
{
    /// Bounds of interval
    double min, max;

    /// The length of the interval
    @safe @nogc auto length() const nothrow
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
    @safe @nogc static Ray originTo(Vec3 dir) pure nothrow
    {
        return Ray(Vec3.zero, dir);
    }

    /// The ray's position at some
    /// point in time (t)
    @safe @nogc auto positionAt(double t) const pure nothrow
    {
        return origin + direction * t;
    }
}
