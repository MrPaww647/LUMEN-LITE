#version 330 compatibility
#define coloredLight //Colored light approximation from the vanilla lightmap
#define localLightStrength 0.8 //Local light strength [0.0 0.25 0.5 0.75 1.0]

uniform sampler2D gtexture;
uniform sampler2D lightmap;
in vec2 texcoord;
in vec4 vertexColor;
in vec2 lightmapCoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * vertexColor;
    if (tex.a < 0.1) discard;
    vec3 light = texture(lightmap, lightmapCoord).rgb;
#ifdef coloredLight
    float blockLight = clamp(lightmapCoord.x, 0.0, 1.0);
    vec3 warm = vec3(1.0, 0.63, 0.34);
    vec3 cool = vec3(0.52, 0.78, 1.0);
    vec3 tint = mix(warm, cool, smoothstep(0.2, 0.9, lightmapCoord.x));
    light = mix(light, light * tint, clamp(blockLight * localLightStrength * 0.35, 0.0, 0.35));
#endif
    fragColor = vec4(tex.rgb * light, tex.a);
}