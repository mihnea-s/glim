module glim.image.buffer;

import glim.image.rgba;

class RGBABuffer
{
  private RGBA[] _data;
  private ulong _width, _height;

  /// Create a buffer with the given width and height
  this(ulong width, ulong height) @safe nothrow
  {
    _data = new RGBA[width * height];
    _width = width;
    _height = height;
  }

  /// The raw data of the buffer
  @property ref auto data() const @safe nothrow
  {
    return _data;
  }

  /// Width of the buffer
  @property auto width() const @safe nothrow
  {
    return _width;
  }

  /// Height of the buffer
  @property auto height() const @safe nothrow
  {
    return _height;
  }

  /// Get color in buffer by index
  ref auto opIndex(ulong index)
  {
    return data[index];
  }

  /// Get color in buffer by row and column
  ref auto opIndex(ulong row, ulong col)
  {
    assert(row < _height && col < _width);
    return _data[row * _width + col];
  }
}
