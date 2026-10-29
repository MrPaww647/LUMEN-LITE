#version 330 compatibility
uniform sampler2D colortex0;
in vec2 texcoord;
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 c = texture(colortex0, texcoord);
    c.rgb = c.rgb / (c.rgb + vec3(0.08));
    c.rgb = pow(max(c.rgb, vec3(0.0)), vec3(0.97));
    fragColor = vec4(c.rgb, c.a);
}