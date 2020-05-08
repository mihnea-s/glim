module glim.materials.glass;

import glim.math;
import glim.image;

import glim.materials.material;

///
class Glass : Material
{
  private double _refractiveIndex;

  ///
  this(double refractiveIndex)
  {
    _refractiveIndex = refractiveIndex;
  }

  override bool scatter(const ref Ray ray, const ref Hit hit, out RGBA atten, out Ray bounce) const @safe
  {
    import std.math : sqrt, pow;
    import std.algorithm.comparison : min;

    atten = RGBA.white;

    immutable etaQuot = ray.direction.dot(hit.normal) <= 0 //
     ? 1.0 / _refractiveIndex //
     : _refractiveIndex //
    ;

    immutable dirNorm = ray.direction.normalized;
    immutable cosTheta = min(1.0, hit.normal.dot(-dirNorm));
    immutable sinTheta = sqrt(1.0 - pow(cosTheta, 2));

    if (etaQuot * sinTheta > 1.0)
    {
      immutable refl = dirNorm.reflect(hit.normal);
      bounce = Ray(hit.position, refl);
    }
    else
    {
      immutable refr = dirNorm.refract(hit.normal, etaQuot);
      bounce = Ray(hit.position, refr);
    }

    return true;
  }
}
