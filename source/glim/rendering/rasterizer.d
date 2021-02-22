module glim.rendering.rasterizer;

import std.math;
import std.algorithm.mutation;

import glim.image;
import glim.math.vector;
import glim.rendering.camera;

// Depth / Z buffer type
private alias BufferDepth = Buffer2D!float;

/// TODO
public class Rasterizer
{
    // Data used in render
    private const Camera _camera;

    // Render buffers
    private BufferRGBA _buffer;
    private BufferDepth _depth;

    /// Parameters to start up the rasterizer
    public static struct Params
    {
    }

    /// Create a new rasterizer.
    public this(const Camera camera, const ref Params params) @safe nothrow
    {
        this._camera = camera;

        // Construct buffers
        this._buffer = new BufferRGBA(_camera.width, _camera.height);
        this._depth = new BufferDepth(_camera.width, _camera.height);
    }

    // Draw line between two points
    private void line(Vec3 p1, Vec3 p2, RGBA color)
    {
        immutable steep = (p1.x - p2.x).abs < (p1.y - p2.y).abs;

        if (steep)
        {
            swap(p1.x, p1.y);
            swap(p2.x, p2.y);
        }

        if (p1.x > p2.x)
        {
            swap(p1, p2);
        }

        foreach (x; cast(ulong) p1.x .. cast(ulong) p2.x + 1)
        {
            const t = (x - p1.x) / (p2.x - p1.x);
            const y = cast(ulong)(p1.y * (1.0 - t) + p2.y * t);

            if (steep)
            {
                _buffer[x, y] = color;
            }
            else
            {
                _buffer[y, x] = color;
            }
        }
    }

    // Draw a filled triangle
    private void triangle(Vec3 a, Vec3 b, Vec3 c, RGBA color)
    {
        if (a.y > b.y)
            swap(a, b);
        if (a.y > c.y)
            swap(a, c);
        if (b.y > c.y)
            swap(b, c);

        line(a, b, color);
        line(a, c, color);
        line(b, c, color.lerp(RGBA.white, 0.5));
    }

    /// TODO
    public void render() @safe nothrow
    {
        // Fill buffers
        _buffer.fill(_camera.skybox.skyColor(Vec3.zero));
        _depth.fill(-float.infinity);
    }

    /// TODO
    public auto encodeToArray(BufferEncoder!RGBA encoder)
    {
        return encoder.encodeToArray(_buffer);
    }

    /// TODO
    public auto encodeToFile(BufferEncoder!RGBA encoder, const string path)
    {
        return encoder.encodeToFile(_buffer, path);
    }
}
