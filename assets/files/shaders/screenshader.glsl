#ifdef GL_ES
precision mediump float;
#endif

varying vec2 tcoord;
uniform sampler2D tex0;

void main() {
	vec2 uv = tcoord;

	vec4 final = texture2D(tex0, vec2(uv.x, uv.y+sin(uv.x)));

    gl_FragColor = final;
}
