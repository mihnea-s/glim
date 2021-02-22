module glim.shapes.csgdifference;

import std.typecons;
import std.container.rbtree;

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

    @safe override final immutable(HitActionTable) getActionTable() const
    {
        with (HitState) with (HitAction)
            return [

                // A is Entered
                tuple(Entered, Entered): redBlackTree(ReturnAIfCloser, AdvanceBAndLoop),
                tuple(Entered, Exited): redBlackTree(ReturnAIfFarther, AdvanceAAndLoop),
                tuple(Entered, Missed): redBlackTree(ReturnA),

                // A is Exited
                tuple(Exited, Entered): redBlackTree(ReturnAIfCloser, ReturnBIfCloser, FlipB),
                tuple(Exited, Exited): redBlackTree(ReturnBIfCloser, AdvanceAAndLoop),
                tuple(Exited, Missed): redBlackTree(ReturnA),

                // A is Missed
                tuple(Missed, Entered): redBlackTree(ReturnMiss),
                tuple(Missed, Exited): redBlackTree(ReturnMiss),
                tuple(Missed, Missed): redBlackTree(ReturnMiss),
            ];
    }
}
