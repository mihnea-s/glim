module glim.materials.glass;

import glim.math;
import glim.image;

import glim.materials.material;

///
class Glass : Material
{
  private RGBA _albedo;
  private double _refractiveIndex;

  ///
  this(RGBA albedo, double refractiveIndex)
  {
    _albedo = albedo;
    _refractiveIndex = refractiveIndex;
  }

  static private auto schlick(double cosine, double etaQuot)
  {
    import std.math : pow;

    auto r0 = pow((1 - etaQuot) / (1 + etaQuot), 2);
    return r0 + (1 - r0) * pow((1 - cosine), 5);
  }

  override bool scatter(const ref Ray ray, const ref Hit hit, out RGBA atten, out Ray bounce) const @safe
  {
    import std.math : sqrt, pow;
    import std.algorithm.comparison : min;
    import std.random : uniform;

    atten = _albedo;

    immutable frontHit = ray.direction.dot(hit.normal) <= 0;

    immutable etaQuot = frontHit //
     ? 1.0 / _refractiveIndex //
     : _refractiveIndex //
    ;

    immutable dirNorm = ray.direction.normalized;
    immutable rayFacingNorm = frontHit ? hit.normal : -hit.normal;

    immutable cosTheta = min(1.0, rayFacingNorm.dot(-dirNorm));
    immutable sinTheta = sqrt(1.0 - pow(cosTheta, 2));

    immutable shouldReflect = etaQuot * sinTheta > 1.0 //
     || uniform(0.0, 1.0) < schlick(cosTheta, etaQuot) //
    ;

    if (shouldReflect)
    {
      immutable refl = dirNorm.reflect(rayFacingNorm);
      bounce = Ray(hit.position, refl);
    }
    else
    {
      immutable refr = dirNorm.refract(rayFacingNorm, etaQuot);
      bounce = Ray(hit.position, refr);
    }

    return true;
  }
}
