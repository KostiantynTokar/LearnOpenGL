#version 330 core

struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct DirectionalLight
{
    // Assumes light direction in view space.
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct Attenuation
{
    float constant;
    float linear;
    float quadratic;
};

struct PointLight
{
    // Assumes light position in view space.
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    Attenuation attenuation;
};

struct SpotLight
{
    // Assumes light position in view space.
    vec3 position;
    // Assumes light direction in view space.
    vec3 direction;
    float cosInnerCutOff;
    float cosOuterCutOff;
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
// uniform DirectionalLight directionalLight;
// uniform PointLight pointLight;
uniform SpotLight spotLight;

void main()
{
    // Directional light calculations.
    // {
    //     vec3 ambient = directionalLight.ambient * vec3(texture(material.diffuse, fTexCoords));

    //     vec3 norm = normalize(fNormal);
    //     vec3 lightDir = normalize(directionalLight.direction);
    //     float diffuseMult = max(dot(norm, -lightDir), 0.0);
    //     vec3 diffuse = directionalLight.diffuse * diffuseMult * vec3(texture(material.diffuse, fTexCoords));

    //     vec3 viewDir = normalize(fragPos);
    //     vec3 reflectDir = reflect(lightDir, norm);
    //     float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), material.shininess);
    //     vec3 specular = directionalLight.specular * specularMult * vec3(texture(material.specular, fTexCoords));

    //     vec3 res = ambient + diffuse + specular;
    //     fragColor = vec4(res, 1.0);
    // }

    // Point light calculations.
    // vec3 ambient = pointLight.ambient * vec3(texture(material.diffuse, fTexCoords));

    // vec3 norm = normalize(fNormal);
    // vec3 lightDir = normalize(fragPos - pointLight.position);
    // float diffuseMult = max(dot(norm, -lightDir), 0.0);
    // vec3 diffuse = pointLight.diffuse * diffuseMult * vec3(texture(material.diffuse, fTexCoords));

    // vec3 viewDir = normalize(fragPos);
    // vec3 reflectDir = reflect(lightDir, norm);
    // float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), material.shininess);
    // vec3 specular = pointLight.specular * specularMult * vec3(texture(material.specular, fTexCoords));

    // float dist = length(pointLight.position - fragPos);
    // float attenuationValue = 1.0 /
    //     (pointLight.attenuation.constant +
    //      pointLight.attenuation.linear * dist +
    //      pointLight.attenuation.quadratic * dist * dist);

    // vec3 res = attenuationValue * (ambient + diffuse + specular);
    // fragColor = vec4(res, 1.0);

    // Spot light calculations.
    {
        vec3 ambient = spotLight.ambient * vec3(texture(material.diffuse, fTexCoords));

        vec3 norm = normalize(fNormal);
        vec3 lightDir = normalize(fragPos - spotLight.position);
        float diffuseMult = max(dot(norm, -lightDir), 0.0);
        vec3 diffuse = spotLight.diffuse * diffuseMult * vec3(texture(material.diffuse, fTexCoords));

        vec3 viewDir = normalize(fragPos);
        vec3 reflectDir = reflect(lightDir, norm);
        float specularMult = pow(max(dot(-viewDir, reflectDir), 0.0), material.shininess);
        vec3 specular = spotLight.specular * specularMult * vec3(texture(material.specular, fTexCoords));

        float cosLightDir = dot(viewDir, normalize(spotLight.direction));
        float interpolationInterval = spotLight.cosInnerCutOff - spotLight.cosOuterCutOff;
        float intensity = clamp((cosLightDir - spotLight.cosOuterCutOff) / interpolationInterval, 0.0, 1.0);

        float dist = length(spotLight.position - fragPos);
        float attenuationValue = 1.0 /
            (spotLight.attenuation.constant +
             spotLight.attenuation.linear * dist +
             spotLight.attenuation.quadratic * dist * dist);
        
        vec3 res = attenuationValue * (ambient + intensity * (diffuse + specular));
        fragColor = vec4(res, 1.0);
    }
}
