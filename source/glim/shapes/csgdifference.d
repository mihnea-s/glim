module glim.shapes.csgdifference;

import std.math : pow;
import std.typecons : tuple;
import std.container.rbtree;

import glim.math.ray;
import glim.math.vector;
import glim.shapes.shape;
import glim.shapes.csg;
import glim.shapes.csgunion;

/// Constructive Solid Geometry Difference
class CSGDifference : CSG
{
    /// Create CSG Difference from two shapes
    this(Shape a, Shape b) @safe nothrow
    {
        _a = a;
        _b = b;
    }

    /// Create CSG Difference from multiple shapes
    this(Shape a, Shape[] subtrahends...) @safe nothrow
    {
        _a = a;
        _b = new CSGUnion(subtrahends);
    }

    override final immutable(HitActionTable) getActionTable() const @safe nothrow
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
