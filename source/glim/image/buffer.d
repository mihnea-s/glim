module glim.image.buffer;

import glim.image.rgba;

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
  ref auto opIndex(ulong index)
  {
    return data[index];
  }

  /// Get color in buffer by row and column
  ref auto opIndex(ulong row, ulong col)
  {
    assert(row < height && col < width);
    return data[row * width + col];
  }
}
