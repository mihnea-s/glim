module glim.rendering.skybox;

import std.math;
import std.conv;
import std.algorithm;

import glim.math.vector;
import glim.image.rgba;
import glim.image.buffer;

/// Represents a skybox for rendering
public interface Skybox
{
    /// Get the skybox color for a normalized vector direction
    @safe public RGBA skyColor(const Vec3) const nothrow;
}

/// Simple solid color skybox
public final class SolidSkybox : Skybox
{
    private const RGBA _color;

    /// Create a new solid skybox with the given color
    public this(const RGBA color)
    {
        this._color = color;
    }

    @safe @nogc public override RGBA skyColor(const Vec3 _) const nothrow
    {
        return _color;
    }
}

/// Three color gradient skybox
public final class GradientSkybox : Skybox
{
    // Treshold at which the horizon starts
    private static immutable double HORIZON_TRESHOLD = -0.075;

    // Gradient buffer between horizon and sky
    private static immutable double HORIZON_BUFFER = 0.0125;

    private const RGBA _sun;
    private const RGBA _horizon;
    private const RGBA _ground;

    /// Create a new gradient skybox with the given colors
    public this(const RGBA sun, const RGBA horizon, const RGBA ground)
    {
        this._sun = sun;
        this._horizon = horizon;
        this._ground = ground;
    }

    @safe @nogc public override RGBA skyColor(const Vec3 direction) const nothrow
    {
        if (direction.y < HORIZON_TRESHOLD)
        {
            const horBlend = max(0.0, direction.y + HORIZON_TRESHOLD.abs + HORIZON_BUFFER);
            return _ground.lerp(_horizon, horBlend / HORIZON_BUFFER);
        }

        return _horizon.lerp(_sun, clamp(direction.y, 0.0, 1.0));
    }
}

/// Simple solid color skybox
public final class CubemapSkybox : Skybox
{
    // Direction of each image in the cubemap
    private static immutable IMAGE_DIRECTIONS = [
        Vec3.up, Vec3.down, Vec3.forward, Vec3.right, Vec3.backward, Vec3.left
    ];

    // Order: above, below, forward, right, backward, left
    private const BufferRGBA[6] _images;

    /// Create a new skybox with the given images
    public this(const BufferRGBA[6] images...)
    {
        this._images = images;
    }

    @safe private Vec2 squishVector(const ref Vec3 axis, const ref Vec3 vec) const nothrow
    {
        import std.exception : assertNotThrown;

        // dfmt off
        return assertNotThrown(axis.predSwitch!"a == b"(
            Vec3.forward, Vec2(vec.x, -vec.y),
            Vec3.backward, -Vec2(vec.x, vec.y),
            Vec3.right, Vec2(vec.z, -vec.y),
            Vec3.left, -Vec2(vec.z, vec.y),
            Vec3.up, Vec2(-vec.x, vec.z),
            Vec3.down, -Vec2(vec.x, vec.z),
            assert(false, "axis vector is invalid")
        ));
        // dfmt on
    }

    @trusted private RGBA sampleImage(ulong index, const ref Vec3 direction) const nothrow
    {
        immutable invLen = 1.0 / direction.dot(IMAGE_DIRECTIONS[index]);
        immutable uv = squishVector(IMAGE_DIRECTIONS[index], direction) * invLen;
        immutable u = cast(ulong)(_images[index].width * clamp((uv.x + 1.0) / 2.0, 0.0, 1.0));
        immutable v = cast(ulong)(_images[index].height * clamp((uv.y + 1.0) / 2.0, 0.0, 1.0));
        return _images[index][u, v];
    }

    @safe public override RGBA skyColor(const Vec3 direction) const nothrow
    {
        static foreach (index, imageDirection; IMAGE_DIRECTIONS)
        {
            if (imageDirection.dot(direction) >= cos(PI / 4))
            {
                return sampleImage(index, direction);
            }
        }

        const index = IMAGE_DIRECTIONS[].map!(dir => direction.dot(dir)).maxIndex();
        return sampleImage(index, direction);
    }
}
