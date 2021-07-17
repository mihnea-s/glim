module glim.rasterizing.shaders.shader;

import glim.image.rgba;

/// Abstract interface for shaders
interface Shader
{
    /// Fragment shader for lines.
    @safe RGBA fragLine() const;

    /// Fragment shader for triangles.
    @safe RGBA fragTriangle() const;
}
