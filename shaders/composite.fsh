#version 330 compatibility
#define SHADOWS //Enable sun/moon shadow mapping
#define shadowDistance 96.0 //Shadow distance in blocks [32.0 48.0 64.0 96.0 128.0 160.0]
#define coloredLight //Colored light approximation from the vanilla lightmap
#define localLightStrength 0.8 //Local light strength [0.0 0.25 0.5 0.75 1.0]
#define waterTint 0.28 //Water tint strength [0.0 0.1 0.2 0.3 0.4 0.5]
#define shadowSoftness 1 //Soft shadow taps [0 1 2]
#define atmosphereStrength 0.25 //Atmospheric color grade [0.0 0.1 0.2 0.3 0.4 0.5]
#define saturationStrength 1.0 //Color saturation [0.8 0.9 1.0 1.1 1.2]
#define waterReflectionStrength 0.15 //Subtle screen-space water response [0.0 0.1 0.2 0.3 0.4]
#define waterWaveStrength 0.4 //Water shimmer [0.0 0.2 0.4 0.6 0.8 1.0]
#define renderQuality 1 //Profile quality [0 1 2]

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
uniform vec3 sunPosition;
uniform vec3 skyColor;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;
in vec2 texcoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

float shadowAt(vec3 viewPos) {
#ifdef SHADOWS
    vec4 view = vec4(viewPos, 1.0);
    vec4 world = gbufferModelViewInverse * view;
    vec4 shadowPos = shadowProjection * shadowModelView * world;
    shadowPos.xyz /= max(shadowPos.w, 0.0001);
    vec3 coord = shadowPos.xyz * 0.5 + 0.5;
    if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0 || coord.z < 0.0 || coord.z > 1.0) return 1.0;
    float bias = 0.0015;
    float lit = texture(shadowtex0, coord.xy).r + bias >= coord.z ? 1.0 : 0.42;
#if shadowSoftness > 0
    vec2 px = 1.0 / vec2(max(viewWidth, 1.0), max(viewHeight, 1.0));
    float s = 0.0;
    s += texture(shadowtex0, coord.xy + px * vec2(-1.0, 0.0)).r + bias >= coord.z ? 1.0 : 0.42;
    s += texture(shadowtex0, coord.xy + px * vec2( 1.0, 0.0)).r + bias >= coord.z ? 1.0 : 0.42;
    s += texture(shadowtex0, coord.xy + px * vec2(0.0, -1.0)).r + bias >= coord.z ? 1.0 : 0.42;
    s += texture(shadowtex0, coord.xy + px * vec2(0.0,  1.0)).r + bias >= coord.z ? 1.0 : 0.42;
    lit = mix(lit, s * 0.2, 0.35);
#endif
    return lit;
#else
    return 1.0;
#endif
}
void main() {
    vec4 base = texture(colortex0, texcoord);
    float depth = texture(depthtex0, texcoord).r;
    if (depth < 0.999999) {
        vec4 clip = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
        vec4 view = gbufferProjectionInverse * clip;
        view /= max(abs(view.w), 0.00001);
        float distanceToCamera = length(view.xyz);
        float shadow = distanceToCamera < shadowDistance ? shadowAt(view.xyz) : 1.0;
        base.rgb *= shadow;
    }
    float rain = clamp(rainStrength, 0.0, 1.0);
    vec3 muted = mix(base.rgb, base.rgb * vec3(0.88, 0.93, 1.0), rain * 0.12);
    float luma = dot(muted, vec3(0.2126, 0.7152, 0.0722));
    muted = mix(vec3(luma), muted, saturationStrength);
    muted = mix(muted, muted * vec3(0.97, 0.99, 1.0), atmosphereStrength * 0.12);
    fragColor = vec4(muted, base.a);
}