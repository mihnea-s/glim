module glimmer.image.png;

import glimmer.image.buffer;
import glimmer.image.encoder;

/// Encoder for PNG files
class PNGEncoder : BufferEncoder
{

  /// Encode to file
  void encodeToFile(in RGBABuffer buffer, string path)
  {
    // TODO
  }

  /// Encode in memory
  ubyte[] encodeToArray(in RGBABuffer buffer)
  {
    // TODO
    return [];
  }
}
