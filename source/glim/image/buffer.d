module glim.image.buffer;

import std.algorithm.mutation;

import glim.image.rgba;

/// 
alias BufferRGBA = Buffer2D!RGBA;

/// Storage class for an image templated using
/// the pixel type.
public class Buffer2D(Px)
{
  private Px[] _data;
  private ulong _width, _height;

  /// Create a buffer with the given width and height
  public this(ulong width, ulong height) @safe nothrow
  {
    _data = new Px[width * height];
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

  /// Fill the whole buffer with one value.
  public void fill(const Px filler) @safe nothrow
  {
    _data.fill(filler);
  }

  /// Get color in buffer by index
  ref auto opIndex(ulong index)
  {
    return _data[index];
  }

  /// Get color in buffer by row and column
  ref auto opIndex(ulong row, ulong column)
  {
    assert(row < _height && column < _width);
    return _data[row * _width + column];
  }
}
