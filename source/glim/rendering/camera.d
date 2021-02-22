module glim.rendering.camera;

import glim.math;

import glim.image.rgba;
import glim.rendering.skybox;

/// Camera
public struct Camera
{
  /// Width and height of the rendered image
  private immutable ulong _width, _height;

  // Position in the world
  private immutable Vec3 _position;

  // Basis vectors
  private immutable Vec3 _basisI, _basisJ, _basisK;

  // Virtual plane
  private immutable Vec3 _planeTopLeft, _planeHorizontal, _planeVertical;

  // Lens radius
  private immutable double _lensRadius;

  // Skybox
  private const Skybox _skybox;

  private static struct Builder
  {
    private ulong _width = 600, _height = 300;
    private Vec3 _position = Vec3.zero;
    private Vec3 _target = Vec3.forward;
    private double _verticalFov = 30;
    private double _aperture = 0;
    private double _focusDistance = 1;
    private Skybox _skybox = new SolidSkybox(RGBA.black);

    public auto extent(ulong width, ulong height)
    {
      _width = width;
      _height = height;
      return this;
    }

    public auto position(Vec3 position)
    {
      _position = position;
      return this;
    }

    public auto target(Vec3 target)
    {
      _target = target;
      return this;
    }

    public auto verticalFov(double verticalFov)
    {
      _verticalFov = verticalFov;
      return this;
    }

    public auto aperture(double aperture)
    {
      _aperture = aperture;
      return this;
    }

    public auto focusDistance(double focusDistance)
    {
      _focusDistance = focusDistance;
      return this;
    }

    public auto skybox(Skybox skybox)
    {
      _skybox = skybox;
      return this;
    }

    public auto build() @safe nothrow
    {
      return Camera(_width, _height, _position, _target, _verticalFov,
          _aperture, _focusDistance, _skybox);
    }
  }

  /// Create a camera from parameters
  private this(ulong width, ulong height, Vec3 position, Vec3 target,
      double verticalFov, double aperture, double focusDistance, const Skybox skybox) @safe nothrow
  {
    import std.math : PI, tan;

    assert(aperture >= 0.0, "aperture is negative");
    assert(focusDistance > 0.0, "focus distance is negative");
    assert(verticalFov > 0, "vfov should be bigger than 0");
    assert(width > 0 && height > 0, "height & width should be positive");

    _width = width;
    _height = height;
    _position = position;
    _lensRadius = aperture / 2.0;

    immutable vfov = verticalFov / 360.0 * 2.0 * PI;
    immutable aspect = (width * 1.0) / height;

    // Vertical & horizontal
    immutable v = 2.0 * tan(vfov / 2.0);
    immutable h = aspect * v;

    // Camera orthonormal basis
    _basisK = (position - target).normalized;
    _basisI = Vec3.up.cross(_basisK).normalized;
    _basisJ = _basisK.cross(_basisI).normalized;

    _planeTopLeft = // top left corner of the virtual plane
      (Vec3.zero //
           - _basisI * (h / 2.0) // half width on the x
           + _basisJ * (v / 2.0) // half height on the y
           - _basisK) * focusDistance;

    _planeHorizontal = _basisI * focusDistance * h;
    _planeVertical = _basisJ * focusDistance * v;
    _skybox = skybox;
  }

  /// Create a new builder for a new camera.
  public static auto builder() @safe nothrow pure
  {
    return Builder();
  }

  /// Getter for camera position.
  public auto position() const @safe @nogc nothrow pure
  {
    return _position;
  }

  /// Getter for camera basis i vector.
  public auto basisI() const @safe @nogc nothrow pure
  {
    return _basisI;
  }

  /// Getter for camera basis j vector.
  public auto basisJ() const @safe @nogc nothrow pure
  {
    return _basisJ;
  }

  /// Getter for camera basis k vector.
  public auto basisK() const @safe @nogc nothrow pure
  {
    return _basisK;
  }

  /// Getter for camera's virtual plane's top left corner.
  public auto planeTopLeft() const @safe @nogc nothrow pure
  {
    return _planeTopLeft;
  }

  /// Getter for camera planeHorizontal.
  public auto planeHorizontal() const @safe @nogc nothrow pure
  {
    return _planeHorizontal;
  }

  /// Getter for camera planeVertical.
  public auto planeVertical() const @safe @nogc nothrow pure
  {
    return _planeVertical;
  }

  /// Getter for camera's len's radius.
  public auto lensRadius() const @safe @nogc nothrow pure
  {
    return _lensRadius;
  }

  /// Getter for the render's width in pixels.
  public auto width() const @safe @nogc nothrow pure
  {
    return _width;
  }

  /// Getter for the render's height in pixels.
  public auto height() const @safe @nogc nothrow pure
  {
    return _height;
  }

  /// Getter for the camera's skybox.
  public auto skybox() const @safe @nogc nothrow pure
  {
    return _skybox;
  }
}
