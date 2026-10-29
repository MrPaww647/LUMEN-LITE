#version 330 compatibility
uniform sampler2D gtexture;
uniform sampler2D lightmap;
in vec2 texcoord;
in vec4 vertexColor;
in vec2 lightmapCoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 tex = texture(gtexture, texcoord) * vertexColor;
    if (tex.a < 0.05) discard;
    fragColor = vec4(tex.rgb * texture(lightmap, lightmapCoord).rgb, tex.a);
}