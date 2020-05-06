module glimmer.image.rgba;

///
struct RGBA
{
  /// RGB components
  ubyte red, green, blue, alpha;

  /// Black color
  static RGBA black() @safe nothrow
  {
    return RGBA(0, 0, 0, ubyte.max);
  }

  /// White color
  static RGBA white() @safe nothrow
  {
    return RGBA.same(ubyte.max);
  }

  /// Create an RGBA value with the same value
  /// in every component
  static RGBA same(ubyte value) @safe nothrow
  {
    return RGBA(value, value, value, value);
  }

  /// Construct RGBA from double
  static RGBA doubles(double r, double g, double b, double a) @safe nothrow
  {
    return RGBA( //
        cast(ubyte)(ubyte.max * r), //
        cast(ubyte)(ubyte.max * g), //
        cast(ubyte)(ubyte.max * b), //
        cast(ubyte)(ubyte.max * a), //
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
        cast(ubyte)(this.red + t * (other.red - this.red)), //
        cast(ubyte)(this.green + t * (other.green - this.green)), //
        cast(ubyte)(this.blue + t * (other.blue - this.blue)), //
        cast(ubyte)(this.alpha + t * (other.alpha - this.alpha)), //
        );
  }

  @safe nothrow unittest
  {
    immutable a = RGBA.white;
    immutable b = RGBA.black;
    assert(a.lerp(b, 0.5) == RGBA(127, 127, 127, 255));
  }
}
