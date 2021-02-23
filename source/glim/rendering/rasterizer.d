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
    @safe public this(const Camera camera, const ref Params params) nothrow
    {
        this._camera = camera;

        // Construct buffers
        this._buffer = new BufferRGBA(_camera.width, _camera.height);
        this._depth = new BufferDepth(_camera.width, _camera.height);
    }

    /// Getter for the render buffer of the raytracer
    @property @safe @nogc auto buffer() const pure nothrow
    {
        return _buffer;
    }

    // Draw line between two points
    @trusted @nogc private void line(Vec2u p1, Vec2u p2, const RGBA color) nothrow
    {
        immutable steep = (p1.x - p2.x).abs < (p1.y - p2.y).abs;

        if (steep)
        {
            p1 = p1.transpose();
            p2 = p2.transpose();
        }

        if (p1.x > p2.x)
        {
            swap(p1, p2);
        }

        foreach (x; p1.x .. p2.x + 1)
        {
            const t = (x - p1.x * 1.0) / (p2.x - p1.x);
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
    @safe @nogc private void triangle(Vec2u a, Vec2u b, Vec2u c, RGBA color) nothrow
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
    @safe public void render() nothrow
    {
        // Fill buffers
        _buffer.fill(_camera.skybox.skyColor(Vec3.zero));
        _depth.fill(-float.infinity);

        triangle(Vec2u(150, 20), Vec2u(50, 180), Vec2u(250, 180), RGBA.white,);
    }
}
