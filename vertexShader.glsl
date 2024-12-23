#version 330 core

// Input variables
layout(location = 0) in vec3 aPosition;
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTexCoord;

// Output variables for the fragment shader
out vec3 fragmentPosition;
out vec3 fragmentVertexNormal;
out vec2 fragmentTextureCoordinate;

// Struct definitions (must match fragment shader)
struct Material {
    vec3 diffuseColor;
    vec3 specularColor;
    float shininess;
};

struct DirectionalLight {
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    int bActive;
};

struct PointLight {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    int bActive;
};

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

// Uniforms (types must match fragment shader)
uniform int bUseTexture;
uniform int bUseLighting;
uniform Material material;
uniform DirectionalLight directionalLight;
uniform PointLight pointLights[5];
uniform SpotLight spotLight;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 viewPosition;

// Pass through the data to fragment shader
void main()
{
    fragmentPosition = vec3(model * vec4(aPosition, 1.0));
    fragmentVertexNormal = mat3(transpose(inverse(model))) * aNormal;
    fragmentTextureCoordinate = aTexCoord;

    gl_Position = projection * view * vec4(fragmentPosition, 1.0);
}
