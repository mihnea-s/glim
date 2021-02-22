module glim.rendering.skybox;

import std.math;
import std.algorithm.comparison;

import glim.math.vector;
import glim.image.rgba;

/// Represents a skybox for rendering
public interface Skybox
{
    /// Get the skybox color for a normalized vector direction
    public RGBA skyColor(const Vec3) const @safe nothrow;
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

    public override RGBA skyColor(const Vec3 _) const @safe nothrow
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

    public override RGBA skyColor(const Vec3 direction) const @safe nothrow
    {
        if (direction.y < HORIZON_TRESHOLD)
        {
            const horBlend = max(0.0, direction.y + HORIZON_TRESHOLD.abs + HORIZON_BUFFER);
            return _ground.lerp(_horizon, horBlend / HORIZON_BUFFER);
        }

        return _horizon.lerp(_sun, clamp(direction.y, 0.0, 1.0));
    }
}
