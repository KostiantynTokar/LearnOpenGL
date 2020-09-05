/**
 * High-level graphics abstractions.
 *
 * Authors: Kostiantyn Tokar
 */
module glsu.abstractions;

struct Camera
{
    import gfm.math.vector : vec3f;
    import gfm.math.matrix : mat4f;
    import std.math : PI, PI_2;

    this(vec3f position, float yaw = -PI_2, float pitch = 0.0f,
            vec3f worldUp = vec3f(0.0f, 1.0f, 0.0f)) nothrow @nogc @safe
    {
        _position = position;
        _worldUp = worldUp;
        updateAngles(yaw, pitch);
        updateVectors();
    }

    vec3f position() const pure nothrow @nogc @safe
    {
        return _position;
    }

    vec3f front() const pure nothrow @nogc @safe
    {
        return _front;
    }

    vec3f right() const pure nothrow @nogc @safe
    {
        return _right;
    }

    vec3f up() const pure nothrow @nogc @safe
    {
        return _up;
    }

    vec3f worldUp() const pure nothrow @nogc @safe
    {
        return _worldUp;
    }

    float yaw() const pure nothrow @nogc @safe
    {
        return _yaw;
    }

    float pitch() const pure nothrow @nogc @safe
    {
        return _pitch;
    }

    mat4f getView() const pure nothrow @nogc @safe
    {
        return mat4f.lookAt(position, position + front, up);
    }

    void move(vec3f offset) pure nothrow @nogc @safe
    {
        _position += offset;
    }

    void moveFront(float offset) pure nothrow @nogc @safe
    {
        _position += offset * front;
    }

    void moveRight(float offset) pure nothrow @nogc @safe
    {
        _position += offset * right;
    }

    void moveUp(float offset) pure nothrow @nogc @safe
    {
        _position += offset * up;
    }

    void rotate(float yawOffset, float pitchOffset) nothrow @nogc @safe
    {
        updateAngles(yaw + yawOffset, pitch + pitchOffset);
        updateVectors();
    }

private:
    vec3f _position;
    vec3f _front;
    vec3f _up;
    vec3f _right;
    vec3f _worldUp;
    float _yaw;
    float _pitch;

    void updateAngles(float newYaw, float newPitch) nothrow @nogc @safe
    {
        import std.math : fmod;
        import gfm.math.funcs : radians;

        _yaw = fmod(newYaw, PI);
        _pitch = fmod(newPitch, radians(89.0f));
    }

    void updateVectors() pure nothrow @nogc @safe
    {
        import std.math : sin, cos;
        import gfm.math.vector : cross;

        immutable sp = sin(pitch);
        immutable cp = cos(pitch);

        immutable sy = sin(yaw);
        immutable cy = cos(yaw);

        _front = vec3f(cy * cp, sp, sy * cp).normalized;
        _right = cross(_front, _worldUp).normalized;
        _up = cross(_right, _front).normalized;
    }
}
