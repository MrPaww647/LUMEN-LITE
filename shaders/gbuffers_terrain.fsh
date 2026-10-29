#version 330 compatibility
#define coloredLight // Subtle lightmap tint, not artificial light sources
#define localLightStrength 0.45 // Keep colored lighting restrained [0.0 0.25 0.5 0.75 1.0]

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
    vec3 warm = vec3(1.0, 0.78, 0.57);
    vec3 cool = vec3(0.72, 0.84, 1.0);
    vec3 tint = mix(warm, cool, smoothstep(0.12, 0.95, lightmapCoord.x));
    light = mix(light, light * tint, clamp(blockLight * localLightStrength * 0.22, 0.0, 0.18));
#endif
    // Avoid boosting brightness here: Minecraft's lightmap remains the primary lighting source.
    fragColor = vec4(tex.rgb * light, tex.a);
}