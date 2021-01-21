/**
 * High-level graphics abstractions.
 *
 * Authors: Kostiantyn Tokar.
 * Copyright: (c) 2020 Kostiantyn Tokar.
 * License: MIT License.
 */
module glsu.abstractions;

/** 
 * Camera abstraction. Simplifies work with view matrix.
 *
 * Do not support roll Euler angle.
 *
 * Note:
 *   All angles are specified in radians.
 *
 *   Uses right-handed coordinate system (as in OpenGL),
 *   so that negative Z should point into the screen (positive to the user);
 *   positive Y should be "up", and positive X should be to the right.
 */
struct Camera
{
    import gfm.math : vec3f, dot;
    import gfm.math : mat4f;
    import std.math : PI, PI_2, approxEqual;
    import gfm.math : radians;

    /** 
     * Constructor of the camera.
     * Params:
     *   position = 3D position coordinates of the camera.
     *   yaw = Yaw Euler angle in radians, default is `-PI/2` (so camera looks at negative z-axis).
     *         Wrapped to interval [-PI, PI$(RPAREN), grows anticlockwise at xz plane.
     *   pitch = Pitch Euler angle in radians, default is `0` (so camera looks perpendicularly y-axis).
     *           Clamped to interval [-radians(89.0f), radians(89.0f)], grows anticlockwise at yz plane.
     *   worldUp = Constant to determine camera orientation angles.
     */
    this(vec3f position, float yaw = -PI_2, float pitch = 0.0f,
         vec3f worldUp = vec3f(0.0f, 1.0f, 0.0f)) pure nothrow @nogc @safe
    {
        _position = position;
        _worldUp = worldUp.normalized;
        updateVectors(yaw, pitch);
    }

    /// 3D position coordinates of the camera.
    vec3f position() const pure nothrow @nogc @safe
    {
        return _position;
    }

    /// Angle that determines camera orientation.
    vec3f front() const pure nothrow @nogc @safe
    {
        return _front;
    }
    /// ditto
    vec3f right() const pure nothrow @nogc @safe
    {
        return _right;
    }
    /// ditto
    vec3f up() const pure nothrow @nogc @safe
    {
        return _up;
    }

    /// Constant world up direction.
    vec3f worldUp() const pure nothrow @nogc @safe
    {
        return _worldUp;
    }

    /// Yaw Euler angle in radians. Wrapped to interval [-PI, PI$(RPAREN).
    float yaw() const pure nothrow @nogc @safe
    {
        return calcYawFromOrigin(front);
    }

    /// Pitch Euler angle in radians. Clamped to interval [-radians(89.0f), radians(89.0f)].
    float pitch() const pure nothrow @nogc @safe
    {
        return calcPitchFromOrigin(front);
    }

    /// Calculates view matrix of the camera.
    mat4f getView() const pure nothrow @nogc @safe
    {
        return mat4f.lookAt(position, position + front, up);
    }

    /// Change position of the camera by specified offset.
    void move(vec3f offset) pure nothrow @nogc @safe
    {
        _position += offset;
    }

    /// Change position of the camera in front direction.
    void moveFront(float offset) pure nothrow @nogc @safe
    {
        _position += offset * front;
    }

    /// Change position of the camera in right direction.
    void moveRight(float offset) pure nothrow @nogc @safe
    {
        _position += offset * right;
    }

    /// Change position of the camera in up direction.
    void moveUp(float offset) pure nothrow @nogc @safe
    {
        _position += offset * up;
    }

    /// Change position of the camera in world up direction.
    void moveWorldUp(float offset) pure nothrow @nogc @safe
    {
        _position += offset * worldUp;
    }

    /// Rotates using Euler angles in radians.
    void rotate(float yawOffset, float pitchOffset) pure nothrow @nogc @safe
    {
        updateVectors(yaw + yawOffset, pitch + pitchOffset);
    }

    /// Change yaw and pitch so that front points to `point`.
    void lookAt(vec3f point) pure nothrow @nogc @safe
    {
        immutable newFront = (point - position).normalized;
        updateVectors(newFront);
    }
    ///
    unittest
    {
        import std.math : approxEqual;

        auto camera = Camera(vec3f(0.5));

        auto point = vec3f(0, 0, 1);
        camera.lookAt(point);
        assert(camera.front[].approxEqual((point - camera.position).normalized[]));

        point = vec3f(1, 0, -1);
        camera.lookAt(point);
        assert(camera.front[].approxEqual((point - camera.position).normalized[]));
    }

private:
    vec3f _position;
    vec3f _front;
    vec3f _up;
    vec3f _right;
    vec3f _worldUp;

    void updateVectors(float newYaw, float newPitch) pure nothrow @nogc @safe
    out(; _front.magnitude.approxEqual(1.0f))
    out(; _right.magnitude.approxEqual(1.0f))
    out(; _up.magnitude.approxEqual(1.0f))
    out(; dot(_front, _up).approxEqual(0.0f))
    out(; dot(_front, _right).approxEqual(0.0f))
    out(; dot(_right, _up).approxEqual(0.0f))
    {
        import std.math : sin, cos;
        import gfm.math.vector : cross;

        immutable t = constrainAngles(newYaw, newPitch);

        immutable sp = sin(t.pitch);
        immutable cp = cos(t.pitch);

        immutable sy = sin(t.yaw);
        immutable cy = cos(t.yaw);

        _front = vec3f(cy * cp, sp, sy * cp).normalized;
        _right = cross(_front, _worldUp).normalized;
        _up = cross(_right, _front).normalized;
    }

    void updateVectors(vec3f newFront) pure nothrow @nogc @safe
    in(newFront.magnitude.approxEqual(1.0f))
    out(; _front.magnitude.approxEqual(1.0f))
    out(; _right.magnitude.approxEqual(1.0f))
    out(; _up.magnitude.approxEqual(1.0f))
    out(; dot(_front, _up).approxEqual(0.0f))
    out(; dot(_front, _right).approxEqual(0.0f))
    out(; dot(_right, _up).approxEqual(0.0f))
    {
        import gfm.math.vector : cross;

        _front = newFront;
        _right = cross(_front, _worldUp).normalized;
        _up = cross(_right, _front).normalized;
    }

    import std.typecons : Tuple;
    /// Wraps `yaw` in [-PI, PI) and clamps `pitch` to [-89.radians, 89.radians].
    static Tuple!(float, "yaw", float, "pitch") 
        constrainAngles(float yaw, float pitch) pure nothrow @nogc @safe
    out(res; -PI <= res.yaw && res.yaw < PI)
    out(res; -radians(89.0f) <= res.pitch && res.pitch <= radians(89.0f))
    {
        import std.typecons : tuple;
        import std.algorithm : clamp;
        import gfm.math.funcs : radians;

        return tuple!("yaw", "pitch")(wrapAngle(yaw),
                                      clamp(pitch, -radians(89.0f), radians(89.0f)));
    }

    /** 
     * Constrain angle in [-PI, PI) by angle wrapping.
     * Params:
     *   angle = Value to wrap.
     * Returns: Value in interval [-PI, PI).
     */
    static float wrapAngle(float angle) pure nothrow @nogc @safe
    {
        angle = (angle + PI) % (2 * PI);
        if (angle < 0)
        {
            angle += 2 * PI;
        }
        return angle - PI;
    }
    ///
    unittest
    {
        assert(Camera.wrapAngle(0.0f).approxEqual(0.0f));
        
        assert(Camera.wrapAngle(PI_2).approxEqual(PI_2));
        assert(Camera.wrapAngle(PI + PI_2).approxEqual(-PI_2));
        assert(Camera.wrapAngle(2 * PI + PI_2).approxEqual(PI_2));

        assert(Camera.wrapAngle(-PI_2).approxEqual(-PI_2));
        assert(Camera.wrapAngle(-PI - PI_2).approxEqual(PI_2));
        assert(Camera.wrapAngle(-2 * PI - PI_2).approxEqual(-PI_2));
    }

    /// Return yaw between (0,0,0) and `point`.
    static float calcYawFromOrigin(vec3f point) pure nothrow @nogc @safe
    {
        import std.math : atan2;
        return atan2(-point.z, -point.x) - PI;
    }

    /// Return pitch between (0,0,0) and `point`.
    static float calcPitchFromOrigin(vec3f point) pure nothrow @nogc @safe
    {
        import std.math : atan2, hypot;
        return atan2(point.y, cast(float) hypot(point.x, point.z));
    }
}
///
unittest
{
    import gfm.math : vec3f, vec4f, mat3f;
    import std.math : PI_2, PI_4, approxEqual;

    vec3f fromHomogeneous(vec4f v)
    {
        return v.xyz / v.w;
    }
    vec3f applyView(Camera camera, vec3f v)
    {
        return fromHomogeneous(camera.getView() * vec4f(v, 1.0f));
    }

    auto origin = vec3f(0.0f, 0.0f, 0.0f);
    auto camera = Camera(vec3f(0.0f, 0.0f, 1.0f));

    assert(applyView(camera, origin)[].approxEqual([0.0f, 0.0f, -1.0f]));

    camera.rotate(PI_2, 0.0f);
    assert(applyView(camera, origin)[].approxEqual([-1.0f, 0.0f, 0.0f]));

    camera.moveFront(1.0f);
    assert(applyView(camera, origin)[].approxEqual([-1.0f, 0.0f, 1.0f]));

    camera.rotate(0.0f, PI_4);
    assert(applyView(camera, origin)[].approxEqual((mat3f.rotateX(-PI_4) * vec3f(-1.0f, 0.0f, 1.0f))[]));
}
