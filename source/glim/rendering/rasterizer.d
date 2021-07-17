module glim.rendering.rasterizer;

import std.math;
import std.range;
import std.algorithm;
import std.algorithm.mutation;

import glim.image;
import glim.materials.material;
import glim.math.vector;
import glim.math.matrix;
import glim.rendering.camera;

// Depth / Z buffer type
private alias BufferDepth = Buffer2D!float;

/// Object to rasterize
public struct Rasterized
{
    /// Faces of the object
    public Vec3[3][] faces;

    /// Position, scale and rotation
    public Vec3[3] transform;

    /// Material of the object
    public Material material;
}

/// How to rasterize the objects
public enum RasterMode
{
    Triangles,
    Lines,
}

/// TODO
public class Rasterizer
{
    // Data used in render
    private const Camera _camera;
    private const Rasterized[] _world;
    private immutable Mat4 _projView;
    private immutable RasterMode _mode;

    // Render buffers
    private BufferRGBA _buffer;
    private BufferDepth _depth;

    /// Parameters to start up the rasterizer
    public static struct Params
    {
        /// How to rasterize the objects
        public RasterMode mode;
    }

    /// Create a new rasterizer.
    @safe public this(const Camera camera, const Rasterized[] world, const ref Params params) nothrow
    {
        this._camera = camera;
        this._world = world;

        // Settings
        this._projView = _camera.projection * _camera.view;
        this._mode = params.mode;

        // Construct buffers
        this._buffer = new BufferRGBA(_camera.width, _camera.height);
        this._depth = new BufferDepth(_camera.width, _camera.height);
    }

    /// Getter for the render buffer of the rasterizer
    @property @safe @nogc auto buffer() const pure nothrow
    {
        return _buffer;
    }

    /// Getter for the depth buffer of the rasterizer
    @property @safe @nogc auto depthBuffer() const pure nothrow
    {
        return _depth;
    }

    // Paint a pixel using the z-buffer for depth testing
    @trusted @nogc private void paint(Vec2u pos, const RGBA color, double z) nothrow
    {
        immutable row = pos.y, col = pos.x;

        if (_depth[row, col] < z)
        {
            _buffer[row, col] = color;
            _depth[row, col] = z;
        }
    }

    // Shader for edge painting, first argument is lerp between
    // vertices, second argument is the z-depth value
    alias EdgeShader = @safe RGBA delegate(double, double) nothrow;

    /// Line used for drawing
    struct Edge
    {
        /// Vertices positions
        public Vec3[2] xy;

        /// Shader
        public EdgeShader shader;
    }

    // Draw line between two points
    @trusted private void paint(const Edge edge) nothrow
    {
        // Screen space
        auto p1 = screenSpace(edge.xy[0]);
        auto p2 = screenSpace(edge.xy[1]);

        // Z depth
        double z1 = edge.xy[0].z;
        double z2 = edge.xy[1].z;

        // angle of line between [pi/4, 3pi/4] or [5pi/4, 7pi/4]
        immutable dx = (p2.x * 1. - p1.x).abs;
        immutable dy = (p2.y * 1. - p1.y).abs;
        immutable steep = dx < dy;
        immutable swapped = p1.x > p2.x;

        // draw line horizontally in the y direction
        if (steep)
        {
            p1 = p1.reverse();
            p2 = p2.reverse();
        }

        // draw from left to right
        if (swapped)
        {
            swap(p1, p2);
            swap(z1, z2);
        }

        // floating point vectors
        immutable p1f = Vec2(p1.x, p1.y);
        immutable p2f = Vec2(p2.x, p2.y);

        foreach (col; max(0, p1.x) .. min(p2.x + 1, _camera.width))
        {
            const t = (col - p1f.x) / (p2f.x - p1f.x);

            // Row value on the pixel canvas
            const row = cast(uint) round(p1f.y + (p2f.y - p1f.y) * t);

            if (!(0 <= row && row < _camera.height))
            {
                continue;
            }

            // Z value is lerped between the two vertices
            const zval = z1 * (1 - t) + z2 * t;

            if (!(0 <= zval && zval <= 1))
            {
                continue;
            }

            // Get color using the shader
            const color = edge.shader(swapped ? (1 - t) : t, zval);

            // Position might be transposed if the edge is steep
            const pos = steep ? Vec2u(row, col) : Vec2u(col, row);

            paint(pos, color, zval);
        }
    }

    // Shader for face painting, first argument is lerp between
    // all vertices of the triangle, second argument is the z-depth value
    alias FaceShader = @safe RGBA delegate(Vec3, double) nothrow;

    /// Triangle used for drawing
    struct Face
    {
        /// Vertices positions
        public Vec3[3] xyz;

        /// Face Shader
        public FaceShader shader;
    }

    // Draw a filled triangle
    @trusted private void paint(const Face face) nothrow
    {
        // Screen space
        immutable ss = face.xyz.dup.map!(v => screenSpace(v)).array;

        // Depth values
        immutable zs = Vec3(face.xyz[0].z, face.xyz[1].z, face.xyz[2].z);

        // dfmt off

        immutable boxMin = Vec2u(
            ss.map!`a.x`.minElement.clamp(0, _camera.width),
            ss.map!`a.y`.minElement.clamp(0, _camera.height),
        );

        immutable boxMax = Vec2u(
            ss.map!`a.x`.maxElement.clamp(0, _camera.width),
            ss.map!`a.y`.maxElement.clamp(0, _camera.height),
        );

        // dfmt on

        foreach (col; max(boxMin.x, 0) .. min(boxMax.x, _camera.width))
        {
            foreach (row; max(boxMin.y, 0) .. min(boxMax.y, _camera.height))
            {
                immutable p = barycentric(ss, Vec2i(row, col));

                if (p.x < 0 || p.y < 0 || p.z < 0)
                {
                    continue;
                }

                immutable zval = zs.dot(p);

                if (!(0 <= zval && zval <= 1))
                {
                    continue;
                }

                immutable color = face.shader(p, zval);

                paint(Vec2u(row, col), color, zval);
            }
        }
    }

    @safe @nogc private auto barycentric(const ref Vec2i[] tri, Vec2i p)
    {
        immutable abAcPaX = Vec3(tri[2].x - tri[0].x, tri[1].x - tri[0].x, tri[0].x - p.x);
        immutable abAcPaY = Vec3(tri[2].y - tri[0].y, tri[1].y - tri[0].y, tri[0].y - p.y);

        immutable im = abAcPaX.cross(abAcPaY);

        if (im.z.abs < 1)
        {
            return -Vec3.one;
        }

        return Vec3(1 - (im.x + im.y) / im.z, im.y / im.z, im.x / im.z);
    }

    @safe @nogc private auto mvpSpace(const ref Vec3 vec, const ref Mat4 mvp) nothrow
    {
        immutable local = Vec4(vec.x, vec.y, vec.z, 1);
        return mvp * local;
    }

    @safe @nogc private auto clipSpace(const Vec4 vec) nothrow
    {
        immutable x = (vec.x / vec.w) / 2 + 0.5;
        immutable y = (vec.y / vec.w) / 2 + 0.5;
        immutable z = vec.z / vec.w;
        return Vec3(x, y, z);
    }

    @safe @nogc private auto screenSpace(const Vec3 vec) nothrow
    {
        return Vec2i(cast(int)(_camera.width * vec.x), cast(int)(_camera.height * vec.y));
    }

    @safe private void rasterize(const Vec3[3] face, const ref Mat4 mvp) nothrow
    {
        immutable a = clipSpace(mvpSpace(face[0], mvp));
        immutable b = clipSpace(mvpSpace(face[1], mvp));
        immutable c = clipSpace(mvpSpace(face[2], mvp));

        final switch (_mode) with (RasterMode)
        {
        case Lines:
            paint(Edge([a, b], null));
            paint(Edge([b, c], null));
            paint(Edge([c, a], null));
            break;

        case Triangles:
            paint(Face([a, b, c], null));
            break;
        }
    }

    /// TODO
    @safe public void render() nothrow
    {
        // Fill buffers
        _buffer.fill(_camera.skybox.skyColor(Vec3.zero));
        _depth.fill(-float.infinity);

        // Render out objects
        foreach (ref rastrerized; _world)
        {
            immutable p = rastrerized.transform[0];
            immutable s = rastrerized.transform[1];
            immutable r = rastrerized.transform[2];
            immutable model = Mat4.transform(p, s, r);
            immutable mvp = model * _projView;

            foreach (ref face; rastrerized.faces)
            {
                rasterize(face, mvp);
            }
        }
    }
}
