module glim.shapes.csgunion;

import std.math : pow;
import std.typecons : tuple;
import std.container.rbtree;

import glim.math.ray;
import glim.math.vector;
import glim.shapes.shape;
import glim.shapes.csg;

/// Constructive Solid Geometry Union
class CSGUnion : CSG
{
    /// Create CSG Union from two shapes
    this(Shape a, Shape b) @safe nothrow
    {
        _a = a;
        _b = b;
    }

    /// Create CSG Union from multiple shapes
    this(Shape[] shapes...) @safe nothrow
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

    override final immutable(HitActionTable) getActionTable() const @safe nothrow
    {
        with (HitState) with (HitAction)
            return [

                // A is Entered
                tuple(Entered, Entered): redBlackTree(ReturnAIfCloser, ReturnBIfCloser),
                tuple(Entered, Exited): redBlackTree(ReturnBIfCloser, AdvanceAAndLoop),
                tuple(Entered, Missed): redBlackTree(ReturnA),

                // A is Exited
                tuple(Exited, Entered): redBlackTree(ReturnAIfCloser, AdvanceBAndLoop),
                tuple(Exited, Exited): redBlackTree(ReturnAIfFarther, ReturnBIfFarther),
                tuple(Exited, Missed): redBlackTree(ReturnA),

                // A is Missed
                tuple(Missed, Entered): redBlackTree(ReturnB),
                tuple(Missed, Exited): redBlackTree(ReturnB),
                tuple(Missed, Missed): redBlackTree(ReturnMiss),
            ];
    }
}
