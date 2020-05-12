module glim.materials.material;

import glim.image;
import glim.math;

/// Abstract interface for materials
interface Material
{
  bool scatterRay(const ref Ray, const ref Hit, out RGBA, out Ray) const @safe;
}
