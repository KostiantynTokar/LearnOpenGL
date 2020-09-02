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

T checkError(T)(from!"std.variant".Algebraic!(T, string) valueOrError) nothrow
{
    import core.stdc.stdlib : exit, EXIT_FAILURE;
    import std.stdio : stderr, writeln;

    T res;
    try
    {
        if (string* error = valueOrError.peek!string)
        {
            stderr.writeln(*error);
            exit(EXIT_FAILURE);
        }
        res = valueOrError.get!T;
    }
    catch (Exception e)
    {
        exit(EXIT_FAILURE);
    }
    return res;
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

enum ScopedBind(alias obj) = __traits(identifier, obj) ~ ".bind();"
    ~ "scope(exit)" ~ __traits(identifier, obj) ~ ".unbind();";

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

        glGenBuffers(1, &_id);
        setData(buffer, usage);
    }

    void setData(T)(const T[] buffer, DataUsage usage) @nogc nothrow 
            if (type == BufferType.array || is(T == ubyte) || is(T == ushort) || is(T == uint))
    {
        import glad.gl.funcs : glBindBuffer, glBufferData;

        mixin(ScopedBind!this);
        glBufferData(type, buffer.length * T.sizeof, buffer.ptr, usage);

        static if (type == BufferType.element)
        {
            _indexType = valueofGLType!T;
        }
    }

    uint id() const @safe pure @nogc nothrow
    {
        return _id;
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

    static if (type == BufferType.element)
    {
        GLType indexType() const @nogc nothrow
        {
            return _indexType;
        }
    }

private:
    uint _id;

    static if (type == BufferType.element)
    {
        GLType _indexType;
    }
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

enum RenderMode
{
    points = from!"glad.gl.enums".GL_POINTS,
    lineStrip = from!"glad.gl.enums".GL_LINE_STRIP,
    lineLoop = from!"glad.gl.enums".GL_LINE_LOOP,
    lines = from!"glad.gl.enums".GL_LINES,
    lineStripAdjacency = from!"glad.gl.enums".GL_LINE_STRIP_ADJACENCY,
    linesAdjacency
        = from!"glad.gl.enums".GL_LINES_ADJACENCY,
        triangleStrip = from!"glad.gl.enums".GL_TRIANGLE_STRIP,
        triangleFan = from!"glad.gl.enums".GL_TRIANGLE_FAN, triangles
        = from!"glad.gl.enums".GL_TRIANGLES, triangleStripAdjacency
        = from!"glad.gl.enums".GL_TRIANGLE_STRIP_ADJACENCY,
        trianglesAdjacency = from!"glad.gl.enums".GL_TRIANGLES_ADJACENCY
}

struct VertexArrayObject
{
    this(VertexBufferObject VBO, AttribPointer[] attrs) @nogc nothrow
    {
        import glad.gl.funcs : glGenVertexArrays;

        glGenVertexArrays(1, &_id);
        mixin(ScopedBind!this);

        VBO.bind();
        foreach (ref attr; attrs)
        {
            attr.enable();
        }
    }

    this(T)(const T[] buffer, DataUsage usage) @nogc nothrow
    {
        auto VBO = VertexBufferObject(buffer, usage);

        import std.traits : getSymbolsByUDA, getUDAs;
        import std.meta : staticMap, staticSort, ApplyRight, NoDuplicates;
        import gfm.math.vector : Vector;

        alias attrSymbols = getSymbolsByUDA!(T, VertexAttrib);

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
                static assert(0, "vertex attribute should be a static array or gfm.math.vector.Vector");
            }
        }}
        //dfmt on

        this(VBO, attrPointers);
    }

    uint id() const @safe pure @nogc nothrow
    {
        return _id;
    }

    VertexArrayObjectIndexed bindElementBufferArray(ElementBufferArray EBO) @nogc nothrow
    {
        return VertexArrayObjectIndexed(this, EBO);
    }

    void draw(RenderMode mode, int first, int count) @nogc nothrow
    {
        import glad.gl.funcs : glDrawArrays;

        mixin(ScopedBind!this);
        glDrawArrays(mode, first, count);
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
    uint _id;
}

struct VertexArrayObjectIndexed
{
    VertexArrayObject VAO;

    alias VAO this;

    this(VertexArrayObject VAO, ElementBufferArray EBO) @nogc nothrow
    {
        this.VAO = VAO;
        indexType = EBO.indexType;
        mixin(ScopedBind!this);
        EBO.bind();
    }

    void drawElements(RenderMode mode, int count) @nogc nothrow
    {
        import glad.gl.funcs : glDrawElements;

        mixin(ScopedBind!this);
        glDrawElements(mode, count, indexType, null);
    }

private:
    GLType indexType;
}

struct Shader
{
    alias ShaderOrError = from!"std.variant".Algebraic!(Shader, string);
    static ShaderOrError create(string vertexShaderPath, string fragmentShaderPath)() nothrow
    {
        import std.variant : Algebraic;
        import std.string : toStringz;
        import glad.gl.funcs : glCreateShader, glShaderSource, glCompileShader,
            glGetShaderiv, glGetShaderInfoLog, glCreateProgram,
            glAttachShader, glLinkProgram, glGetProgramiv, glGetProgramInfoLog, glDeleteShader;
        import glad.gl.enums : GL_VERTEX_SHADER, GL_COMPILE_STATUS,
            GL_INFO_LOG_LENGTH, GL_FRAGMENT_SHADER, GL_LINK_STATUS;

        ShaderOrError res;

        int success;
        int infoLogLength;

        const(char)* vertexShaderSource = import(vertexShaderPath).toStringz;
        uint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexShaderSource, null);
        glCompileShader(vertexShader);
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &infoLogLength);
            char[] infoLog = new char[infoLogLength];
            glGetShaderInfoLog(vertexShader, infoLogLength, null, infoLog.ptr);
            res = "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n"
                ~ vertexShaderPath ~ "\n" ~ infoLog.idup;
            return res;
        }

        const(char)* fragmentShaderSource = import(fragmentShaderPath).toStringz;
        uint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, null);
        glCompileShader(fragmentShader);
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH, &infoLogLength);
            char[] infoLog = new char[infoLogLength];
            glGetShaderInfoLog(fragmentShader, infoLogLength, null, infoLog.ptr);
            res = "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n"
                ~ fragmentShaderPath ~ "\n" ~ infoLog.idup;
            return res;
        }

        uint shaderProgram = glCreateProgram();
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

        res = Shader(shaderProgram);
        return res;
    }

    uint id() const @safe pure @nogc nothrow
    {
        return _id;
    }

    void use() @nogc nothrow
    {
        import glad.gl.funcs : glUseProgram;

        glUseProgram(id);
    }

    int getUniformLocation(string name) const nothrow
    {
        import std.string : toStringz;
        import glad.gl.funcs : glGetUniformLocation;

        return glGetUniformLocation(id, name.toStringz);
    }

    void setUniform(Ts...)(string name, Ts values) nothrow 
            if (0 < Ts.length && Ts.length < 5
                && from!"std.traits".allSameType!Ts && (is(Ts[0] == bool)
                || is(Ts[0] == int) || is(Ts[0] == uint) || is(Ts[0] == float)))
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

        mixin("import glad.gl.funcs : " ~ funcName ~ ";");

        mixin(funcName ~ "(location, values);");
    }

    import gfm.math.matrix : Matrix;

    void setUniform(int R, int C)(string name, Matrix!(float, R, C)[] values...) nothrow
            if (2 <= R && R <= 4 && 2 <= C && C <= 4)
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

        mixin("import glad.gl.funcs : " ~ funcName ~ ";");

        mixin(funcName ~ "(location, cast(int) values.length, GL_TRUE, values[0].ptr);");
    }

    void setTextures(from!"std.typecons".Tuple!(Texture, string)[] textures...) nothrow
    in(textures.length <= 32, "It's possible to bind only 32 textures")do
    {
        foreach (i, textureNamePair; textures)
        {
            textureNamePair[0].bind(cast(uint) i);
            setUniform(textureNamePair[1], cast(int) i);
        }
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
        import glad.gl.funcs : glGenTextures, glBindTexture, glTexImage2D, glGenerateMipmap;

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

    void setWrapMode(Coord coord, Wrap wrap) @nogc nothrow
    {
        import glad.gl.funcs : glTexParameteri;
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

    void setMinFilter(Filter filter) @nogc nothrow
    {
        import glad.gl.funcs : glTexParameteri;
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER;

        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
    }

    void setMagFilter(Filter filter) @nogc nothrow
    {
        import glad.gl.funcs : glTexParameteri;
        import glad.gl.enums : GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER;

        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
    }

    uint id() const @safe pure @nogc nothrow
    {
        return _id;
    }

    void bind(uint index = 0) @nogc nothrow
    in(index <= 32, "It's possible to bind only 32 textures")do
    {
        import glad.gl.funcs : glActiveTexture, glBindTexture;
        import glad.gl.enums : GL_TEXTURE0, GL_TEXTURE_2D;

        glActiveTexture(GL_TEXTURE0 + index);
        glBindTexture(GL_TEXTURE_2D, id);
    }

private:
    uint _id;
}

struct Camera
{
    import gfm.math.vector : vec3f;
    import gfm.math.matrix : mat4f;
    import std.math : PI, PI_2;

    this(vec3f position, float yaw = -PI_2, float pitch = 0.0f,
            vec3f worldUp = vec3f(0.0f, 1.0f, 0.0f)) @safe @nogc nothrow
    {
        _position = position;
        _worldUp = worldUp;
        updateAngles(yaw, pitch);
        updateVectors();
    }

    vec3f position() const @safe pure @nogc nothrow
    {
        return _position;
    }

    vec3f front() const @safe pure @nogc nothrow
    {
        return _front;
    }

    vec3f right() const @safe pure @nogc nothrow
    {
        return _right;
    }

    vec3f up() const @safe pure @nogc nothrow
    {
        return _up;
    }

    vec3f worldUp() const @safe pure @nogc nothrow
    {
        return _worldUp;
    }

    float yaw() const @safe pure @nogc nothrow
    {
        return _yaw;
    }

    float pitch() const @safe pure @nogc nothrow
    {
        return _pitch;
    }

    mat4f getView() const @safe pure @nogc nothrow
    {
        return mat4f.lookAt(position, position + front, up);
    }

    void move(vec3f offset) @safe pure @nogc nothrow
    {
        _position += offset;
    }

    void moveFront(float offset) @safe pure @nogc nothrow
    {
        _position += offset * front;
    }

    void moveRight(float offset) @safe pure @nogc nothrow
    {
        _position += offset * right;
    }

    void moveUp(float offset) @safe pure @nogc nothrow
    {
        _position += offset * up;
    }

    void rotate(float yawOffset, float pitchOffset) @safe @nogc nothrow
    {
        updateAngles(yaw + yawOffset, pitch + pitchOffset);
        updateVectors();
    }

private:
    vec3f _position;
    vec3f _front;
    vec3f _up;
    vec3f _right;
    vec3f _worldUp;
    float _yaw;
    float _pitch;

    void updateAngles(float newYaw, float newPitch) @safe @nogc nothrow
    {
        import std.math : fmod;
        import gfm.math.funcs : radians;

        _yaw = fmod(newYaw, PI);
        _pitch = fmod(newPitch, radians(89.0f));
    }

    void updateVectors() @safe pure @nogc nothrow
    {
        import std.math : sin, cos;
        import gfm.math.vector : cross;

        immutable sp = sin(pitch);
        immutable cp = cos(pitch);

        immutable sy = sin(yaw);
        immutable cy = cos(yaw);

        _front = vec3f(cy * cp, sp, sy * cp).normalized;
        _right = cross(_front, _worldUp).normalized;
        _up = cross(_right, _front).normalized;
    }
}
