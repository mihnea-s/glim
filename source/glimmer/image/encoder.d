module glimmer.image.encoder;

import glimmer.image.buffer;

/// Interface for RGBABuffer encoders
interface BufferEncoder
{
  /// Encode the buffer into a file at `path`
  void encodeToFile(in RGBABuffer buffer, string path);

  /// Encode the file in memory
  ubyte[] encodeToArray(in RGBABuffer buffer);
}
