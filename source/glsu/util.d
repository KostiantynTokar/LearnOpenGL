/**
 * Utility functions and tempaltes.
 *
 * Authors: Kostiantyn Tokar
 */
module glsu.util;

import glsu.enums : GLType, GLError;

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

/** 
 * Import as expression.
 * Params:
 *   moduleName = name of a module to import from
 * See_Also: $(LINK2 https://dlang.org/blog/2017/02/13/a-new-import-idiom/, A New Import Idiom)
 * 
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

/** 
 * Repeatedly calls `glGetError`, clearing all GL error flags.
 */
void clearGLErrors() nothrow @nogc
{
    import glad.gl.funcs : glGetError;

    while(glGetError()) {}
}

/** 
 * Repeatedly checks `glGetError`.
 *
 * If error was discovered, prints error message to `stderr`
 * and exits program with `EXIT_FAILURE` code.
 * Params:
 *   message = written to stderr
 *   file = file name of caller
 *   line = line number of caller
 */
void checkGLErrors(string message = "",
                   string file = __FILE__,
                   size_t line = __LINE__)
{
    import glad.gl.funcs : glGetError;
    
    import core.stdc.stdlib : exit, EXIT_FAILURE;
    import std.stdio : stderr, writeln;
    
    bool flag = false;
    auto e = glGetError();
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

    if(flag)
    {
        exit(EXIT_FAILURE);
    }
}

/** 
 * If `valueOrError` holds `string`, then `stderr` it and exit program
 * with `EXIT_FAILURE` code;
 * else returns first component of `valueOrError` `Algebraic`.
 * Params:
 *   valueOrError = argument to check
 * Returns: value (i.e. first component of `Algebraic`) if `valueOrError` doesn't hold string.
 */
T checkError(T)(from!"std.variant".Algebraic!(T, string) valueOrError)
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
///
unittest
{
    import std.variant : Algebraic;

    auto a = Algebraic!(int, string)(42);
    assert(checkError!int(a) == 42);
}

/** 
 * UDA for UDAs.
 * All UDAs are attributed by this type.
 */
package struct UDA
{
}

/// mixin to `bind` `obj` immediately and `unbind` at `scope(exit)`.
enum ScopedBind(alias obj) = __traits(identifier, obj) ~ ".bind();"
    ~ "scope(exit)" ~ __traits(identifier, obj) ~ ".unbind();";

/** 
 * Hack to use until compiler bug with relaxed nothrow checks in nothrow context is fixed.
 * Params:
 *   a = delegate that is to used in nothrow context
 */
package void debugHack(scope void delegate() a) nothrow @nogc @trusted
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
