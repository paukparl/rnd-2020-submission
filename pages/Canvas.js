import React, {
  Suspense,
  useMemo,
  useEffect,
  useState,
  useRef
} from 'react';
import {
  Canvas,
  useThree,
  useFrame,
} from 'react-three-fiber';
import * as THREE from 'three';
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader';
import vertexShader from '../shaders/vert.glsl';
import fragmentShader from '../shaders/frag.glsl';

const Placeholder = () => {
  return (
    <mesh />
  );
};

const url = '/rnd-model.obj';

const Scene = () => {

  const [geometry, setGeometry] = useState();

  const loader = new OBJLoader();

  const { camera } = useThree();

  const mesh = useRef();

  useEffect(() => {
    loader.load(url, (obj) => {
      const temp = obj.children[0].geometry;
      setGeometry(temp);
    });
  }, []);

  useEffect(() => {
    if (!mesh.current) return;
    const transformer = new THREE.Object3D();
    console.log(mesh.current);
    transformer.position.set(-4, -3, 0);
    transformer.scale.set(0.01, 0.01, 0.01);
    transformer.updateMatrix();
    console.log(mesh.current.matrix);
    mesh.current.geometry.applyMatrix4(transformer.matrix);
    console.log(mesh.current.matrix);

    camera.position.set( 0, 0, 10,);
  },[geometry]);

  const material = useMemo(() => {
    const temp = new THREE.ShaderMaterial({
      uniforms: {
        time: { value: 0 },
      },
      vertexShader,
      fragmentShader,
    });
    return temp;
  }, []);

  console.log(geometry);

  const {clock} = useThree();

  useFrame(() => {
    const {elapsedTime} = clock;
    material.uniforms.time.value = elapsedTime;
  });


  return geometry ? (
    <mesh 
    ref={mesh}
    args={[geometry, material]}
    />
  ) : null;
};

export default () => {
  return (
    <Canvas
      camera={{ fov: 55, near: 1, far: 200 }}
    >
      <Suspense fallback={<Placeholder />}>
        <Scene />
      </Suspense>
    </Canvas>
  );
}