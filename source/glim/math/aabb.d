module glim.math.aabb;

import glim.math.ray;
import glim.math.vector;

/// Axis-Aligned Bounding Box
struct AABB
{
    /// Bounds of AABB
    Vec3 begin, end;

    private bool computeInverval(string component)(const ref Ray ray, out Interval interval) @safe const nothrow
    {
        import std.algorithm : min, max;
        import std.algorithm.mutation : swap;

        immutable invD = 1.0f / mixin("ray.direction." ~ component);

        auto t0 = (mixin("begin." ~ component) - mixin("ray.origin." ~ component)) * invD;
        auto t1 = (mixin("end." ~ component) - mixin("ray.origin." ~ component)) * invD;

        if (invD < 0.0f)
        {
            swap(t0, t1);
        }

        interval.min = min(t0, interval.min);
        interval.max = max(t1, interval.max);

        if (interval.min >= interval.max)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    /// Check if a ray overlaps the AABB
    public bool overlaps(const ref Ray ray, Interval interval) @safe const nothrow
    {
        static foreach (component; ["x", "y", "z"])
        {
            if (!computeInverval!component(ray, interval))
            {
                return false;
            }
        }

        return true;
    }

    /// Operations between two vectors
    auto opBinary(string op)(const AABB rhs) const
    {
        import std.algorithm : max, min;

        static if (op != "+")
        {
            assert(false, "unimplemented operator " ~ op ~ " for aabb");

        }

        immutable begin = Vec3( //
                min(this.begin.x, rhs.begin.x), //
                min(this.begin.y, rhs.begin.y), //
                min(this.begin.z, rhs.begin.z) //
                );

        immutable end = Vec3( //
                min(this.end.x, rhs.end.x), //
                min(this.end.y, rhs.end.y), //
                min(this.end.z, rhs.end.z) //
                );

        return AABB(begin, end);
    }
}
