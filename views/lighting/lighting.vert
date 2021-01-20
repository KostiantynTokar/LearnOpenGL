#version 330 core

layout(location = 0) in vec3 vPos;
layout(location = 1) in vec3 vNormal; // Assumes normalized.
layout(location = 2) in vec2 vTexCoords;

out vec3 fNormal;
out vec3 fragPos;
out vec2 fTexCoords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    mat4 modelView = view * model;
    vec4 fragPos4 = modelView * vec4(vPos, 1.0);

    gl_Position = projection * fragPos4;
    fragPos = vec3(fragPos4);
    fNormal = normalize(transpose(inverse(mat3(modelView))) * vNormal);
    fTexCoords = vTexCoords;
}
