module glim.rendering.camera;

import glim.math;

import glim.image.rgba;
import glim.rendering.skybox;

/// Camera
public struct Camera
{
    /// Width and height of the rendered image
    private immutable ulong _width, _height;

    // Position in the world
    private immutable Vec3 _position;

    // Basis vectors
    private immutable Vec3 _basisI, _basisJ, _basisK;

    // Virtual plane
    private immutable Vec3 _planeTopLeft, _planeHorizontal, _planeVertical;

    // Lens radius, vertical fov and aspect ratio
    private immutable double _lensRadius, _vfov, _aspect;

    // Skybox
    private const Skybox _skybox;

    // Matrices
    private immutable Mat4 _projection, _view;

    private static struct Builder
    {
        private ulong _width = 600, _height = 300;
        private Vec3 _position = Vec3.zero;
        private Vec3 _target = Vec3.forward;
        private double _verticalFov = 30;
        private double _aperture = 0;
        private double _focusDistance = 1;
        private Skybox _skybox = new SolidSkybox(RGBA.black);

        public auto extent(ulong width, ulong height)
        {
            _width = width;
            _height = height;
            return this;
        }

        public auto position(Vec3 position)
        {
            _position = position;
            return this;
        }

        public auto target(Vec3 target)
        {
            _target = target;
            return this;
        }

        public auto verticalFov(double verticalFov)
        {
            _verticalFov = verticalFov;
            return this;
        }

        public auto aperture(double aperture)
        {
            _aperture = aperture;
            return this;
        }

        public auto focusDistance(double focusDistance)
        {
            _focusDistance = focusDistance;
            return this;
        }

        public auto skybox(Skybox skybox)
        {
            _skybox = skybox;
            return this;
        }

        public auto build() @safe nothrow
        {
            return Camera(_width, _height, _position, _target, _verticalFov,
                    _aperture, _focusDistance, _skybox);
        }
    }

    /// Create a camera from parameters
    private this(ulong width, ulong height, Vec3 position, Vec3 target,
            double verticalFov, double aperture, double focusDistance, const Skybox skybox) @safe nothrow
    {
        import std.math : PI, tan;

        assert(aperture >= 0.0, "aperture is negative");
        assert(focusDistance > 0.0, "focus distance is negative");
        assert(verticalFov > 0, "vfov should be bigger than 0");
        assert(width > 0 && height > 0, "height & width should be positive");

        _width = width;
        _height = height;
        _position = position;
        _lensRadius = aperture / 2.0;

        _vfov = verticalFov / 360.0 * 2.0 * PI;
        _aspect = (width * 1.0) / height;

        // Vertical & horizontal
        immutable v = 2.0 * tan(_vfov / 2.0);
        immutable h = _aspect * v;

        // Camera orthonormal basis
        _basisK = -(position - target).normalized;
        _basisI = _basisK.cross(Vec3.up).normalized;
        _basisJ = _basisI.cross(_basisK).normalized;

        _planeTopLeft = // top left corner of the virtual plane
            (Vec3.zero //
                     - _basisI * (h / 2.0) // half width on the x
                     + _basisJ * (v / 2.0) // half height on the y
                     + _basisK) * focusDistance;

        _planeHorizontal = _basisI * focusDistance * h;
        _planeVertical = _basisJ * focusDistance * v;
        _skybox = skybox;

        // Compute projection matrix
        _projection = Mat4.projection(_vfov, _aspect, focusDistance * 0.01, focusDistance * 100);

        // Compute view matrix
        immutable negPos = -_position;

        // dfmt off
        _view = Mat4([
            _basisI.x, _basisI.y, _basisI.z, negPos.dot(_basisI),
            _basisJ.x, _basisJ.y, _basisJ.z, negPos.dot(_basisJ),
            _basisK.x, _basisK.y, _basisK.z, negPos.dot(_basisK),
            0,         0,         0,         1,
        ]);
        // dfmt on
    }

    /// Create a new builder for a new camera.
    @safe @nogc public static auto builder() pure nothrow
    {
        return Builder();
    }

    /// Getter for camera position.
    @nogc public auto position() const pure nothrow
    {
        return _position;
    }

    /// Getter for camera basis i vector.
    @nogc public auto basisI() const pure nothrow
    {
        return _basisI;
    }

    /// Getter for camera basis j vector.
    @nogc public auto basisJ() const pure nothrow
    {
        return _basisJ;
    }

    /// Getter for camera basis k vector.
    @nogc public auto basisK() const pure nothrow
    {
        return _basisK;
    }

    /// Getter for camera's virtual plane's top left corner.
    @nogc public auto planeTopLeft() const pure nothrow
    {
        return _planeTopLeft;
    }

    /// Getter for camera planeHorizontal.
    @nogc public auto planeHorizontal() const pure nothrow
    {
        return _planeHorizontal;
    }

    /// Getter for camera planeVertical.
    @nogc public auto planeVertical() const pure nothrow
    {
        return _planeVertical;
    }

    /// Getter for camera's len's radius.
    @nogc public auto lensRadius() const pure nothrow
    {
        return _lensRadius;
    }

    /// Getter for the render's width in pixels.
    @nogc public auto width() const pure nothrow
    {
        return _width;
    }

    /// Getter for the render's height in pixels.
    @nogc public auto height() const pure nothrow
    {
        return _height;
    }

    /// Getter for the camera's skybox.
    @nogc public auto skybox() const pure nothrow
    {
        return _skybox;
    }

    /// Projection Matrix using this camera's settings.
    @nogc public auto projection() const pure nothrow
    {
        return _projection;
    }

    /// View Matrix using this camera's settings.
    @nogc public auto view() const pure nothrow
    {
        return _view;
    }
}
