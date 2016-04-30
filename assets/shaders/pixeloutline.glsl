#define web

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 tcoord;
varying vec4 color;

uniform sampler2D tex0;
uniform vec2 texSize;
uniform vec4 outlineColor;

void main() {
	vec2 uv = tcoord;

	vec4 final = texture2D(tex0, uv);

	float texelSizeX = 1.0/texSize.x;
	float texelSizeY = 1.0/texSize.y;

	if(final.a == 0.0) {
		if(texture2D(tex0, vec2(uv.x - texelSizeX, uv.y)).a > 0.0) {
			final = outlineColor;
		}
		else if(texture2D(tex0, vec2(uv.x + texelSizeX, uv.y)).a > 0.0) {
			final = outlineColor;
		}
		else if(texture2D(tex0, vec2(uv.x, uv.y - texelSizeY)).a > 0.0) {
			final = outlineColor;
		}
		else if(texture2D(tex0, vec2(uv.x, uv.y + texelSizeY)).a > 0.0) {
			final = outlineColor;
		}
	}

    gl_FragColor = final * color;
}
