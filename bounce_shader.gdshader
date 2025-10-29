shader_type canvas_item;
//that is a tileset shader

uniform float red : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float green : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float blue : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float alpha : hint_range(0.0, 1.0, 0.1) = 1.0;

uniform sampler2D noise_texture;

void vertex(){
	float sin_rot = sin(TIME)/5.0;
	float cos_rot = abs(cos(TIME))/5.0+0.8;
	mat2 rotation = mat2(vec2(cos_rot, -sin_rot), vec2(sin_rot, cos_rot));
	
	
	VERTEX = rotation * VERTEX;
}

