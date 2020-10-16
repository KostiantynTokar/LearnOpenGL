/** 
 * Behaviors are a way to implement partial structs.
 *
 * See_Also: $(LINK2 https://youtu.be/rSY78Hu8DqI, Mad With Power - The Hunt for New Compile-Time Idioms)
 */
module glsu.util.behaviors;

import glsu.util;
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

    /** 
     * Activates attributes with specified indices.
     *
     * Only active attributes of the layout are enabled in `bind` call.
     * Range interface provides range only over active attributes.
     * By default all atributes are active.
     *
     * Params:
     *   indices = Attributes with these indices will be activated.
     */
    public void activate(size_t[] indices...) pure nothrow @nogc @safe
    {
        if(_deactivatedAttrs !is null)
        {
            _deactivatedAttrs.removeKey(indices);
        }
    }

    /** 
     * Activates all attributes of the layout.
     *
     * Only active attributes of the layout are enabled in `bind` call.
     * Range interface provides range only over active attributes.
     * By default all atributes are active.
     */
    public void activateAll() pure nothrow @nogc @safe
    {
        if(_deactivatedAttrs !is null)
        {
            _deactivatedAttrs.clear();
        }
    }

    /** 
     * Deactivates attributes with specified indices.
     *
     * Only active attributes of the layout are enabled in `bind` call.
     * Range interface provides range only over active attributes.
     * By default all atributes are active.
     *
     * Params:
     *   indices = Attributes with these indices will be deactivated.
     */
    public void deactivate(size_t[] indices...) pure nothrow @safe
    {
        import std.algorithm : filter;
        if(indices.length > 0)
        {
            if(_deactivatedAttrs is null)
            {
                _deactivatedAttrs = new RedBlackTree!size_t();
            }
            _deactivatedAttrs.insert(indices.filter!(i => i < attrCount));
        }
    }

    /// Checks if attribute with specified index is active.
    public bool isActive(size_t index) const pure nothrow @nogc @safe
    {
        return _deactivatedAttrs is null || index !in _deactivatedAttrs;
    }

    private size_t _batchCount = 1;
    invariant(_batchCount != 0, "There should be at least 1 attribute in a batch.");

    import std.container : RedBlackTree;
    import std.typecons : scoped;

    private RedBlackTree!size_t _deactivatedAttrs;

    /// Converts index of an attribute into an index of that attribute in a range of active attributes.
    private size_t calcActiveIndex(size_t index) const pure nothrow @nogc @safe
    {
        import std.range : iota, popFrontExactly;
        import std.algorithm : filter, map;
        
        if(_deactivatedAttrs is null)
        {
            return index;
        }
        else
        {
            auto activeInds = iota(attrCount)
                .packWith(&this)
                .filter!(unpack!((i, l) => i !in l._deactivatedAttrs))
                .map!(unpack!((i, l) => i));
            popFrontExactly(activeInds, index);
            return activeInds.front;
        }
    }
    
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
