module glimmer.image.jpeg;

import glimmer.image.buffer;
import glimmer.image.encoder;

/// Encoder for JPEG files
class JPEGEncoder : BufferEncoder
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
