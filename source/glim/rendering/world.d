module glim.rendering.world;

import glim.math;
import glim.shapes;
import glim.materials;
import glim.image;

class World
{
  private struct WorldObject
  {
    Shape shape;
    Material material;
  }

  private WorldObject[string] _objects;

  /// Create a new world
  this()
  {
  }

  bool raycast(const Ray ray, double min, double max, out Hit hit) const
  {

    auto tempHit = Hit.init;
    auto closest = max;
    auto hasHit = false;

    foreach (name, obj; _objects)
    {
      if (obj.shape.testRay(ray, Shape.Interval(min, closest), tempHit))
      {
        hit = tempHit;
        hit.name = name;

        hasHit = true;
        closest = tempHit.t;
      }
    }

    return hasHit;
  }

  bool scatter(const ref Ray ray, const ref Hit hit, out RGBA atten, out Ray scattered) const
  {
    if (hit.name !in _objects)
    {
      return false;
    }

    return _objects[hit.name].material.scatterRay(ray, hit, atten, scattered);
  }

  auto opIndexAssign(Shape shape, const string name)
  {
    if (name !in _objects)
    {
      _objects[name] = WorldObject();
    }

    return _objects[name].shape = shape;
  }

  auto opIndexAssign(Material material, const string name)
  {
    if (name !in _objects)
    {
      _objects[name] = WorldObject();
    }

    return _objects[name].material = material;
  }
}
