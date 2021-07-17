module glim.raytracing.shapes.csgunion;

import std.typecons : tuple;
import std.container.rbtree;

import glim.raytracing.shapes.csg;
import glim.raytracing.shapes.shape;

/// Constructive Solid Geometry Union
class CSGUnion : CSG
{
    /// Create CSG Union from two shapes
    @safe @nogc this(Shape a, Shape b) nothrow
    {
        _a = a;
        _b = b;
    }

    /// Create CSG Union from multiple shapes
    @safe this(Shape[] shapes...) nothrow
    {
        assert(shapes.length > 1);

        auto lastShape = new CSGUnion(shapes[0], shapes[1]);

        foreach (shape; shapes[2 .. $ - 2])
        {
            lastShape = new CSGUnion(lastShape, shape);
        }

        _a = lastShape;
        _b = shapes[$ - 1];
    }

    @safe override final ushort getActions(const ubyte state) const nothrow
    {

        final switch (state) with (HitState) with (HitAction)
        {
            // A is Entered
        case AEntered | BEntered:
            return ReturnAIfCloser | ReturnBIfCloser;
        case AEntered | BExited:
            return ReturnBIfCloser | AdvanceAAndLoop;
        case AEntered | BMissed:
            return ReturnA;

            // A is Exited
        case AExited | BEntered:
            return ReturnAIfCloser | AdvanceBAndLoop;
        case AExited | BExited:
            return ReturnAIfFarther | ReturnBIfFarther;
        case AExited | BMissed:
            return ReturnA;

            // A is Missed
        case AMissed | BEntered:
            return ReturnB;
        case AMissed | BExited:
            return ReturnB;
        case AMissed | BMissed:
            return ReturnMiss;
        }
    }
}
