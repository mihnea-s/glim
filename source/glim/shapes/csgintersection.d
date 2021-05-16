module glim.shapes.csgintersection;

import glim.shapes.csg;
import glim.shapes.shape;

/// Constructive Solid Geometry Intersection
class CSGIntersection : CSG
{
    /// Create CSG Intersection from two shapes
    @safe @nogc this(Shape a, Shape b) nothrow
    {
        _a = a;
        _b = b;
    }

    /// Create CSG Intersection from multiple shapes
    @safe this(Shape[] shapes...) nothrow
    {
        assert(shapes.length > 1);

        auto lastShape = new CSGIntersection(shapes[0], shapes[1]);

        foreach (shape; shapes[2 .. $ - 2])
        {
            lastShape = new CSGIntersection(lastShape, shape);
        }

        _a = lastShape;
        _b = shapes[$ - 1];
    }

    @safe override final ushort getActions(const ubyte state) const nothrow
    {

        final switch (state) with (HitState) with (HitAction)
        {
        case AEntered | BEntered:
            return ReturnAIfFarther | ReturnBIfFarther;
        case AEntered | BExited:
            return ReturnAIfCloser | AdvanceBAndLoop;
        case AEntered | BMissed:
            return ReturnMiss;

            // A is Exited
        case AExited | BEntered:
            return ReturnBIfCloser | AdvanceAAndLoop;
        case AExited | BExited:
            return ReturnAIfCloser | ReturnBIfCloser;
        case AExited | BMissed:
            return ReturnMiss;

            // A is Missed
        case AMissed | BEntered:
            return ReturnMiss;
        case AMissed | BExited:
            return ReturnMiss;
        case AMissed | BMissed:
            return ReturnMiss;
        }
    }
}
