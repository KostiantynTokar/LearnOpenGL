#version 330 core

layout (location = 0) in vec2 pos;
layout (location = 1) in vec3 color;

out vec3 myColor;

uniform float horOffset;
uniform float time;

void main()
{
    vec2 rotated = vec2(cos(time) * pos.x - sin(time) * pos.y, sin(time) * pos.x + cos(time) * pos.y);
    vec2 translated = vec2(rotated.x + horOffset, rotated.y);
    gl_Position = vec4(translated, 0.0f, 1.0f);
    myColor = vec3(translated, 0.0f);
}