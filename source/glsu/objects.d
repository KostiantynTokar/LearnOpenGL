/**
 * Wrappers of GL objects.
 *
 * Authors: Kostiantyn Tokar
 */
module glsu.objects;

import glsu.util;
import glsu.enums;
import glsu.gl_funcs;

/**
 * Represents buffer in GPU memory.
 * See_Also: `VertexBufferObject` and `ElementBufferArray` as actual instantiations of the template.
 */
struct BufferObejct(BufferType type)
{
    /** 
     * Constructor that transfer data to GPU memory.
     * Params:
     *   buffer = Buffer to transfer to GPU memory.
     *   usage = Describes how the buffer would be used.
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
     *   usage = Describes how the buffer would be used.
     */
    void setData(T)(const T[] buffer, DataUsage usage) nothrow @nogc
            if (type == BufferType.array || is(T == ubyte) || is(T == ushort) || is(T == uint))
    in(isValid && buffer.length <= int.max)do
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
     * Returns: OpenGL object id.
     */
    uint id() const pure nothrow @nogc @safe
    in(_id != 0)do
    {
        return _id;
    }

    /** 
     * Binds the buffer, affecting state of OpenGL.
     */
    void bind() const nothrow @nogc
    in(isValid)do
    {
        glBindBuffer(type, id);
    }

    /** 
     * Unbinds the buffer, affecting state of OpenGL.
     */
    void unbind() const nothrow @nogc
    in(isValid)do
    {
        glBindBuffer(type, 0);
    }

    static if (type == BufferType.element)
    {
        /** 
         * Returns: Type of indices that the buffer contains.
         */
        GLType indexType() const pure nothrow @nogc @safe
        in(isValid)do
        {
            return _indexType;
        }

        /** 
         * Returns: Count of indices that the buffer contains.
         */
        uint count() const pure nothrow @nogc @safe
        in(isValid)do
        {
            return _count;
        }
    }

    /** 
     * Deletes the object, affecting state of OpenGL. Object can't be used afterwards.
     */
    void destroy() nothrow @nogc
    in(isValid)do
    {
        glDeleteBuffers(1, &_id);
        _id = 0;
    }

    /** 
     * Checks if object is not destroyed and it can be used.
     * Returns: Whether object is not destroyed.
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
 *   `VertexArrayObjectIndexed` for examples.
 */
alias ElementBufferArray = BufferObejct!(BufferType.element);

/// Represents abstract vertex attribute. Set of `AttribPointer`'s is used to specify layout of `VertexBufferObject`.
struct AttribPointer
{
    /** 
     * Constructor that sets arguments for `glVertexAttribPointer` (doesn't do anything else).
     * Params:
     *   index = Specifies the index of the generic vertex attribute to be modified.
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
     *   pointer = Specifies a offset of the first component of the first generic vertex attribute in the `VertexBufferObject`.
     */
    this(uint index, int size, GLType type, bool normalized, int stride, ptrdiff_t pointer) pure nothrow @nogc @safe
    in(0 < size && size < 5)
    in(normalized || type == GLType.glFloat || type == GLType.glDouble,
       "normalized may be set only for integer types")
    do
    {
        this._index = index;
        this._size = size;
        this._type = type;
        this._normalized = normalized;
        this._stride = stride;
        this._pointer = pointer;
    }

    /** 
     * Enables and sets the attribute.
     */
    void enable() const nothrow @nogc
    {
        glVertexAttribPointer(_index, _size, _type, _normalized, _stride, cast(void*) _pointer);
        glEnableVertexAttribArray(_index);
    }

    /** 
     * Disables the attribute.
     */
    void disable() const nothrow @nogc
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

/**
 * Represents `VertexBufferObject` layout. Works as an array of `AttribPointer`'s.
 *
 * Allows specifying a layout step-by-step.
 * Calls to `push` and `pushUsingPattern` should be done accordingly to the offset of vertex attributes,
 * so that attributes with lesser offset should be pushed earlier.
 */
struct VertexBufferLayout
{
public:
    /** 
     * Pushes new attribute to the layout.
     * Params:
     *   size = Specifies the number of components per generic vertex attribute. Must be 1, 2, 3, 4.
     *   type = Specifies the data type of each component in the array.
     *   normalized = specifies whether fixed-point data values should be normalized (true) or
     *                converted directly as fixed-point values (false) when they are accessed.
     *                If `normalized` is set to true, it indicates that values stored in an integer format
     *                are to be mapped to the range [-1,1] (for signed values) or [0,1] (for unsigned values)
     *                when they are accessed and converted to floating point.
     *                Otherwise, values will be converted to floats directly without normalization.
     */
    void push(int size, GLType type, bool normalized = false) pure nothrow @nogc
    in(0 < size && size < 5)
    in(normalized || type == GLType.glFloat || type == GLType.glDouble,
       "normalized may be set only for integer types")
    do
    {
        elements ~= LayoutElement(size, type, normalized, calcStride());
    }

    /** 
     * Pushes new attribute to the layout. Determines `GLType` from the template parameter.
     * Params:
     *   size = Specifies the number of components per generic vertex attribute. Must be 1, 2, 3, 4.
     *   normalized = specifies whether fixed-point data values should be normalized (true) or
     *                converted directly as fixed-point values (false) when they are accessed.
     *                If `normalized` is set to true, it indicates that values stored in an integer format
     *                are to be mapped to the range [-1,1] (for signed values) or [0,1] (for unsigned values)
     *                when they are accessed and converted to floating point.
     *                Otherwise, values will be converted to floats directly without normalization.
     */
    void push(T)(int size, bool normalized = false) pure nothrow @nogc
    in(0 < size && size < 5)do
    {
        push(size, valueOfGLType!T, normalized);
    }

    void pushUsingPattern(T)() pure nothrow @nogc
    {
        import std.traits : getSymbolsByUDA, getUDAs;
        import std.meta : staticMap, staticSort, ApplyRight, NoDuplicates;
        import std.range : only, enumerate;
        import std.algorithm.searching : all;
        import gfm.math.vector : Vector;

        alias attrSymbols = getSymbolsByUDA!(T, VertexAttrib);

        alias attrs = staticMap!(ApplyRight!(getUDAs, VertexAttrib), attrSymbols);
        static assert(attrs.length == NoDuplicates!attrs.length, "indices should be unique");

        enum Comp(VertexAttrib a1, VertexAttrib a2) = a1.index < a2.index;
        alias sortedAttrs = staticSort!(Comp, attrs);
        static assert(sortedAttrs.only.enumerate.all!"a.index == a.value.index", 
                "indices should ascend from 0 by 1");

        immutable prevLength = elements.length;
        immutable prevStride = calcStride();
        elements.length = elements.length + attrs.length;
        //dfmt off
        static foreach (i; 0 .. attrSymbols.length)
        {{
            static if (is(typeof(attrSymbols[i]) == Vector!(U, N), U, int N) ||
                       is(typeof(attrSymbols[i]) == U[N], U, int N))
            {
                static assert(0 < N && N < 5,
                        "size (dimension of vector) should be in range from 1 to 4");
                enum type = valueOfGLType!U;
                static assert(attrs[i].normalized || type == GLType.glFloat || type == GLType.glDouble,
                              "normalized may be set only for integer types");

                elements[prevLength + attrs[i].index] = 
                    LayoutElement(N, type, attrs[i].normalized, prevStride + attrSymbols[i].offsetof);
            }
            else
            {
                static assert(0, "vertex attribute should be a static array or gfm.math.vector.Vector");
            }
        }}
        //dfmt on
    }

    void enable() const nothrow @nogc
    in(elements.length <= uint.max)do
    {
        import std.range : enumerate;
        
        immutable stride = calcStride();

        foreach(i, ref elem; elements[].enumerate)
        {
            glVertexAttribPointer(cast(uint) i, elem.size, elem.type, elem.normalized, stride, cast(void*) elem.pointer);
            glEnableVertexAttribArray(cast(uint) i);
        }
    }

    void disable() const nothrow @nogc
    in(elements.length <= uint.max)do
    {
        foreach (i; 0 .. elements.length)
        {
            glDisableVertexAttribArray(cast(uint) i);
        }
    }
private:
    import std.container.array : Array;

    struct LayoutElement
    {
        int size; // actually count
        GLType type;
        bool normalized;
        ptrdiff_t pointer;
    }

    Array!LayoutElement elements;

    int calcStride() const pure nothrow @nogc
    {
        import std.algorithm.iteration : fold;
        
        return elements[].fold!((acc, elem) => acc + elem.size * elem.type.sizeOfGLType)(0);
    }
}

struct VertexArrayObject
{
    this(VertexBufferObject VBO, AttribPointer[] attrs) nothrow @nogc
    {
        glGenVertexArrays(1, &_id);
        mixin(ScopedBind!this);

        VBO.bind();
        foreach (ref attr; attrs)
        {
            attr.enable();
        }
    }

    this(VertexBufferObject VBO, VertexBufferLayout layout) nothrow @nogc
    {
        glGenVertexArrays(1, &_id);
        mixin(ScopedBind!this);

        VBO.bind();
        layout.enable();
    }

    this(T)(const T[] buffer, DataUsage usage) nothrow @nogc
    {
        auto VBO = VertexBufferObject(buffer, usage);
        VertexBufferLayout layout;
        layout.pushUsingPattern!T();
        this(VBO, layout);
    }

    uint id() const pure nothrow @nogc @safe
    in(_id != 0)do
    {
        return _id;
    }

    VertexArrayObjectIndexed bindElementBufferArray(ElementBufferArray EBO) const nothrow @nogc
    in(isValid)do
    {
        return VertexArrayObjectIndexed(this, EBO);
    }

    void draw(RenderMode mode, int first, int count) const nothrow @nogc
    in(isValid)do
    {
        mixin(ScopedBind!this);
        glDrawArrays(mode, first, count);
    }

    void bind() const nothrow @nogc
    in(isValid)do
    {
        glBindVertexArray(id);
    }

    void unbind() const nothrow @nogc
    in(isValid)do
    {
        glBindVertexArray(0);
    }

    void destroy() nothrow @nogc
    in(isValid)do
    {
        glDeleteVertexArrays(1, &_id);
        _id = 0;
    }

    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;
}

struct VertexArrayObjectIndexed
{
    VertexArrayObject VAO;

    alias VAO this;

    this(VertexArrayObject VAO, ElementBufferArray EBO) nothrow @nogc
    {
        this.VAO = VAO;
        _indexType = EBO.indexType;
        _count = EBO.count;
        mixin(ScopedBind!this);
        EBO.bind();
    }

    void drawElements(RenderMode mode, int count) const nothrow @nogc
    in(isValid)do
    {
        mixin(ScopedBind!this);
        glDrawElements(mode, count, _indexType, null);
    }

    void drawElements(RenderMode mode) const nothrow @nogc
    in(isValid)do
    {
        mixin(ScopedBind!this);
        glDrawElements(mode, _count, _indexType, null);
    }

private:
    GLType _indexType;
    int _count;
}

struct ShaderProgram
{
    enum Type
    {
        vertex = from!"glad.gl.enums".GL_VERTEX_SHADER,
        fragment = from!"glad.gl.enums".GL_FRAGMENT_SHADER,
    }

    alias ShaderProgramOrError = from!"std.variant".Algebraic!(ShaderProgram, string);
    static ShaderProgramOrError create(string vertexShaderPath, string fragmentShaderPath)()
    {
        import glad.gl.enums : GL_INFO_LOG_LENGTH, GL_FRAGMENT_SHADER, GL_LINK_STATUS;

        ShaderProgramOrError res;

        alias ShaderOrError = from!"std.variant".Algebraic!(uint, string);

        ShaderOrError compileShader(string shaderPath)(Type type)
        {
            import std.string : toStringz;
            import std.uni : toUpper;

            import glad.gl.enums : GL_COMPILE_STATUS;

            ShaderOrError res;

            int success;
            int infoLogLength;

            const(char)* shaderSource = import(shaderPath).toStringz;
            uint shader = glCreateShader(type);
            glShaderSource(shader, 1, &shaderSource, null);
            glCompileShader(shader);
            glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
            if (!success)
            {
                glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
                char[] infoLog = new char[infoLogLength];
                glGetShaderInfoLog(shader, infoLogLength, null, infoLog.ptr);
                res = "ERROR::SHADER::" ~ type.stringof.toUpper
                    ~ "::COMPILATION_FAILED\n" ~ shaderPath ~ "\n" ~ infoLog.idup;
                glDeleteShader(shader);
                return res;
            }

            res = shader;
            return res;
        }

        ShaderOrError vertexShaderOrError = compileShader!vertexShaderPath(Type.vertex);
        immutable vertexShader = assertNoError!uint(vertexShaderOrError);
        scope (exit)
            glDeleteShader(vertexShader);

        ShaderOrError fragmentShaderOrError = compileShader!fragmentShaderPath(Type.fragment);
        immutable fragmentShader = assertNoError!uint(fragmentShaderOrError);
        scope (exit)
            glDeleteShader(fragmentShader);

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
            res = "ERROR::SHADER::PROGRAM::LINK_FAILED\n" ~ infoLog.idup;
            return res;
        }

        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);

        res = ShaderProgram(shaderProgram);
        return res;
    }

    uint id() const pure nothrow @nogc @safe
    in(_id != 0)do
    {
        return _id;
    }

    void use() const nothrow @nogc
    in(isValid)do
    {
        glUseProgram(id);
    }

    int getUniformLocation(string name) const nothrow
    in(isValid)do
    {
        import std.string : toStringz;

        return glGetUniformLocation(id, name.toStringz);
    }

    void setUniform(Ts...)(string name, Ts values) nothrow 
            if (0 < Ts.length && Ts.length < 5
                && from!"std.traits".allSameType!Ts && (is(Ts[0] == bool)
                || is(Ts[0] == int) || is(Ts[0] == uint) || is(Ts[0] == float)))
    in(isValid)do
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

    import gfm.math.matrix : Matrix;

    void setUniform(int R, int C)(string name, Matrix!(float, R, C)[] values...) nothrow
            if (2 <= R && R <= 4 && 2 <= C && C <= 4)
    in(isValid)do
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

    void setTextures(from!"std.typecons".Tuple!(Texture, string)[] textures...) nothrow
    in(textures.length <= 32, "It's possible to bind only 32 textures")
    in(isValid)do
    {
        foreach (i, textureNamePair; textures)
        {
            textureNamePair[0].bind(cast(uint) i);
            setUniform(textureNamePair[1], cast(int) i);
        }
    }

    void destroy() nothrow @nogc
    in(isValid)do
    {
        glDeleteProgram(id);
        _id = 0;
    }

    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;
}

struct Texture
{
    alias TextureOrError = from!"std.variant".Algebraic!(Texture, string);
    static TextureOrError create(string imageFileName) nothrow
    {
        import imagefmt : set_yaxis_up_on_load, read_image, IF_ERROR;
        import glad.gl.enums : GL_RED, GL_RG, GL_RGB, GL_RGBA, GL_TEXTURE_2D,
            GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT;

        TextureOrError res;

        set_yaxis_up_on_load(true);
        auto image = read_image(imageFileName);
        if (image.e)
        {
            res = "ERROR::TEXTURE::READ_FAILED\n" ~ IF_ERROR[image.e];
            return res;
        }

        uint format;
        switch (image.c)
        {
        case 1:
            format = GL_RED;
            break;
        case 2:
            format = GL_RG;
            break;
        case 3:
            format = GL_RGB;
            break;
        case 4:
            format = GL_RGBA;
            break;
        default:
            assert(0);
        }

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
        glTexImage2D(GL_TEXTURE_2D, 0, cast(int) GL_RGB, image.w, image.h, 0,
                format, type, image.buf8.ptr);
        glGenerateMipmap(GL_TEXTURE_2D);

        res = Texture(texture);
        return res;
    }

    enum Coord
    {
        s,
        t
    }

    enum Wrap
    {
        clampToEdge = from!"glad.gl.enums".GL_CLAMP_TO_EDGE,
        clamptoBorder = from!"glad.gl.enums".GL_CLAMP_TO_BORDER,
        mirroredRepeat = from!"glad.gl.enums".GL_MIRRORED_REPEAT,
        repeat = from!"glad.gl.enums".GL_REPEAT
    }

    void setWrapMode(Coord coord, Wrap wrap) nothrow @nogc
    in(isValid)do
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

    enum Filter
    {
        nearest = from!"glad.gl.enums".GL_NEAREST,
        linear = from!"glad.gl.enums".GL_LINEAR,
        nearestMipmapNearest = from!"glad.gl.enums".GL_NEAREST_MIPMAP_NEAREST,
        nearestMipmapLinear = from!"glad.gl.enums".GL_NEAREST_MIPMAP_LINEAR,
        linearMipmapNearest = from!"glad.gl.enums".GL_LINEAR_MIPMAP_NEAREST,
        linearMipmapLinear = from!"glad.gl.enums".GL_LINEAR_MIPMAP_LINEAR

    }

    void setMinFilter(Filter filter) nothrow @nogc
    in(isValid)do
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER;

        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
    }

    void setMagFilter(Filter filter) nothrow @nogc
    in(isValid)do
    {
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER;

        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
    }

    uint id() const pure nothrow @nogc @safe
    in(_id != 0)do
    {
        return _id;
    }

    void bind(uint index = 0) const nothrow @nogc
    in(index <= 32, "It's possible to bind only 32 textures")
    in(isValid)do
    {
        import glad.gl.enums : GL_TEXTURE0, GL_TEXTURE_2D;

        glActiveTexture(GL_TEXTURE0 + index);
        glBindTexture(GL_TEXTURE_2D, id);
    }

    void destroy() nothrow @nogc
    in(isValid)do
    {
        glDeleteTextures(1, &_id);
        _id = 0;
    }

    bool isValid() const pure nothrow @nogc @safe
    {
        return id != 0;
    }

private:
    uint _id;
}
