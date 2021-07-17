module glim.rasterizing.meshes.mesh;

import glim.image.buffer;
import glim.math.vector;

/// TODO
public struct Face
{
    /// TODO
    public Vec3[3] position;

    /// TODO
    public Vec3[3] normal;

    /// TODO
    public Vec3[3] texture;
}

/// TODO
public struct Mesh
{
    /// TODO
    public Face[] faces;

    /// TODO
    public BufferRGBA defuse;
}
