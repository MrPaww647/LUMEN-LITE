#version 330 compatibility
out vec2 texcoord;
out vec4 vertexColor;
out vec2 lightmapCoord;
out vec3 normalView;
out vec3 positionView;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightmapCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vertexColor = gl_Color;
    normalView = normalize(gl_NormalMatrix * gl_Normal);
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    positionView = viewPos.xyz;
    gl_Position = gl_ProjectionMatrix * viewPos;
}