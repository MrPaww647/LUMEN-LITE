#version 330 compatibility
#define SHADOWS // Enable sun shadows
#define shadowDistance 96.0 // Shadow distance in blocks [32.0 48.0 64.0 96.0 128.0]
#define shadowSoftness 1 // PCF filter taps [0 1 2]
#define shadowStrength 0.72 // Shadow contrast [0.45 0.6 0.72 0.85 1.0]
#define reflectionStrength 0.42 // SSR intensity [0.0 0.2 0.4 0.6 0.8]
#define reflectionSteps 12 // SSR ray steps [4 8 12 16 24]
#define atmosphereStrength 0.18 // Color grade [0.0 0.1 0.2 0.3 0.4]
#define saturationStrength 1.0 // Saturation [0.8 0.9 1.0 1.1 1.2]

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
uniform float viewWidth;
uniform float viewHeight;
uniform float shadowMapResolution;
uniform float rainStrength;
in vec2 texcoord;
/* RENDERTARGETS: 2 */
layout(location = 0) out vec4 fragColor;

vec3 reconstructView(vec2 uv, float depth) {
    vec4 p = gbufferProjectionInverse * vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    return p.xyz / max(abs(p.w), 0.00001) * sign(p.w);
}

float compareShadow(vec3 coord) {
    return texture(shadowtex0, coord.xy).r + 0.0018 >= coord.z ? 1.0 : (1.0 - shadowStrength);
}
float getShadow(vec3 viewPos) {
#ifdef SHADOWS
    vec4 worldPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
    vec4 shadowPos = shadowProjection * shadowModelView * worldPos;
    shadowPos.xyz /= max(abs(shadowPos.w), 0.00001);
    vec3 coord = shadowPos.xyz * 0.5 + 0.5;
    if (coord.x <= 0.002 || coord.x >= 0.998 || coord.y <= 0.002 || coord.y >= 0.998 || coord.z <= 0.0 || coord.z >= 1.0) return 1.0;
    float result = compareShadow(coord);
#if shadowSoftness > 0
    float texel = 1.0 / max(shadowMapResolution, 512.0);
    result += compareShadow(coord + vec3(-texel, -texel, 0.0));
    result += compareShadow(coord + vec3( texel, -texel, 0.0));
    result += compareShadow(coord + vec3(-texel,  texel, 0.0));
    result += compareShadow(coord + vec3( texel,  texel, 0.0));
    result *= 0.2;
#endif
#if shadowSoftness > 1
    float texel2 = 2.0 / max(shadowMapResolution, 512.0);
    result += compareShadow(coord + vec3(-texel2, 0.0, 0.0));
    result += compareShadow(coord + vec3( texel2, 0.0, 0.0));
    result += compareShadow(coord + vec3(0.0, -texel2, 0.0));
    result += compareShadow(coord + vec3(0.0,  texel2, 0.0));
    result *= 0.5555556;
#endif
    return result;
#else
    return 1.0;
#endif
}

vec3 screenSpaceReflection(vec2 uv, float depth, vec3 normal) {
    if (depth >= 0.99999 || reflectionStrength <= 0.001) return vec3(0.0);
    vec3 origin = reconstructView(uv, depth);
    vec3 incident = normalize(origin);
    vec3 ray = normalize(reflect(incident, normalize(normal)));
    // Only trace rays travelling back into the visible scene.
    if (ray.z >= -0.02) return vec3(0.0);

    float start = 0.12;
    float endDistance = 18.0;
    float hit = 0.0;
    vec2 hitUV = uv;
    float travel = start;
    for (int i = 0; i < reflectionSteps; ++i) {
        vec3 samplePos = origin + ray * travel;
        vec4 clip = gbufferProjection * vec4(samplePos, 1.0);
        if (clip.w <= 0.0) break;
        vec2 suv = clip.xy / clip.w * 0.5 + 0.5;
        if (suv.x <= 0.002 || suv.x >= 0.998 || suv.y <= 0.002 || suv.y >= 0.998) break;
        float sceneDepth = texture(depthtex1, suv).r;
        if (sceneDepth < 0.99999) {
            vec3 scenePos = reconstructView(suv, sceneDepth);
            float delta = samplePos.z - scenePos.z;
            if (delta < 0.0 && abs(delta) < max(0.22, travel * 0.035)) {
                hit = 1.0;
                hitUV = suv;
                break;
            }
        }
        travel += mix(0.18, 1.45, float(i) / max(float(reflectionSteps - 1), 1.0));
        if (travel > endDistance) break;
    }
    if (hit < 0.5) return vec3(0.0);
    float edgeFade = clamp(min(min(hitUV.x, 1.0-hitUV.x), min(hitUV.y, 1.0-hitUV.y)) * 9.0, 0.0, 1.0);
    float distanceFade = 1.0 - clamp(travel / endDistance, 0.0, 1.0);
    float confidence = edgeFade * distanceFade * reflectionStrength;
    return texture(colortex0, hitUV).rgb * confidence;
}

void main() {
    vec4 base = texture(colortex0, texcoord);
    float depth = texture(depthtex1, texcoord).r;
    if (depth < 0.99999) {
        vec3 viewPos = reconstructView(texcoord, depth);
        float dist = length(viewPos);
        if (dist < shadowDistance) {
            float sh = getShadow(viewPos);
            base.rgb *= sh;
        }
    }

    vec4 water = texture(colortex1, texcoord);
    if (water.a > 0.5) {
        vec3 normal = normalize(water.rgb * 2.0 - 1.0);
        vec3 reflected = screenSpaceReflection(texcoord, texture(depthtex0, texcoord).r, normal);
        float facing = clamp(abs(normal.z), 0.12, 0.9);
        base.rgb = mix(base.rgb, reflected, clamp(reflectionStrength * facing, 0.0, 0.58));
    }

    float rain = clamp(rainStrength, 0.0, 1.0);
    base.rgb = mix(base.rgb, base.rgb * vec3(0.90, 0.95, 1.0), rain * 0.10);
    float luma = dot(base.rgb, vec3(0.2126, 0.7152, 0.0722));
    base.rgb = mix(vec3(luma), base.rgb, saturationStrength);
    base.rgb = mix(base.rgb, base.rgb * vec3(0.985, 0.995, 1.0), clamp(atmosphereStrength, 0.0, 0.4) * 0.12);
    fragColor = vec4(max(base.rgb, vec3(0.0)), base.a);
}