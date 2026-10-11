shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.14,0.135,0.15,1.0);
varying vec3 world_pos;
float hash(vec3 p) { return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453); }
float noise3(vec3 p) {
 vec3 i=floor(p); vec3 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex() { world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
 float n=noise3(world_pos*2.4)*0.65+noise3(world_pos*18.0)*0.35;
 float vein=pow(1.0-abs(noise3(world_pos*0.8)*2.0-1.0),20.0);
 ALBEDO=base_color.rgb*(0.76+n*0.47)+vec3(0.004,0.004,0.006)*vein;
 ROUGHNESS=0.78+n*0.18;
}
