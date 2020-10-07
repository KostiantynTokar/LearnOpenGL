#version 330 core

struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light
{
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

in vec3 fNormal;
in vec3 fragPos;
in vec2 fTexCoords;

out vec4 fragColor;

uniform Material material;
uniform Light light;

void main()
{
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, fTexCoords));

    vec3 norm = normalize(fNormal);
    vec3 lightDir = normalize(fragPos - light.position);
    float diffuseMult = max(dot(norm, -lightDir), 0.0);
    vec3 diffuse = light.diffuse * diffuseMult * vec3(texture(material.diffuse, fTexCoords));

    vec3 viewDir = normalize(fragPos);
    vec3 reflectDir = reflect(lightDir, norm);
    float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * specularMult * vec3(texture(material.specular, fTexCoords));

    vec3 res = ambient + diffuse + specular;
    fragColor = vec4(res, 1.0);
}
