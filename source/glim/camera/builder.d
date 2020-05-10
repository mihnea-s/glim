module glim.camera.builder;

import glim.math.vector;
import glim.camera.camera;

///
class CameraBuilder
{
  private Vec3 _position;
  private Vec3 _lookAt;

  private double _vfov;

  private ulong _width;
  private ulong _height;

  private uint _samplesPerPixel;
  private uint _maxBounces;
  private uint _numThreads;

  /// Create a new camera builder
  /// with default values:
  ///
  ///  `position`     = `Vec3.zero`
  ///  `width`        = `300`
  ///  `height`       = `200`
  ///  `vfov`         = `60`
  ///  `samplesPerPx` = `1`
  ///  `maxBounces`   = `3`
  ///  `numThreads`   = `1`
  this()
  {
    _position = Vec3.zero;
    _lookAt = Vec3.up;

    _vfov = 60;
    _width = 300;
    _height = 200;

    _samplesPerPixel = 1;
    _maxBounces = 3;
    _numThreads = 1;
  }

  /// Set the camera's position in the world
  CameraBuilder position(Vec3 pos) @safe nothrow
  {
    _position = pos;
    return this;
  }

  /// Set the camera's target
  CameraBuilder lookAt(Vec3 lookAt) @safe nothrow
  {
    _lookAt = lookAt;
    return this;
  }

  /// Set the camera's vertical fov (in degrees)
  CameraBuilder vfov(double vfov) @safe nothrow
  {
    _vfov = vfov;
    return this;
  }

  /// Set the camera's width
  CameraBuilder width(ulong width) @safe nothrow
  {
    _width = width;
    return this;
  }

  /// Set the camera's height
  CameraBuilder height(ulong height) @safe nothrow
  {
    _height = height;
    return this;
  }

  /// Set the camera's samples per pixel
  CameraBuilder samplesPerPx(uint samplesPerPx) @safe nothrow
  {
    _samplesPerPixel = samplesPerPx;
    return this;
  }

  /// Set the max amount of light bounces
  CameraBuilder maxBounces(uint maxBounces) @safe nothrow
  {
    _maxBounces = maxBounces;
    return this;
  }

  /// Set the amount of threads the camera should use
  /// when rendering
  CameraBuilder numThreads(uint numThreads) @safe nothrow
  {
    _numThreads = numThreads;
    return this;
  }

  ///
  Camera build() @safe nothrow const
  {
    return new Camera( //
        _position, //
        _lookAt, //
        _vfov, //

        _width, //
        _height, //

        _samplesPerPixel, //
        _maxBounces, //
        _numThreads, //
        );
  }
}
