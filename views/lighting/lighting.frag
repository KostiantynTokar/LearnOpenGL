#version 330 core

in vec3 fNormal;
in vec3 fragPos;
in vec3 fViewLightPos;

out vec4 fragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 norm = normalize(fNormal);
    vec3 lightDir = normalize(fragPos - fViewLightPos);
    float diffuseMult = max(dot(norm, -lightDir), 0.0);
    vec3 diffuse = diffuseMult * lightColor;

    float specularStrength = 0.5;
    vec3 viewDir = normalize(fragPos);
    vec3 reflectDir = reflect(lightDir, norm);
    float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), 32);
    vec3 specular = specularStrength * specularMult * lightColor;

    vec3 res = (ambient + diffuse + specular) * objectColor;
    fragColor = vec4(res, 1.0);
}
