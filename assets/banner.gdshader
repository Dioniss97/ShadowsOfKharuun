shader_type spatial;
render_mode cull_disabled;
uniform vec4 cloth_color : source_color = vec4(0.36,0.016,0.028,1.0);
void vertex() {
 float weight=UV.y;
 VERTEX.z+=sin(VERTEX.y*2.4+TIME*1.7+VERTEX.x)*0.16*weight;
}
void fragment() {
 float border=step(0.07,UV.x)*step(UV.x,0.93);
 float rune=step(abs(UV.x-0.5),0.055)*step(0.23,UV.y)*step(UV.y,0.76);
 float crossbar=step(abs(UV.y-0.44),0.022)*step(abs(UV.x-0.5),0.23);
 ALBEDO=mix(vec3(0.42,0.27,0.10),cloth_color.rgb,border);
 ALBEDO=mix(ALBEDO,vec3(0.58,0.38,0.17),max(rune,crossbar));
 ROUGHNESS=0.95;
}
