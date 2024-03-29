module glim.raytracing.materials.metallic;

import glim.math;
import glim.image;

import glim.raytracing.materials.material;

/// TODO
public final class Metallic : Material
{
    private RGBA _albedo;
    private double _fuzziness;

    /// TODO
    @safe @nogc this(RGBA albedo, float fuzziness)
    {
        _albedo = albedo;
        _fuzziness = fuzziness;
    }

    /// TODO
    @safe override bool scatterRay(const ref Ray ray, const ref Hit hit, out RGBA atten,
            out Ray bounce) const
    {
        immutable refl = ray.direction.reflect(hit.normal);

        bounce = Ray(hit.position, refl + Vec3.random * _fuzziness);
        atten = _albedo;

        return refl.dot(hit.normal) > 0.0;
    }
}
