module glsu.enums;

import glad.gl.enums;

/// GL privitive types
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
/// Kind of primitives to render in GL draw functions.
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

/// Error codes that could be returned by `glGetError`.
enum GLError
{
    /**
     * No error has been recorded. The value of this symbolic constant is guaranteed to be 0.
     */
    noError = GL_NO_ERROR,

    /**
     * An unacceptable value is specified for an enumerated argument.
     * The offending command is ignored and has no other side effect than to set the error flag.
     */
    invalidEnum = GL_INVALID_ENUM,

    /**
     * A numeric argument is out of range.
     * The offending command is ignored and has no other side effect than to set the error flag.
     */
    invalidValue = GL_INVALID_VALUE,

    /**
     * The specified operation is not allowed in the current state.
     * The offending command is ignored and has no other side effect than to set the error flag.
     */
    invalidOperation = GL_INVALID_OPERATION,

    /**
     * The framebuffer object is not complete.
     * The offending command is ignored and has no other side effect than to set the error flag.
     */
    invalidFramebufferOperation = GL_INVALID_FRAMEBUFFER_OPERATION,

    /**
     * There is not enough memory left to execute the command.
     * The state of the GL is undefined, except for the state of the error flags, after this error is recorded.
     */
    outOfMemory = GL_OUT_OF_MEMORY
}
