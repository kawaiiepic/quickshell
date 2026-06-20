#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float saturation;
    float contrast;
    float brightness;
};
layout(binding = 1) uniform sampler2D src;

void main() {
    vec4 color = texture(src, qt_TexCoord0);
    //fragColor = vec4(vec3(dot(tex.rgb, vec3(0.344, 0.5, 0.156))), tex.a) * 1;

    // brightness
    color.rgb += brightness;
    color.rgb = (color.rgb - 0.5) * contrast + 0.5;

    // saturation
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(gray), color.rgb, saturation);

    fragColor = color;
}
