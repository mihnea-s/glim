module glim.image.rgba;

import glim.math.vector;

/// A single pixel using four floating point components
/// representing the red, green, blue and alpha channels.
struct RGBA
{
    /// RGB components
    float red, green, blue, alpha;

    /// Black color
    @safe @nogc static RGBA black() pure nothrow
    {
        return RGBA.same(0.0);
    }

    /// White color
    @safe @nogc static RGBA white() pure nothrow
    {
        return RGBA.same(1.0);
    }

    /// Create an RGBA value with the same value
    /// in every component and maximum alpha
    @safe @nogc static RGBA same(double value) pure nothrow
    {
        return RGBA(value, value, value, 1.0);
    }

    /// Create an RGBA value with maximum opacity
    @safe @nogc static RGBA opaque(double r, double g, double b) pure nothrow
    {
        return RGBA(r, g, b, 1.0);
    }

    /// Create an opaque pixel from a Vec3
    @safe @nogc static RGBA fromVec(const Vec3 vec) pure nothrow
    {
        return RGBA(vec.x, vec.y, vec.z, 1.0);
    }

    /// Attenuate this color with some other color
    @safe @nogc auto attenuate(const RGBA other) const pure nothrow
    {
        return RGBA( //
                this.red * other.red, //
                this.green * other.green, //
                this.blue * other.blue, //
                this.alpha * other.alpha, //
                );
    }

    /// Lerp between two colors
    @safe @nogc auto lerp(const RGBA other, double t) const pure nothrow
    {
        if (t == 0.0)
        {
            return this;
        }
        else if (t == 1.0)
        {
            return other;
        }

        return RGBA( //
                this.red + t * (other.red - this.red), //
                this.green + t * (other.green - this.green), //
                this.blue + t * (other.blue - this.blue), //
                this.alpha + t * (other.alpha - this.alpha), //
                );
    }

    @safe nothrow unittest
    {
        immutable a = RGBA.white;
        immutable b = RGBA.black;
        assert(a.lerp(b, 0.5) == RGBA.same(0.5));
    }
}
