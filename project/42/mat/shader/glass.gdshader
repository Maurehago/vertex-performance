// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_always,diffuse_burley,specular_schlick_ggx,vertex_lighting;
// cull_disabled
uniform vec4 albedo : source_color;
uniform float roughness : hint_range(0,1) = 0.2;
uniform float alpha : hint_range(0,1) = 0.2;
uniform float specular;
uniform float metallic : hint_range(0,1) = 1.0;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform float clearcoat : hint_range(0,1);
uniform float clearcoat_roughness : hint_range(0,1);
uniform float ao_light_affect;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	ROUGHNESS=roughness;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = COLOR;
	
	//vec3 deph = texture(DEPTH_TEXTURE, SCREEN_UV).rgb;
	//vec3 screen = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float basic_fresnel = fresnel(0.5, NORMAL, VIEW);
	//ALBEDO = screen;
	
	ALBEDO = (albedo.rgb * albedo_tex.rgb) * basic_fresnel;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	ALPHA = alpha;
	CLEARCOAT = clearcoat;	CLEARCOAT_ROUGHNESS = clearcoat_roughness;
	//AO = dot(texture(texture_ambient_occlusion,base_uv),ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;
	

}
