#version 330 compatibility
out vec2 texcoord;
out vec4 vertexColor;
out vec2 lightmapCoord;
void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightmapCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vertexColor = gl_Color;
    gl_Position = ftransform();
}