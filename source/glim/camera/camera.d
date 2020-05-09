module glim.camera.camera;

import std.concurrency : thisTid, Tid, send, receive, receiveOnly;
import std.typecons : tuple, Nullable;

import glim.shapes;
import glim.image;
import glim.math;
import glim.world;

// Messages for message passing concurrency

/// Camera
class Camera
{
  private immutable Vec3 _position;

  private immutable Vec3 _topLeft;
  private immutable Vec3 _horizontal;
  private immutable Vec3 _vertical;

  private immutable uint _samplesPerPx;
  private immutable uint _maxBounces;
  private immutable uint _numThreads;

  private RGBABuffer _renderBuffer;
  private const(World)* _renderWorld;

  static private immutable MIN_TRESH = 0.0001;

  ///
  this(Vec3 position, double vfov, ulong width, ulong height, uint samplesPerPx,
      uint maxBounces, uint numThreads) @safe nothrow
  {
    import std.math : PI, tan;

    assert(width > 0 && height > 0, "height & width should be positive");
    assert(vfov > 0, "vfov should be bigger than 0");

    _position = position;

    _samplesPerPx = samplesPerPx;
    _maxBounces = maxBounces;
    _numThreads = numThreads;

    immutable fovRads = vfov / 360.0 * 2.0 * PI;
    immutable aspect = (width * 1.0) / height;

    // Vertical & horizontal
    immutable v = 2.0 * tan(fovRads / 2.0);
    immutable h = aspect * v;

    _topLeft = Vec3(-h / 2.0, v / 2.0, -1.0);
    _horizontal = Vec3(h, 0.0, 0.0);
    _vertical = Vec3(0.0, v, 0.0);

    _renderBuffer = RGBABuffer.fromWH(width, height);
    _renderWorld = null;
  }

  private auto rayOf(double u, double v) const
  {
    immutable offset = _position + _topLeft + (_horizontal * u) - (_vertical * v);
    return Ray(_position, offset.normalized);
  }

  private RGBA colorOf(const ref Ray ray, uint depth = 0) const
  {
    // Max bounce check
    if (depth >= _maxBounces)
    {
      return RGBA.black;
    }

    // Hit information
    auto hit = Hit.init;

    // Check if we hit anything
    if (_renderWorld.raycast(ray, MIN_TRESH, double.infinity, hit))
    {
      auto scattered = Ray();
      auto attenuation = RGBA.white;

      // Scatter the ray according to object material
      if (_renderWorld.scatter(ray, hit, attenuation, scattered))
      {
        // If the ray scatters, cast the scattered ray
        return colorOf(scattered, depth + 1).attenuate(attenuation);
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

  private struct MsgRequestNextRow
  {
    immutable uint threadIndex;
  }

  private struct MsgAcceptNextRow
  {
    immutable ulong row;
  }

  private struct MsgCalculatedColor
  {
    immutable ulong row, column;
    immutable RGBA value;
  }

  private struct MsgFinish
  {
  }

  static private void renderWorker(Tid parent, uint index, const Camera camera)
  {
    // Accept MsgAcceptNextRow, calculate every color in the row
    // then send it back in a MsgCalculatedColor repeat until a MsgFinish
    // is encountered, then exit
    auto finished = false;

    while (!finished)
    {
      send(parent, MsgRequestNextRow(index));

      receive( //
          (MsgFinish _) { finished = true; }, //
          (MsgAcceptNextRow msg) {
        immutable row = msg.row;

        foreach (col; 0 .. camera._renderBuffer.width)
        {
          double r = 0, g = 0, b = 0, a = 0;

          foreach (i; 0 .. camera._samplesPerPx)
          {
            import std.random : uniform;

            auto u = (col + uniform(0.0, 1.0)) / (camera._renderBuffer.width - 1.0);
            auto v = (row + uniform(0.0, 1.0)) / (camera._renderBuffer.height - 1.0);

            immutable ray = camera.rayOf(u, v);
            immutable color = camera.colorOf(ray);

            r += color.red;
            g += color.green;
            b += color.blue;
            a += color.alpha;
          }

          import std.math : sqrt;

          immutable scale = 1.0 / camera._samplesPerPx;

          immutable color = RGBA( //
            sqrt(scale * r), //
            sqrt(scale * g), //
            sqrt(scale * b), //
            sqrt(scale * a), //
            );

          send(parent, MsgCalculatedColor(row, col, color));
        }

      });
    }
  }

  ///
  void renderMultiThreaded(const World world)
  {
    import std.concurrency : spawn;
    import std.algorithm.comparison : min;

    // Send each tile to renderWorker then MsgFinish to each one

    assert(world !is null, "world to be rendered is null");
    _renderWorld = &world;

    auto threads = new Tid[_numThreads];

    foreach (i; 0 .. _numThreads)
    {
      threads[i] = spawn(&renderWorker, thisTid, i, cast(immutable(Camera)) this);
    }

    ulong finished = 0, row = 0;

    while (finished != _numThreads)
    {
      receive( //
          (MsgCalculatedColor msg) {
        this._renderBuffer[msg.row, msg.column] = msg.value;
      }, //
          (MsgRequestNextRow req) {
        auto thread = threads[req.threadIndex];

        if (row >= _renderBuffer.height)
        {
          send(thread, MsgFinish());
          finished++;
        }
        else
        {
          send(thread, MsgAcceptNextRow(row));
          row++;
        }
      }, //
          );
    }
  }

  ///
  void renderSingleThreaded(const World world)
  {
    _renderWorld = &world;

    foreach (ref row; 0 .. _renderBuffer.height)
    {
      foreach (ref col; 0 .. _renderBuffer.width)
      {
        double r = 0, g = 0, b = 0, a = 0;

        foreach (i; 0 .. _samplesPerPx)
        {
          import std.random : uniform;

          auto u = (col + uniform(0.0, 1.0)) / (_renderBuffer.width - 1.0);
          auto v = (row + uniform(0.0, 1.0)) / (_renderBuffer.height - 1.0);

          immutable ray = this.rayOf(u, v);
          immutable color = this.colorOf(ray);

          r += color.red;
          g += color.green;
          b += color.blue;
          a += color.alpha;
        }

        import std.math : sqrt;

        immutable scale = 1.0 / _samplesPerPx;

        _renderBuffer[row, col] = RGBA( //
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
    return encoder.encodeToArray(_renderBuffer);
  }

  ///
  auto encodeToFile(BufferEncoder encoder, const string path)
  {
    return encoder.encodeToFile(_renderBuffer, path);
  }
}
