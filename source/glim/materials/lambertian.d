module glim.materials.lambertian;

import glim.math;
import glim.image;

import glim.materials.material;

///
class Lambertian : Material
{
  private RGBA _albedo;

  ///
  this(RGBA albedo)
  {
    _albedo = albedo;
  }

  override bool scatter(const ref Ray ray, const ref Hit hit, out RGBA atten, out Ray bounce) const @safe
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
