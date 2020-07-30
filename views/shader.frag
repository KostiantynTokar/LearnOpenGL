#version 330 core

uniform vec4 myColor;

out vec4 fragColor;

void main()
{
    fragColor = myColor;
}