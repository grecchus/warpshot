shader_type canvas_item;
//that is a tileset shader

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	float brightness = (pixel_color.r + pixel_color.g + pixel_color.b)/ 4.0;
	vec4 gray_scale = vec4(brightness, brightness, brightness, 1.0*pixel_color.a);

	
	COLOR = gray_scale;
}
