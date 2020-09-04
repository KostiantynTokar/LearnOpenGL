module glsu.enums;

import glad.gl.enums;

enum GLType
{
    glByte = GL_BYTE,
    glUByte = GL_UNSIGNED_BYTE,
    glShort = GL_SHORT,
    glUShort = GL_UNSIGNED_SHORT,
    glInt = GL_INT,
    glUInt = GL_UNSIGNED_INT,
    glHalfFloat = GL_HALF_FLOAT,
    glFloat = GL_FLOAT,
    glDouble = GL_DOUBLE
}

/// Hint to the GL implementation as to how a `BufferObject`'s data store will be accessed.
enum DataUsage
{
    streamDraw = GL_STREAM_DRAW, /// Modified once by app, used few times, source for GL.
    streamRead = GL_STREAM_READ, /// Modified once by GL, used few times, source for app.
    streamCopy = GL_STREAM_COPY, /// Modified once by GL, used few times, source for GL.

    staticDraw = GL_STATIC_DRAW, /// Modified once by app, used many times, source for GL.
    staticRead = GL_STATIC_READ, /// Modified once by GL, used many times, source for app.
    staticCopy = GL_STATIC_COPY, /// Modified once by GL, used many times, source for GL.

    dynamicDraw = GL_DYNAMIC_DRAW, /// Modified repeatedly by app, used many times, source for GL.
    dynamicRead = GL_DYNAMIC_READ, /// Modified repeatedly by GL, used many times, source for app.
    dynamicCopy = GL_DYNAMIC_COPY /// Modified repeatedly by GL, used many times, source for GL.
}

// dfmt off
enum RenderMode
{
    points = GL_POINTS,
    lineStrip = GL_LINE_STRIP,
    lineLoop = GL_LINE_LOOP,
    lines = GL_LINES,
    lineStripAdjacency = GL_LINE_STRIP_ADJACENCY,
    linesAdjacency = GL_LINES_ADJACENCY,
    triangleStrip = GL_TRIANGLE_STRIP,
    triangleFan = GL_TRIANGLE_FAN,
    triangles = GL_TRIANGLES,
    triangleStripAdjacency = GL_TRIANGLE_STRIP_ADJACENCY,
    trianglesAdjacency = GL_TRIANGLES_ADJACENCY
}
// dfmt on
