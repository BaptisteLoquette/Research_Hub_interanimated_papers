"use client";

/**
 * Minimal react-three-fiber lesson shell — copy into a Next.js app after installing
 * @react-three/fiber, @react-three/drei, three.
 */
import { Canvas } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";

function PlaceholderSubject() {
  return (
    <mesh>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="#a8a8a8" />
    </mesh>
  );
}

export default function LessonSceneExample() {
  return (
    <div
      className="h-[400px] w-full rounded-[var(--cur-radius-lg)] border shadow-[var(--cur-shadow-sm)]"
      style={{
        borderColor: "var(--cur-border)",
        background: "var(--cur-bg-canvas)",
      }}
    >
      <Canvas camera={{ position: [3, 3, 3] }}>
        <ambientLight intensity={Math.PI / 4} />
        <directionalLight position={[2, 2, 2]} intensity={Math.PI / 2} />
        <PlaceholderSubject />
        <OrbitControls enablePan enableZoom enableRotate />
      </Canvas>
    </div>
  );
}
