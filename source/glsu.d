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

struct BufferObejct
{
    this(const void[] buffer, BufferType type, DataUsage usage) @nogc nothrow
    {
        import glad.gl.funcs: glGenBuffers;
        glGenBuffers(1, &id);
        setData(buffer, type, usage);
    }

    void setData(const void[] buffer, BufferType type, DataUsage usage) @nogc nothrow
    {
        this.type = type;

        import glad.gl.funcs: glBindBuffer, glBufferData;
        glBindBuffer(type, id);
        glBufferData(type, buffer.length, buffer.ptr, usage);
        glBindBuffer(type, 0);
    }

    void bind() @nogc nothrow
    {
        import glad.gl.funcs: glBindBuffer;
        glBindBuffer(type, id);
    }
    
    void unbind() @nogc nothrow
    {
        import glad.gl.funcs: glBindBuffer;
        glBindBuffer(type, 0);
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

    enum BufferType
    {
        array = from!"glad.gl.enums".GL_ARRAY_BUFFER,
        element = from!"glad.gl.enums".GL_ELEMENT_ARRAY_BUFFER
    }

    private:
    uint id;
    BufferType type;
}

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

        import glad.gl.funcs: glVertexAttribPointer;
        glVertexAttribPointer(index, size, type, normalized, stride, cast(void*) pointer);
    }

    void enable() @nogc nothrow
    {
        import glad.gl.funcs: glEnableVertexAttribArray;
        glEnableVertexAttribArray(index);
    }

    void disable() @nogc nothrow
    {
        import glad.gl.funcs: glDisableVertexAttribArray;
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
