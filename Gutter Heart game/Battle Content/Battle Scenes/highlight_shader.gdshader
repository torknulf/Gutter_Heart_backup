shader_type canvas_item;

render_mode unshaded;
uniform float highlight : hint_range(0.0, 1.0) = 0.0;


void fragment() {
	// sprite texture at the current pixel
	vec4 pixel_color = texture(TEXTURE, UV);
	
	// blend highlight color with original color
	vec3 highlight_rgb = mix(pixel_color.rgb, vec3(1.0, 1.0, 1.0), highlight);
	
	// output using original alpha 
	COLOR = vec4(highlight_rgb, pixel_color.a);
}
