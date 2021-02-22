module glim.image.png;

import std.file;
import std.outbuffer;
import std.bitmanip;
import std.zlib;

import glim.image.rgba;
import glim.image.buffer;
import glim.image.encoder;

/// Encoder for PNG files
class PNGEncoder : BufferEncoder!RGBA
{
  static private immutable ubyte[] HEADER = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
  ];

  static private immutable ubyte BITDEPTH = 8;
  static private immutable ubyte COLORTYPE = 6;
  static private immutable ubyte CHANNELS = 4;

  private void encodeChunk(W)(const ref ubyte[] chunk, W writer)
  {
    // Chunk header length in bytes
    immutable chunkHeaderLength = 4;

    auto chunkLength = nativeToBigEndian(cast(uint) chunk.length - chunkHeaderLength);
    writer.write(chunkLength);

    // Write the actual chunk
    writer.write(chunk);

    auto chunkCheckum = nativeToBigEndian(crc32(0, chunk));
    writer.write(chunkCheckum);
  }

  private void encodeHeader(W)(const BufferRGBA buffer, W writer)
  {
    auto headerBytes = new ubyte[17];
    headerBytes[0 .. 4] = cast(ubyte[]) "IHDR";
    headerBytes[4 .. 8] = nativeToBigEndian(cast(uint) buffer.width);
    headerBytes[8 .. 12] = nativeToBigEndian(cast(uint) buffer.height);
    headerBytes[12] = BITDEPTH;
    headerBytes[13] = COLORTYPE;
    headerBytes[14 .. 16] = [0x0, 0x0];
    headerBytes[16] = 0x0;
    encodeChunk(headerBytes, writer);
  }

  private void encodeFooter(W)(W writer)
  {
    immutable footerBytes = cast(immutable(ubyte[])) "IEND";
    encodeChunk(footerBytes, writer);
  }

  private ubyte[] filterScanlines(const BufferRGBA buf, const RGBA[] scanline1,
      const RGBA[] scanline2)
  {
    // TODO
    auto filtered = new ubyte[1 + scanline2.length * CHANNELS];
    filtered[0] = 0x0;

    uint index = 1;

    foreach (ref value; scanline2)
    {
      filtered[index + 0] = cast(ubyte)(value.red * ubyte.max);
      filtered[index + 1] = cast(ubyte)(value.green * ubyte.max);
      filtered[index + 2] = cast(ubyte)(value.blue * ubyte.max);
      filtered[index + 3] = cast(ubyte)(value.alpha * ubyte.max);
      index += 4;
    }

    return filtered;
  }

  private void encodeToWriter(W)(const BufferRGBA buffer, W writer)
  {
    writer.write(HEADER);
    encodeHeader(buffer, writer);

    // buffer for the image data
    ubyte[] imageData;

    foreach (row; 0 .. buffer.height)
    {
      // First row
      const firstScanline = (row == 0) //
       ? new RGBA[buffer.width] //
       : buffer.data[(row - 1) * buffer.width .. row * buffer.width] //
      ;

      // Second row
      const secondScanline = buffer.data[row * buffer.width .. (row + 1) * buffer.width];

      // Filter rows and append them to buffer
      imageData ~= filterScanlines(buffer, firstScanline, secondScanline);
    }

    ubyte[] chunkData;
    chunkData ~= cast(ubyte[]) "IDAT";
    chunkData ~= cast(ubyte[]) compress(cast(void[]) imageData);
    encodeChunk(chunkData, writer);

    encodeFooter(writer);
  }

  /// Encode the buffer to `path`
  override void encodeToFile(const BufferRGBA buffer, const string path)
  {
    std.file.write(path, encodeToArray(buffer));
  }

  /// Encode the buffer to bytes
  override ubyte[] encodeToArray(const BufferRGBA buffer)
  {
    auto buf = new OutBuffer;
    encodeToWriter(buffer, buf);
    return buf.toBytes();
  }
}
