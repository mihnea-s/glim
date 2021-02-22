module glim.shapes.csgintersection;

import std.math : pow;
import std.typecons : tuple;
import std.container.rbtree;

import glim.math.ray;
import glim.math.vector;
import glim.shapes.shape;
import glim.shapes.csg;



/// Constructive Solid Geometry Intersection
class CSGIntersection : CSG
{
    /// Create CSG Intersection from two shapes
    this(Shape a, Shape b) @safe nothrow
    {
        _a = a;
        _b = b;
    }

    /// Create CSG Intersection from multiple shapes
    this(Shape[] shapes...) @safe nothrow
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

    override final immutable(HitActionTable) getActionTable() const @safe nothrow
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
