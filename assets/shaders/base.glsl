#version 330 core

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;
in vec2 tcoord;
in vec4 color;
out vec4 frag;

void main() {
    vec4 texcolor = texture(tex0, tcoord);
    frag = color * texcolor;
}
