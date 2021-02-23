module glim.image.encoder;

import glim.image.buffer;

/// Interface for RGBABuffer encoders
interface BufferEncoder(Px)
{
    /// Encode the buffer into a file at `path`
    void encodeToFile(const Buffer2D!Px buffer, const string path);

    /// Encode the file in memory
    ubyte[] encodeToArray(const Buffer2D!Px buffer);
}
