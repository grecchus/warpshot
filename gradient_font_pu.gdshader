shader_type canvas_item;

uniform float red : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float green : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float blue : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float alpha : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float shine_speed = 8.0;


void fragment() {
	vec4 text_color = texture(TEXTURE, UV);
	
	float gradient = sin(UV.x * 8.0 - TIME * shine_speed);
	
	vec4 color = vec4(gradient, green, blue, alpha);
	COLOR = text_color * color;
}