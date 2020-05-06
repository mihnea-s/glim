module glim.camera.builder;

import glim.math.vector;
import glim.camera.camera;

///
class CameraBuilder
{
  private Vec3 _position;
  private ulong _width;
  private ulong _height;
  private double _fov;
  private ulong _samplesPerPixel;
  private uint _maxBounces;

  /// Create a new camera builder
  this()
  {
    _position = Vec3.zero;
    _width = 300;
    _height = 200;
    _fov = 2.0 ^^ 10.0;
    _samplesPerPixel = 1;
    _maxBounces = 3;
  }

  /// Set the camera's position in the world
  CameraBuilder position(Vec3 pos) @safe nothrow
  {
    _position = pos;
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

  /// Set the camera's fov
  CameraBuilder fov(ubyte fov) @safe nothrow
  {
    _fov = 2.0 ^^ fov;
    return this;
  }

  /// Set the camera's samples per pixel
  CameraBuilder samplesPerPx(ulong samplesPerPx) @safe nothrow
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

  ///
  Camera build() @safe nothrow const
  {
    return new Camera( //
        _position, //
        _width, //
        _height, //
        _fov, //
        _samplesPerPixel, //
        _maxBounces, //
        );
  }
}
