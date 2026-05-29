shader_type canvas_item;

uniform vec2 atlas_size;
uniform vec2 atlas_offset;

void fragment() {
    // Convert Rect size to normalized UV space
    vec2 tile_size = atlas_size / vec2(textureSize(TEXTURE, 0));
    vec2 tile_offset = atlas_offset / vec2(textureSize(TEXTURE, 0));
    
    // Repeat UV strictly within the atlas region
    vec2 repeated_uv = mod(UV, tile_size) + tile_offset;
    
    COLOR = texture(TEXTURE, repeated_uv);
}
