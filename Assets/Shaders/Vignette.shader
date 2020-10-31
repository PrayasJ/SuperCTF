shader_type canvas_item;

const float RADIUS = 0.75;

const float SOFTNESS = 0.45;




void fragment()
{
	vec4 texColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	vec2 centralposition = (FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE).xy) - vec2(0.5); 
	
	float len = length(centralposition);
	

	
	float vignette = smoothstep(RADIUS, RADIUS-SOFTNESS, len);
	
	texColor.rgb *= vignette;
	
	COLOR = texColor;
}