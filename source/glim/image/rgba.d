module glim.image.rgba;

import glim.math.vector;

struct RGBA
{
  /// RGB components
  float red, green, blue, alpha;

  /// Black color
  static RGBA black() @safe nothrow
  {
    return RGBA.same(0.0);
  }

  /// White color
  static RGBA white() @safe nothrow
  {
    return RGBA.same(1.0);
  }

  /// Create an RGBA value with the same value
  /// in every component and maximum alpha
  static RGBA same(double value) @safe nothrow
  {
    return RGBA(value, value, value, 1.0);
  }

  /// Create an RGBA value with maximum opacity
  static RGBA opaque(double r, double g, double b) @safe nothrow
  {
    return RGBA(r, g, b, 1.0);
  }

  static RGBA fromVec(const Vec3 vec) @safe nothrow
  {
    return RGBA(vec.x, vec.y, vec.z, 1.0);
  }

  /// Attenuate this color with some other color
  auto attenuate(const RGBA other) const @safe nothrow
  {
    return RGBA( //
        this.red * other.red, //
        this.green * other.green, //
        this.blue * other.blue, //
        this.alpha * other.alpha, //
        );
  }

  /// Lerp between two colors
  auto lerp(const RGBA other, double t) const @safe nothrow
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
