module glim.rendering.raytracer;

import std.concurrency : Tid;
import std.typecons;

import glim.image;
import glim.math;
import glim.shapes;
import glim.materials;

import glim.rendering.camera;

/// TODO: WorldObject documentation
public struct Renderable
{
    /// Shape of the object
    public Shape shape;

    /// Material of the object
    public Material material;
}

/// Raytracer
public class Raytracer
{
    // Minimum distance from camera for a collision to take place
    static private immutable MIN_TRESH = 0.0001;

    // Data used in render
    private const Camera _camera;
    private const Renderable[] _world;
    private const uint _samplesPerPx;
    private const uint _maxBounces;
    private const uint _numThreads;

    // Render buffer
    private BufferRGBA _buffer;

    /// Parameters to start up the raytracer
    public static struct Params
    {
        /// How many samples should be used for
        /// each pixel
        uint samplesPerPx = 100;

        /// Max amount of bounces a ray can
        /// perform
        uint maxBounces = 50;

        /// Number of threads to be used when
        /// rendering
        uint numThreads = 4;
    }

    /// Create a camera from parameters
    public this(const Camera camera, const Renderable[] world, const ref Params params) @safe nothrow
    {
        assert(world !is null, "world to be rendered is null");

        // World data
        this._camera = camera;
        this._world = world;

        // Parameter data
        this._samplesPerPx = params.samplesPerPx;
        this._maxBounces = params.maxBounces;
        this._numThreads = params.numThreads;

        // Construct buffer
        this._buffer = new BufferRGBA(_camera.width, _camera.height);
    }

    private auto computeDof() const @safe
    {
        import std.math : sqrt, pow;
        import std.random : uniform;

        // Calculate a random X
        immutable rX = uniform!"()"(-1.0, 1.0);

        // Calculate a treshold for Y such that
        // X**2 + Y**2 < 1
        immutable tresh = sqrt(1.0 - pow(rX, 2));

        // Calculate Y between tresholds
        immutable rY = uniform!"()"(-tresh, tresh);

        // Calculate offset vector using camera basis vectors
        return _camera.basisI * _camera.lensRadius * rX - _camera.basisJ * _camera.lensRadius * rY;
    }

    private auto computeRay(double u, double v) const @safe
    {
        import std.random : uniform;

        // Depth of field offset
        immutable offset = computeDof();

        // Target vector on virtual film plane
        immutable to = _camera.planeTopLeft //
         + (_camera.planeHorizontal * u) //
         - (_camera.planeVertical * v) //
        ;

        return Ray(_camera.position + offset, (to - offset).normalized);
    }

    // Raycast collision with a Renderable
    private static struct Collision
    {
        Hit hit;
        Material mat;
    }

    private Nullable!Collision raycast(const Ray ray, Interval interval) const @trusted
    {
        auto collision = Nullable!Collision.init;

        foreach (ref obj; _world)
        {
            auto hit = obj.shape.testRay(ray, interval);

            if (!hit.isNull)
            {
                collision = Collision(hit.get, cast(Material) obj.material).nullable;
                interval.max = hit.get.t;
            }
        }

        return collision;
    }

    private RGBA sampleRay(const ref Ray ray, uint depth = 0) const @trusted
    {
        // Max bounce check
        if (depth >= _maxBounces)
        {
            return RGBA.black;
        }

        // Collision information
        const collision = raycast(ray, Interval(MIN_TRESH, double.infinity));

        // Check if we hit anything
        if (!collision.isNull)
        {
            const hit = collision.get.hit;
            const mat = collision.get.mat;

            auto scattered = Ray(Vec3.zero, Vec3.zero);
            auto attenuation = RGBA.white;

            // Scatter the ray according to object material
            if (mat.scatterRay(ray, hit, attenuation, scattered))
            {
                // If the ray scatters, cast the scattered ray
                return sampleRay(scattered, depth + 1).attenuate(attenuation);
            }
            else
            {
                // If the ray is absorbed, return black
                return RGBA.black;
            }
        }

        // Return skybox color if we hit nothing
        return _camera.skybox.skyColor(ray.direction.normalized);
    }

    private RGBA sampleRowColumn(ulong row, ulong column) const @safe
    {
        double r = 0, g = 0, b = 0, a = 0;

        foreach (i; 0 .. _samplesPerPx)
        {
            import std.random : uniform;

            auto u = (column + uniform(0.0, 1.0)) / (_buffer.width - 1.0);
            auto v = (row + uniform(0.0, 1.0)) / (_buffer.height - 1.0);

            immutable ray = computeRay(u, v);
            immutable color = sampleRay(ray);

            r += color.red;
            g += color.green;
            b += color.blue;
            a += color.alpha;
        }

        import std.math : sqrt;

        immutable scale = 1.0 / _samplesPerPx;

        return RGBA( //
                sqrt(scale * r), //
                sqrt(scale * g), //
                sqrt(scale * b), //
                sqrt(scale * a), //
                );
    }

    private static struct MsgRequestNextRow
    {
        immutable uint threadIndex;
    }

    private static struct MsgAcceptNextRow
    {
        immutable ulong row;
    }

    private static struct MsgCalculatedColor
    {
        immutable ulong row, column;
        immutable RGBA value;
    }

    private static struct MsgFinish
    {
    }

    private static void renderWorker(Tid parent, uint index, const typeof(this) raytracer)
    {
        // dfmt off
        import std.concurrency : send, receive;

        // Accept MsgAcceptNextRow, calculate every color in the row
        // then send it back in a MsgCalculatedColor repeat until a MsgFinish
        // is encountered, then exit
        auto finished = false;

        while (!finished)
        {
            send(parent, MsgRequestNextRow(index));

            receive(
                (MsgFinish _) { 
                    finished = true;
                },

                (MsgAcceptNextRow msg) {
                    foreach (column; 0 .. raytracer._buffer.width)
                    {
                        immutable color = raytracer.sampleRowColumn(msg.row, column);
                        send(parent, MsgCalculatedColor(msg.row, column, color));
                    }
                }
            );
        }

        // dfmt on
    }

    /// TODO
    void renderMultiThreaded()
    {
        // dfmt off
        import std.concurrency : spawn, thisTid, send, receive;
        import std.algorithm.comparison : min;

        // Send each tile to renderWorker then MsgFinish to each one
        auto threads = new Tid[_numThreads];

        foreach (i; 0 .. _numThreads)
        {
            threads[i] = spawn(&renderWorker, thisTid, i, cast(immutable(typeof(this))) this);
        }

        ulong finished = 0, row = 0;

        while (finished != _numThreads)
        {
            receive(
                (MsgCalculatedColor msg) {
                    this._buffer[msg.row, msg.column] = msg.value;
                },

                (MsgRequestNextRow req) {
                    auto thread = threads[req.threadIndex];

                    if (row >= _buffer.height)
                    {
                        send(thread, MsgFinish());
                        finished++;
                    }
                    else
                    {
                        send(thread, MsgAcceptNextRow(row));
                        row++;
                    }
                },
            );
        }

        // dfmt on
    }

    /// TODO
    void renderSingleThreaded()
    {
        foreach (ref row; 0 .. _buffer.height)
        {
            foreach (ref column; 0 .. _buffer.width)
            {
                _buffer[row, column] = sampleRowColumn(row, column);
            }
        }
    }

    /// TODO
    auto encodeToArray(BufferEncoder!RGBA encoder)
    {
        return encoder.encodeToArray(_buffer);
    }

    /// TODO
    auto encodeToFile(BufferEncoder!RGBA encoder, const string path)
    {
        return encoder.encodeToFile(_buffer, path);
    }
}
