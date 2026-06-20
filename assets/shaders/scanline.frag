#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
} ubuf;

void main() {
    float line = mod(floor(qt_TexCoord0.y * 300.0), 2.0);
    fragColor = vec4(0.0, 0.0, 0.0, line * 0.25 * ubuf.qt_Opacity);
}