module glim.math.vector;

import std.math : sqrt, pow;
import std.algorithm : canFind;

/// A 3-dimensional vector
struct Vec3
{
  /// The values of the vector
  double x, y, z;

  /// Create a zero vector
  static Vec3 zero() @safe nothrow
  {
    return Vec3.same(0);
  }

  /// Create a unit vector
  static Vec3 unit() @safe nothrow
  {
    return Vec3.same(1);
  }

  /// Create a unit vector pointing
  /// in the positive y axis
  static Vec3 up() @safe nothrow
  {
    return Vec3(0, 1.0, 0);
  }

  /// Create a unit vector pointing
  /// in the negative z axis
  static Vec3 forward() @safe nothrow
  {
    return Vec3(0, 0, -1.0);
  }

  /// Create a vector with the same value
  /// for all coordinates
  static Vec3 same(double v) @safe nothrow
  {
    return Vec3(v, v, v);
  }

  /// Create a random vector along the
  /// surface of the unit sphere
  static Vec3 random() @safe
  {
    import std.random : uniform;
    import std.math : PI, sqrt, sin, cos;

    immutable a = uniform(0.0, 2.0 * PI);
    immutable z = uniform(-1.0, 1.0);
    immutable r = sqrt(1.0 - pow(z, 2.0));

    return Vec3(r * sin(a), r * cos(a), z);
  }

  /// The length of the vector
  auto length() const @safe nothrow
  {
    return sqrt(x * x + y * y + z * z);
  }

  /// Get a unit vector pointing in same direction
  auto normalized() const @safe nothrow
  {
    immutable len = this.length;
    assert(len != 0, "vector length is 0");

    return Vec3( //
        this.x / len, //
        this.y / len, //
        this.z / len, //
        );
  }

  @safe nothrow unittest
  {
    immutable a = Vec3(1, 0, 0);
    assert(a.normalized == a);

    immutable b = Vec3(20, 0, 0);
    assert(b.normalized == b / 20);

    immutable c = Vec3(1, 1, 1);
    assert(c.normalized == Vec3.same(1.0 / sqrt(3.0)));
  }

  /// Dot product
  auto dot(const Vec3 other) const @safe nothrow
  {
    return this.x * other.x + this.y * other.y + this.z * other.z;
  }

  @safe nothrow unittest
  {
    immutable a = Vec3(0, 1, 0);
    immutable b = Vec3(0, -1, 0);
    assert(a.dot(b) == -1);

    immutable c = Vec3(1, 2, 3);
    immutable d = Vec3(6, 7, 8);
    assert(c.dot(d) == 44);
  }

  /// Cross product
  auto cross(const Vec3 other) const @safe nothrow
  {
    return Vec3( //
        this.y * other.z - this.z * other.y, //
        this.z * other.x - this.x * other.z, //
        this.x * other.y - this.y * other.x, //
        );
  }

  @safe nothrow unittest
  {
    immutable i = Vec3(1, 0, 0);
    immutable j = Vec3(0, 1, 0);
    immutable k = Vec3(0, 0, 1);

    assert(i.cross(j) == k);
    assert(i.cross(k) == -j);

    assert(j.cross(k) == i);
    assert(j.cross(i) == -k);

    assert(k.cross(i) == j);
    assert(k.cross(j) == -i);
  }

  /// Reflect in regards to a normal
  auto reflect(const Vec3 norm) const @safe
  {
    assert(0.98 < norm.length && norm.length < 1.02);
    return this - norm * this.dot(norm) * 2.0;
  }

  /// Refract the ray using a normal
  auto refract(const Vec3 norm, const double etaQuot) const @safe
  {
    import std.math : sqrt, pow;

    assert(0.98 < norm.length && norm.length < 1.02);

    immutable cosTheta = norm.dot(-this);

    immutable parallel = (this + norm * cosTheta) * etaQuot;
    immutable perpen = norm * -sqrt(1.0 - pow(parallel.length, 2));

    return parallel + perpen;
  }

  /// Vector negation
  auto opUnary(string op)() const
  {
    static if (["-", "+"].canFind(op))
    {
      return Vec3(-this.x, -this.y, -this.z);
    }

    assert(false, "unimplemented operator " ~ op ~ " for vec3");
  }

  /// Operations between two vectors
  auto opBinary(string op)(const Vec3 rhs) const
  {
    static if (["+", "-", "/", "*"].canFind(op))
    {
      return Vec3( //
          mixin("this.x" ~ op ~ "rhs.x"), //
          mixin("this.y" ~ op ~ "rhs.y"), //
          mixin("this.z" ~ op ~ "rhs.z"), //
          );
    }

    assert(false, "unimplemented operator " ~ op ~ " for vec3");
  }

  /// Operations between a vector and a scalar value
  auto opBinary(string op)(const double rhs) const
  {
    static if (["*", "/"].canFind(op))
    {
      return Vec3( //
          mixin("this.x" ~ op ~ "rhs"), //
          mixin("this.y" ~ op ~ "rhs"), //
          mixin("this.z" ~ op ~ "rhs"), //
          );
    }

    assert(false, "unimplemented operator " ~ op ~ " for vec3");
  }

  /// Operator assignment of a vector
  auto opOpAssign(string op)(Vec3 value)
  {
    static if (["+=", "-=", "/=", "*="].canFind(op))
    {
      mixin("this.x" ~ op ~ "value.x");
      mixin("this.y" ~ op ~ "value.y");
      mixin("this.z" ~ op ~ "value.z");
    }
    else
    {
      assert(false, "unimplemented " ~ op ~ " for vec3");
    }

    return this;
  }

  /// Operator assignment of a scalar value
  auto opOpAssign(string op)(double value)
  {
    static if (["/=", "*="].canFind(op))
    {
      mixin("this.x" ~ op ~ "value");
      mixin("this.y" ~ op ~ "value");
      mixin("this.z" ~ op ~ "value");

      return this;
    }

    assert(false, "unimplemented " ~ op ~ " for vec3");
  }
}
