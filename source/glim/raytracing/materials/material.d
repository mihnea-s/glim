module glim.raytracing.materials.material;

import glim.image;
import glim.math;

/// Abstract interface for materials
interface Material
{
    /// Scatter the ray.
    @safe bool scatterRay(const ref Ray, const ref Hit, out RGBA, out Ray) const;
}
