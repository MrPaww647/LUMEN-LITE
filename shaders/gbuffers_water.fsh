#version 330 compatibility
#define waterTint 0.28 //Water tint strength [0.0 0.1 0.2 0.3 0.4 0.5]
uniform sampler2D gtexture;
uniform sampler2D lightmap;
in vec2 texcoord;
in vec4 vertexColor;
in vec2 lightmapCoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 tex = texture(gtexture, texcoord) * vertexColor;
    vec3 light = texture(lightmap, lightmapCoord).rgb;
    vec3 aqua = vec3(0.62, 0.84, 0.94);
    tex.rgb = mix(tex.rgb, tex.rgb * aqua, clamp(waterTint, 0.0, 0.8));
    fragColor = vec4(tex.rgb * light, tex.a);
}