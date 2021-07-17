module glim.math.matrix;

import std.math;
import std.traits;
import std.range;

import glim.math.vector;

/// Generalised 2x2 Matrix
alias Matrix2(T) = Matrix!(2, T);

/// Specialised 2x2 Matrices
alias Mat2i = Matrix2!int;
alias Mat2u = Matrix2!uint;
alias Mat2f = Matrix2!float;
alias Mat2 = Matrix2!double;

/// Generalised 3x3 Matrix
alias Matrix3(T) = Matrix!(3, T);

/// Specialised 3x3 Matrices
alias Mat3i = Matrix3!int;
alias Mat3u = Matrix3!uint;
alias Mat3f = Matrix3!float;
alias Mat3 = Matrix3!double;

/// Generalised 4x4 Matrix
alias Matrix4(T) = Matrix!(4, T);

/// Specialised 4x4 Matrices
alias Mat4i = Matrix4!int;
alias Mat4u = Matrix4!uint;
alias Mat4f = Matrix4!float;
alias Mat4 = Matrix4!double;

/// An n-dimensional square Matrix
struct Matrix(int N, T)
{
    // Type constraints
    static assert(isNumeric!T);
    static assert(1 <= N && N <= 4);

    /// For convinence
    alias ThisMatrix = Matrix!(N, T);

    /// Raw matrix data
    T[N * N] data;

    /// Matrix with all rows and columns set to zero.
    @safe @nogc static ThisMatrix zero()
    {
        return mixin("ThisMatrix([" ~ "0".repeat(N * N).join(",") ~ "])");
    }

    /// Identity matrix for the given size
    @safe @nogc static ThisMatrix identity()
    {
        auto mat = zero();

        static foreach (i; iota(N))
        {
            mat.data[i * N + i] = 1;
        }

        return mat;
    }

    /// Identity matrix with the ones residing on the anti-diagonal
    @safe @nogc static ThisMatrix antiIdentity()
    {
        auto mat = zero();

        static foreach (i; iota(N))
        {
            mat.data[i * N + (N - i - 1)] = 1;
        }

        return mat;
    }

    /// Get a row of the matrix as a vector
    @safe @nogc auto row(int R)() const nothrow
    {
        static assert(R < N);

        auto vec = Vector!(N, T)();

        static foreach (int C; iota(N))
        {
            vec[C] = data[R * N + C];
        }

        return vec;
    }

    /// Get a column of the matrix as a vector
    @safe @nogc auto column(int C)() const nothrow
    {
        static assert(C < N);

        auto vec = Vector!(N, T)();

        static foreach (int R; iota(N))
        {
            vec[R] = data[R * N + C];
        }

        return vec;
    }

    @safe nothrow unittest
    {
        immutable id = Mat4.identity();

        assert(id.row!0 == Vec4(1, 0, 0, 0));
        assert(id.row!1 == Vec4(0, 1, 0, 0));
        assert(id.row!2 == Vec4(0, 0, 1, 0));
        assert(id.row!3 == Vec4(0, 0, 0, 1));

        assert(id.column!0 == Vec4(1, 0, 0, 0));
        assert(id.column!1 == Vec4(0, 1, 0, 0));
        assert(id.column!2 == Vec4(0, 0, 1, 0));
        assert(id.column!3 == Vec4(0, 0, 0, 1));

        immutable anid = Mat4.antiIdentity();

        assert(anid.row!0 == Vec4(0, 0, 0, 1));
        assert(anid.row!1 == Vec4(0, 0, 1, 0));
        assert(anid.row!2 == Vec4(0, 1, 0, 0));
        assert(anid.row!3 == Vec4(1, 0, 0, 0));

        assert(anid.column!0 == Vec4(0, 0, 0, 1));
        assert(anid.column!1 == Vec4(0, 0, 1, 0));
        assert(anid.column!2 == Vec4(0, 1, 0, 0));
        assert(anid.column!3 == Vec4(1, 0, 0, 0));
    }

    static if (N == 4 && isFloatingPoint!T)
    {
        /// Create a translation matrix given a position
        @safe @nogc static ThisMatrix translate(const Vector3!T p)
        {
            // dfmt off
            return ThisMatrix([
                1, 0, 0, p.x,
                0, 1, 0, p.y,
                0, 0, 1, p.z,
                0, 0, 0, 1,
            ]);
            // dfmt on
        }

        /// Create a scale matrix given a position
        @safe @nogc static ThisMatrix scale(const Vector3!T s)
        {
            // dfmt off
            return ThisMatrix([
                s.x, 0,   0,   0,
                0,   s.y, 0,   0,
                0,   0,   s.z, 0,
                0,   0,   0,   1,
            ]);
            // dfmt on
        }

        /// Create a roatation matrix given a rotation vector
        /// (compontents are angles in radians)
        @safe @nogc static ThisMatrix rotate(const Vector3!T r)
        {
            // dfmt off
            
            immutable roll = ThisMatrix([
                cos(r.x), -sin(r.x), 0, 0,
                sin(r.x),  cos(r.x), 0, 0,
                0,         0,        1, 0,
                0,         0,        0, 1,
            ]);

            immutable yaw = ThisMatrix([
                cos(r.z),  0, sin(r.z), 0,
                0,         1, 0,        0,
                -sin(r.z), 0, cos(r.z), 0,
                0,         0, 0,        1,
            ]);
            
            immutable pitch = ThisMatrix([
                 1, 0,         0,        0,
                 0, cos(r.y), -sin(r.y), 0,
                 0, sin(r.y),  cos(r.y), 0,
                 0, 0,         0,        1,
            ]);
            
            // dfmt on

            return roll * yaw * pitch;
        }

        /// Create a transformation matrix given a position, scale and rotation vector
        /// (compontents are angles in radians)
        @safe @nogc static ThisMatrix transform(const Vector3!T p,
                const Vector3!T s, const Vector3!T r)
        {
            return translate(p) * scale(s) * rotate(r);
        }

        /// Create a projection matrix given a theta angle in radians for the vertical field of view,
        /// the aspect ratio of the viewport and the far and near Z clipping planes.
        @safe @nogc static ThisMatrix projection(double theta, double aspect,
                double near, double far)
        {
            immutable k = 1 / tan(theta / 2);

            immutable ak = aspect * k;

            immutable zx = (near + far) / (near - far);
            immutable zy = -2 * (near * far) / (near - far);

            // dfmt off
            return ThisMatrix([
                ak, 0,  0,  0,
                0,  k,  0,  0,
                0,  0, zx, zy,
                0,  0, -1,  0,
            ]);
            // dfmt on
        }

        /// Create a look at matrix where the camera is positioned at position looking towards
        /// target and the up direction is up
        @safe @nogc static ThisMatrix view(const Vector3!T target,
                const Vector3!T position, const Vector3!T up = Vector3!T.up)
        {
            immutable direction = (target - position).normalized;

            immutable right = direction.cross(up).normalized;
            immutable vup = direction.cross(right);
            immutable forward = vup.cross(right);

            immutable negPos = -position;
            immutable px = negPos.dot(right);
            immutable py = negPos.dot(vup);
            immutable pz = negPos.dot(forward);

            // dfmt off
            return ThisMatrix([
                right.x,   right.y,   right.z,   px,
                vup.x,     vup.y,     vup.z,     py,
                forward.x, forward.y, forward.z, pz,
                0,         0,         0,         1,
            ]);
            // dfmt on
        }
    }

    /// Matrix-Vector multiplication
    @safe @nogc auto opBinary(string op)(const Vector!(N, T) rhs) const nothrow
    {
        static assert(op == "*");

        auto vec = Vector!(N, T)();

        static foreach (int R; iota(N))
        {
            vec[R] = rhs.dot(this.row!R);
        }

        return vec;
    }

    @safe nothrow unittest
    {
        immutable id = Mat4.identity();
        immutable vec = Vec4(-2, 3, -5, 5);

        assert(id * vec == vec);
    }

    /// Matrix-Matrix multiplication
    auto opBinary(string op)(const ThisMatrix rhs) const
    {
        static if (op == "+" || op == "-")
        {
            auto mat = ThisMatrix.zero;

            static foreach (Idx; iota(N * N))
            {
                mat.data[Idx] = mixin("data[Idx]" ~ op ~ "rhs.data[Idx]");
            }

            return mat;
        }
        else
        {
            static assert(op == "*", "Unsuported operator '" ~ op ~ "' between matrices");
        }

        auto mat = ThisMatrix.zero;

        static foreach (R; iota(N))
        {
            static foreach (C; iota(N))
            {
                mat.data[R * N + C] = cast(T) this.row!R.dot(rhs.column!C);
            }
        }

        return mat;
    }

    @safe nothrow unittest
    {
        // dfmt off

        immutable a = Mat4([
            6, 7, 1, 2,
            3, 4, 5, 6,
            9, 8, 1, 1,
            5, 4, 3, 2,
        ]);

        immutable b = Mat4([
            1, 1, 2, 0,
            7, 3, 4, 8,
            5, 9, 5, 3,
            6, 5, 2, 5,
        ]);

        immutable ab = Mat4([
            72,	46,	49,	69,
            92,	90,	59,	77,
            76,	47,	57,	72,
            60,	54,	45,	51,
        ]);

        assert(a * b == ab);
        assert(b * a != ab);

        // dfmt on
    }

    /// Matrix scalar multiplication
    auto opBinaryRight(string op, L)(const L lhs) const
    {
        static assert(isNumeric!L, "Unsupported type for scalar matrix multiplication");
        static assert(op == "*", "Unsupported operator '" ~ op ~ "' for scalar multiplication");

        auto mat = ThisMatrix.zero;

        static foreach (Idx; iota(N * N))
        {
            mat.data[Idx] = lhs * data[Idx];
        }

        return mat;
    }

    @safe nothrow unittest
    {
        immutable id = Mat2.identity();
        immutable twice = 2 * id;

        assert(twice.row!0 == Vec2(2, 0));
        assert(twice.row!1 == Vec2(0, 2));
    }

    bool opEquals(const ThisMatrix other) const
    {
        static foreach (Idx; iota(N * N))
        {
            if (this.data[Idx] != other.data[Idx])
            {
                return false;
            }
        }

        return true;
    }

    size_t toHash() const @safe pure nothrow
    {
        auto hash = 0L;

        static foreach (Idx; iota(N * N))
        {
            hash = data[Idx].hashOf(hash);
        }

        return hash;
    }
}
