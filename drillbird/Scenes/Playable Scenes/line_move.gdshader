shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 moving_uv = vec2(UV.x-(TIME*0.5),UV.y);
	vec4 in_tex=texture(TEXTURE,moving_uv);
	COLOR=in_tex;
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
