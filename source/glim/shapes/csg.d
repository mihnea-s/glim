module glim.shapes.csg;

import std.math : pow;
import std.typecons;
import std.container.rbtree;

import glim.math.ray;
import glim.math.vector;
import glim.math.aabb;
import glim.shapes.shape;

/// Constructive Solid Geometry Base
/// Implements http://xrt.wdfiles.com/local--files/doc%3Acsg/CSG.pdf
/// DO NOT USE THIS DIRECTLY
class CSG : Shape
{
    protected Shape _a, _b;

    // The amount to advance the ray upon a hit.
    private static immutable ADVANCE_AMOUNT = 0.001;

    protected enum HitState
    {
        Missed,
        Entered,
        Exited,
    }

    protected enum HitAction
    {
        ReturnA,
        ReturnAIfCloser,
        ReturnAIfFarther,

        ReturnB,
        ReturnBIfCloser,
        ReturnBIfFarther,

        AdvanceAAndLoop,
        AdvanceBAndLoop,

        FlipB,
        ReturnMiss,
    }

    protected alias HitActionTable = RedBlackTree!HitAction[Tuple!(HitState, HitState)];

    abstract immutable(HitActionTable) getActionTable() const @safe nothrow;

    private HitState getHitState(const Ray ray, const Nullable!Hit hit) const @safe nothrow
    {
        // dfmt off
        return hit.isNull 
                ? ray.direction.dot(hit.get.normal) <= 0
                    ? HitState.Entered 
                    : HitState.Exited
                : HitState.Missed;
        // dfmt on
    }

    /// Test sphere hit
    override final Nullable!Hit testRay(const Ray ray, Interval interval) const @safe nothrow
    {
        import std.math : sqrt;
        import std.typecons : tuple;
        import std.algorithm : canFind;

        immutable actionTable = getActionTable();

        auto invA = interval, invB = interval;

        auto hitA = _a.testRay(ray, invA);
        auto hitB = _b.testRay(ray, invB);

        auto stateA = getHitState(ray, hitA);
        auto stateB = getHitState(ray, hitB);

        while (true)
        {
            // dfmt off
            immutable actions = actionTable[tuple(stateA, stateB)];

            // Actions returning A
            if (HitAction.ReturnA in actions
                 || (HitAction.ReturnAIfCloser in actions && hitA.get.t <= hitB.get.t)
                 || (HitAction.ReturnAIfFarther in actions && hitA.get.t > hitB.get.t))
                {
                return hitA;
            }
            // Actions returning B
            else if (HitAction.ReturnB in actions
                 || (HitAction.ReturnBIfCloser in actions && hitB.get.t <= hitA.get.t)
                 || (HitAction.ReturnBIfFarther in actions && hitB.get.t > hitA.get.t))
            {
                // Flip B's hit normal if needed
                if (HitAction.FlipB in actions)
                {
                    hitB.get.normal = -hitB.get.normal;
                }

                return hitB;
            }
            // Actions returning a miss
            else if (HitAction.ReturnMiss in actions)
            {
                return Nullable!Hit.init;
            }
            // Advance A and loop action
            else if (HitAction.AdvanceAAndLoop in actions)
            {
                invA.min = hitA.get.t + ADVANCE_AMOUNT;
                hitA = _a.testRay(ray, invA);
                stateA = getHitState(ray, hitA);
            }
            // Advance B and loop action
            else if (HitAction.AdvanceBAndLoop in actions)
            {
                invB.min = hitB.get.t + ADVANCE_AMOUNT;
                hitB = _b.testRay(ray, invB);
                stateB = getHitState(ray, hitB);
            }

            // dfmt on
        }
    }

    /// Make bounding box for CSG
    override Nullable!AABB makeAABB() const @safe nothrow
    {
        return Nullable!AABB.init;
    }
}
