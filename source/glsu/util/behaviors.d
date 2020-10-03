/** 
 * Behaviors are a way to implement partial structs.
 *
 * See_Also: $(LINK2 https://youtu.be/rSY78Hu8DqI, Mad With Power - The Hunt for New Compile-Time Idioms)
 */
module glsu.util.behaviors;

import glsu.util.udas : Behavior;

/** 
 * Basic functionality for vertex buffer layout objects.
 *
 * See_Also: `glsu.objects.VertexBufferLayout`, `glsu.objects.VertexBufferLayoutFromPattern`.
 */
@Behavior
mixin template VertexBufferLayoutBase()
{
    /** 
     * Count of attributes in a batch. Should be either 1 or equal to number of vertices in a buffer.
     *
     * By default equals to 1.
     *
     * Batch is a consecutive sequence of the same attributes.
     *
     * If `batchCount` is equal to 1, then attributes located in an interleaved way like
     *
     * 123412341234
     *
     * If `batchCount` greater then 1, it means that the same attributes located consecutively.
     * Example for `batchCount` equal to 3:
     *
     * 111222333444
     *
     * See_Also: $(LINK2 https://www.khronos.org/opengl/wiki/Vertex_Specification_Best_Practices, Vertex Specification Best Practices)
     */
    public size_t batchCount() const pure nothrow @nogc @safe
    {
        return _batchCount;
    }
    /// ditto
    public void batchCount(size_t newBatchCount) pure nothrow @nogc @safe
    {
        _batchCount = newBatchCount;
    }

    private size_t _batchCount = 1;
    invariant(_batchCount != 0, "There should be at least 1 attribute in a batch.");
    
    /** 
     * Internally used instead of `AttribPointer`.
     *
     * Index of an attribute is an index of the entry in `_elements`,
     * and stride and pointer is calculated according to `batchCount` and `padding`.
     */
    private struct LayoutElement
    {
        int size; // actually count
        GLType type;
        bool normalized;
        size_t padding;
    }
}
