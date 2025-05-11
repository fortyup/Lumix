#version 410 core


in vec2 vaUV0;
in ivec2 vaUV2;
in vec3 vaPosition;
in vec3 vaNormal;
in vec4 vaColor;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat3 normalMatrix;
uniform vec3 chunkOffset;

out vec2 texCoord;
out vec2 lightMapCoords;
out vec3 foliageColor;
out vec3 geoNormal;

void main()
{
    geoNormal = normalMatrix * vaNormal;
    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    
    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1.0);
}