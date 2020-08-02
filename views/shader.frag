#version 330 core

in vec3 fColor;
in vec2 fTexCoord;

out vec4 fragColor;

uniform sampler2D texture1;
uniform sampler2D texture2;
uniform float mixParam;

void main()
{
    fragColor = mix(texture(texture1, fTexCoord), texture(texture2, fTexCoord), mixParam) * vec4(fColor, 1.0f);
}