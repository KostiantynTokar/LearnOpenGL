module glsu;

/** 
 * Import as expression
 * Params:
 *   moduleName = name of a module to import from
 */
template from(string moduleName)
{
    mixin("import from = " ~ moduleName ~ ";");
}

struct UDA
{
}

@UDA struct VertexAttrib
{
    uint index;
    bool normalized = false;
}

struct GLFW
{
    @disable this();

static:
    bool isActive() @safe @nogc nothrow
    {
        return active;
    }

    bool activate(uint major, uint minor) @nogc nothrow
    {
        if (isActive)
        {
            return GLFW.major == major && GLFW.minor;
        }

        GLFW.major = major;
        GLFW.minor = minor;
        active = true;
        initLib();
        return true;
    }

    bool deactivate() @nogc nothrow
    {
        if (!isActive)
        {
            return false;
        }
        import bindbc.glfw : glfwTerminate;

        glfwTerminate();
        active = false;
        return true;
    }

    from!"bindbc.glfw".GLFWwindow* createWindow(int width, int height, string label) nothrow
    {
        import bindbc.glfw : glfwCreateWindow;
        import std.string : toStringz;

        return glfwCreateWindow(width, height, label.toStringz, null, null);
    }

private:
    bool active = false;
    uint major;
    uint minor;

    void initLib() @nogc nothrow
    {
        import bindbc.glfw : glfwInit, glfwWindowHint;
        import bindbc.glfw.types : GLFW_CONTEXT_VERSION_MAJOR,
            GLFW_CONTEXT_VERSION_MINOR, GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE;

        glfwInit();
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, major);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, minor);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    }
}

struct Binder(T)
{
    this(scope T* obj)
    {
        this.obj = obj;
        this.obj.bind();
    }

    ~this()
    {
        obj.unbind();
    }

private:

    T* obj;
}

auto binder(T)(return scope T* obj)
{
    return Binder!T(obj);
}

enum BufferType
{
    array = from!"glad.gl.enums".GL_ARRAY_BUFFER,
    element = from!"glad.gl.enums".GL_ELEMENT_ARRAY_BUFFER
}

enum DataUsage
{
    streamDraw = from!"glad.gl.enums".GL_STREAM_DRAW,
    streamRead = from!"glad.gl.enums".GL_STREAM_READ,
    streamCopy = from!"glad.gl.enums".GL_STREAM_COPY,

    staticDraw = from!"glad.gl.enums".GL_STATIC_DRAW,
    staticRead = from!"glad.gl.enums".GL_STATIC_READ,
    staticCopy = from!"glad.gl.enums".GL_STATIC_COPY,

    dynamicDraw = from!"glad.gl.enums".GL_DYNAMIC_DRAW,
    dynamicRead = from!"glad.gl.enums".GL_DYNAMIC_READ,
    dynamicCopy = from!"glad.gl.enums".GL_DYNAMIC_COPY
}

struct BufferObejct(BufferType type)
{
    this(T)(const T[] buffer, DataUsage usage) @nogc nothrow 
            if (type == BufferType.array || is(T == ubyte) || is(T == ushort) || is(T == uint))
    {
        import glad.gl.funcs : glGenBuffers;

        glGenBuffers(1, &id);
        setData(buffer, usage);
    }

    void setData(T)(const T[] buffer, DataUsage usage) @nogc nothrow 
            if (type == BufferType.array || is(T == ubyte) || is(T == ushort) || is(T == uint))
    {
        import glad.gl.funcs : glBindBuffer, glBufferData;

        auto b = binder(&this);
        glBufferData(type, buffer.length * T.sizeof, buffer.ptr, usage);
    }

    void bind() @nogc nothrow
    {
        import glad.gl.funcs : glBindBuffer;

        glBindBuffer(type, id);
    }

    void unbind() @nogc nothrow
    {
        import glad.gl.funcs : glBindBuffer;

        glBindBuffer(type, 0);
    }

private:
    uint id;
}

alias VertexBufferObject = BufferObejct!(BufferType.array);
alias ElementBufferArray = BufferObejct!(BufferType.element);

enum GLType
{
    glByte = from!"glad.gl.enums".GL_BYTE,
    glUByte = from!"glad.gl.enums".GL_UNSIGNED_BYTE,
    glShort = from!"glad.gl.enums".GL_SHORT,
    glUShort = from!"glad.gl.enums".GL_UNSIGNED_SHORT,
    glInt = from!"glad.gl.enums".GL_INT,
    glUInt = from!"glad.gl.enums".GL_UNSIGNED_INT,
    glHalfFloat = from!"glad.gl.enums".GL_HALF_FLOAT,
    glFloat = from!"glad.gl.enums".GL_FLOAT,
    glDouble = from!"glad.gl.enums".GL_DOUBLE
}

template valueofGLType(T)
{
    static if (is(T == byte))
    {
        enum valueofGLType = GLType.glByte;
    }
    else static if (is(T == ubyte))
    {
        enum valueofGLType = GLType.glUByte;
    }
    else static if (is(T == short))
    {
        enum valueofGLType = GLType.glShort;
    }
    else static if (is(T == ushort))
    {
        enum valueofGLType = GLType.glUShort;
    }
    else static if (is(T == int))
    {
        enum valueofGLType = GLType.glInt;
    }
    else static if (is(T == uint))
    {
        enum valueofGLType = GLType.glUInt;
    }
    else static if (is(T == float))
    {
        enum valueofGLType = GLType.glFloat;
    }
    else static if (is(T == double))
    {
        enum valueofGLType = GLType.glDouble;
    }
    else
    {
        static assert(0, "no according GLType");
    }
}

struct AttribPointer
{
    this(uint index, int size, GLType type, bool normalized, int stride, ptrdiff_t pointer) @nogc nothrow
    {
        this.index = index;
        this.size = size;
        this.type = type;
        this.normalized = normalized;
        this.stride = stride;
        this.pointer = pointer;
    }

    void enable() @nogc nothrow
    {
        import glad.gl.funcs : glEnableVertexAttribArray;
        import glad.gl.funcs : glVertexAttribPointer;

        glVertexAttribPointer(index, size, type, normalized, stride, cast(void*) pointer);
        glEnableVertexAttribArray(index);
    }

    void disable() @nogc nothrow
    {
        import glad.gl.funcs : glDisableVertexAttribArray;

        glDisableVertexAttribArray(index);
    }

private:

    uint index;
    int size;
    GLType type;
    bool normalized;
    int stride;
    ptrdiff_t pointer;
}

struct VertexArrayObject
{
    this(VertexBufferObject VBO, AttribPointer[] attrs) @nogc nothrow
    {
        import glad.gl.funcs : glGenVertexArrays;

        glGenVertexArrays(1, &id);
        auto b = binder(&this);

        VBO.bind();
        foreach (ref attr; attrs)
        {
            attr.enable();
        }
    }

    this(T)(const T[] buffer, DataUsage usage) @nogc nothrow
    {
        auto VBO = VertexBufferObject(buffer, usage);

        import glad.gl.enums : GL_MAX_VERTEX_ATTRIBS;
        import std.traits : getSymbolsByUDA, getUDAs;
        import std.meta : staticMap, staticSort, ApplyRight, NoDuplicates;
        import dlib.math.vector : Vector;

        alias attrSymbols = getSymbolsByUDA!(T, VertexAttrib);
        static assert(attrSymbols.length < GL_MAX_VERTEX_ATTRIBS, "too many attributes");

        alias attrs = staticMap!(ApplyRight!(getUDAs, VertexAttrib), attrSymbols);
        static assert(attrs.length == NoDuplicates!attrs.length, "indices should be unique");

        enum Comp(VertexAttrib a1, VertexAttrib a2) = a1.index < a2.index;
        alias sortedAttrs = staticSort!(Comp, attrs);
        bool isStepByOne(VertexAttrib[] attrs...) @safe @nogc pure nothrow
        {
            foreach (i, attr; attrs)
            {
                if (attr.index != i)
                    return false;
            }
            return true;
        }

        //why sortedAttrs.expand.only.enumarate.all!"a[0] == a[1].index" doesn't work? Expand?
        static assert(isStepByOne(sortedAttrs), "indices should ascend from 0 by 1");

        AttribPointer[attrs.length] attrPointers;
        //dfmt off
        static foreach (i; 0 .. attrSymbols.length)
        {{
            static if (is(typeof(attrSymbols[i]) == Vector!(U, N), U, int N) ||
                       is(typeof(attrSymbols[i]) == U[N], U, int N))
            {
                static assert(0 < N && N < 5,
                        "size (dimension of vector) should be in range from 1 to 4");

                GLType type = valueofGLType!U;

                attrPointers[i] = AttribPointer(attrs[i].index, N, type,
                        attrs[i].normalized, T.sizeof, attrSymbols[i].offsetof);
            }
            else
            {
                static assert(0, "vertex attribute should be a static array or dlib.math.vector.Vector");
            }
        }}
        //dfmt on

        this(VBO, attrPointers);
    }

    void bindElementBufferArray(ElementBufferArray EBO) @nogc nothrow
    {
        auto b = binder(&this);
        EBO.bind();
    }

    void unbindElementBufferArray() @nogc nothrow
    {
        import glad.gl.funcs : glBindBuffer;

        auto b = binder(&this);
        glBindBuffer(BufferType.element, 0);
    }

    void bind() @nogc nothrow
    {
        import glad.gl.funcs : glBindVertexArray;

        glBindVertexArray(id);
    }

    void unbind() @nogc nothrow
    {
        import glad.gl.funcs : glBindVertexArray;

        glBindVertexArray(0);
    }

private:

    uint id;
}
