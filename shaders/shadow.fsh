#version 330 compatibility
uniform sampler2D gtexture;
in vec2 texcoord;
in vec4 vertexColor;
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 tex = texture(gtexture, texcoord) * vertexColor;
    if (tex.a < 0.1) discard;
    fragColor = tex;
}