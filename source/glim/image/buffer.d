module glim.image.buffer;

import std.algorithm.mutation;

import glim.image.rgba;

/// 
alias BufferRGBA = Buffer2D!RGBA;

/// Storage class for an image templated using
/// the pixel type.
public class Buffer2D(Px)
{
    private Px[] _data;
    private ulong _width, _height;

    /// Create a buffer with the given width and height
    @safe this(ulong width, ulong height) nothrow
    {
        _data = new Px[width * height];
        _width = width;
        _height = height;
    }

    /// The raw data of the buffer
    @safe @nogc @property ref auto data() const pure nothrow
    {
        return _data;
    }

    /// Width of the buffer
    @safe @nogc @property auto width() const pure nothrow
    {
        return _width;
    }

    /// Height of the buffer
    @safe @nogc @property auto height() const pure nothrow
    {
        return _height;
    }

    /// Fill the whole buffer with one value.
    @safe @nogc public void fill(const Px filler) nothrow
    {
        _data.fill(filler);
    }

    /// Get color in buffer by index
    @nogc ref auto opIndex(ulong index) nothrow
    {
        return _data[index];
    }

    /// Get color in buffer by index
    @nogc auto opIndex(ulong index) const nothrow
    {
        return _data[index];
    }

    /// Get color in buffer by row and column
    @nogc ref auto opIndex(ulong row, ulong column) nothrow
    {
        assert(row < _height && column < _width);
        return _data[row * _width + column];
    }

    /// Get color in buffer by row and column
    @nogc auto opIndex(ulong row, ulong column) const nothrow
    {
        assert(row < _height && column < _width);
        return _data[row * _width + column];
    }
}
