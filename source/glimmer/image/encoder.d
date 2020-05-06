module glimmer.image.encoder;

import glimmer.image.buffer;

/// Interface for RGBABuffer encoders
interface BufferEncoder
{
  /// Encode the buffer into a file at `path`
  void encodeToFile(const ref RGBABuffer buffer, const string path);

  /// Encode the file in memory
  ubyte[] encodeToArray(const ref RGBABuffer buffer);
}
