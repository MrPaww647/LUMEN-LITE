#version 330 compatibility
#define waterTint 0.18 // Restrained water tint [0.0 0.1 0.2 0.3 0.4 0.5]
uniform sampler2D gtexture;
uniform sampler2D lightmap;
in vec2 texcoord;
in vec4 vertexColor;
in vec2 lightmapCoord;
in vec3 normalView;
in vec3 positionView;
/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 waterData;

void main() {
    vec4 tex = texture(gtexture, texcoord) * vertexColor;
    vec3 light = texture(lightmap, lightmapCoord).rgb;
    vec3 aqua = vec3(0.72, 0.88, 0.96);
    tex.rgb = mix(tex.rgb, tex.rgb * aqua, clamp(waterTint, 0.0, 0.5));
    // Save a water mask and view-space normal for the later screen-space reflection pass.
    vec3 n = normalize(normalView);
    waterData = vec4(n * 0.5 + 0.5, 1.0);
    fragColor = vec4(tex.rgb * light, tex.a);
}