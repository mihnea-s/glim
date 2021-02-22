module glim.shapes.csgintersection;

import std.typecons;
import std.container.rbtree;

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

    @safe override final immutable(HitActionTable) getActionTable() const
    {
        with (HitState) with (HitAction)
            return [

                // A is Entered
                tuple(Entered, Entered): redBlackTree(ReturnAIfFarther, ReturnBIfFarther),
                tuple(Entered, Exited): redBlackTree(ReturnAIfCloser, AdvanceBAndLoop),
                tuple(Entered, Missed): redBlackTree(ReturnMiss),

                // A is Exited
                tuple(Exited, Entered): redBlackTree(ReturnBIfCloser, AdvanceAAndLoop),
                tuple(Exited, Exited): redBlackTree(ReturnAIfCloser, ReturnBIfCloser),
                tuple(Exited, Missed): redBlackTree(ReturnMiss),

                // A is Missed
                tuple(Missed, Entered): redBlackTree(ReturnMiss),
                tuple(Missed, Exited): redBlackTree(ReturnMiss),
                tuple(Missed, Missed): redBlackTree(ReturnMiss),
            ];
    }
}
