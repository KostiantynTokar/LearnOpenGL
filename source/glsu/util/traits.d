module glsu.util.traits;

import glsu.util : from;

/**
 * Trait to determine vertex buffer layouts.
 *
 * Layout object is such an object that can be iterated in foreach loop as range of `glsu.objects.AttribPointer`'s.
 *
 * See_Also: `glsu.objects.AttribPointer`, `glsu.objects.VertexBufferLayout`, `glsu.objects.VertexBufferLayoutFromPattern`.
 */
enum isVertexBufferLayout(T) = is(from!"std.traits".ForeachType!T == from!"glsu.objects".AttribPointer);

/// Checks if `T` is a basic scalar GLSL type, i.e. `bool`, `int`, `uint` or `float`.
enum isGLSLBasicScalarType(T) = is(T == bool) || is(T == int) || is(T == uint) || is(T == float);

/** 
 * Checks if `T` is a basic vector GLSL type, i.e. `bvecn`, `ivecn`, `uvecn` or `vecn`, n = 2, 3 or 4.
 *
 * Here `gfm.math.Vector!(U, N)` with appropriate U and N correspond to GLSL analogue.
 */
template isGLSLBasicVectorType(T)
{
    import gfm.math : Vector;
    enum isGLSLBasicVectorType = is(T == Vector!(U, N), U, int N)
                                 && 1 < N && N < 5 && isGLSLBasicScalarType!U;
}

/// Checks if `T` is a basic scalar or vector GLSL type.
enum isGLSLBasicType(T) = isGLSLBasicScalarType!T || isGLSLBasicVectorType!T;

/// Checks if `T` is an array of basic GLSL type values.
enum isGLSLBasicArrayType(T) = from!"std.traits".isArray!T && isGLSLBasicType!(typeof(T.init[0]));

/// Checks if `T` is a struct that contains only GLSL basic types,
/// basic array types or another struct with such property.
template isGLSLStructType(T)
{
    static if(is(T == struct))
    {
        import std.meta : allSatisfy;
        import std.traits : Fields;

        enum isGLSLStructType = allSatisfy!(isGLSLType, Fields!T);
    }
    else
    {
        enum isGLSLStructType = false;
    }
}

/// Checks if `T` is an array of GLSL structs.
enum isGLSLStructArrayType(T) = from!"std.traits".isArray!T && isGLSLStructType!(typeof(T.init[0]));

/// Checks if `T` is an array of GLSL type values.
enum isGLSLArrayType(T) = isGLSLBasicArrayType!T || isGLSLStructArrayType!T;

/// Checks if `T` is a GLSL type.
enum isGLSLType(T) = isGLSLBasicType!T || isGLSLStructType!T || isGLSLArrayType!T;
///
unittest
{
    import gfm.math : vec2i, vec3f;

    struct A
    {
        float f;
        vec2i v;
        int i;
        bool[] bb;
    }
    struct B
    {
        vec3f v;
        A a;
        A[] aa;
    }
    struct C
    {
        B b;
        string s;
    }
    static assert(isGLSLType!(B[42]));
    static assert(!isGLSLType!C);
}