/**
 * Redefines OpenGL functions, could be imported instead of `glad.gl.funcs`.
 *
 * If debug specifier `glChecks` is active, redefines
 * all functions of `glad.gl.funcs` module (except `glGetError`)
 * and wraps them between `glsu.util.clearGLErrors` and `glsu.util.assertNoGLErrors` calls.
 * Each wrapper additionaly take two parameters, that are defaulted
 * to  `__FILE__` and `__LINE__`.
 *
 * If debug specifier `glChecks` is not active, just
 * public imports `glad.gl.funcs`.
 *
 * Authors: Kostiantyn Tokar.
 * Copyright: (c) 2020 Kostiantyn Tokar.
 * License: MIT License.
 */
module glsu.gl_funcs;

import glad.gl.funcs;

import std.traits : isFunctionPointer;
import std.meta : staticMap, Filter, templateNot;

private alias symbolOf(string name) = __traits(getMember, glad.gl.funcs, name);

private enum notIsModuleNorPackage(string name) = !__traits(isModule, symbolOf!name) &&
                                                  !__traits(isPackage, symbolOf!name);
private enum isFunctionPointerValue(string name) = !is(symbolOf!name) && isFunctionPointer!(symbolOf!name);

private alias allNames = __traits(allMembers, glad.gl.funcs);
private alias importableNames = Filter!(notIsModuleNorPackage, allNames);

/// Names of funcs to wrap (if `debug=glChecks`) (except `glGetError`).
private alias funcNames = Filter!(isFunctionPointerValue, importableNames);
/// Names to import unconditionally.
private alias anotherNames = Filter!(templateNot!isFunctionPointerValue, importableNames);

static foreach(name; anotherNames)
{
    mixin("public import glad.gl.funcs : " ~ name ~ ";");
}

debug(glChecks)
{
    public import glad.gl.funcs : glGetError;
    
    import glad.gl.types;
    import glad.gl.funcs;

    import std.traits : Parameters, ReturnType, fullyQualifiedName;
    import std.array : join;
    import std.range : iota, only, enumerate;
    import std.conv : to;
    import std.algorithm.iteration : map;
    import std.meta : allSatisfy;

    import glsu.util : debugHack;

    private enum isNotVoid(T) = !is(T == void);

    /** 
     * Generates parameter list without enclosing parentheses with parameter names of form `argk`, k = 0 .. Ts.length.
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
    ///
    unittest
    {
        assert(genParamList!() == "");
        assert(genParamList!(int) == "int arg0");
        assert(genParamList!(int, long) == "int arg0, long arg1");
    }
    
    /** 
     * Generates argument list without enclosing parentheses with argument names of form `argk`, k = 0 .. typeNames.length.
     * Params:
     *   n = Number of arguments.
     */
    private auto genArgList(uint n)
    {
        return iota(0, n).map!"\"arg\" ~ to!string(a)".join(", ");
    }
    ///
    unittest
    {
        assert(genArgList(0) == "");
        assert(genArgList(1) == "arg0");
        assert(genArgList(2) == "arg0, arg1");
    }
    
    /** 
     * Defines a wrapper of a function from module `glad.gl.funcs` with the same name.
     *
     * Wraps a function with calls to `glsu.util.clearGLErrors` and `glsu.util.ckechGLErrors`,
     * additionally taking two parameters, that are defaulted to
     *  `__FILE__` and `__LINE__`.
     * Params:
     *   name = Name of function to wrap.
     */
    private mixin template genCheckedFunc(string name)
    {
        import glsu.util : clearGLErrors, assertNoGLErrors;

        alias func = __traits(getMember, glad.gl.funcs, name);
        enum fullName = fullyQualifiedName!func;

        alias Params = Parameters!func;
        alias Ret = ReturnType!func;

        enum params = genParamList!Params;
        enum additionalParams = "string file = __FILE__, size_t line = __LINE__";
        enum extendedParams = params ~ (params.length == 0 ? "" : ", ") ~ additionalParams;
        enum args = genArgList(Params.length);
        enum ret = Ret.stringof;


        enum signature = "__gshared extern(System) " ~ ret ~ " " ~ name ~ "(" ~ extendedParams ~ ") nothrow @nogc";
        
        enum bodyImport = "\timport nogc.conv : text;";
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

        static if(Params.length == 0)
        {
            enum logMessage = `"Executing ` ~ name ~ `()"`;
        }
        else
        {
            enum logMessage = `text("Executing ` ~ name ~
                            `(", ` ~ iota(Params.length).map!`"arg" ~ a.to!string`.join(`, ", ", `) ~ `, ')')[]`;
        }
        enum bodyEnd = "\tassertNoGLErrors(" ~ logMessage ~ ", file, line);";

        enum body = "{\n" ~ 
                        bodyImport ~ "\n" ~
                        bodyBegin ~ "\n" ~
                        bodyMid ~ "\n" ~
                        bodyEnd ~
                        bodyRet ~ "\n" ~
                    "}";

        enum generatedFunc = signature ~ "\n" ~ body;
        mixin(generatedFunc);
    }

    static foreach (name; funcNames)
    {
        static if (name != "glGetError")
        {
            mixin genCheckedFunc!name;
        }
    }
}
else
{
    public import glad.gl.funcs;
}
