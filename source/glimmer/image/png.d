module glimmer.image.png;

import glimmer.image.buffer;
import glimmer.image.encoder;

/// Encoder for PNG files
class PNGEncoder : BufferEncoder
{

  /// Encode to file
  override void encodeToFile(const ref RGBABuffer buffer, const string path)
  {
    // TODO
  }

  /// Encode in memory
  override ubyte[] encodeToArray(const ref RGBABuffer buffer)
  {
    // TODO
    return [];
  }
}
