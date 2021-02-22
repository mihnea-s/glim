module glim.shapes.csgunion;

import std.typecons : tuple;
import std.container.rbtree;

import glim.shapes.csg;
import glim.shapes.shape;

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

    @safe override final immutable(HitActionTable) getActionTable() const
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
