module glsu.util;

import glsu.enums : GLType;

template valueofGLType(T)
{
    static assert(0, "no according GLType");
}
enum valueofGLType(T : byte) = GLType.glByte;
enum valueofGLType(T : ubyte) = GLType.glUByte;
enum valueofGLType(T : short) = GLType.glShort;
enum valueofGLType(T : ushort) = GLType.glUShort;
enum valueofGLType(T : int) = GLType.glInt;
enum valueofGLType(T : uint) = GLType.glUInt;
enum valueofGLType(T : float) = GLType.glFloat;
enum valueofGLType(T : double) = GLType.glDouble;

/** 
 * Import as expression.
 * Params:
 *   moduleName = name of a module to import from
 */
template from(string moduleName)
{
    mixin("import from = " ~ moduleName ~ ";");
}

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
        stderr.writefln!"\tError code: 0x%X"(e);
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

/** 
 * UDA for UDAs.
 * All UDAs are attributed by this type.
 */
package struct UDA
{
}

/** 
* Hack to use until compiler bug with relaxed nothrow checks in nothrow context is fixed.
* Params:
*   a = delegate that is to used in nothrow context
* Examples:
* ---
* void foo() {}
* @safe nothrow @nogc pure void main()
* {
*     debug debugHack({foo();});
* }    
* ---
*/
package void debugHack(scope void delegate() a) nothrow @nogc @trusted
{
    auto hack = cast(void delegate() @nogc) a;
    try
    hack();
    catch(Exception e)
        assert(0, e.msg);
}
