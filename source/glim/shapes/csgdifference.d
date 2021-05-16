module glim.shapes.csgdifference;

import glim.shapes.csg;
import glim.shapes.shape;
import glim.shapes.csgunion;

/// Constructive Solid Geometry Difference
class CSGDifference : CSG
{
    /// Create CSG Difference from two shapes
    @safe @nogc public this(Shape a, Shape b) nothrow
    {
        _a = a;
        _b = b;
    }

    /// Create CSG Difference from multiple shapes
    @safe public this(Shape a, Shape[] subtrahends...) nothrow
    {
        _a = a;
        _b = new CSGUnion(subtrahends);
    }

    @safe override final ushort getActions(const ubyte state) const nothrow
    {
        final switch (state) with (HitState) with (HitAction)
        {
            // A is Entered
        case AEntered | BEntered:
            return ReturnAIfCloser | AdvanceBAndLoop;
        case AEntered | BExited:
            return ReturnAIfFarther | AdvanceAAndLoop;
        case AEntered | BMissed:
            return ReturnA;

            // A is Exited
        case AExited | BEntered:
            return ReturnAIfCloser | ReturnBIfCloser | FlipB;
        case AExited | BExited:
            return ReturnBIfCloser | AdvanceAAndLoop;
        case AExited | BMissed:
            return ReturnA;

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
