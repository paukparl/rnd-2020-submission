import dynamic from 'next/dynamic';

export default () => {
  const Canvas = dynamic(
    () => import('./Canvas'),
    { ssr: false },
  );

  return (
    <Canvas />
  )
  

};
