module glim.rendering.raytracer;

import std.math;
import std.range;
import std.typecons;
import std.parallelism;

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
    private immutable uint _samplesPerPx;
    private immutable uint _maxBounces;
    private immutable uint _numThreads;
    private immutable double _gammaCorrection;

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

        /// Gamma correction
        double gammaCorrection = 0.5;
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
        this._gammaCorrection = params.gammaCorrection;

        // Construct buffer
        this._buffer = new BufferRGBA(_camera.width, _camera.height);
    }

    @safe private auto computeDof() const
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

    @safe private auto computeRay(double u, double v) const
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

    @trusted private Nullable!Collision raycast(const Ray ray, Interval interval) const
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

    @trusted private RGBA sampleRay(const ref Ray ray, uint depth = 0) const
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

    @safe private RGBA sampleRowColumn(ulong row, ulong column) const
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

        immutable scale = 1.0 / _samplesPerPx;

        // dfmt off
        return RGBA(
            pow(scale * r, _gammaCorrection),
            pow(scale * g, _gammaCorrection),
            pow(scale * b, _gammaCorrection),
            pow(scale * a, _gammaCorrection),
        );
    }

    /// TODO
    void renderMultiThreaded()
    {
        auto taskPool = new TaskPool(_numThreads);

        foreach (row; taskPool.parallel(iota(_buffer.height)))
        {
            foreach (column; 0 .. _buffer.width)
            {
                _buffer[row, column] = sampleRowColumn(row, column);
            }
        }
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
