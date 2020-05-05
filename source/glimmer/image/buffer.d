module glimmer.image.buffer;

import glimmer.image.rgba;

///
struct RGBABuffer
{
  /// The raw data of the buffer
  RGBA[] data;

  /// Width and height of the buffer
  ulong width, height;

  /// Create a buffer with the given width and height
  static RGBABuffer fromWH(ulong width, ulong height) @safe nothrow
  {
    return RGBABuffer(new RGBA[width * height], width, height);
  }

  /// Get color in buffer by index
  ref auto opIndex(size_t index)
  {
    return data[index];
  }

  /// Get color in buffer by row and column
  ref auto opIndex(size_t row, size_t col)
  {
    assert(row < height && col < width);
    return data[row * width + col];
  }
}
