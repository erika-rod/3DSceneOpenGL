#version 330 core

// Output fragment color
out vec4 fragmentColor;

// Input variables from the vertex shader
in vec3 fragmentPosition;
in vec3 fragmentVertexNormal;
in vec2 fragmentTextureCoordinate;

// Material structure
struct Material {
    vec3 diffuseColor;
    vec3 specularColor;
    float shininess;
}; 


// Directional light structure
struct DirectionalLight {
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    int bActive;
};

// Point light structure
struct PointLight {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    int bActive;
};

// Spot light structure
struct SpotLight {
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;
    float constant;
    float linear;
    float quadratic;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    int bActive;
};

// Constants
#define TOTAL_POINT_LIGHTS 5

// Uniform variables
uniform int bUseTexture = 0;
uniform int bUseLighting = 0;
uniform vec4 objectColor = vec4(1.0f);
uniform vec3 viewPosition;
uniform DirectionalLight directionalLight;
uniform PointLight pointLights[TOTAL_POINT_LIGHTS];
uniform SpotLight spotLight;
uniform Material material;
uniform sampler2D objectTexture;
uniform vec2 UVscale = vec2(1.0f, 1.0f);

// Function prototypes
vec3 CalcDirectionalLight(DirectionalLight light, vec3 normal, vec3 viewDir);
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir);
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

// Main function
void main()
{    
    vec3 phongResult = vec3(0.0f);

    if (bUseLighting == 1) // Enable lighting
    {
        vec3 norm = normalize(fragmentVertexNormal);
        vec3 viewDir = normalize(viewPosition - fragmentPosition);
    
        if (directionalLight.bActive == 1)
        {
            phongResult += CalcDirectionalLight(directionalLight, norm, viewDir);
        }

        for (int i = 0; i < TOTAL_POINT_LIGHTS; i++)
        {
            if (pointLights[i].bActive == 1)
            {
                phongResult += CalcPointLight(pointLights[i], norm, fragmentPosition, viewDir);   
            }
        } 

        if (spotLight.bActive == 1)
        {
            phongResult += CalcSpotLight(spotLight, norm, fragmentPosition, viewDir);    
        }
    }

    if (bUseTexture == 1)
{
    // Sample the texture color
    vec4 texColor = texture(objectTexture, fragmentTextureCoordinate * UVscale);
    
    // Combine texture with lighting
    vec3 blendedColor = texColor.rgb * phongResult; // Multiply texture color with lighting
    
    // Final output
    fragmentColor = vec4(blendedColor, texColor.a); // Preserve texture transparency
}
else
{
    // No texture, use lighting and object color
    fragmentColor = vec4(phongResult * objectColor.rgb, objectColor.a);
}

}

// Lighting calculations
vec3 CalcDirectionalLight(DirectionalLight light, vec3 normal, vec3 viewDir)
{
    vec3 lightDir = normalize(-light.direction);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);

    vec3 ambient = light.ambient * material.diffuseColor;
    vec3 diffuse = light.diffuse * diff * material.diffuseColor;
    vec3 specular = light.specular * spec * material.specularColor;

    return (ambient + diffuse + specular);
}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);

    vec3 ambient = light.ambient * material.diffuseColor;
    vec3 diffuse = light.diffuse * diff * material.diffuseColor;
    vec3 specular = light.specular * spec * material.specularColor;

    return (ambient + diffuse + specular);
}

vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);

    float distance = length(light.position - fragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));

    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = light.cutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);

    vec3 ambient = light.ambient * material.diffuseColor;
    vec3 diffuse = light.diffuse * diff * material.diffuseColor;
    vec3 specular = light.specular * spec * material.specularColor;

    ambient *= attenuation * intensity;
    diffuse *= attenuation * intensity;
    specular *= attenuation * intensity;

    return (ambient + diffuse + specular);
}
