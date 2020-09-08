/**
 * Utility functions and tempaltes.
 *
 * Authors: Kostiantyn Tokar
 */
module glsu.util;

import glsu.enums : GLType, GLError;
import glsu.objects : VertexBufferLayout, VertexBufferLayoutFromPattern;

/// Determine GL enum value that corresponds to D type.
template valueOfGLType(T)
{
    static assert(0, "no according GLType");
}
enum valueOfGLType(T : byte) = GLType.glByte; /// ditto
enum valueOfGLType(T : ubyte) = GLType.glUByte; /// ditto
enum valueOfGLType(T : short) = GLType.glShort; /// ditto
enum valueOfGLType(T : ushort) = GLType.glUShort; /// ditto
enum valueOfGLType(T : int) = GLType.glInt; /// ditto
enum valueOfGLType(T : uint) = GLType.glUInt; /// ditto
enum valueOfGLType(T : float) = GLType.glFloat; /// ditto
enum valueOfGLType(T : double) = GLType.glDouble; /// ditto

/// Size of GL privitive type in bytes.
ubyte sizeOfGLType(GLType t) pure nothrow @nogc @safe
{
    final switch(t)
    {
        case GLType.glByte: return byte.sizeof;
        case GLType.glUByte: return ubyte.sizeof;
        case GLType.glShort: return short.sizeof;
        case GLType.glUShort: return ushort.sizeof;
        case GLType.glInt: return int.sizeof;
        case GLType.glUInt: return uint.sizeof;
        case GLType.glFloat: return float.sizeof;
        case GLType.glDouble: return double.sizeof;
    }
}

/** 
 * Import as expression.
 * Params:
 *   moduleName = Name of a module to import from.
 *
 * See_Also: $(LINK2 https://dlang.org/blog/2017/02/13/a-new-import-idiom/, A New Import Idiom)
 */
template from(string moduleName)
{
    mixin("import from = " ~ moduleName ~ ";");
}
///
unittest
{
    void f(from!"std.typecons".Tuple!(int, double) arg)
    {
        from!"std.stdio".writeln(arg);
    }
}

//dfmt off
/// Description of GLError.
string errorDescription(GLError e)
{
    final switch(e)
    {
        case GLError.noError:
            return "No error has been recorded. The value of this symbolic constant is guaranteed to be 0.";
        
        case GLError.invalidEnum:
            return "An unacceptable value is specified for an enumerated argument. " ~
                   "The offending command is ignored and has no other side effect than to set the error flag.";
        
        case GLError.invalidValue:
            return "A numeric argument is out of range. " ~
                   "The offending command is ignored and has no other side effect than to set the error flag.";
        
        case GLError.invalidOperation:
            return "The specified operation is not allowed in the current state. " ~
                   "The offending command is ignored and has no other side effect than to set the error flag.";

        case GLError.invalidFramebufferOperation:
            return "The framebuffer object is not complete. " ~
                   "The offending command is ignored and has no other side effect than to set the error flag.";

        case GLError.outOfMemory:
            return "There is not enough memory left to execute the command. " ~
                   "The state of the GL is undefined, except for the state of the error flags, " ~
                   "after this error is recorded.";
    }
}
//dfmt on

bool isIntegral(GLType type) pure nothrow @nogc @safe
{
    final switch(type)
    {
        case GLType.glByte:
        case GLType.glUByte:
        case GLType.glShort:
        case GLType.glUShort:
        case GLType.glInt:
        case GLType.glUInt:
            return true;

        case GLType.glFloat:
        case GLType.glDouble:
            return false;
    }
}

/// Trait to determine vertex buffer layouts.
enum isVertexBufferLayout(T) = is(T : VertexBufferLayout) || is(T : VertexBufferLayoutFromPattern!(U), U);

/** 
 * Repeatedly calls `glGetError`, clearing all GL error flags.
 */
void clearGLErrors() nothrow @nogc
{
    import glad.gl.funcs : glGetError;

    while(glGetError()) {}
}

/** 
 * Asserts there are no active GL error glags.
 *
 * If error was discovered with `glGetError`,
 * prints error message to `stderr` and commits `assert(0)`.
 * Params:
 *   message = Written to stderr.
 *   file = File name of caller.
 *   line = Line number of caller.
 */
void assertNoGLErrors(string message = "",
                   string file = __FILE__,
                   size_t line = __LINE__) nothrow
{
    import glad.gl.funcs : glGetError;
    
    import std.stdio : stderr, writeln;
    
    bool flag = false;
    auto e = glGetError();

    try
    {
        if(e)
        {
            stderr.writeln("ERROR::GL::CALL");
            stderr.writeln("\t", message);
            stderr.writefln!"\tat %s:%s"(file, line);
            flag = true;
        }
        for(; e != 0; e = glGetError())
        {
            stderr.writefln!"\tError 0x%X: %s"(e, errorDescription(cast(GLError) e));
        }
    }
    catch (Exception e)
    {
        assert(0, "Exeption was thrown while writing error message.");
    }
    

    assert(!flag);
}

/** 
 * If `valueOrError` holds `string`, then `stderr` it and commits `assert(0)`;
 * else returns first component of `valueOrError` `Algebraic`.
 * Params:
 *   valueOrError = Argument to check.
 * Returns: Value (i.e. first component of `Algebraic`) if `valueOrError` doesn't hold string.
 */
T assertNoError(T)(from!"std.variant".Algebraic!(T, string) valueOrError) nothrow
{
    import std.stdio : stderr, writeln;

    T res;
    try
    {
        if (string* error = valueOrError.peek!string)
        {
            stderr.writeln(*error);
            assert(0);
        }
        res = valueOrError.get!T;
    }
    catch (Exception e)
    {
        assert(0, "Exeption was thrown while writing error message.");
    }
    return res;
}
///
unittest
{
    import std.variant : Algebraic;

    auto a = Algebraic!(int, string)(42);
    assert(assertNoError!int(a) == 42);
}

/** 
 * UDA for UDAs.
 * All UDAs are attributed by this type.
 */
package struct UDA
{
}

/// Wraps some functionality of GLFW
struct GLFW
{
    @disable this();

static:
    /** 
    * Checks if GLFW is active.
    * Returns: whether GLFW is active.
    */
    bool isActive() nothrow @nogc @safe
    {
        return _active;
    }

    /** 
     * Activate GLFW. GLFW should be activated before use.
     * Params:
     *   major = Major version of OpenGL to use.
     *   minor = Minor version of OpenGL to use.
     * Returns: Whether GLFW is activated with specified version of OpenGL.
     */
    bool activate(uint major, uint minor) nothrow @nogc
    {
        if (isActive)
        {
            return GLFW._major == major && GLFW._minor == minor;
        }

        GLFW._major = major;
        GLFW._minor = minor;
        _active = true;
        initLib();
        return true;
    }

    /** 
     * Deactivate GLFW.
     * Returns: Whether GLFW was active before.
     */
    bool deactivate() nothrow @nogc
    {
        if (!isActive)
        {
            return false;
        }
        import bindbc.glfw : glfwTerminate;

        glfwTerminate();
        _active = false;
        return true;
    }

    /** 
     * Create Window. GLFW should be active.
     * Params:
     *   width = Width of the window in pixels.
     *   height = Height of the window in pixels.
     *   label = Label of the window.
     * Returns: Handle of newly created window or null if window was not created.
     */
    from!"bindbc.glfw".GLFWwindow* createWindow(int width, int height, string label) nothrow
    {
        import bindbc.glfw : glfwCreateWindow;
        import std.string : toStringz;

        return glfwCreateWindow(width, height, label.toStringz, null, null);
    }

private:
    bool _active = false;
    uint _major;
    uint _minor;

    void initLib() nothrow @nogc
    {
        import bindbc.glfw : glfwInit, glfwWindowHint;
        import bindbc.glfw.types : GLFW_CONTEXT_VERSION_MAJOR,
            GLFW_CONTEXT_VERSION_MINOR, GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE;

        glfwInit();
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, _major);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, _minor);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    }
}

/// mixin to `bind` `obj` immediately and `unbind` at `scope(exit)`.
enum ScopedBind(alias obj) = __traits(identifier, obj) ~ ".bind();"
    ~ "scope(exit)" ~ __traits(identifier, obj) ~ ".unbind();";

/** 
 * Hack to use until compiler bug with relaxed nothrow checks in nothrow context is fixed.
 * Params:
 *   a = Delegate that is to used in nothrow context.
 */
void debugHack(scope void delegate() a) nothrow @nogc @trusted
{
    auto hack = cast(void delegate() @nogc) a;
    try
    hack();
    catch(Exception e)
        assert(0, e.msg);
}
///
unittest
{
    void foo() {}
    @safe nothrow @nogc pure void bar()
    {
        debug debugHack({foo();});
    }
}

/**
 * Tuple unpacker
 *
 * Usage: `myTuple.unpack!((x, y) => f(x, y));`
 *
 * Arguments are bound by order; names are irrelevant.
 *
 * See_Also:
 *   Based on `tupArg` by Dukc: $(LINK2 https://forum.dlang.org/thread/rkfezigmrvuzkztxqqxy@forum.dlang.org, An (old/new?) pattern to utilize phobos better with @nogc),
 *   $(LINK2 https://forum.dlang.org/post/lwcciwwvwdizlrwoxyiu@forum.dlang.org, @nogc closures),
 *   `packWith`.
 */
template unpack(alias func)
{
	import std.typecons: isTuple;

	auto unpack(TupleType)(TupleType tup)
		if (isTuple!TupleType)
	{
		return func(tup.expand);
	}
}
///
@nogc
unittest
{
    import std.range : zip, repeat;
    import std.algorithm : filter, map, each;
    
    const int j = 2;
    int i = 0;
    const int[3] tmp = [1, 2, 3];

    // tmp[]
    //     .filter!((x)scope => x == j) // lambda closes over variable j
    //     .each!((x)scope => i = x);
    tmp[]
    	.zip(repeat(j))
    	.filter!(unpack!((x, j) => x == j))
        .map!(unpack!((x, j) => x))
        .each!((x) scope => i = x);
    
    assert(i == 2);
}

/** 
 * Attaches values to a range. Usefull to avoid GC allocation of closure.
 * Params:
 *   r = An `InputRange`.
 *   args = Values that would be attached to each entry of `r`.
 *
 * See_Also:
 *   $(LINK2 https://forum.dlang.org/thread/rkfezigmrvuzkztxqqxy@forum.dlang.org, An (old/new?) pattern to utilize phobos better with @nogc),
 *   $(LINK2 https://forum.dlang.org/post/lwcciwwvwdizlrwoxyiu@forum.dlang.org, @nogc closures),
 *   `unpack`.
 */
auto packWith(R, Args...)(R r, Args args)
{
    import std.range : zip, repeat;

    string constructMixin() pure nothrow @safe
    {
        import std.range : iota, join, repeat;
        import std.algorithm : map;
        import std.conv : to;

        string res = "return r.zip(";
        res ~= iota(0, Args.length)
            .map!(i => "args[" ~ i.to!string ~ "].repeat")
            .join(",");
        res ~= ");";
        return res;
    }

    mixin(constructMixin());
}
///
@nogc
unittest
{
    import std.range : zip, repeat;
    import std.algorithm : filter, map, each;
    
    const int j = 2;
    const int k = 2;
    int i = 0;
    const int[3] tmp = [1, 2, 3];

    // tmp[]
    //     .filter!((x)scope => x == j) // lambda closes over variable j
    //     .each!((x)scope => i = x);
    tmp[]
    	.packWith(j, k)
    	.filter!(unpack!((x, j, k) => x * k == j))
        .map!(unpack!((x, j, k) => x))
        .each!((x) scope => i = x);
    
    assert(i == 1);
}

version(unittest)
{
    import bindbc.glfw;
    import glad.gl.loader;

    void setupOpenGLContext()
    {
        if(GLFW.isActive) return;

        GLFW.activate(3, 3);

        GLFWwindow* window = GLFW.createWindow(800, 600, "LearnOpenGL");
        assert(window, "Failed to create GLFW window.");
        glfwMakeContextCurrent(window);

        assert(gladLoadGL(), "Failed to initialize GLAD.");
    }
}
