#version 330 core

struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct PhongLighting
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct DirectionalLight
{
    vec3 direction; // Assumes normalized light direction in view space.
    PhongLighting components;
};

struct Attenuation
{
    float constant;
    float linear;
    float quadratic;
};

struct PointLight
{
    vec3 position; // Assumes light position in view space.
    PhongLighting components;
    Attenuation attenuation;
};

struct SpotLight
{
    vec3 position; // Assumes light position in view space.
    vec3 direction; // Assumes normalized light direction in view space.
    float cosInnerCutOff;
    float cosOuterCutOff;
    PhongLighting components;
    Attenuation attenuation;
};

in vec3 fNormal; // Assumes normalized.
in vec3 fragPos;
in vec2 fTexCoords;

out vec4 fragColor;

uniform Material material;
uniform DirectionalLight directionalLight;
#define NR_POINT_LIGHTS 3
uniform PointLight pointLights[NR_POINT_LIGHTS];
uniform SpotLight spotLight;

// Assumes normalized normal and viewerDirToFragment.
vec3 calcDirectionalLight(DirectionalLight light, vec3 materialDiffuse, vec3 materialSpecular, vec3 normal, vec3 viewerDirToFragment);

// Assumes normalized normal and viewerDirToFragment.
vec3 calcPointLight(PointLight light, vec3 materialDiffuse, vec3 materialSpecular, vec3 normal, vec3 fragPos, vec3 viewerDirToFragment);

// Assumes normalized normal and viewerDirToFragment.
vec3 calcSpotLight(SpotLight light, vec3 materialDiffuse, vec3 materialSpecular, vec3 normal, vec3 fragPos, vec3 viewerDirToFragment);

void main()
{
    vec3 materialDiffuse = vec3(texture(material.diffuse, fTexCoords));
    vec3 materialSpecular = vec3(texture(material.specular, fTexCoords));

    vec3 viewerDirToFragment = normalize(fragPos);

    vec3 res = vec3(0.0);
    res += calcDirectionalLight(directionalLight, materialDiffuse, materialSpecular, fNormal, viewerDirToFragment);
    for(int i=0; i < NR_POINT_LIGHTS; ++i)
    {
        res += calcPointLight(pointLights[i], materialDiffuse, materialSpecular, fNormal, fragPos, viewerDirToFragment);
    }
    res += calcSpotLight(spotLight, materialDiffuse, materialSpecular, fNormal, fragPos, viewerDirToFragment);
    fragColor = vec4(res, 1.0);
}

vec3 calcAmbientComponent(vec3 lightSourceAmbient, vec3 materialDiffuse)
{
    // return lightSourceAmbient * vec3(texture(material.diffuse, fTexCoords));
    return lightSourceAmbient * materialDiffuse;
}

// Assumes normalized normal and lightDirToFragment.
vec3 calcDiffuseComponent(vec3 lightSourceDiffuse, vec3 materialDiffuse, vec3 normal, vec3 lightDirToFragment)
{
    float diffuseMult = max(dot(normal, -lightDirToFragment), 0.0);
    // return lightSourceDiffuse * diffuseMult * vec3(texture(material.diffuse, fTexCoords));
    return lightSourceDiffuse * diffuseMult * materialDiffuse;
}

// Assumes normalized normal, lightDirToFragment, and viewerDirToFragment.
vec3 calcSpecularComponent(vec3 lightSourceSpecular, vec3 materialSpecular, vec3 normal, vec3 lightDirToFragment, vec3 viewerDirToFragment)
{
    vec3 reflectDir = reflect(lightDirToFragment, normal);
    float specularMult = pow(max(dot(-viewerDirToFragment, reflectDir), 0.0), material.shininess);
    // return lightSourceSpecular * specularMult * vec3(texture(material.specular, fTexCoords));
    return lightSourceSpecular * specularMult * materialSpecular;
}

float calcAttenuationValue(Attenuation attenuation, float distLightToFragment)
{
    return 1.0 /
        (attenuation.constant +
         attenuation.linear * distLightToFragment +
         attenuation.quadratic * distLightToFragment * distLightToFragment);
}

// Returns Phong lighting components of an object given lighting and object's material properties.
PhongLighting calcPhongLightComponents(PhongLighting lightComponents,
                                       vec3 materialDiffuse, vec3 materialSpecular,
                                       vec3 normal, vec3 lightDirToFragment, vec3 viewerDirToFragment)
{
    return PhongLighting
    (
        calcAmbientComponent(lightComponents.ambient, materialDiffuse),
        calcDiffuseComponent(lightComponents.diffuse, materialDiffuse, normal, lightDirToFragment),
        calcSpecularComponent(lightComponents.specular, materialSpecular, normal, lightDirToFragment, viewerDirToFragment)
    );
}

vec3 calcDirectionalLight(DirectionalLight light, vec3 materialDiffuse, vec3 materialSpecular, vec3 normal, vec3 viewerDirToFragment)
{
    vec3 lightDirToFragment = light.direction;

    PhongLighting objComponents =
        calcPhongLightComponents(light.components,
                                 materialDiffuse, materialSpecular,
                                 normal, lightDirToFragment, viewerDirToFragment);

    return objComponents.ambient + objComponents.diffuse + objComponents.specular;
}

vec3 calcPointLight(PointLight light, vec3 materialDiffuse, vec3 materialSpecular, vec3 normal, vec3 fragPos, vec3 viewerDirToFragment)
{
    vec3 lightDirToFragment = normalize(fragPos - light.position);
    float distLightToFragment = length(light.position - fragPos);

    PhongLighting objComponents =
        calcPhongLightComponents(light.components,
                                 materialDiffuse, materialSpecular,
                                 normal, lightDirToFragment, viewerDirToFragment);
    float attenuationValue = calcAttenuationValue(light.attenuation, distLightToFragment);

    return attenuationValue * (objComponents.ambient + objComponents.diffuse + objComponents.specular);
}

vec3 calcSpotLight(SpotLight light, vec3 materialDiffuse, vec3 materialSpecular, vec3 normal, vec3 fragPos, vec3 viewerDirToFragment)
{
    vec3 lightDirToFragment = normalize(fragPos - light.position);
    float distLightToFragment = length(light.position - fragPos);

    PhongLighting objComponents =
        calcPhongLightComponents(light.components,
                                 materialDiffuse, materialSpecular,
                                 normal, lightDirToFragment, viewerDirToFragment);
    float attenuationValue = calcAttenuationValue(light.attenuation, distLightToFragment);

    float cosLightDir = dot(viewerDirToFragment, normalize(light.direction));
    float interpolationInterval = light.cosInnerCutOff - light.cosOuterCutOff;
    float intensity = clamp((cosLightDir - light.cosOuterCutOff) / interpolationInterval, 0.0, 1.0);

    return attenuationValue * (objComponents.ambient + intensity * (objComponents.diffuse + objComponents.specular));
}
