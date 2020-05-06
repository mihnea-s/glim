module glimmer.camera;

import std.typecons : tuple;

import glimmer.shapes;
import glimmer.image;
import glimmer.math;
import glimmer.world;

/// Camera
class Camera
{
  private Vec3 _position;
  private RGBABuffer _buffer;

  private immutable Vec3 _topLeft;
  private immutable Vec3 _horizontal;
  private immutable Vec3 _vertical;

  ///
  this(Vec3 position, ulong width, ulong height)
  {
    _position = position;
    _buffer = RGBABuffer.fromWH(width, height);

    immutable fov = 2.0 ^^ 10.0;

    immutable h = width / fov;
    immutable v = height / fov;

    _topLeft =    Vec3(-h / 2.0,  v / 2.0,  -1.0);
    _horizontal = Vec3(   h    ,   0.0   ,   0.0);
    _vertical =   Vec3(  0.0   ,    v    ,   0.0);
  }

  private auto rayOf(double u, double v)
  {
    immutable offset = _position + _topLeft + (_horizontal * u) - (_vertical * v);
    return Ray(_position, offset.normalized);
  }

  private auto colorOf(const World world, const ref Ray ray)
  {
    auto hit = Hit.init;
    if (world.raycast(ray, 0, double.infinity, hit))
    {
      immutable N = (hit.normal + Vec3.same(1)) * 0.5;
      return RGBA.doubles(N.x, N.y, N.z, 1.0);
    }

    immutable dir = ray.direction.normalized;
    immutable t = 0.5 * (dir.y + 1.0);

    return RGBA.white().lerp(RGBA.doubles(0.2, 0.4, 0.8, 1.0), t);
  }

  ///
  void render(const World world)
  {

    foreach (ref row; 0 .. _buffer.height)
    {
      foreach (ref col; 0 .. _buffer.width)
      {
        auto u = cast(double)(col) / cast(double)(_buffer.width - 1);
        auto v = cast(double)(row) / cast(double)(_buffer.height - 1);

        immutable ray = this.rayOf(u, v);
        _buffer[row, col] = this.colorOf(world, ray);
      }
    }
  }

  /// 
  auto encodeToArray(BufferEncoder encoder)
  {
    return encoder.encodeToArray(_buffer);
  }

  ///
  auto encodeToFile(BufferEncoder encoder, const string path)
  {
    return encoder.encodeToFile(_buffer, path);
  }

}
