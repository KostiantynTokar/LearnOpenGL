/// GLSU-specific traits.
module glsu.util.traits;

import std.typecons : Flag, Yes, No;
import glsu.util : from, belongs;
import glsu.enums;

/**
 * Trait to determine vertex buffer layouts.
 *
 * Layout object is such an object that can be iterated in foreach loop as range of `glsu.objects.AttribPointer`'s.
 *
 * See_Also: `glsu.objects.AttribPointer`, `glsu.objects.VertexBufferLayout`, `glsu.objects.VertexBufferLayoutFromPattern`.
 */
enum isVertexBufferLayout(T) = is(from!"std.traits".ForeachType!T == from!"glsu.objects".AttribPointer);

/** 
 * Checks if type is one of basic types of image representation.
 *
 * See_Also:
 *   $(LINK2 https://www.khronos.org/opengl/wiki/Image_Format, Image Format),
 *   $(LINK2 https://www.khronos.org/opengl/wiki/Sampler_(GLSL), Sampler (GLSL)),
 *   $(LINK2 https://www.khronos.org/opengl/wiki/Image_Load_Store, Image Load Store).
 */
enum isImageFormatBasicType(T) = belongs!(T, ImageFormatBasicTypes);

/// Checks if `T` is a sampler type.
enum isGLSLSamplerType(T) = from!"std.traits".isInstanceOf!(from!"glsu.objects".Sampler, T);

/// Checks if `T` is a basic scalar GLSL type.
enum isGLSLBasicScalarType(T) = belongs!(T, GLSLBasicScalarTypes);

/** 
 * Checks if `T` is a basic vector GLSL type, i.e. `bvecn`, `ivecn`, `uvecn` or `vecn`, n = 2, 3 or 4.
 *
 * Here `gfm.math.Vector!(U, N)` with appropriate U and N corresponds to GLSL analogue.
 */
template isGLSLBasicVectorType(T)
{
    import gfm.math : Vector;
    enum isGLSLBasicVectorType = is(T == Vector!(U, N), U, int N)
                                 && 1 < N && N < 5 && isGLSLBasicScalarType!U;
}

/// Checks if `T` is a basic type of GLSL matrix.
enum isGLSLMatrixBasicType(T) = belongs!(T, GLSLMatrixBasicTypes);

/** 
 * Checks if `T` is a basic vector GLSL type, i.e. `bvecn`, `ivecn`, `uvecn` or `vecn`, n = 2, 3 or 4.
 *
 * Here `gfm.math.Matrix!(U, R, C)` with appropriate U, R and C corresponds to GLSL analogue.
 */
template isGLSLBasicMatrixType(T)
{
    import gfm.math : Matrix;
    enum isGLSLBasicMatrixType = is(T == Matrix!(U, R, C), U, int R, int C)
                                 && 1 < R && R < 5 && 1 < C && C < 5 &&  isGLSLMatrixBasicType!U;
}

/// Checks if `T` is a basic scalar, vector, or matrix GLSL type.
enum isGLSLBasicNonOpaqueType(T) = isGLSLBasicScalarType!T || isGLSLBasicVectorType!T || isGLSLBasicMatrixType!T;

/// Checks if `T` is a basic opaque GLSL type.
enum isGLSLBasicOpaqueType(T) = isGLSLSamplerType!T;

/// Checks if `T` is a basic scalar, vector, matrix or opaque GLSL type.
enum isGLSLBasicType(T) = isGLSLBasicNonOpaqueType!T || isGLSLBasicOpaqueType!T;

/// Checks if `T` is an array of basic GLSL non-opaque type values.
enum isGLSLBasicNonOpaqueArrayType(T) = from!"std.traits".isArray!T && isGLSLBasicNonOpaqueType!(typeof(T.init[0]));

/// Checks if `T` is an array of basic GLSL opaque type values.
enum isGLSLBasicOpaqueArrayType(T) = from!"std.traits".isArray!T && isGLSLBasicOpaqueType!(typeof(T.init[0]));

/// Checks if `T` is an array of basic GLSL type values.
enum isGLSLBasicArrayType(T) = isGLSLBasicNonOpaqueArrayType!T || isGLSLBasicOpaqueArrayType!T;

private template isGLSLStructTypeImpl(T, Flag!"checkOpaque" checkOpaque)
{
    static if(is(T == struct) && !isGLSLBasicVectorType!T && !isGLSLBasicMatrixType!T && !isGLSLSamplerType!T)
    {
        import std.meta : allSatisfy, anySatisfy;
        import std.traits : Fields;

        static if(checkOpaque)
        {
            enum isGLSLStructTypeImpl = allSatisfy!(isGLSLType, Fields!T) &&
                                        anySatisfy!(isGLSLOpaqueType, Fields!T);
        }
        else
        {
            enum isGLSLStructTypeImpl = allSatisfy!(isGLSLNonOpaqueType, Fields!T);
        }
    }
    else
    {
        enum isGLSLStructTypeImpl = false;
    }
}
/// Checks if `T` is a struct that contains only GLSL non-opaque basic types,
/// non-opaque basic array types or another struct with such property.
enum isGLSLNonOpaqueStructType(T) = isGLSLStructTypeImpl!(T, No.checkOpaque);
/// Checks if `T` is a struct that contains only GLSL basic types,
/// basic array types or another struct with such property
/// and at least one of these types is opaque.
enum isGLSLOpaqueStructType(T) = isGLSLStructTypeImpl!(T, Yes.checkOpaque);
/// Checks if `T` is a struct that contains only GLSL basic types,
/// basic array types or another struct with such property.
enum isGLSLStructType(T) = isGLSLOpaqueStructType!T || isGLSLNonOpaqueStructType!T;
///
unittest
{
    import gfm.math : vec2i;
    import glsu.objects : Sampler2Di;

    struct A
    {
        int i;
        float f;
        bool[] bb;
    }

    static assert(isGLSLStructType!A);
    static assert(!isGLSLStructType!vec2i);
    static assert(!isGLSLStructType!Sampler2Di);
}

/// Checks if `T` is an array of non-opaque GLSL structs.
enum isGLSLNonOpaqueStructArrayType(T) = from!"std.traits".isArray!T && isGLSLNonOpaqueStructType!(typeof(T.init[0]));

/// Checks if `T` is an array of opaque GLSL structs.
enum isGLSLOpaqueStructArrayType(T) = from!"std.traits".isArray!T && isGLSLOpaqueStructType!(typeof(T.init[0]));

/// Checks if `T` is an array of GLSL structs.
enum isGLSLStructArrayType(T) = isGLSLNonOpaqueStructArrayType!T || isGLSLOpaqueStructArrayType!T;

/// Checks if `T` is an array of non-opaque GLSL type values.
enum isGLSLNonOpaqueArrayType(T) = isGLSLBasicNonOpaqueArrayType!T || isGLSLNonOpaqueStructArrayType!T;

/// Checks if `T` is an array of GLSL type values.
enum isGLSLOpaqueArrayType(T) = isGLSLBasicOpaqueArrayType!T || isGLSLOpaqueStructArrayType!T;

/// Checks if `T` is an array of GLSL type values.
enum isGLSLArrayType(T) = isGLSLNonOpaqueArrayType!T || isGLSLOpaqueArrayType!T;

/// Checks if `T` is a non-opaque GLSL type.
enum isGLSLNonOpaqueType(T) = isGLSLBasicNonOpaqueType!T || isGLSLNonOpaqueStructType!T || isGLSLNonOpaqueArrayType!T;
///
unittest
{
    import glsu.objects : Sampler2Df;

    struct A
    {
        int i;
        bool b;
        Sampler2Df s;
    }
    struct B
    {
        float f;
        A a;
    }
    struct C
    {
        uint u;
        bool[] bb;
    }

    static assert(!isGLSLNonOpaqueType!A);
    static assert(!isGLSLNonOpaqueType!B);
    static assert(isGLSLNonOpaqueType!C);
}

/// Checks if `T` is an opaque GLSL type.
enum isGLSLOpaqueType(T) = isGLSLBasicOpaqueType!T || isGLSLOpaqueStructType!T || isGLSLOpaqueArrayType!T;
///
unittest
{
    import glsu.objects : Sampler2Df;

    struct A
    {
        int i;
        bool b;
        Sampler2Df s;
    }
    struct B
    {
        float f;
        A a;
    }
    struct C
    {
        uint u;
        bool[] bb;
    }

    static assert(isGLSLOpaqueType!A);
    static assert(isGLSLOpaqueType!B);
    static assert(!isGLSLOpaqueType!C);
}

/// Checks if `T` is a GLSL type.
enum isGLSLType(T) = isGLSLNonOpaqueType!T || isGLSLOpaqueType!T;
///
unittest
{
    import gfm.math : vec2i, vec3f, mat3f, Matrix;
    import glsu.objects : Sampler2Df;

    struct A
    {
        float f;
        vec2i v;
        int i;
        bool[] bb;
        mat3f[] mm;
    }
    struct B
    {
        vec3f v;
        A a;
        A[] aa;
        Sampler2Df s;
    }
    struct C
    {
        B b;
        string s;
    }
    static assert(isGLSLType!(B[42]));
    static assert(!isGLSLType!C);
    static assert(!isGLSLType!(Matrix!(int, 3, 3)));
}