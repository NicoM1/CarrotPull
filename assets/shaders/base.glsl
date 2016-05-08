//#version 330 core

#ifdef GL_ES
precision mediump float;
#endif

uniform float blurdist;
uniform float darkness;
uniform sampler2D tex0;
varying vec2 tcoord;
varying vec4 color;
//out vec4 frag;

void main() {
	float offset = blurdist;
    vec4 texcolor = texture(tex0, tcoord);
	vec4 texcolor1 = texture(tex0, vec2(tcoord.x - offset, tcoord.y));
	vec4 texcolor2 = texture(tex0, vec2(tcoord.x + offset, tcoord.y));
	vec4 texcolor3 = texture(tex0, vec2(tcoord.x, tcoord.y - offset));
	vec4 texcolor4 = texture(tex0, vec2(tcoord.x, tcoord.y + offset));
	//vec4 texcolor5 = texture(tex0, vec2(tcoord.x - offset*2, tcoord.y));
	vec4 texcolor6 = texture(tex0, vec2(tcoord.x + offset*2, tcoord.y));
	vec4 texcolor7 = texture(tex0, vec2(tcoord.x, tcoord.y - offset*2));
	vec4 texcolor8 = texture(tex0, vec2(tcoord.x, tcoord.y + offset*2));
	//originally a bug, now intentionally over-divided
	gl_FragColor = (texcolor + texcolor1 + texcolor2 + texcolor3 + texcolor4 + texcolor6 + texcolor7 + texcolor8)/9;
	gl_FragColor.rgb *= darkness;
}
