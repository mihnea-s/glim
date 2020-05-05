module glimmer.image.ppm;

import std.stdio;

import glimmer.image.rgba;
import glimmer.image.buffer;
import glimmer.image.encoder;

/// Encoder for PPM files
class PPMEncoder : BufferEncoder
{
  private static const HEADER = "P3";

  /// Encode the buffer to `path`
  void encodeToFile(in RGBABuffer buffer, string path)
  {
    auto f = File(path, "w");

    f.write(HEADER, "\n");
    f.write(buffer.width, " ", buffer.height, "\n");
    f.write(ubyte.max, "\n");

    foreach (RGBA color; buffer.data)
    {
      f.write(color.red, " ", color.green, " ", color.blue, "\n");
    }
  }

  /// Encode the buffer to bytes
  ubyte[] encodeToArray(in RGBABuffer buffer)
  {
    // TODO
    return [];
  }
}
