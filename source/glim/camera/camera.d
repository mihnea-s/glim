module glim.camera.camera;

import std.typecons : tuple;

import glim.shapes;
import glim.image;
import glim.math;
import glim.world;

/// Camera
class Camera
{
  private Vec3 _position;
  private RGBABuffer _buffer;
  private ulong _samplesPerPx;
  private uint _maxBounces;

  private immutable Vec3 _topLeft;
  private immutable Vec3 _horizontal;
  private immutable Vec3 _vertical;

  ///
  this(Vec3 position, ulong width, ulong height, double fov, ulong samplesPerPx, uint maxBounces) @safe nothrow
  {
    _position = position;
    _buffer = RGBABuffer.fromWH(width, height);
    _samplesPerPx = samplesPerPx;
    _maxBounces = maxBounces;

    immutable h = width / fov;
    immutable v = height / fov;

    _topLeft = Vec3(-h / 2.0, v / 2.0, -1.0);
    _horizontal = Vec3(h, 0.0, 0.0);
    _vertical = Vec3(0.0, v, 0.0);
  }

  private auto rayOf(double u, double v)
  {
    immutable offset = _position + _topLeft + (_horizontal * u) - (_vertical * v);
    return Ray(_position, offset.normalized);
  }

  private RGBA colorOf(const World world, const ref Ray ray, uint depth = 0)
  {
    if (depth > _maxBounces)
    {
      return RGBA.black;
    }

    auto hit = Hit.init;
    if (world.raycast(ray, 0, double.infinity, hit))
    {
      immutable next = hit.position + hit.normal + Vec3.random().normalized;
      immutable nextRay = Ray(hit.position, next);

      return RGBA.black.lerp(colorOf(world, nextRay, depth + 1), 0.5);
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
        ulong r = 0, g = 0, b = 0, a = 0;

        foreach (i; 0 .. _samplesPerPx)
        {
          import std.random : uniform;

          auto u = (col + uniform(0.0, 1.0)) / (_buffer.width - 1.0);
          auto v = (row + uniform(0.0, 1.0)) / (_buffer.height - 1.0);

          immutable ray = this.rayOf(u, v);
          immutable color = this.colorOf(world, ray);

          r += color.red;
          g += color.green;
          b += color.blue;
          a += color.alpha;
        }

        _buffer[row, col] = RGBA( //
            cast(ubyte)(r / _samplesPerPx), //
            cast(ubyte)(g / _samplesPerPx), //
            cast(ubyte)(b / _samplesPerPx), //
            cast(ubyte)(a / _samplesPerPx), //
            );
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
