module glimmer.camera;

import glimmer.shapes;
import glimmer.image;
import glimmer.math;

/// Camera
class Camera
{
  private Vec3 _position;

  ///
  auto colorOf(const ref Ray ray)
  {
    auto sp = new Sphere(Vec3(3, 0, 0), 1.0);

    if (sp.isHitBy(ray))
    {
      return RGBA.doubles(1.0, 0.0, 0.0, 1.0);
    }

    immutable dir = ray.direction.normalized();
    immutable t = 0.5 * (dir.y + 1.0);

    return RGBA.white().lerp(RGBA.black(), 1.0 - t);
  }
}
