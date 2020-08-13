varying vec3 vWorldPosition;


uniform vec3 up;
uniform vec2 resolution;
uniform float time;
uniform float speed;

const vec3 cameraPos = vec3( 0.0, 0.0, 0.0 );

// 	<www.shadertoy.com/view/XsX3zB>
//	by Nikita Miropolskiy

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

const float F3 =  0.3333333;
const float G3 =  0.1666667;
float snoise(vec3 p) {

	vec3 s = floor(p + dot(p, vec3(F3)));
	vec3 x = p - s + dot(s, vec3(G3));
	 
	vec3 e = step(vec3(0.0), x - x.yzx);
	vec3 i1 = e*(1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	vec3 x1 = x - i1 + G3;
	vec3 x2 = x - i2 + 2.0*G3;
	vec3 x3 = x - 1.0 + 3.0*G3;
	 
	vec4 w, d;
	 
	w.x = dot(x, x);
	w.y = dot(x1, x1);
	w.z = dot(x2, x2);
	w.w = dot(x3, x3);
	 
	w = max(0.6 - w, 0.0);
	 
	d.x = dot(random3(s), x);
	d.y = dot(random3(s + i1), x1);
	d.z = dot(random3(s + i2), x2);
	d.w = dot(random3(s + 1.0), x3);
	 
	w *= w;
	w *= w;
	d *= w;
	 
	return dot(d, vec4(52.0));
}

float snoiseFractal(vec3 m) {
	return   0.5333333* snoise(m)
				+0.2666667* snoise(2.0*m)
				+0.1333333* snoise(4.0*m)
				+0.0666667* snoise(8.0*m);
}




void main() {
  vec2 st = gl_FragCoord.xy / resolution;
  st = st * 2. - 1.;
  st.x *= resolution.x / resolution.y;

  // Noise
  st += snoiseFractal(vec3(st * 0.5, time * 0.02)) * 0.8;
  // st += noise(vec3(st* 2.3, time*2.3));

  vec3 direction = normalize( 
    vWorldPosition + vec3(0., 2., 0.) // + height
    - cameraPosition 
  );

  vec2 shift = vec2(0.);
  vec4 sum = vec4(0,0,0,0); 
  // z position of camera 
  float z = - cameraPosition.z;

  // retColor = vec3(z, 0., 0.);

  float groundStrength = pow(clamp(-direction.y, 0., 0.), 0.7);
  vec3 groundColor = vec3(
    1.,
    0.6,
    1.
  );
  groundColor = groundColor * groundStrength;

  float skyParam = pow(clamp(direction.y, 0., 1.), 0.7);
  
  vec3 skyColor = mix(
    vec3(0.7, 1., 0.), // horizon color
    vec3(0.2, 0., 0.8), // sky color
    skyParam
  );
  // skyColor *= skyStrength;
 
  vec3 faceColor = vec3( 0.1, 0.1, 0.2 );
  // faceColor =vec3(0.);
  // faceColor = vec3( 1.0, 0.6, 0.6 );
  // faceColor = vec3( 0.2, 0.2, 0.6 - ((st.y + 1.) * 0.4) );
  vec3 faceColor1 = vec3(0.);
  vec3 faceColor2 = vec3( 0.2 + ((st.y + 1.) * 0.25), 0.4, 0.5 );

  float stage = (1. - cos(z * 0.01)) * 0.5;

  faceColor = mix(faceColor1, faceColor2, stage);

  vec3 lineColor = vec3( st.x, st.y, 0.7 );
  // lineColor = vec3( 1.0, 0.6, 0.6 );
  // lineColor = vec3( 0.0, 0.5, 0.8 - ((st.y + 1.) * 0.5) );
  lineColor = vec3( 0.2 + ((st.y + 1.) * 0.25), 0.4, 0.5 );
  lineColor = vec3(0.2, 0.7, 0.5);

  // float factor = pow( (sin((st.x) * 150.)+1.)*0.5 , 50.);
  float factor = pow( (sin((st.x) * 150.)+1.)*0.5 , 50.);

  factor += pow( (sin(st.y * 150.)+1.)*0.5 , 50.);
  vec3 baseClor = mix( faceColor, lineColor, factor);

  vec3 color = vec3(0.);
  color += baseClor * smoothstep(0., 0.5, direction.y);
  color += baseClor * smoothstep(0., -0.5, direction.y);

  // color = vec3(1.-direction.y, 0.5 - direction.y, 0.2);
  color = mix(
    vec3( 0.6, 0.3, 0.5),
    vec3( 0.6, 0.7, 1.),
    direction.y
  );

  gl_FragColor = vec4( color, 1.0 );

}
