module glim.shapes.metaball;

import std.typecons;

import glim.math.ray;
import glim.math.vector;
import glim.math.aabb;
import glim.shapes.shape;

/// A metaball
struct Metaball
{
    /// Metaball position
    Vec3 position;

    /// Radius
    double radius;

    /// Smoothness level 
    ubyte smoothness;
}

/// Container for metaballs
class Metavolume : Shape
{
    private double _treshold;
    private Metaball[] _metaballs;

    /// Contstruct a metavolume containing metaballs
    this(double treshold, Metaball[] metaballs...)
    {
        _treshold = treshold;
        _metaballs ~= metaballs;
    }

    private double densityAtPoint(const Vec3 point) const @safe nothrow
    {
        import std.math : sqrt, pow;

        double sum = 0.0;

        foreach (metaball; _metaballs)
        {
            immutable q = pow((point - metaball.position).length, 2.0) / metaball.radius;
            sum += pow(1 - q, metaball.smoothness);
        }

        return sum - _treshold;
    }

    /// Test sphere hit
    override final Nullable!Hit testRay(const Ray ray, Interval interval) const @safe nothrow
    {
        import std.math : abs;

        const I = 50; // num iteratrions
        const U = 0.1; // offset

        auto hit = Hit.init;

        for (auto t = interval.min; t < I * U + t && t < interval.max; t += U)
        {
            if (densityAtPoint(ray.positionAt(t)).abs < 0.001)
            {
                hit.position = ray.positionAt(t);
                hit.normal = -ray.direction;
                return hit.nullable;
            }
        }

        return Nullable!Hit.init;
    }

    /// Make bounding box for Metavolume
    override final Nullable!AABB makeAABB() const @safe nothrow
    {
        return Nullable!AABB.init;
    }
}
