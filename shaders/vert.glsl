uniform vec3 up;
uniform float time;

varying vec3 vNormal;

void main() {

  vec3 transformed = position;
  transformed.y *= sin(position.x * 0.5 + time);

  vNormal = normal;

  gl_Position = projectionMatrix * modelViewMatrix * vec4( transformed, 1.0 );
  gl_Position.z = gl_Position.w; // set z to camera.far
}
