module glim.image.ppm;

import std.stdio;
import std.outbuffer;

import glim.image.rgba;
import glim.image.buffer;
import glim.image.encoder;

/// Encoder for PPM files
class PPMEncoder : BufferEncoder!RGBA
{
  static private immutable HEADER = "P3";

  private void encodeToWriter(W)(const BufferRGBA buffer, W writer)
  {
    writer.writef("%s\n", HEADER);
    writer.writef("%d %d\n", buffer.width, buffer.height);
    writer.writef("%d\n", ubyte.max);

    foreach (ref color; buffer.data)
    {
      immutable red = cast(ubyte)(color.red * ubyte.max);
      immutable green = cast(ubyte)(color.green * ubyte.max);
      immutable blue = cast(ubyte)(color.blue * ubyte.max);

      writer.writef("%d %d %d\n", red, green, blue);
    }
  }

  /// Encode the buffer to `path`
  override void encodeToFile(const BufferRGBA buffer, const string path)
  {
    auto f = File(path, "w");
    encodeToWriter(buffer, f);
  }

  /// Encode the buffer to bytes
  override ubyte[] encodeToArray(const BufferRGBA buffer)
  {
    auto buf = new OutBuffer;
    encodeToWriter(buffer, buf);
    return buf.toBytes();
  }
}
