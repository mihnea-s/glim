module glim.shapes.csg;

import std.math : pow;
import std.typecons;
import std.exception;

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

    protected enum HitState : ubyte
    {
        AMissed = 1 << 0,
        AEntered = 1 << 1,
        AExited = 1 << 2,

        BMissed = 1 << 3,
        BEntered = 1 << 4,
        BExited = 1 << 5,
    }

    protected enum HitAction : ushort
    {
        ReturnA = 1 << 0,
        ReturnAIfCloser = 1 << 1,
        ReturnAIfFarther = 1 << 2,

        ReturnB = 1 << 3,
        ReturnBIfCloser = 1 << 4,
        ReturnBIfFarther = 1 << 5,

        AdvanceAAndLoop = 1 << 6,
        AdvanceBAndLoop = 1 << 7,

        FlipB = 1 << 8,
        ReturnMiss = 1 << 9,
    }

    @safe abstract ushort getActions(const ubyte) const nothrow;

    @safe @nogc private HitState getHitState(const Ray ray,
            const Nullable!Hit hitA, const Nullable!Hit hitB) const nothrow
    {
        // dfmt off
        immutable stateA = (!hitA.isNull)
                            ? ray.direction.dot(hitA.get.normal) <= 0
                                ? HitState.AEntered 
                                : HitState.AExited
                            : HitState.AMissed;

        immutable stateB = (!hitB.isNull)
                            ? ray.direction.dot(hitB.get.normal) <= 0
                                ? HitState.BEntered 
                                : HitState.BExited
                            : HitState.BMissed;
        // dfmt on

        return stateA | stateB;
    }

    /// Test sphere hit
    @safe override final Nullable!Hit testRay(const Ray ray, Interval interval) const nothrow
    {
        auto invA = interval, invB = interval;
        auto hitA = _a.testRay(ray, invA), hitB = _b.testRay(ray, invB);

        while (true)
        {
            // dfmt off
            immutable state = getHitState(ray, hitA, hitB);
            immutable actions = getActions(state);

            // Actions returning A
            if (HitAction.ReturnA & actions
                 || ((HitAction.ReturnAIfCloser & actions) && hitA.get.t <= hitB.get.t)
                 || ((HitAction.ReturnAIfFarther & actions) && hitA.get.t > hitB.get.t))
                {
                return hitA;
            }
            // Actions returning B
            else if (HitAction.ReturnB & actions
                 || ((HitAction.ReturnBIfCloser & actions) && hitB.get.t <= hitA.get.t)
                 || ((HitAction.ReturnBIfFarther & actions) && hitB.get.t > hitA.get.t))
            {
                // Flip B's hit normal if needed
                if (HitAction.FlipB & actions)
                {
                    hitB.get.normal = -hitB.get.normal;
                }

                return hitB;
            }
            // Actions returning a miss
            else if (HitAction.ReturnMiss & actions)
            {
                return Nullable!Hit.init;
            }
            // Advance A and loop action
            else if (HitAction.AdvanceAAndLoop & actions)
            {
                invA.min = hitA.get.t + ADVANCE_AMOUNT;
                hitA = _a.testRay(ray, invA);
            }
            // Advance B and loop action
            else if (HitAction.AdvanceBAndLoop & actions)
            {
                invB.min = hitB.get.t + ADVANCE_AMOUNT;
                hitB = _b.testRay(ray, invB);
            }
            else 
            {
                assert(false, "invalid actions");
            }

            // dfmt on
        }
    }

    /// Make bounding box for CSG
    @safe @nogc override Nullable!AABB makeAABB() const nothrow
    {
        return Nullable!AABB.init;
    }
}
