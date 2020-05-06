module glimmer.image.ppm;

import std.stdio;
import std.outbuffer;

import glimmer.image.rgba;
import glimmer.image.buffer;
import glimmer.image.encoder;

/// Encoder for PPM files
class PPMEncoder : BufferEncoder
{
  private static const HEADER = "P3";

  /// Encode the buffer to `path`
  override void encodeToFile(const ref RGBABuffer buffer, const string path)
  {
    auto f = File(path, "w");

    f.writef("%s\n", HEADER);
    f.writef("%d %d\n", buffer.width, buffer.height);
    f.writef("%d\n", ubyte.max);

    foreach (ref color; buffer.data)
    {
      f.writef("%d %d %d\n", color.red, color.green, color.blue);
    }
  }

  /// Encode the buffer to bytes
  override ubyte[] encodeToArray(const ref RGBABuffer buffer)
  {
    auto buf = new OutBuffer;

    buf.writef("%s\n", HEADER);
    buf.writef("%d %d\n", buffer.width, buffer.height);
    buf.writef("%d\n", ubyte.max);

    foreach (ref color; buffer.data)
    {
      buf.writef("%d %d %d\n", color.red, color.green, color.blue);
    }

    return buf.toBytes();
  }
}
