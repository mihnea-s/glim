module glim.materials.metallic;

import glim.math;
import glim.image;

import glim.materials.material;

class Metallic : Material
{
  private RGBA _albedo;
  private double _fuzziness;

  this(RGBA albedo, float fuzziness)
  {
    _albedo = albedo;
    _fuzziness = fuzziness;
  }

  override bool scatterRay(const ref Ray ray, const ref Hit hit, out RGBA atten, out Ray bounce) const @safe
  {
    immutable refl = ray.direction.reflect(hit.normal);

    bounce = Ray(hit.position, refl + Vec3.random * _fuzziness);
    atten = _albedo;

    return refl.dot(hit.normal) > 0.0;
  }
}
