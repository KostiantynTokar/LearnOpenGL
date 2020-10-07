#version 330 core

struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Attenuation
{
    float constant;
    float linear;
    float quadratic;
};

struct PointLight
{
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    Attenuation attenuation;
};

in vec3 fNormal;
in vec3 fragPos;
in vec2 fTexCoords;

out vec4 fragColor;

uniform Material material;
uniform PointLight pointLight;

void main()
{
    vec3 ambient = pointLight.ambient * vec3(texture(material.diffuse, fTexCoords));

    vec3 norm = normalize(fNormal);
    vec3 lightDir = normalize(fragPos - pointLight.position);
    float diffuseMult = max(dot(norm, -lightDir), 0.0);
    vec3 diffuse = pointLight.diffuse * diffuseMult * vec3(texture(material.diffuse, fTexCoords));

    vec3 viewDir = normalize(fragPos);
    vec3 reflectDir = reflect(lightDir, norm);
    float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = pointLight.specular * specularMult * vec3(texture(material.specular, fTexCoords));

    float dist = length(pointLight.position - fragPos);
    float attenuationValue = 1.0 /
        (pointLight.attenuation.constant +
         pointLight.attenuation.linear * dist +
         pointLight.attenuation.quadratic * dist * dist);

    vec3 res = attenuationValue * (ambient + diffuse + specular);
    fragColor = vec4(res, 1.0);
}
