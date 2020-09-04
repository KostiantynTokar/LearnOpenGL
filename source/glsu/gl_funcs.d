module glsu.gl_funcs;

debug(glChecks)
{
    public import glad.gl.funcs : glGetError;
    
    import glad.gl.types;
    import glad.gl.funcs;

    import std.traits : isFunctionPointer, Parameters, ReturnType, isSomeString, fullyQualifiedName;
    import std.array : join;
    import std.range : isInputRange, ElementType, iota, only, enumerate;
    import std.algorithm.iteration : map;
    import std.meta : staticMap, allSatisfy;

    import glsu.util : debugHack;

    private enum isNotVoid(T) = !is(T == void);

    /** 
     * Generates parameter list without enclosing parentheses with parameter names of form argn, n = 0 .. typeNames.length.
     * Params:
     *   typeNames = range of string representations of types
     * Examples: genParamList(only("int", "long")) == "int arg0, long arg1"
     */
    private auto genParamList(R)(R typeNames)
        if(isInputRange!R && isSomeString!(ElementType!R))
    {
        return typeNames.enumerate.map!"a.value ~ \" arg\" ~ to!string(a.index)".join(", ");
    }

    /** 
     * Generates parameter list without enclosing parentheses with parameter names of form argn, n = 0 .. typeNames.length.
     * Params:
     *   typeNames = string representations of types
     * Examples: genParamList("int", "long") == "int arg0, long arg1"
     */
    private auto genParamList(Ts...)(Ts typeNames)
        if(allSatisfy!(isSomeString, Ts))
    {
        return only(typeNames).genParamList();
    }

    /** 
     * Generates parameter list without enclosing parentheses with parameter names of form argn, n = 0 .. typeNames.length.
     * Examples: genParamList!(int, long) == "int arg0, long arg1"
     */
    private auto genParamList(Ts...)()
        // if(allSatisfy!(isNotVoid, Ts) && !Ts.length > 0)
    {
        enum typeToString(T) = T.stringof;
        return genParamList(staticMap!(typeToString, Ts));
    }

    private auto genParamList()
    {
        return "";
    }

    /** 
     * Generates argument list without enclosing parentheses with argument names of form argn, n = 0 .. typeNames.length.
     * Params:
     *   n = number of arguments
     */
    private auto genArgList(uint n)
    {
        return iota(0, n).map!"\"arg\" ~ to!string(a)".join(", ");
    }

    private void clearGLErrors() nothrow @nogc
    {
        while(glGetError()) {}
    }

    private void checkGLErrors(string file, size_t line, string func) @nogc
    {
        import core.stdc.stdlib : exit, EXIT_FAILURE;
        import std.stdio : stderr, writeln;
        
        bool flag = false;
        auto e = glGetError();
        if(e)
        {
            debug stderr.writeln("ERROR::GL::CALL");
            debug stderr.writefln!"\tin %s:%s while executing\n\t%s"(file, line, func);
            flag = true;
        }
        for(; e != 0; e = glGetError())
        {
            debug stderr.writefln!"\tError code: %X"(e);
        }

        if(flag)
        {
            exit(EXIT_FAILURE);
        }
    }

    mixin template genCheckedFunc(string name)
    {
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