shader_type canvas_item;
void fragment() {
 vec2 p=UV-0.5;
 float v=smoothstep(0.28,0.73,length(p*vec2(1.0,0.8)));
 COLOR=vec4(0.035,0.012,0.02,v*0.43);
}
