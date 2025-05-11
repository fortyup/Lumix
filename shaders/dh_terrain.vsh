#version 410 compatibility

out vec4 blockColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;

void main()
{
    blockColor = gl_Color;
    lightMapCoords = (gl_TextureMatrix[2] * gl_MultiTexCoord2).xy;
    viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;
    
    gl_Position = ftransform();
}