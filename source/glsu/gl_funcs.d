/**
 * Redefines OpenGL functions.
 *
 * If debug specifier `glChecks` is active, redefines
 * all functions of `glad.gl.funcs` module (except `glGetError`)
 * and wraps them between `glsu.clearGLErrors` and `glsu.checkGLErrors` calls.
 * Each wrapper additionaly take three parameters, that are defaulted
 * to  `__FILE_FULL_PATH__`, `__LINE__`, and `__PRETTY_FUNCTION__`.
 *
 * If debug specifier `glChecks` is not active, just
 * public imports `glad.gl.funcs`.
 */
module glsu.gl_funcs;

debug(glChecks)
{
    public import glad.gl.funcs : glGetError;
    
    import glad.gl.types;
    import glad.gl.funcs;

    import std.traits : isFunctionPointer, Parameters, ReturnType, fullyQualifiedName;
    import std.array : join;
    import std.range : iota, only, enumerate;
    import std.algorithm.iteration : map;
    import std.meta : staticMap, allSatisfy;

    import glsu.util : debugHack;

    private enum isNotVoid(T) = !is(T == void);

    /** 
     * Generates parameter list without enclosing parentheses with parameter names of form `argn`, n = 0 .. typeNames.length.
     * Examples: `genParamList!(int, long) == "int arg0, long arg1`"
     */
    private auto genParamList(Ts...)()
        if(allSatisfy!(isNotVoid, Ts))
    {
        enum typeToString(T) = T.stringof;
        static if(Ts.length > 0)
        {
            return only(staticMap!(typeToString, Ts)).
                    enumerate.
                    map!"a.value ~ \" arg\" ~ to!string(a.index)".
                    join(", ");
        }
        else
        {
            return "";
        }
    }

    /** 
     * Generates argument list without enclosing parentheses with argument names of form `argn`, n = 0 .. typeNames.length.
     * Params:
     *   n = number of arguments
     */
    private auto genArgList(uint n)
    {
        return iota(0, n).map!"\"arg\" ~ to!string(a)".join(", ");
    }

    /** 
     * Defines a wrapper of a function from module `glad.gl.funcs` with the same name.
     *
     * Wraps a function with calls to `glsu.clearGLErrors` and `glsu.ckechGLErrors`,
     * additionally taking three parameters, that are defaulted to
     *  `__FILE_FULL_PATH__`, `__LINE__`, and `__PRETTY_FUNCTION__`.
     * Params:
     *   name = name of function to wrap
     */
    private mixin template genCheckedFunc(string name)
    {
        import glsu : clearGLErrors, checkGLErrors;

        alias func = __traits(getMember, glad.gl.funcs, name);
        enum fullName = fullyQualifiedName!func;

        alias Params = Parameters!func;
        alias Ret = ReturnType!func;

        enum params = genParamList!Params;
        enum additionalParams = "string file = __FILE_FULL_PATH__, size_t line = __LINE__, "
            ~ "string caller = __PRETTY_FUNCTION__";
        enum extendedParams = params ~ (params.length == 0 ? "" : ", ") ~ additionalParams;
        enum args = genArgList(Params.length);
        enum ret = Ret.stringof;

        enum signature = "extern(System) " ~ ret ~ " " ~ name ~ "(" ~ extendedParams ~ ") nothrow @nogc";
        
        enum bodyBegin = "\tclearGLErrors();";
        static if(is(Ret == void))
        {
            enum bodyMid = "\t" ~ fullName ~ "(" ~ args ~ ");";
            enum bodyRet = "";
        }
        else
        {
            enum bodyMid = "\t" ~ ret ~ " returnValue = " ~ fullName ~ "(" ~ args ~ ");";
            enum bodyRet = "\n\treturn returnValue;";
        }
        enum bodyEnd = "\tdebugHack({checkGLErrors(file, line, caller);});";

        enum body = "{\n" ~ bodyBegin ~ "\n" ~ bodyMid ~ "\n" ~ bodyEnd ~ bodyRet ~ "\n" ~ "}";

        enum generatedFunc = signature ~ "\n" ~ body;

        mixin(generatedFunc);
    }

    static foreach (name; __traits(allMembers, glad.gl.funcs))
    {
        static if (name != "glGetError"
                   && !is(__traits(getMember, glad.gl.funcs, name))
                   && isFunctionPointer!(__traits(getMember, glad.gl.funcs, name)))
        {
            mixin genCheckedFunc!name;
        }
    }
}
else
{
    public import glad.gl.funcs;
}