module glimmer.image.jpeg;

import glimmer.image.buffer;
import glimmer.image.encoder;

/// Encoder for JPEG files
class JPEGEncoder : BufferEncoder
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
