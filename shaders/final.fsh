#version 330 compatibility
uniform sampler2D colortex2;
in vec2 texcoord;
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 c = texture(colortex2, texcoord);
    // A restrained filmic shoulder; avoid washing out torches and emissive textures.
    c.rgb = c.rgb / (vec3(0.22) + c.rgb);
    c.rgb = pow(max(c.rgb, vec3(0.0)), vec3(1.02));
    fragColor = vec4(c.rgb, c.a);
}