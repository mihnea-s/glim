module glimmer.world;

import glimmer.math;
import glimmer.shapes;

///
class World
{
  private Shape[string] _shapes;

  /// Create a new world
  this()
  {
  }

  ///
  bool raycast(const Ray ray, double min, double max, out Hit hit) const
  {

    auto tempHit = Hit.init;
    bool hitAnything = false;
    auto closest = max;

    foreach (shape; _shapes)
    {
      if (shape.testRay(ray, Shape.Interval(min, closest), tempHit))
      {
        hitAnything = true;
        closest = tempHit.t;
        hit = tempHit;
      }
    }

    return hitAnything;
  }

  ///
  ref auto opIndex(string name)
  {
    if (name in _shapes)
    {
      return _shapes[name];
    }

    return null;
  }

  ///
  auto opIndexAssign(Shape shape, const string name)
  {
    return _shapes[name] = shape;
  }
}
