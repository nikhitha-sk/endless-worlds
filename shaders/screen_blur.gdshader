shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0.0, 8.0) = 3.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = SCREEN_PIXEL_SIZE * blur_strength;

	vec4 col = vec4(0.0);
	col += texture(SCREEN_TEXTURE, uv + vec2(-px.x, -px.y));
	col += texture(SCREEN_TEXTURE, uv + vec2( px.x, -px.y));
	col += texture(SCREEN_TEXTURE, uv + vec2(-px.x,  px.y));
	col += texture(SCREEN_TEXTURE, uv + vec2( px.x,  px.y));
	col *= 0.25;

	COLOR = col;
}
