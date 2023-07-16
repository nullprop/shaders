#version 330

uniform mat4 matVP;
uniform mat4 matGeo;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec3 normal;

out vec3 vert_pos;

void main() {
    vec4 vert = (matGeo * vec4(pos, 1.0));
    vert_pos = vert.xyz;
    gl_Position = matVP * vert;
}
