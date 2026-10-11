shader_type sky;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void sky() {
 float h=max(EYEDIR.y,0.0);
 vec3 col=mix(vec3(0.63,0.18,0.075),vec3(0.085,0.027,0.06),smoothstep(0.0,0.65,h));
 vec2 p=EYEDIR.xz/(abs(EYEDIR.y)+0.24)*2.7;
 float clouds=noise(p)+0.5*noise(p*2.5)+0.25*noise(p*6.0);
 col=mix(col,vec3(0.07,0.035,0.053),smoothstep(0.65,1.15,clouds)*0.82);
 float orb=dot(EYEDIR,normalize(vec3(0.27,0.34,-1.0)));
 float disc=smoothstep(0.992,0.993,orb);
 float corona=exp(-abs(orb-0.993)*500.0);
 col=col*(1.0-disc*0.94)+vec3(1.0,0.38,0.13)*corona*0.7;
 COLOR=col;
}
