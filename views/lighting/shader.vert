#version 330 core

layout(location = 0) in vec3 vPos;
layout(location = 1) in vec3 vNormal;

out vec3 fNormal;
out vec3 fragPos;
out vec3 fViewLightPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 lightPos;

void main()
{
    gl_Position = projection * view * model * vec4(vPos, 1.0);
    fragPos = vec3(view * model * vec4(vPos, 1.0));
    fNormal = mat3(transpose(inverse(view * model))) * vNormal;
    fViewLightPos = vec3(view * vec4(lightPos, 1.0));
}
