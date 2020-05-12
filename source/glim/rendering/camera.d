module glim.rendering.camera;

import std.concurrency : Tid;

import glim.shapes;
import glim.image;
import glim.math;

import glim.rendering.world;

/// Camera
class Camera
{
  private immutable Vec3 _position;
  private immutable Vec3 _basisI, _basisJ, _basisK;
  private immutable Vec3 _planeTopLeft, _planeHorizontal, _planeVertical;

  private immutable double _lensRadius;
  private immutable uint _samplesPerPx;
  private immutable uint _maxBounces;
  private immutable uint _numThreads;

  private RGBABuffer _renderBuffer;
  private const(World)* _renderWorld;

  static private immutable MIN_TRESH = 0.0001;

  /// Parameters to construct a camera
  struct Params
  {
    /// Camera position
    Vec3 position = Vec3.zero;

    /// Where the camera should point to
    Vec3 target = Vec3.forward;

    /// The camera's vertical field of vision
    double verticalFov = 30;

    /// Aperture of the camera
    double aperture = 0;

    /// Distance of the focus plane from the
    /// camera
    double focusDistance = 1;

    /// Width and height of the rendered image
    ulong width = 600, height = 300;

    /// How many samples should be used for
    /// each pixel
    uint samplesPerPx = 100;

    /// Max amount of bounces a ray can
    /// perform
    uint maxBounces = 50;

    /// Number of threads to be used when
    /// rendering
    uint numThreads = 4;
  }

  /// Create a camera from parameters
  this(const Params params) @safe nothrow
  {
    import std.math : PI, tan;

    assert(params.aperture >= 0.0, "aperture is negative");
    assert(params.focusDistance > 0.0, "focus distance is negative");
    assert(params.verticalFov > 0, "vfov should be bigger than 0");
    assert(params.width > 0 && params.height > 0, "height & width should be positive");

    _lensRadius = params.aperture / 2.0;
    _samplesPerPx = params.samplesPerPx;
    _maxBounces = params.maxBounces;
    _numThreads = params.numThreads;

    _position = params.position;

    immutable vfov = params.verticalFov / 360.0 * 2.0 * PI;
    immutable aspect = (params.width * 1.0) / params.height;

    // Vertical & horizontal
    immutable v = 2.0 * tan(vfov / 2.0);
    immutable h = aspect * v;

    // Camera orthonormal basis
    _basisK = (params.position - params.target).normalized;
    _basisI = Vec3.up.cross(_basisK).normalized;
    _basisJ = _basisK.cross(_basisI).normalized;

    _planeTopLeft = // top left corner of the virtual plane
      (Vec3.zero //
           - _basisI * (h / 2.0) // half width on the x
           + _basisJ * (v / 2.0) // half height on the y
           - _basisK) * params.focusDistance;

    _planeHorizontal = _basisI * params.focusDistance * h;
    _planeVertical = _basisJ * params.focusDistance * v;

    _renderBuffer = new RGBABuffer(params.width, params.height);
    _renderWorld = null;
  }

  private auto dofOffsetVec() const
  {
    import std.math : sqrt, pow;
    import std.random : uniform;

    // Calculate a random X
    immutable rX = uniform!"()"(-1.0, 1.0);

    // Calculate a treshold for Y such that
    // X**2 + Y**2 < 1
    immutable tresh = sqrt(1.0 - pow(rX, 2));

    // Calculate Y between tresholds
    immutable rY = uniform!"()"(-tresh, tresh);

    // Calculate offset vector using camera basis vectors
    return _basisI * _lensRadius * rX - _basisJ * _lensRadius * rY;
  }

  private auto rayOf(double u, double v) const
  {
    import std.random : uniform;

    // Depth of field offset
    immutable offset = dofOffsetVec();

    // Target vector on virtual film plane
    immutable to = _planeTopLeft + (_planeHorizontal * u) - (_planeVertical * v);

    return Ray(_position + offset, (to - offset).normalized, AIR_REFRACTIVE_INDEX);
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
      auto scattered = ray.copyMedium(Vec3.zero, Vec3.zero);
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
    import std.concurrency : send, receive;

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

  void renderMultiThreaded(const World world)
  {
    import std.concurrency : spawn, thisTid, send, receive;
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

  auto encodeToArray(BufferEncoder encoder)
  {
    return encoder.encodeToArray(_renderBuffer);
  }

  auto encodeToFile(BufferEncoder encoder, const string path)
  {
    return encoder.encodeToFile(_renderBuffer, path);
  }
}
