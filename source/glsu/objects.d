/**
 * Wrappers of GL objects.
 *
 * Authors: Kostiantyn Tokar.
 * Copyright: (c) 2020 Kostiantyn Tokar.
 * License: MIT License.
 */
module glsu.objects;

import glsu.util;
import glsu.enums;
import glsu.gl_funcs;

/**
 * Represents buffer in GPU memory.
 *
 * See_Also: `VertexBufferObject` and `ElementBufferArray` as actual instantiations of the template.
 */
struct BufferObejct(BufferType type)
{
    @disable this();

    /** 
     * Constructor that transfer data to GPU memory.
     * Params:
     *   buffer = Buffer to transfer to GPU memory.
     *   usage = Describes how the `VertexBufferObject` would be used.
     */
    this(T)(const T[] buffer, DataUsage usage) nothrow @nogc
            if (type == BufferType.array || is(T == ubyte) || is(T == ushort) || is(T == uint))
    {
        glGenBuffers(1, &_id);
        setData(buffer, usage);
    }

    /** 
     * Transfers data to GPU memory.
     * Params:
     *   buffer = Buffer to transfer to GPU memory.
     *   usage = Describes how the `VertexBufferObject` would be used.
     */
    void setData(T)(const T[] buffer, DataUsage usage) nothrow @nogc
            if (type == BufferType.array || is(T == ubyte) || is(T == ushort) || is(T == uint))
    in(isValid && buffer.length <= int.max)
    {
        mixin(ScopedBind!this);
        glBufferData(type, buffer.length * T.sizeof, buffer.ptr, usage);

        static if (type == BufferType.element)
        {
            _indexType = valueOfGLType!T;
            _count = cast(int) buffer.length;
        }
    }

    /** 
     * OpenGL object id.
     */
    uint id() const pure nothrow @nogc @safe
    in(_id != 0)
    {
        return _id;
    }

    /** 
     * Binds the object, affecting state of OpenGL.
     */
    void bind() const nothrow @nogc
    in(isValid)
    {
        glBindBuffer(type, id);
    }

    /** 
     * Unbinds the object, affecting state of OpenGL, if debug=glChecks.
     */
    void unbind() const nothrow @nogc
    in(isValid)
    {
        debug(glChecks) glBindBuffer(type, 0);
    }

    static if (type == BufferType.element)
    {
        /** 
         * Type of indices that the buffer contains.
         */
        GLType indexType() const pure nothrow @nogc @safe
        in(isValid)
        {
            return _indexType;
        }

        /** 
         * Count of indices that the buffer contains.
         */
        uint count() const pure nothrow @nogc @safe
        in(isValid)
        {
            return _count;
        }
    }

    /** 
     * Deletes the object, affecting state of OpenGL. Object can't be used afterwards.
     */
    void destroy() nothrow @nogc
    in(isValid)
    {
        glDeleteBuffers(1, &_id);
        _id = 0;
    }

    /** 
     * Checks if object is not destroyed and it can be used.
     */
    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;

    static if (type == BufferType.element)
    {
        GLType _indexType;
        int _count;
    }
}

/** 
 * Represents raw data in GPU memory.
 *
 * See_Also: `BufferObject` for `VertexBufferObject` methods documentation.
 */
alias VertexBufferObject = BufferObejct!(BufferType.array);
///
unittest
{
    setupOpenGLContext();
    // Buffer in main memory.
    float[] abstractData = [
        -0.5f, -0.5f,
         0.5f, -0.5f,
         0.0f,  0.5f,
    ];
    // Transfer data to GPU memory.
    auto VBO = VertexBufferObject(abstractData, DataUsage.staticDraw);
    scope(exit) VBO.destroy();
}

/** 
 * Represents buffer of indices in GPU memory.
 *
 * See_Also:
 *   `BufferObject` for `ElementBufferArray` methods documentation.
 * 
 *   `IndexedVertexArrayObject` for examples.
 */
alias ElementBufferArray = BufferObejct!(BufferType.element);

/** 
 * Represents abstract vertex attribute. Set of `AttribPointer`'s can be used to specify layout of `VertexBufferObject`.
 *
 * See_Also: `VertexBufferObject`, `VertexArrayObject`, `VertexBufferLayout`.
 */
struct AttribPointer
{
    @disable this();

    /** 
     * Constructor that sets arguments for `glVertexAttribPointer` (doesn't do anything else).
     * Params:
     *   index = Specifies the index of the generic vertex attribute to be modified
     *           and location of the attribute in a vertex shader.
     *   size = Specifies the number of components per generic vertex attribute. Must be 1, 2, 3, 4.
     *   type = Specifies the data type of each component in the array.
     *   normalized = specifies whether fixed-point data values should be normalized (true) or
     *                converted directly as fixed-point values (false) when they are accessed.
     *                If `normalized` is set to true, it indicates that values stored in an integer format
     *                are to be mapped to the range [-1,1] (for signed values) or [0,1] (for unsigned values)
     *                when they are accessed and converted to floating point.
     *                Otherwise, values will be converted to floats directly without normalization.
     *   stride = Specifies the byte offset between consecutive generic vertex attributes.
     *            If stride is 0, the generic vertex attributes are understood to be tightly packed in the array.
     *   pointer = Specifies an offset of the first component of the first generic vertex attribute in the `VertexBufferObject`.
     */
    this(size_t index, int size, GLType type, bool normalized,
         size_t stride, ptrdiff_t pointer) pure nothrow @nogc @safe
    in(index <= uint.max)
    in(stride <= int.max)
    in(0 < size && size < 5,
        "Size (dimension of vector) should be in range from 1 to 4.")
    in(!normalized || isIntegral(type),
       "Normalized may be set only for integer types.")
    do
    {
        this._index = cast(uint) index;
        this._size = size;
        this._type = type;
        this._normalized = normalized;
        this._stride = cast(int) stride;
        this._pointer = pointer;
    }

    /** 
     * Enables and sets the attribute.
     */
    void bind() const nothrow @nogc
    {
        glVertexAttribPointer(_index, _size, _type, _normalized, _stride, cast(const(void)*) _pointer);
        glEnableVertexAttribArray(_index);
    }

    /** 
     * Disables the attribute.
     */
    void unbind() const nothrow @nogc
    {
        glDisableVertexAttribArray(_index);
    }

private:
    uint _index;
    int _size; // actually count
    GLType _type;
    bool _normalized;
    int _stride;
    ptrdiff_t _pointer;
}
///
unittest
{
    setupOpenGLContext();
    // Specifying layout of interleaved buffer.
    // 2D-coordinates and RGB color (5 floats total) per vertex.
    float[] vertices = [
        -0.5f, -0.5f, 1.0f, 0.0f, 0.0f, // vertex 1
         0.5f, -0.5f, 0.0f, 1.0f, 0.0f, // vertex 2
         0.0f,  0.5f, 0.0f, 0.0f, 1.0f, // vertex 3
    ];
    auto VBO = VertexBufferObject(vertices, DataUsage.staticDraw);
    auto positionAttrib = AttribPointer(0, 2, GLType.glFloat, false, 5 * float.sizeof, 0);
    auto colorAttrib = AttribPointer(1, 3, GLType.glFloat, false, 5 * float.sizeof, 2 * float.sizeof);
    auto VAO = VertexArrayObject(VBO, [positionAttrib, colorAttrib]);
    VAO.bind();
    // Now position and color of the vertex is accessible in vertex shader as
    // layout (location = 0) in vec2 position;
    // layout (location = 1) in vec3 color;
}
///
unittest
{
    setupOpenGLContext();
    // Specifying layout of buffer, that stores attribute blocks in a batch.
    // 2D-coordinates and RGB color (5 floats total) per vertex.
    float[] vertices = [
         // vertex 1          // vertex 2          // vertex 3
        -0.5f, -0.5f,         0.5f, -0.5f,         0.0f,  0.5f,        // positions
         1.0f,  0.0f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f, // colors
    ];
    auto VBO = VertexBufferObject(vertices, DataUsage.staticDraw);
    auto positionAttrib = AttribPointer(0, 2, GLType.glFloat, false, 2 * float.sizeof, 0);
    auto colorAttrib = AttribPointer(1, 3, GLType.glFloat, false, 3 * float.sizeof, 3 * 2 * float.sizeof);
    auto VAO = VertexArrayObject(VBO, [positionAttrib, colorAttrib]);
    VAO.bind();
    // Now position and color of the vertex is accessible in vertex shader as
    // layout (location = 0) in vec2 position;
    // layout (location = 1) in vec3 color;
}

/** 
 * UDA for fields of a struct that are to used as vertex in `VertexBufferArray`.
 *
 * See_Also: `VertexBufferLayout`.
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

/** 
 * Basic functionality for vertex buffer layout objects.
 *
 * See_Also: `VertexBufferLayout`, `VertexBufferLayoutFromPattern`.
 */
private struct VertexBufferLayoutBase
{
public:
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
    size_t batchCount() const pure nothrow @nogc @safe
    {
        return _batchCount;
    }
    /// ditto
    void batchCount(size_t newBatchCount) pure nothrow @nogc @safe
    {
        _batchCount = newBatchCount;
    }
private:
    size_t _batchCount = 1;
    invariant(_batchCount != 0, "There should be at least 1 attribute in a batch.");

    /** 
     * Internally used instead of `AttribPointer`.
     *
     * Index of an attribute is an index of the entry in `_elements`,
     * and stride and pointer is calculated according to `batchCount` and `padding`.
     */
    struct LayoutElement
    {
        int size; // actually count
        GLType type;
        bool normalized;
        size_t padding;
    }
}

/**
 * Represents `VertexBufferObject` layout. Works as an array of `AttribPointer`'s.
 *
 * Allows specifying a layout step-by-step.
 * Calls to `push` and should be done accordingly to the offset of vertex attributes,
 * so that attributes with lesser offset should be pushed earlier.
 *
 * Extends `VertexBufferLayoutBase`.
 *
 * See_Also: `VertexBufferLayoutBase`, `VertexBufferLayoutFromPattern`.
 */
struct VertexBufferLayout
{
public:
    /** 
     * Pushes new attribute to the layout.
     * Params:
     *   T = Specifies the data type of each component in the array.
     *   size = Specifies the number of components per generic vertex attribute. Must be 1, 2, 3, 4.
     *   type = Specifies the data type of each component in the array.
     *   normalized = specifies whether fixed-point data values should be normalized (true) or
     *                converted directly as fixed-point values (false) when they are accessed.
     *                If `normalized` is set to true, it indicates that values stored in an integer format
     *                are to be mapped to the range [-1,1] (for signed values) or [0,1] (for unsigned values)
     *                when they are accessed and converted to floating point.
     *                Otherwise, values will be converted to floats directly without normalization.
     *   padding = number of padding bytes to insert before attribute (if `batchCount == 1`)
     *             or before batch of attributes (if `batchCount > 1`).
     */
    void push(int size, GLType type, bool normalized = false, size_t padding = 0) pure nothrow @nogc
    in
    {
        immutable elem = LayoutElement(size, type, normalized, padding);
        immutable attr = calcAttribForNewElement(elem);
    }
    do
    {
        _elements ~= LayoutElement(size, type, normalized, padding);
    }
    /// ditto
    void push(T)(int size, bool normalized = false, size_t padding = 0) pure nothrow @nogc
    {
        push(size, valueOfGLType!T, normalized, padding);
    }

    /** 
     * Enables and sets all of the attributes represented by this object.
     */
    void bind() const nothrow @nogc
    {
        foreach(i; 0 .. _elements.length)
        {
            calcAttrib(i).bind();
        }
    }

    /** 
     * Disables all of the attributes represented by this object.
     */
    void unbind() const nothrow @nogc
    {
        foreach (i; 0 .. _elements.length)
        {
            calcAttrib(i).unbind();
        }
    }

    /** 
     * Indexing interface to interpret `VertexBufferLayout` as range of `AttribPointer`'s,
     */
    AttribPointer opIndex(size_t index) const pure nothrow @nogc
    {
        return calcAttrib(index);
    }
    /// ditto
    auto opIndex() const pure nothrow @nogc
    {
        return this[0 .. $];
    }
    /// ditto
    auto opIndex(size_t[2] slice) const pure nothrow @nogc
    {
        import std.range : iota, zip, repeat;
        import std.algorithm : map;
           
        return iota(slice[0], slice[1])
            .packWith(&this)
            .map!(unpack!((i, layout) => layout.calcAttrib(i)));
    }
    /// ditto
    size_t[2] opSlice(size_t dim : 0)(size_t start, size_t end) const pure nothrow @nogc @safe
    {
        return [start, end];
    }
    /// ditto
    size_t opDollar(size_t dim : 0)() const pure nothrow @nogc @safe
    {
        return _elements.length;
    }

private:
    /// Extended object.
    VertexBufferLayoutBase _base;
    
    alias _base this;

    import std.container.array : Array;
    alias LayoutElement = VertexBufferLayoutBase.LayoutElement;

    Array!LayoutElement _elements;

    /** 
     * Size of vertex attribute in bytes.
     */
    static size_t sizeOfAttribute(in ref LayoutElement elem) pure nothrow @nogc @safe
    {
        return elem.size * elem.type.sizeOfGLType;
    }
    /// ditto
    size_t sizeOfAttribute(size_t index) const pure nothrow @nogc @safe
    {
        return sizeOfAttribute(_elements[index]);
    }

    /** 
     * Size of vertex attribute in bytes (with padding).
     */
    static size_t sizeOfPaddedAttribute(in ref LayoutElement elem) pure nothrow @nogc @safe
    {
        return elem.padding + sizeOfAttribute(elem);
    }
    /// ditto
    size_t sizeOfPaddedAttribute(size_t index) const pure nothrow @nogc @safe
    {
        return sizeOfPaddedAttribute(_elements[index]);
    }

    /** 
     * Size of attribute batch in bytes.
     */
    size_t sizeOfBatch(in ref LayoutElement elem) const pure nothrow @nogc @safe
    {
        if(batchCount == 1)
        {
            return sizeOfPaddedAttribute(elem);
        }
        else
        {
            return elem.padding + batchCount * sizeOfAttribute(elem);
        }
    }
    /// ditto
    size_t sizeOfBatch(size_t index) const pure nothrow @nogc @safe
    {
        return sizeOfBatch(_elements[index]);
    }

    /** 
     * Calculates stride of the attribute located on `index`.
     */
    size_t calcStride(size_t index) const pure nothrow @nogc
    {
        import std.algorithm.iteration : map, sum;
        
        if(batchCount == 1)
        {
            return _elements[]
                .map!(sizeOfPaddedAttribute)()
                .sum(size_t.init);
        }
        else
        {
            return sizeOfAttribute(index);
        }
    }

    debug
    {
        size_t calcStrideForNewElement(in ref LayoutElement elem) const pure nothrow @nogc
        {
            import std.algorithm.iteration : map, sum;

            if(batchCount == 1)
            {
                return sizeOfPaddedAttribute(elem)
                    + _elements[]
                    .map!(sizeOfPaddedAttribute)()
                    .sum(size_t.init);
            }
            else
            {
                return sizeOfAttribute(elem);
            }
        }
    }

    /** 
     * Calculates pointer of the attribute located on `index`.
     */
    ptrdiff_t calcPointer(size_t index) const pure nothrow @nogc
    {
        import std.algorithm.iteration : map, sum;
        import std.range : iota;

        return _elements[index].padding
            + iota(index)
            .packWith(&this)
            .map!(unpack!((i, l) => l.sizeOfBatch(i)))()
            .sum(ptrdiff_t.init);
    }

    debug
    {
        ptrdiff_t calcPointerForNewElement(in ref LayoutElement elem) const pure nothrow @nogc @safe
        {
            import std.algorithm.iteration : map, sum;
            import std.range : iota;

            return elem.padding
                + iota(_elements.length)
                .packWith(&this)
                .map!(unpack!((i, l) => l.sizeOfBatch(i)))()
                .sum(ptrdiff_t.init);
        }
    }

    /** 
     * Calculates actual `AttribPointer` with specified index.
     * Params:
     *   index = Index of attribute to get.
     */
    AttribPointer calcAttrib(size_t index) const pure nothrow @nogc
    {
        return AttribPointer(index, _elements[index].size,
                             _elements[index].type, _elements[index].normalized,
                             calcStride(index), calcPointer(index));
    }

    debug
    {
        AttribPointer calcAttribForNewElement(in ref LayoutElement elem) const pure nothrow @nogc
        {
            return AttribPointer(_elements.length, elem.size,
                                 elem.type, elem.normalized,
                                 calcStrideForNewElement(elem), calcPointerForNewElement(elem));
        }
    }
}
///
unittest
{
    setupOpenGLContext();

    VertexBufferLayout layout1;
    layout1.push(3, GLType.glFloat);
    layout1.push(2, GLType.glInt, true);
    layout1.push!float(4);

    auto layout2 = [
        AttribPointer(0, 3, GLType.glFloat, false, (3 + 4) * float.sizeof + 2 * int.sizeof, 0),
        AttribPointer(1, 2, GLType.glInt,   true,  (3 + 4) * float.sizeof + 2 * int.sizeof, 3 * float.sizeof),
        AttribPointer(2, 4, GLType.glFloat, false, (3 + 4) * float.sizeof + 2 * int.sizeof, 3 * float.sizeof +
                                                                                            2 * int.sizeof)
    ];

    import std.algorithm : equal;
    assert(layout1[].equal(layout2));
    assert(layout1[0] == layout2[0]);
    assert(layout1[$ - 1] == layout2[$ - 1]);
    assert(layout1[0 .. 2].equal(layout2[0 .. 2]));

    // Now change batch size and reorganize layout.
    layout1.batchCount = 100;

    // Pay attention to stride and pointer.
    auto layout3 = [
        AttribPointer(0, 3, GLType.glFloat, false, 3 * float.sizeof, 0),
        AttribPointer(1, 2, GLType.glInt,   true,  2 * int.sizeof,   100 * 3 * float.sizeof),
        AttribPointer(2, 4, GLType.glFloat, false, 4 * float.sizeof, 100 * 3 * float.sizeof + 100 * 2 * int.sizeof)
    ];

    assert(layout1[].equal(layout3));
    assert(layout1[0] == layout3[0]);
    assert(layout1[$ - 1] == layout3[$ - 1]);
    assert(layout1[0 .. 2].equal(layout3[0 .. 2]));
}
///
unittest
{
    // Example with paddings.

    setupOpenGLContext();

    VertexBufferLayout layout1;
    layout1.push(3, GLType.glFloat, false, 4);
    layout1.push(2, GLType.glByte);
    layout1.push(3, GLType.glInt, true, 2);

    auto layout2 = [
        AttribPointer(0, 3, GLType.glFloat, false, 4 + 3 * float.sizeof + 2 + 2 * byte.sizeof + 3 * int.sizeof,
                                                                            4),
        AttribPointer(1, 2, GLType.glByte,  false, 4 + 3 * float.sizeof + 2 + 2 * byte.sizeof + 3 * int.sizeof,
                                                                            4 + 3 * float.sizeof),
        AttribPointer(2, 3, GLType.glInt,   true,  4 + 3 * float.sizeof + 2 + 2 * byte.sizeof + 3 * int.sizeof,
                                                                            4 + 3 * float.sizeof + 2 * byte.sizeof + 2)
    ];

    import std.algorithm : equal;
    assert(layout1[].equal(layout2));

    layout1.batchCount = 100;

    auto layout3 = [
        AttribPointer(0, 3, GLType.glFloat, false, 3 * float.sizeof, 4),
        AttribPointer(1, 2, GLType.glByte,  false, 2 * byte.sizeof,  4 + 100 * 3 * float.sizeof),
        AttribPointer(2, 3, GLType.glInt,   true,  3 * int.sizeof,   4 + 100 * 3 * float.sizeof + 
                                                                         100 * 2 * byte.sizeof + 2)
    ];

    assert(layout1[].equal(layout3));
}

/** 
 * Represents `VertexBufferObject` layout. Works as an array of `AttribPointer`'s.
 *
 * Layout statically determined by the pattern specified by type `T`.
 *
 * `T` should be a struct or a class.
 * It can represent an `AttribPointer` by specifying a field by UDA `VertexAttrib`.
 * That field should be a static array or has a type `gfm.math.vector.Vector`.
 * `VertexAttrib`s' indices should start from 0 and ascend by 1, but can be specified not in order. 
 *
 * Parameters of the attribute determined by:
 *
 * 1. index --- `VertexAttrib.index` value;
 *
 * 2. size --- length of static array or Vector;
 *
 * 3. type --- type of elements of static array or Vector;
 *
 * 4. normalized --- `VertexAttrib.normalized` value;
 *
 * 5. stride --- size of attributes and batchCount;
 *
 * 6. pointer --- size of attributes and batchCount.
 *
 * Extends `VertexBufferLayoutBase`.
 *
 * See_Also: `VertexBufferLayoutBase`, `VertexBufferLayout`.
 */
struct VertexBufferLayoutFromPattern(T)
    if(is(T == struct) || is(T == class))
{
public:
    /** 
     * Enables and sets all of the attributes represented by this object.
     */
    void bind() const nothrow @nogc
    {
        static foreach (i; 0 .. attrsCount)
        {
            calcAttrib!i().bind();
        }
    }

    /** 
     * Disables all of the attributes represented by this object.
     */
    void unbind() const nothrow @nogc
    {
        static foreach (i; 0 .. attrsCount)
        {
            calcAttrib!i().unbind();
        }
    }

    /** 
     * Indexing interface to interpret `VertexBufferLayout` as range of `AttribPointer`'s,
     */
    AttribPointer opIndex(size_t index) const pure nothrow @nogc
    {
        return this[][index];
    }
    /// ditto
    auto opIndex() const pure nothrow @nogc @safe
    {
        import std.range : only;
        import std.meta : staticMap;

        return only(staticMap!(calcAttrib, staticIota!(size_t, attrsCount)));
    }
    /// ditto
    auto opIndex(size_t[2] slice) const pure nothrow @nogc
    {
        return this[][slice[0] .. slice[1]];
    }
    /// ditto
    size_t[2] opSlice(size_t dim : 0)(size_t start, size_t end) const pure nothrow @nogc @safe
    {
        return [start, end];
    }
    /// ditto
    size_t opDollar(size_t dim : 0)() const pure nothrow @nogc @safe
    {
        return _elements.length;
    }

private:
    /// Extended object.
    VertexBufferLayoutBase _base;
    
    alias _base this;

    import std.traits : getSymbolsByUDA, getUDAs, isIntegral;
    import std.meta : AliasSeq, staticMap, staticSort, ApplyRight, NoDuplicates, staticIndexOf;
    import std.range : only, enumerate;
    import std.algorithm : all, sum;
    import gfm.math.vector : Vector;

    alias LayoutElement = VertexBufferLayoutBase.LayoutElement;

    alias markedSymbols = getSymbolsByUDA!(T, VertexAttrib);

    alias attrs = staticMap!(ApplyRight!(getUDAs, VertexAttrib), markedSymbols);
    static assert(attrs.length == markedSymbols.length, "Each field can be attributed by VertexAttrib only once.");
    static assert(attrs.length == NoDuplicates!attrs.length, "Indices should be unique.");

    enum comp(VertexAttrib a1, VertexAttrib a2) = a1.index < a2.index;
    alias sortedAttrs = staticSort!(comp, attrs);
    static assert(sortedAttrs.only.enumerate.all!"a.index == a.value.index", 
                  "Indices should ascend from 0 by 1.");

    enum compSymbols(alias s1, alias s2) = comp!(getUDAs!(s1, VertexAttrib)[0], getUDAs!(s2, VertexAttrib)[0]);
    alias sortedMarkedSymbols = staticSort!(compSymbols, markedSymbols);

    enum compSymbolsByOffset(alias s1, alias s2) = s1.offsetof < s2.offsetof;
    alias sortedByOffsetMarkedSymbols = staticSort!(compSymbolsByOffset, markedSymbols);

    enum attrsCount = attrs.length;

    enum getElement(size_t index) = LayoutElement(sizeAttributeParam!index,
                                                  valueOfGLType!(typeAttributeParam!index),
                                                  sortedAttrs[index].normalized,
                                                  paddingOfElement!index);

    alias _elements = staticMap!(getElement, staticIota!(size_t, attrsCount));

    template typeAndSizeOfAttribute(size_t index)
    {
        static if(is(typeof(sortedMarkedSymbols[index]) == Vector!(U, N), U, int N) ||
                  is(typeof(sortedMarkedSymbols[index]) == U[N], U, int N))
        {
            alias typeAndSizeOfAttribute = AliasSeq!(U, N);
        }
        else
        {
            static assert(0, "Vertex attribute should be a static array or gfm.math.vector.Vector.");
        }
    }

    /// Type of attribute with specified index.
    alias typeAttributeParam(size_t index) = typeAndSizeOfAttribute!index[0];
    /// Size (i.e. count of values) of attribute with specified index.
    enum sizeAttributeParam(size_t index) = typeAndSizeOfAttribute!index[1];

    /// Padding of an element with specified index.
    template paddingOfElement(size_t index)
    {
        alias curSymb = sortedMarkedSymbols[index];
        enum indexByOffset = staticIndexOf!(curSymb, sortedByOffsetMarkedSymbols);
        
        static if(indexByOffset == 0)
        {
            enum paddingOfElement = sortedMarkedSymbols[index].offsetof;
        }
        else
        {
            alias prevSymb = sortedByOffsetMarkedSymbols[indexByOffset - 1];
            enum paddingOfElement = curSymb.offsetof - (prevSymb.offsetof + prevSymb.sizeof);
        }
    }

    /// Size of vertex attribute in bytes.
    enum sizeOfAttribute(size_t index) = sizeAttributeParam!index * typeAttributeParam!index.sizeof;

    /// Size of vertex attribute in bytes (with padding).
    enum sizeOfPaddedAttribute(size_t index) = _elements[index].padding + sizeOfAttribute!index;

    /// Sum of sizes in bytes of all attributes (with paddings) with indices less then `index`.
    enum sizeOfAllPaddedAttributesBefore(size_t index) = [staticMap!(sizeOfPaddedAttribute, staticIota!(size_t, index))].sum(size_t.init);

    /** 
     * Size of attribute batch in bytes.
     */
    size_t sizeOfBatch(size_t index)() const pure nothrow @nogc @safe
    {
        if(batchCount == 1)
        {
            return sizeOfPaddedAttribute!index;
        }
        else
        {
            return _elements[index].padding + batchCount * sizeOfAttribute!index;
        }
    }

    /** 
     * Calculates stride of the attribute located on `index`.
     */
    size_t calcStride(size_t index)() const pure nothrow @nogc @safe
    {
        if(batchCount == 1)
        {
            return sizeOfAllPaddedAttributesBefore!attrsCount;
        }
        else
        {
            return sizeOfAttribute!index;
        }
    }

    /** 
     * Calculates pointer of the attribute located on `index`.
     */
    size_t calcPointer(size_t index)() const pure nothrow @nogc @safe
    {
        size_t res = _elements[index].padding;
        static foreach(i; 0 .. index)
        {
            res += sizeOfBatch!i();
        }
        return res;
    }

    /** 
     * Calculates actual `AttribPointer` with specified index.
     * Params:
     *   index = Index of attribute to get.
     */
    AttribPointer calcAttrib(size_t index)() const pure nothrow @nogc @safe
    {
        return AttribPointer(index, _elements[index].size,
                             _elements[index].type, _elements[index].normalized,
                             calcStride!(index), calcPointer!(index));
    }
}
///
unittest
{
    setupOpenGLContext();

    import gfm.math : vec4f;

    struct Pattern
    {
        @VertexAttrib(0)
        float[3] position;

        @VertexAttrib(2) // Possible to specify attributes not in order.
        vec4f attrib2;

        @VertexAttrib(1, true)
        int[2] textureCoords;

        // @VertexAttrib(42) // Error, indices should ascend by 1.
        // float[4] somethingElse;
    }

    VertexBufferLayoutFromPattern!Pattern layout1;

    auto layout2 = [
        AttribPointer(0, 3, GLType.glFloat, false, (3 + 4) * float.sizeof + 2 * int.sizeof, 0),
        AttribPointer(1, 2, GLType.glInt,   true,  (3 + 4) * float.sizeof + 2 * int.sizeof, 3 * float.sizeof),
        AttribPointer(2, 4, GLType.glFloat, false, (3 + 4) * float.sizeof + 2 * int.sizeof, 3 * float.sizeof +
                                                                                            2 * int.sizeof)
    ];

    import std.algorithm : equal;
    assert(layout1[].equal(layout2));
    assert(layout1[0] == layout2[0]);
    assert(layout1[$ - 1] == layout2[$ - 1]);
    assert(layout1[0 .. 2].equal(layout2[0 .. 2]));

    // Now change batch size and reorganize layout.
    layout1.batchCount = 100;

    // Pay attention to stride and pointer.
    auto layout3 = [
        AttribPointer(0, 3, GLType.glFloat, false, 3 * float.sizeof, 0),
        AttribPointer(1, 2, GLType.glInt,   true,  2 * int.sizeof,   100 * 3 * float.sizeof),
        AttribPointer(2, 4, GLType.glFloat, false, 4 * float.sizeof, 100 * 3 * float.sizeof + 100 * 2 * int.sizeof)
    ];

    assert(layout1[].equal(layout3));
    assert(layout1[0] == layout3[0]);
    assert(layout1[$ - 1] == layout3[$ - 1]);
    assert(layout1[0 .. 2].equal(layout3[0 .. 2]));
}
///
unittest
{
    // Example with paddings.

    setupOpenGLContext();

    struct Vertex
    {
        byte[4] padding0;

        @VertexAttrib(0)
        float[3] attr0;

        @VertexAttrib(1)
        byte[2] attr1;

        // Here padding2 is not necessary since int.alignof == 4 and field automatically padded by compiler.
        byte[2] padding2;

        @VertexAttrib(2, true)
        int[3] attr2;
    }

    VertexBufferLayoutFromPattern!Vertex layout1;

    auto layout2 = [
        AttribPointer(0, 3, GLType.glFloat, false, 4 + 3 * float.sizeof + 2 + 2 * byte.sizeof + 3 * int.sizeof,
                                                                            4),
        AttribPointer(1, 2, GLType.glByte,  false, 4 + 3 * float.sizeof + 2 + 2 * byte.sizeof + 3 * int.sizeof,
                                                                            4 + 3 * float.sizeof),
        AttribPointer(2, 3, GLType.glInt,   true,  4 + 3 * float.sizeof + 2 + 2 * byte.sizeof + 3 * int.sizeof,
                                                                            4 + 3 * float.sizeof + 2 * byte.sizeof + 2)
    ];

    import std.algorithm : equal;
    assert(layout1[].equal(layout2));

    layout1.batchCount = 100;

    auto layout3 = [
        AttribPointer(0, 3, GLType.glFloat, false, 3 * float.sizeof, 4),
        AttribPointer(1, 2, GLType.glByte,  false, 2 * byte.sizeof,  4 + 100 * 3 * float.sizeof),
        AttribPointer(2, 3, GLType.glInt,   true,  3 * int.sizeof,   4 + 100 * 3 * float.sizeof + 
                                                                         100 * 2 * byte.sizeof + 2)
    ];

    assert(layout1[].equal(layout3));
}

/** 
 * A Vertex Array Object (VAO) is an OpenGL Object that stores all of the state needed to supply vertex data.
 * It stores the format of the vertex data as well as the `BufferObject`'s.
 */
struct VertexArrayObject
{
    @disable this();

    /** 
     * Constructor that binds `VertexBufferObject` with a layout object.
     * Params:
     *   VBO = Buffer to bind with this VAO.
     *   layout = Layout of the `VBO`.
     *
     * See_Also: `VertexBufferObject`, `AttribPointer`, `VertexBufferLayout`, `VertexBufferLayoutFromPattern`.
     */
    this(Layout)(VertexBufferObject VBO, Layout layout) nothrow @nogc
        if(isVertexBufferLayout!Layout)
    {
        glGenVertexArrays(1, &_id);
        mixin(ScopedBind!this);

        VBO.bind();

        static if(is(typeof((Layout l) => l.bind())))
        {
            layout.bind();
        }
        else
        {
            foreach (ref attr; layout)
            {
                attr.bind();
            }
        }
    }
    ///
    unittest
    {
        setupOpenGLContext();

        struct Vertex
        {
            @VertexAttrib(0)
            float[2] position;

            @VertexAttrib(1)
            float[2] textureCoord;
        }

        float[] vertices = [
            -0.5f, -0.5f, 0.0f, 0.0f,
             0.5f, -0.5f, 1.0f, 0.0f,
             0.0f,  0.5f, 0.5f, 1.0f,
        ];
        auto VBO = VertexBufferObject(vertices, DataUsage.staticDraw);


        // Constructing with AttribPointer[].
        AttribPointer[] layout1 = [
            AttribPointer(0, 2, GLType.glFloat, false, 4 * float.sizeof, 0),
            AttribPointer(0, 2, GLType.glFloat, false, 4 * float.sizeof, 2 * float.sizeof),
        ];
        auto VAO1 = VertexArrayObject(VBO, layout1);

        // Constructing with VertexBufferLayout.
        VertexBufferLayout layout2;
        layout2.push!float(2);
        layout2.push!float(2);
        auto VAO2 = VertexArrayObject(VBO, layout2);

        // Constructing with VertexBufferLayoutFromPattern.
        VertexBufferLayoutFromPattern!Vertex layout3;
        auto VAO3 = VertexArrayObject(VBO, layout3);
    }

    /** 
     * Constructor that creates `VertexBufferObject` and automatically determines its layout using `T` as pattern.
     * Params:
     *   buffer = Source for `VertexBufferObject`.
     *   usage = Describes how the `VertexBufferObject` would be used.
     *
     * See_Also: `VertexBufferLayoutFromPattern`.
     */
    this(T)(const T[] buffer, DataUsage usage) nothrow @nogc
    {
        auto VBO = VertexBufferObject(buffer, usage);
        VertexBufferLayoutFromPattern!T layout;
        this(VBO, layout);
    }

    /** 
     * OpenGL object id.
     */
    uint id() const pure nothrow @nogc @safe
    in(_id != 0)
    {
        return _id;
    }

    /** 
     * Binds `ElementBufferArray` to the object.
     *
     * To use indexed drawing one should utilize returned `IndexedVertexArrayObject`.
     * Params:
     *   EBO = Index buffer to bind with the object.
     * Returns: VAO that can use provided `ElementBufferArray` in draw calls.
     *
     * See_Also: `IndexedVertexArrayObject`
     */
    IndexedVertexArrayObject bindElementBufferArray(ElementBufferArray EBO) const nothrow @nogc
    in(isValid)
    {
        return IndexedVertexArrayObject(this, EBO);
    }

    /** 
     * Draw call that uses vertices of `VertexBufferObject` and layout bounded to this object.
     * Params:
     *   mode = Specifies what kind of primitives to render.
     *   first = Specifies the starting index in the binded arrays.
     *   count = Specifies the number of vertices to be rendered.
     */
    void draw(RenderMode mode, int first, int count) const nothrow @nogc
    in(isValid)
    {
        mixin(ScopedBind!this);
        glDrawArrays(mode, first, count);
    }

    /** 
     * Binds the object, affecting state of OpenGL.
     */
    void bind() const nothrow @nogc
    in(isValid)
    {
        glBindVertexArray(id);
    }

    /** 
     * Unbinds the object, affecting state of OpenGL, if debug=glChecks.
     */
    void unbind() const nothrow @nogc
    in(isValid)
    {
        debug(glChecks) glBindVertexArray(0);
    }

    /** 
     * Deletes the object, affecting state of OpenGL. Object can't be used afterwards.
     */
    void destroy() nothrow @nogc
    in(isValid)
    {
        glDeleteVertexArrays(1, &_id);
        _id = 0;
    }

    /** 
     * Checks if object is not destroyed and it can be used.
     */
    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;
}
///
unittest
{
    setupOpenGLContext();
    
    struct Vertex
    {
        @VertexAttrib(0)
        float[2] position;

        @VertexAttrib(1)
        float[3] color;
    }

    Vertex[] vertices = [
        Vertex([-0.5f, -0.5f], [1.0f, 0.0f, 0.0f]),
        Vertex([ 0.5f, -0.5f], [0.0f, 1.0f, 0.0f]),
        Vertex([ 0.0f,  0.5f], [0.0f, 0.0f, 1.0f]),
    ];

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);
    scope(exit) VAO.destroy();

    void later()
    {
        VAO.draw(RenderMode.triangles, 0, 3);
    }
}

/** 
 * `VertexArrayObject` with binded `ElementBufferObject`.
 *
 * Used for indexing drawing.
 */
struct IndexedVertexArrayObject
{
    @disable this();
    
    /** 
     * Constructor that binds `ElementBufferArray` to `VertexArrayObject`.
     */
    this(VertexArrayObject VAO, ElementBufferArray EBO) nothrow @nogc
    {
        this.VAO = VAO;
        _indexType = EBO.indexType;
        _count = EBO.count;
        mixin(ScopedBind!this);
        EBO.bind();
    }

    /** 
     * Draw call that uses vertices of `VertexBufferObject`, layout and `ElementBufferArray` bounded to this object.
     * Params:
     *   mode = Specifies what kind of primitives to render.
     *   count = Specifies the number of elements to be rendered.
     */
    void drawElements(RenderMode mode, int count) const nothrow @nogc
    in(isValid)
    {
        mixin(ScopedBind!this);
        glDrawElements(mode, count, _indexType, null);
    }

    /** 
     * Draw call that uses vertices of `VertexBufferObject`, layout and `ElementBufferArray` bounded to this object.
     *
     * Uses all indices of bounded `ElementBufferArray`.
     * Params:
     *   mode = Specifies what kind of primitives to render.
     */
    void drawElements(RenderMode mode) const nothrow @nogc
    in(isValid)
    {
        mixin(ScopedBind!this);
        glDrawElements(mode, _count, _indexType, null);
    }

private:
    /// Underlying `VertexArrayObject`.
    VertexArrayObject VAO;
    alias VAO this;
    
    GLType _indexType;
    int _count;
}
///
unittest
{
    setupOpenGLContext();
    
    struct Vertex
    {
        @VertexAttrib(0)
        float[2] position;

        @VertexAttrib(1)
        float[3] color;
    }

    Vertex[] vertices = [
        Vertex([-0.5f, -0.5f], [1.0f, 0.0f, 0.0f]), // 0, bottom left
        Vertex([ 0.5f, -0.5f], [0.0f, 1.0f, 0.0f]), // 1, bottom right
        Vertex([ 0.5f,  0.5f], [0.0f, 0.0f, 1.0f]), // 2, top right
        Vertex([-0.5f,  0.5f], [1.0f, 0.0f, 1.0f]), // 3, top left
    ];
    uint[] indices = [
        0, 1, 2, // first triangle
        0, 2, 3, // second triangle
    ];

    auto EBO = ElementBufferArray(indices, DataUsage.staticDraw);

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw).bindElementBufferArray(EBO);
    scope(exit) VAO.destroy();

    void later()
    {
        VAO.drawElements(RenderMode.triangles, 3); // Draw only first triangle.
        VAO.drawElements(RenderMode.triangles); // Draw all elements.
    }
}

/// Represents OpenGL shader program.
struct ShaderProgram
{
    @disable this();

    /// Shader type
    enum ShaderType
    {
        vertex = from!"glad.gl.enums".GL_VERTEX_SHADER,
        fragment = from!"glad.gl.enums".GL_FRAGMENT_SHADER,
    }

    /** 
     * Compiles and links `ShaderProgram`.
     * Params:
     *   vertexShaderPath = Path to vertex shader source.
     *   fragmentShaderPath = Path to fragment shader source.
     * Returns: Ready to use `ShaderProgram` instance.
     * Throws: `CreateException` if compilation or linking failed.
     */
    static ShaderProgram create(string vertexShaderPath, string fragmentShaderPath)()
    {
        uint[2] shaders = compileAllShaders(import(vertexShaderPath), import(fragmentShaderPath),
                                            vertexShaderPath, fragmentShaderPath);
        scope(exit)
        {
            glDeleteShader(shaders[0]);
            glDeleteShader(shaders[1]);
        }
        return linkProgram(shaders[0], shaders[1]);
    }

    /** 
     * Compiles and links `ShaderProgram`.
     * Params:
     *   vertexShaderSource = Source code of vertex shader.
     *   fragmentShaderSource = Source code of fragment shader.
     * Returns: Ready to use `ShaderProgram` instance.
     * Throws: `CreateException` if compilation or linking failed.
     */
    static ShaderProgram createFromString(string vertexShaderSource, string fragmentShaderSource)
    {
        uint[2] shaders = compileAllShaders(vertexShaderSource, fragmentShaderSource);
        scope(exit)
        {
            glDeleteShader(shaders[0]);
            glDeleteShader(shaders[1]);
        }
        return linkProgram(shaders[0], shaders[1]);
    }

    /** 
     * OpenGL object id.
     */
    uint id() const pure nothrow @nogc @safe
    in(_id != 0)
    {
        return _id;
    }

    /** 
     * Activate program.
     */
    void bind() const nothrow @nogc
    in(isValid)
    {
        glUseProgram(id);
    }

    /** 
     * Deactivate program, if debug=glChecks.
     */
    void unbind() const nothrow @nogc
    in(isValid)
    {
        debug(glChecks) glUseProgram(0);
    }

    /** 
     * Gets an integer that represents the location of a
     * specific uniform variable within a program object.
     * Params:
     *   name = Name of the uniform variable in shader source.
     * Returns: Location of a uniform variable.
     */
    int getUniformLocation(string name) const nothrow
    in(isValid)
    {
        import std.string : toStringz;

        return glGetUniformLocation(id, name.toStringz);
    }

    /** 
     * Sets a uniform variable or vector.
     *
     * Values should have the same type
     * and their count should be 1, 2, 3 or 4.
     *
     * This method allows setting uniform values of privitive types (if values.length == 1)
     * and uniform vec's.
     * Params:
     *   name = Name of the uniform variable in shader source.
     *   values = Data to transfer to GPU memory for the `ShaderProgram`.
     */
    void setUniform(Ts...)(string name, Ts values) nothrow 
            if (0 < Ts.length && Ts.length < 5
                && from!"std.traits".allSameType!Ts && (is(Ts[0] == bool)
                || is(Ts[0] == int) || is(Ts[0] == uint) || is(Ts[0] == float)))
    in(isValid)
    {
        import std.conv : to;

        immutable location = getUniformLocation(name);

        alias T = Ts[0];

        static if (is(T == bool) || is(T == int))
        {
            enum suffix = "i";
        }
        else static if (is(T == uint))
        {
            enum suffix = "ui";
        }
        else static if (is(T == float))
        {
            enum suffix = "f";
        }
        enum funcName = "glUniform" ~ to!string(Ts.length) ~ suffix;

        mixin(funcName ~ "(location, values);");
    }

    import gfm.math : Matrix;

    /** 
     * Sets uniform matrix or uniform array of matrices.
     * Params:
     *   name = Name of the uniform variable in shader source.
     *   values = Matrix or matrices to transfer to GPU memory for the `ShaderProgram`.
     */
    void setUniform(int R, int C)(string name, Matrix!(float, R, C)[] values...) nothrow
            if (2 <= R && R <= 4 && 2 <= C && C <= 4)
    in(isValid)
    {
        import std.conv : to;
        import glad.gl.enums : GL_TRUE;

        immutable location = getUniformLocation(name);

        static if (R == C)
        {
            enum suffix = to!string(R);
        }
        else
        {
            enum suffix = to!string(C) ~ "x" ~ to!string(R);
        }
        enum funcName = "glUniformMatrix" ~ suffix ~ "fv";

        mixin(funcName ~ "(location, cast(int) values.length, GL_TRUE, values[0].ptr);");
    }

    /** 
     * Sets textures for the `ShaderProgram`.
     * Params:
     *   textures = pairs texture-name to set for the `ShaderProgram`.
     */
    void setTextures(from!"std.typecons".Tuple!(Texture, string)[] textures...) nothrow
    in(textures.length <= 32, "It's possible to bind only 32 textures")
    in(isValid)
    {
        foreach (i, textureNamePair; textures)
        {
            textureNamePair[0].bind(cast(uint) i);
            setUniform(textureNamePair[1], cast(int) i);
        }
    }

    /** 
     * Deletes the object, affecting state of OpenGL. Object can't be used afterwards.
     */
    void destroy() nothrow @nogc
    in(isValid)
    {
        glDeleteProgram(id);
        _id = 0;
    }

    /** 
     * Checks if object is not destroyed and it can be used.
     */
    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;

    this(uint id) pure nothrow @nogc @safe
    {
        _id = id;
    }

    /** 
     * Compiles shader from a source string.
     * Params:
     *   shaderSource = Source code to compile.
     *   type = Type of a shader.
     *   shaderPath = Path to a shader source file; should be provided if available for better error message.
     * Returns: OpenGL ID of a shader on succes, error message on failure.
     * Throws: `CreateException` if error occured while compiling.
     */
    static uint compileShader(string shaderSource, ShaderType type, string shaderPath = "")
    {
        import std.string : toStringz, empty;
        import std.uni : toUpper;
        import std.range : repeat, enumerate;
        import std.algorithm : map;
        import std.array : array, split, join;
        import std.format : format;

        import glad.gl.enums : GL_COMPILE_STATUS, GL_INFO_LOG_LENGTH;
        import glsu.exceptions : CreateException;

        int success;
        int infoLogLength;

        uint shader = glCreateShader(type);
        const(char)* shaderStringz = shaderSource.toStringz();
        glShaderSource(shader, 1, &shaderStringz, null);
        glCompileShader(shader);
        glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
            char[] infoLog = new char[infoLogLength];
            glGetShaderInfoLog(shader, infoLogLength, null, infoLog.ptr);
            glDeleteShader(shader);

            string message = "ERROR::SHADER::" ~ type.stringof.toUpper ~ "::COMPILATION_FAILED\n";
            if(shaderPath.empty)
            {
                message ~= repeat('-', 80).array.idup ~ "\n" ~ 
                           shaderSource.split("\n").enumerate(1).map!(t => format!"%4d:\t%s"(t.expand)).join("\n") ~ 
                           "\n" ~ repeat('-', 80).array.idup;
            }
            else
            {
                message ~= shaderPath;
            }
            message ~= "\n" ~ infoLog.idup;
            throw new CreateException(message);
        }

        return shader;
    }

    /** 
     * Compiles vertex and fragment shaders from a source strings.
     * Params:
     *   vertexShaderSource = Vertex shader source code to compile.
     *   fragmentShaderSource = Fragment shader source code to compile.
     *   vertexShaderPath = Path to a vertex shader source file; should be provided if available for better error message.
     *   fragmentShaderPath = Path to a fragment shader source file; should be provided if available for better error message.
     * Returns: OpenGL IDs of a vertex shader and fragment shader.
     * Throws: `CreateException` if error occured while compiling.
     */
    static uint[2] compileAllShaders(string vertexShaderSource, string fragmentShaderSource,
                                     string vertexShaderPath = "", string fragmentShaderPath = "")
    {
        uint[2] shaders = [
            compileShader(vertexShaderSource, ShaderType.vertex, vertexShaderPath),
            compileShader(fragmentShaderSource, ShaderType.fragment, fragmentShaderPath)
        ];
        return shaders;
    }

    /** 
     * Links vertex and fragment shader into a shader program.
     * Params:
     *   vertexShader = ID of a vertex shader.
     *   fragmentShader = ID of a fragment shader.
     * Returns: Ready to use `ShaderProgram` instance.
     * Throws: `CreateException` if error occured while linking.
     */
    static ShaderProgram linkProgram(uint vertexShader, uint fragmentShader)
    {
        import glad.gl.enums : GL_INFO_LOG_LENGTH, GL_LINK_STATUS;
        import glsu.exceptions : CreateException;

        int success;
        int infoLogLength;

        immutable shaderProgram = glCreateProgram();
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
        if (!success)
        {
            glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &infoLogLength);
            char[] infoLog = new char[infoLogLength];
            glGetProgramInfoLog(shaderProgram, infoLogLength, null, infoLog.ptr);
            throw new CreateException("ERROR::SHADER::PROGRAM::LINK_FAILED\n" ~ infoLog.idup);
        }

        return ShaderProgram(shaderProgram);
    }
}

/// 2D texture.
struct Texture
{
    @disable this();

    /** 
     * Loads an image and creates OpenGL texture with it.
     * Params:
     *   imageFileName = File name of an image to be used as a texture.
     *   numOfChannelsToStore = Specifies how many channels will be stored in GPU memory.
     *                          If image contains less channels, then stored as many channels as image has.
     * Throws: `glsu.exceptions.CreateException` if image load failed.
     */
    static Texture create(string imageFileName, uint numOfChannelsToStore = 4)
    in(0 < numOfChannelsToStore && numOfChannelsToStore < 5)
    {
        import std.algorithm : min;
        import glad.gl.enums : GL_RED, GL_RG, GL_RGB, GL_RGBA;
        
        static immutable uint[4] formats = [GL_RED, GL_RG, GL_RGB, GL_RGBA];
        
        auto image = readImage(imageFileName);
        scope(exit) image.free();
        immutable internalFormat = formats[min(numOfChannelsToStore, image.c) - 1];
        immutable format = formats[image.c - 1];
        return createImpl(image, internalFormat, format);
    }

    /// `Texture` coordinates.
    enum Coord
    {
        s,
        t
    }

    /// Wrap mode for specified coordinate.
    enum WrapMode
    {
        /**
         * Causes specified coordinates to be clamped to the range [1/2N, 1-1/2N],
         * where N is the size of the texture in the direction of clamping.
         */
        clampToEdge = from!"glad.gl.enums".GL_CLAMP_TO_EDGE,

        /**
         * Evaluates specified coordinates in a similar manner to clampToEdge.
         * However, in cases where clamping would have occurred in clampToEdge mode,
         * the fetched texel data is substituted with the values specified by GL_TEXTURE_BORDER_COLOR.
         */
        clampToBorder = from!"glad.gl.enums".GL_CLAMP_TO_BORDER,

        /**
         * Causes specified coordinate to be set to the fractional part of the texture coordinate
         * if the integer part of coordinate is even;
         * if the integer part of coordinate is odd,
         * then the texture coordinate is set to 1−frac(x),
         * where frac(x) represents the fractional part of x, and x is coordinate value.
         */
        mirroredRepeat = from!"glad.gl.enums".GL_MIRRORED_REPEAT,

        /**
         * Causes the integer part of the specified coordinate to be ignored;
         * the GL uses only the fractional part, thereby creating a repeating pattern.
         */
        repeat = from!"glad.gl.enums".GL_REPEAT
    }

    /** 
     * Sets the wrap parameter for specified texture coordinate.
     *
     * Default: `WrapMode.repeat`.
     */
    void setWrapMode(Coord coord, WrapMode wrap) nothrow @nogc
    in(isValid)
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_TEXTURE_WRAP_T;

        uint glCoord;
        final switch (coord)
        {
        case Coord.s:
            glCoord = GL_TEXTURE_WRAP_S;
            break;
        case Coord.t:
            glCoord = GL_TEXTURE_WRAP_T;
            break;
        }

        bind();
        glTexParameteri(GL_TEXTURE_2D, glCoord, wrap);
    }

    /** 
     * Sets a border color of a texture (used if WrapMode.clampToBorder is set).
     *
     * Default: `[0.0f, 0.0f, 0.0f, 0.0f]`.
     * Params:
     *   color = RGBA color with values from interval [0,1];
     *   if the texture contains depth components, the first component is interpreted as a depth value.
     */
    void setBorderColor(float[4] color) nothrow @nogc
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR;
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, color.ptr);
    }

    /// Filter type for minifying and magnifying functions.
    enum Filter
    {
        /**
         * Returns the value of the texture element that is nearest
         * (in Manhattan distance) to the specified texture coordinates.
         */
        nearest = from!"glad.gl.enums".GL_NEAREST,

        /**
         * Returns the weighted average of the four texture elements
         * that are closest to the specified texture coordinates.
         */
        linear = from!"glad.gl.enums".GL_LINEAR,

        /**
         * Chooses the mipmap that most closely matches the size of the pixel being textured
         * and uses the `nearest` criterion to produce a texture value.
         */
        nearestMipmapNearest = from!"glad.gl.enums".GL_NEAREST_MIPMAP_NEAREST,

        /**
         * Chooses the mipmap that most closely matches the size of the pixel being textured
         * and uses the `linear` criterion to produce a texture value.
         */
        nearestMipmapLinear = from!"glad.gl.enums".GL_NEAREST_MIPMAP_LINEAR,

        /**
         * Chooses the two mipmaps that most closely match the size of the pixel being textured
         * and uses the `nearest` criterion to produce a texture value from each mipmap.
         * The final texture value is a weighted average of those two values.
         */
        linearMipmapNearest = from!"glad.gl.enums".GL_LINEAR_MIPMAP_NEAREST,

        /**
         * Chooses the two mipmaps that most closely match the size of the pixel being textured
         * and uses the `linear` criterion to produce a texture value from each mipmap.
         * The final texture value is a weighted average of those two values.
         */
        linearMipmapLinear = from!"glad.gl.enums".GL_LINEAR_MIPMAP_LINEAR

    }

    /** 
     * Sets minifying filter.
     *
     * Default: `Filter.nearestMipmapLinear`.
     */
    void setMinFilter(Filter filter) nothrow @nogc
    in(isValid)
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER;

        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
    }

    /** 
     * Sets magnifying filter.
     *
     * Could be either Filter.nearest or Filter.linear.
     *
     * Default: `Filter.linear`.
     */
    void setMagFilter(Filter filter) nothrow @nogc
    in(isValid)
    in(filter == Filter.nearest || filter == Filter.linear)
    do
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER;

        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
    }

    /** 
     * OpenGL object id.
     */
    uint id() const pure nothrow @nogc @safe
    in(_id != 0)
    {
        return _id;
    }

    /** 
     * Binds the object, affecting state of OpenGL.
     */
    void bind(uint index = 0) const nothrow @nogc
    in(index <= 32, "It's possible to bind only 32 textures")
    in(isValid)
    {
        import glad.gl.enums : GL_TEXTURE0, GL_TEXTURE_2D;

        glActiveTexture(GL_TEXTURE0 + index);
        glBindTexture(GL_TEXTURE_2D, id);
    }

    /** 
     * Deletes the object, affecting state of OpenGL. Object can't be used afterwards.
     */
    void destroy() nothrow @nogc
    in(isValid)
    {
        glDeleteTextures(1, &_id);
        _id = 0;
    }

    /** 
     * Checks if object is not destroyed and it can be used.
     */
    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;

    this(uint id) pure nothrow @nogc @safe
    {
        _id = id;
    }

    /** 
     * Reads image from memory.
     *
     * Throws: `CreateException` if image load failed.
     */
    static auto readImage(string imageFileName)
    {
        import std.exception : enforce;
        import imagefmt : set_yaxis_up_on_load, read_image, IF_ERROR;
        import glsu.exceptions : CreateException;

        set_yaxis_up_on_load(true);
        auto image = read_image(imageFileName);
        enforce!CreateException(!image.e, "ERROR::TEXTURE::READ_FAILED\n" ~ IF_ERROR[image.e]);
        return image;
    }

    /** 
     * Implementation of `create`.
     * Params:
     *   image = Image to be used as a texture.
     *   internalFormat = May be one of following: `GL_RED`, `GL_RG`, `GL_RGB`, `GL_RGBA`.
     *   format = May be one of following: `GL_RED`, `GL_RG`, `GL_RGB`, `GL_RGBA`.
     * Returns: Ready to use `Texture` object.
     */
    static Texture createImpl(in ref from!"imagefmt".IFImage image, uint internalFormat, uint format)
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT;

        uint type;
        switch (image.bpc)
        {
        case 8:
            type = GL_UNSIGNED_BYTE;
            break;
        case 16:
            type = GL_UNSIGNED_SHORT;
            break;
        default:
            assert(0);
        }

        uint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D, 0, cast(int) internalFormat, image.w, image.h, 0,
                     format, type, image.buf8.ptr);
        glGenerateMipmap(GL_TEXTURE_2D);

        return Texture(texture);
    }
}
