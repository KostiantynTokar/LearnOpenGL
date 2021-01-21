/**
 * Functions to create simple 2D or 3D shapes.
 *
 * Authors: Kostiantyn Tokar.
 * Copyright: (c) 2020 Kostiantyn Tokar.
 * License: MIT License.
 */
module glsu.shapes;

/** 
 * Range of triange vertices. Assumes vertices in anticlockwise order.
 *
 * v1
 * ||\\
 * || \\
 * ||  \\
 * v2===v3
 */
const(Vertex)[3] triangle(Vertex)(in Vertex v1,
                      in Vertex v2,
                      in Vertex v3) pure nothrow @nogc @safe
{
    // import std.range : only;
    // return only(v1, v2, v3);
    import std.array : staticArray;
    return [v1, v2, v3].staticArray;
}

/** 
 * Range of quadrangle vertices as 2 triangles. Assumes vertices in anticlockwise order.
 *
 * v1====v4
 * ||    ||
 * ||    ||
 * ||    ||
 * v2====v3
 * Triangles are (v1, v2, v3) and (v1, v3, v4)
 */
const(Vertex)[6] quadrangle(Vertex)(in Vertex v1,
                        in Vertex v2,
                        in Vertex v3,
                        in Vertex v4) pure nothrow @nogc @safe
{
    import std.range : chain;
    import std.array : staticArray;

    enum verticesByQuadrangle = 6;
    return chain(triangle(v1, v2, v3)[], triangle(v1, v3, v4)[]).staticArray!verticesByQuadrangle;
}

/** 
 * Quadrangle with vertices (-0.5,  0.5), (-0.5, -0.5), ( 0.5, -0.5), ( 0.5,  0.5).
 *
 * See_Also: `quadrangle`.
 */
auto square2D(T)() pure nothrow @nogc @safe
{
    import gfm.math : vec2;
    return quadrangle(vec2!T(-0.5,  0.5),
                      vec2!T(-0.5, -0.5),
                      vec2!T( 0.5, -0.5),
                      vec2!T( 0.5,  0.5),
                      );
}

/** 
 * Quadrangle with vertices (-0.5,  0.5, 0), (-0.5, -0.5, 0), ( 0.5, -0.5, 0), ( 0.5,  0.5, 0).
 *
 * See_Also: `quadrangle`.
 */
auto square3D(T)() pure nothrow @nogc @safe
{
    import gfm.math : vec3;
    return quadrangle(vec3!T(-0.5,  0.5, 0),
                      vec3!T(-0.5, -0.5, 0),
                      vec3!T( 0.5, -0.5, 0),
                      vec3!T( 0.5,  0.5, 0),
                      );
}

/** 
 * Range of octagon vertices as 6 quadrangles.
 *
 * Assumes vertices in the following order:
 *      v8=======v5
 *     //-      /||
 *    //--     //||
 *   // --    // ||
 *  v1=======v4  ||
 *  ||  --   ||  ||
 *  ||  v7---||==v6
 *  || /     || //
 *  ||/      ||//
 *  |/       |//
 *  v2=======v3
 * Quadrangles are traversed in the following order:
 * front, right, back, left, up (top is v8-v5), down (top is v2-v3).
 * 6 vertices by face.
 */
const(Vertex)[36] octagon(Vertex)(Vertex v1,
                     Vertex v2,
                     Vertex v3,
                     Vertex v4,
                     Vertex v5,
                     Vertex v6,
                     Vertex v7,
                     Vertex v8) pure nothrow @nogc @safe
{
    import std.range : chain;
    import std.array : staticArray;

    enum verticesByQuadrangle = 6;
    enum numFaces = 6;
    return chain(quadrangle(v1, v2, v3, v4)[],
                 quadrangle(v4, v3, v6, v5)[],
                 quadrangle(v5, v6, v7, v8)[],
                 quadrangle(v8, v7, v2, v1)[],
                 quadrangle(v8, v1, v4, v5)[],
                 quadrangle(v2, v7, v6, v3)[],
                ).staticArray!(verticesByQuadrangle * numFaces);
}

/** 
 * Octagon with vertices (+-0.5, +-0.5, +-0.5).
 *
 * See_Also: `octagon`.
 */
auto cube(T)() pure nothrow @nogc @safe
{
    import gfm.math : vec3;
    return octagon(vec3!T(-0.5,  0.5,  0.5),
                   vec3!T(-0.5, -0.5,  0.5),
                   vec3!T( 0.5, -0.5,  0.5),
                   vec3!T( 0.5,  0.5,  0.5),
                   vec3!T( 0.5,  0.5, -0.5),
                   vec3!T( 0.5, -0.5, -0.5),
                   vec3!T(-0.5, -0.5, -0.5),
                   vec3!T(-0.5,  0.5, -0.5),
                   );
}

/** 
 * Range of cube normals.
 *
 * See_Also: `cube`.
 */
auto cubeNormals(T)() pure nothrow @nogc @safe
{
    import std.range : chain, repeat;
    import std.array : staticArray;
    import gfm.math : vec3;

    enum verticesByQuadrangle = 6;
    enum numFaces = 6;
    return chain(
                 vec3!T( 0,  0,  1).repeat(verticesByQuadrangle),
                 vec3!T( 1,  0,  0).repeat(verticesByQuadrangle),
                 vec3!T( 0,  0, -1).repeat(verticesByQuadrangle),
                 vec3!T(-1,  0,  0).repeat(verticesByQuadrangle),
                 vec3!T( 0,  1,  0).repeat(verticesByQuadrangle),
                 vec3!T( 0, -1,  0).repeat(verticesByQuadrangle),
                ).staticArray!(const(vec3!T)[verticesByQuadrangle * numFaces]);
}

/** 
 * Range of octagon texture coordinates.
 *
 * See_Also: `octagon`.
 */
auto octagonTextureCoordinates(T)() pure nothrow @nogc @safe
{
    import std.range : repeat;
    import std.algorithm : joiner;
    import std.array : staticArray;
    import gfm.math : vec2;

    enum verticesByQuadrangle = 6;
    enum numFaces = 6;

    immutable bottomLeft = vec2!T(0, 0);
    immutable bottomRight = vec2!T(1, 0);
    immutable topLeft = vec2!T(0, 1);
    immutable topRight = vec2!T(1, 1);
    immutable numOfFaces = 6;
    return quadrangle(topLeft, bottomLeft, bottomRight, topRight)[]
        .repeat(numOfFaces)
        .joiner
        .staticArray!(verticesByQuadrangle * numFaces);
}
