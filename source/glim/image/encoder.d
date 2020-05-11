module glim.image.encoder;

import glim.image.buffer;

/// Interface for RGBABuffer encoders
interface BufferEncoder
{
  /// Encode the buffer into a file at `path`
  void encodeToFile(const RGBABuffer buffer, const string path);

  /// Encode the file in memory
  ubyte[] encodeToArray(const RGBABuffer buffer);
}
