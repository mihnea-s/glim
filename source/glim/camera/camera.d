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

  static private immutable MIN_TRESH = 0.0001;

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
    // Max bounce check
    if (depth > _maxBounces)
    {
      return RGBA.black;
    }

    // Hit information
    auto hit = Hit.init;

    // Check if we hit anything
    if (world.raycast(ray, MIN_TRESH, double.infinity, hit))
    {
      auto scattered = Ray();
      auto attenuation = RGBA.white;

      // Scatter the ray according to object material
      if (world.scatter(ray, hit, attenuation, scattered))
      {
        // If the ray scatters, cast the scattered ray
        return colorOf(world, scattered).attenuate(attenuation);
      }
      else
      {
        // If the ray is absorbed, return black
        return RGBA.black;
      }
    }

    // Return skybox color if we hit nothing
    immutable dir = ray.direction.normalized;
    immutable t = 0.5 * (dir.y + 1.0);

    return RGBA.white().lerp(RGBA.opaque(0.2, 0.4, 0.8), t);
  }

  ///
  void render(const World world)
  {

    foreach (ref row; 0 .. _buffer.height)
    {
      foreach (ref col; 0 .. _buffer.width)
      {
        double r = 0, g = 0, b = 0, a = 0;

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

        import std.math : sqrt;

        immutable scale = 1.0 / _samplesPerPx;

        _buffer[row, col] = RGBA( //
            sqrt(scale * r), //
            sqrt(scale * g), //
            sqrt(scale * b), //
            sqrt(scale * a), //
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
