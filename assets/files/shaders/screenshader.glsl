#ifdef GL_ES
precision mediump float;
#endif

varying vec2 tcoord;
uniform sampler2D tex0;

void main() {
	vec2 uv = tcoord;

	vec4 final = texture2D(tex0, uv);

    gl_FragColor = vec4(uv.x,final.g,0,1);//+ uv.xyxy;
}
