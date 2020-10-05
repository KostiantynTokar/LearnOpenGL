#version 330 core

struct Material
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct Light
{
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform Material material;
uniform Light light;

in vec3 fNormal;
in vec3 fragPos;

out vec4 fragColor;

void main()
{
    vec3 ambient = material.ambient * light.ambient;

    vec3 norm = normalize(fNormal);
    vec3 lightDir = normalize(fragPos - light.position);
    float diffuseMult = max(dot(norm, -lightDir), 0.0);
    vec3 diffuse = material.diffuse * diffuseMult * light.diffuse;

    vec3 viewDir = normalize(fragPos);
    vec3 reflectDir = reflect(lightDir, norm);
    float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = material.specular * specularMult * light.specular;

    vec3 res = ambient + diffuse + specular;
    fragColor = vec4(res, 1.0);
}
