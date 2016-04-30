#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;

varying vec2 tcoord;
varying vec4 color;

out vec4 fragColor;

void main() {
	vec4 col = texture2D(tex0, tcoord);

	fragColor = col;
}
