module glim.materials.lambertian;

import glim.math;
import glim.image;

import glim.materials.material;

/// TODO
class Lambertian : Material
{
    private RGBA _albedo;

    /// TODO
    public this(RGBA albedo)
    {
        _albedo = albedo;
    }

    /// Scatter the ray.
    @safe override bool scatterRay(const ref Ray ray, const ref Hit hit, out RGBA atten,
            out Ray bounce) const
    {
        // Random vector along unit sphere surface
        auto target = Vec3.random();

        // Reverse vector if it isn't in the same
        // hemisphere as the normal
        if (hit.normal.dot(target) < 0)
        {
            target = -target;
        }

        bounce = Ray(hit.position, target);
        atten = _albedo;

        return true;
    }
}
