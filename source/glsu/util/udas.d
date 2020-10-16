module glsu.util.udas;

/** 
 * UDA for UDAs.
 * All UDAs are attributed by this type.
 */
package struct UDA
{
}

/** 
 * Marks a mixin template that contains functionality that can be mixed in struct.
 *
 * Behaviors are a way to implement partial structs.
 *
 * See_Also: $(LINK2 https://youtu.be/rSY78Hu8DqI, Mad With Power - The Hunt for New Compile-Time Idioms)
 */
@UDA struct Behavior
{
}

/** 
 * UDA for fields of a struct that are to used as vertex in `VertexBufferArray`.
 *
 * See_Also: `glsu.objects.VertexBufferLayout`, `glsu.objects.VertexBufferLayoutFromBuffer`.
 */
@UDA struct VertexAttrib
{
    /// Layout position of the attribute in a shader.
    uint index;

    /** 
     * Specifies whether fixed-point data values should be normalized or converted
     * directly as fixed-point values when they are accessed.
     */
    bool normalized = false;
}
