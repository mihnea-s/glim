module glim.math.vector;

import std.range;
import std.math;
import std.traits;
import std.algorithm;

// 2 Dimensional general vector
alias Vector2(T) = Vector!(2, T);

// 3 Dimensional general vector
alias Vector3(T) = Vector!(3, T);

// 4 Dimensional general vector
alias Vector4(T) = Vector!(4, T);

// Specialized 2D vectors
alias Vec2i = Vector2!int;
alias Vec2u = Vector2!uint;
alias Vec2f = Vector2!float;
alias Vec2 = Vector2!double;

// Specialized 3D vectors
alias Vec3i = Vector3!int;
alias Vec3u = Vector3!uint;
alias Vec3f = Vector3!float;
alias Vec3 = Vector3!double;

// Specialized 4D vectors
alias Vec4i = Vector4!int;
alias Vec4u = Vector4!uint;
alias Vec4f = Vector4!float;
alias Vec4 = Vector4!double;

/// A 3-dimensional vector
struct Vector(int N, T)
{
    // Type constraints
    static assert(isNumeric!T);
    static assert(1 <= N && N <= 4);

    // For convinience
    alias ThisVector = Vector!(N, T);

    // Compile time components
    private static immutable _Components = ["x", "y", "z", "w"].take(N);

    /// The values of the vector
    static foreach (comp; _Components)
    {
        mixin("T " ~ comp ~ ";");
    }
    /// Create a zero vector
    @safe @nogc static auto zero() pure nothrow
    {
        return ThisVector.same(0);
    }

    /// Create a unit vector
    @safe @nogc static auto unit() pure nothrow
    {
        return ThisVector.same(1);
    }

    /// Create a vector with the same value
    /// for all components
    @safe @nogc static auto same(T v) pure nothrow
    {
        auto vec = ThisVector();

        static foreach (comp; _Components)
        {
            mixin("vec." ~ comp) = v;
        }

        return vec;
    }

    static if (N == 3)
    {
        /// Create a unit vector pointing
        /// in the positive y axis
        @safe @nogc static auto up() pure nothrow
        {
            return ThisVector(0, 1, 0);
        }

        /// Create a unit vector pointing
        /// in the negative y axis
        @safe @nogc static auto down() pure nothrow
        {
            return -ThisVector.up;
        }

        /// Create a unit vector pointing
        /// in the negative z axis
        @safe @nogc static auto forward() pure nothrow
        {
            return ThisVector(0, 0, -1);
        }

        /// Create a unit vector pointing
        /// in the positive z axis
        @safe @nogc static auto backward() pure nothrow
        {
            return -ThisVector.forward;
        }

        /// Create a unit vector pointing
        /// in the positive x axis
        @safe @nogc static auto right() pure nothrow
        {
            return ThisVector(1, 0, 0);
        }

        /// Create a unit vector pointing
        /// in the negative x axis
        @safe @nogc static auto left() pure nothrow
        {
            return -ThisVector.right;
        }

        /// Create a random vector along the
        /// surface of the unit sphere
        @safe static ThisVector random()
        {
            import std.random : uniform;
            import std.math : PI, sqrt, sin, cos;

            immutable a = uniform(0.0, 2.0 * PI);
            immutable z = uniform(-1.0, 1.0);
            immutable r = sqrt(1.0 - pow(z, 2.0));

            immutable x = cast(T)(r * sin(a));
            immutable y = cast(T)(r * cos(a));

            return ThisVector(x, y, cast(T) z);
        }

        /// Cross product
        @safe @nogc auto cross(const Vec3 other) const pure nothrow
        {
            return Vec3( //
                    this.y * other.z - this.z * other.y, //
                    this.z * other.x - this.x * other.z, //
                    this.x * other.y - this.y * other.x, //
                    );
        }

        // Cross product tests
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
    }

    /// The sum of the components of the vector
    @safe @nogc auto sum() const pure nothrow
    {
        static if (isFloatingPoint!T)
        {
            auto sum = 0.0;
        }
        else
        {
            auto sum = T.init;
        }

        static foreach (comp; _Components)
        {
            sum += mixin(comp);
        }

        return sum;
    }

    static if (isFloatingPoint!T)
    {
        /// The length of the vector
        @safe @nogc auto length() const pure nothrow
        {
            auto sum = 0.0;

            static foreach (comp; _Components)
            {
                sum += pow(mixin(comp), 2);
            }

            return sqrt(sum);
        }

        /// Get a unit vector pointing in same direction
        @safe @nogc auto normalized() const pure nothrow
        {
            immutable len = this.length;
            assert(len != 0, "vector length is 0");
            return this / len;
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
    }

    /// Dot product
    @safe @nogc auto dot(R)(const Vector!(N, R) other) const pure nothrow
    {
        auto sum = 0.0;

        static foreach (comp; _Components)
        {
            sum += mixin(comp) * mixin("other." ~ comp);
        }

        return sum;
    }

    // Dot product tests
    @safe nothrow unittest
    {
        immutable a = Vec3(0, 1, 0);
        immutable b = Vec3(0, -1, 0);
        assert(a.dot(b) == -1);

        immutable c = Vec3(1, 2, 3);
        immutable d = Vec3(6, 7, 8);
        assert(c.dot(d) == 44);
    }

    /// Reflect in regards to a normal
    @safe @nogc auto reflect(R)(const Vector!(N, R) norm) const pure nothrow
    {
        assert(0.98 < norm.length && norm.length < 1.02);
        return this - norm * 2.0 * this.dot(norm);
    }

    /// Refract the ray using a normal
    @safe @nogc auto refract(R)(const Vector!(N, R) norm, const double etaQuot) const pure nothrow
    {
        assert(0.98 < norm.length && norm.length < 1.02);

        immutable cosTheta = norm.dot(-this);

        immutable parallel = (this + norm * cosTheta) * etaQuot;
        immutable perpen = norm * -sqrt(1.0 - pow(parallel.length, 2));

        return parallel + perpen;
    }

    /// Distance between two vectors
    @safe @nogc auto distance(R)(const Vector!(N, R) other) const pure nothrow
    {
        return (this - other).length;
    }

    /// Swap components of a vector
    @safe @nogc auto transpose() const pure nothrow
    {
        ThisVector transposed = this;

        static foreach (tup; zip(_Components[0 .. $ / 2], _Components[$ / 2 .. $].dup.reverse))
        {
            swap(mixin("transposed." ~ tup[0]), mixin("transposed." ~ tup[1]));
        }

        return transposed;
    }

    /// Vector negation
    @safe @nogc auto opUnary(string op)() const pure nothrow
    {
        static if (!["-", "+"].canFind(op))
        {
            static assert(false, "unimplemented operator " ~ op ~ " for vec3");
        }

        auto vec = ThisVector();

        static foreach (comp; _Components)
        {
            // e.g. vec.x = -x
            mixin("vec." ~ comp) = mixin(op ~ comp);
        }

        return vec;
    }

    /// Operations between two vectors
    @safe @nogc auto opBinary(string op, R)(const Vector!(N, R) rhs) const pure nothrow
    {
        static if (!["+", "-", "/", "*"].canFind(op))
        {
            static assert(false, "unimplemented operator " ~ op ~ " for vector");
        }

        auto vec = ThisVector();

        static foreach (comp; _Components)
        {
            // e.g. vec.x = x / rhs.x
            mixin("vec." ~ comp) = mixin(comp ~ op ~ "rhs." ~ comp);
        }

        return vec;
    }

    /// Operations between a vector and a scalar value
    @safe @nogc auto opBinary(string op)(const double rhs) const pure nothrow
    {
        static if (!["*", "/"].canFind(op))
        {
            static assert(false, "unimplemented operator " ~ op ~ " for vector");
        }

        auto vec = ThisVector();

        static foreach (comp; _Components)
        {
            // e.g. vec.x = x / rhs
            mixin("vec." ~ comp) = mixin(comp ~ op ~ "rhs");
        }

        return vec;
    }

    /// Operator assignment of a vector
    @safe @nogc auto opOpAssign(string op, R)(const Vector!(N, R) value) nothrow
    {
        static if (!["+=", "-=", "/=", "*="].canFind(op))
        {
            static assert(false, "unimplemented " ~ op ~ " for vector");
        }

        static foreach (comp; _Components)
        {
            // e.g. x += value.x
            mixin(comp ~ op ~ "value." ~ comp);
        }

        return this;
    }

    /// Operator assignment of a scalar value
    @safe @nogc auto opOpAssign(string op)(double value) nothrow
    {
        static if (!["/=", "*="].canFind(op))
        {
            static assert(false, "unimplemented " ~ op ~ " for vector");
        }

        static foreach (comp; _Components)
        {
            // e.g. x += value
            mixin(comp ~ op ~ "value");
        }

        return this;
    }

    /// Check equality of vectors of the same size
    @safe @nogc bool opEquals(R)(const Vector!(N, R) other) const pure nothrow
    {
        static foreach (comp; _Components)
        {
            if (mixin(comp) != mixin("other." ~ comp))
            {
                return false;
            }
        }

        return true;
    }

    /// Calculate hash
    @safe @nogc ulong toHash() const pure nothrow
    {
        auto hash = 0uL;

        static foreach (comp; _Components)
        {
            hash = mixin(comp).hashOf(hash);
        }

        return hash;
    }

}
