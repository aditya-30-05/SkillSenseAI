"use client";

import React, { useEffect, useRef, useState } from "react";
import * as THREE from "three";

export default function HomePage() {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const reticleRef = useRef<HTMLDivElement | null>(null);
  const retLabelRef = useRef<HTMLElement | null>(null);

  // Kinetic rotating phrase state
  const phrases = ["Detect faster.", "Stay safe.", "Coach in real time."];
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [phraseOut, setPhraseOut] = useState(false);

  // Live telemetry state
  const [telemetry, setTelemetry] = useState({
    ch4: 11.0,
    co: 4.0,
    h2s: 0.4,
    isHot: false,
    chipText: "Scanning pipeline 3B",
    coachMessage: "AI coach is standing by.",
  });

  // Auth inputs & boot sequence state
  const [trainerId, setTrainerId] = useState("TR-DEMO-001");
  const [password, setPassword] = useState("demo-pass-01");
  const [bootSteps, setBootSteps] = useState<string[]>([]);
  const [isBooting, setIsBooting] = useState(false);
  const [buttonLabel, setButtonLabel] = useState("Launch dashboard");
  const [isReady, setIsReady] = useState(false);

  // 1. Kinetic headline text rotation
  useEffect(() => {
    const interval = setInterval(() => {
      setPhraseOut(true);
      setTimeout(() => {
        setPhraseIndex((prev) => (prev + 1) % phrases.length);
        setPhraseOut(false);
      }, 450);
    }, 3200);
    return () => clearInterval(interval);
  }, [phrases.length]);

  // 2. Three.js 3D Interactive Drone & Telemetry Simulation
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    let renderer: THREE.WebGLRenderer | null = null;
    try {
      renderer = new THREE.WebGLRenderer({
        canvas,
        antialias: true,
        alpha: true,
      });
    } catch {
      return;
    }

    const scene = new THREE.Scene();
    scene.fog = new THREE.FogExp2(0x070b10, 0.05);

    const camera = new THREE.PerspectiveCamera(42, 1, 0.1, 100);
    const look = new THREE.Vector3(0.2, -0.9, -1.2);

    scene.add(new THREE.AmbientLight(0x7a97aa, 0.6));
    const key = new THREE.DirectionalLight(0xcfeeff, 0.95);
    key.position.set(3, 5, 5);
    scene.add(key);

    const rim = new THREE.DirectionalLight(0xffb020, 0.35);
    rim.position.set(-5, 2, -4);
    scene.add(rim);

    const under = new THREE.PointLight(0x2fd4b0, 1.1, 7);
    scene.add(under);

    const GROUND = -3.2;
    const LEAK = new THREE.Vector3(1.3, -2.55, -1.2);

    const grid = new THREE.GridHelper(60, 60, 0x0f6a5a, 0x111d27);
    grid.position.y = GROUND;
    scene.add(grid);

    const matPipe = new THREE.MeshStandardMaterial({
      color: 0x1a2733,
      metalness: 0.7,
      roughness: 0.45,
    });

    const createPipe = (z: number, len: number, r: number) => {
      const m = new THREE.Mesh(new THREE.CylinderGeometry(r, r, len, 24), matPipe);
      m.rotation.z = Math.PI / 2;
      m.position.set(0, GROUND + r + 0.04, z);
      scene.add(m);
      for (let x = -len / 2 + 1.5; x < len / 2; x += 3) {
        const f = new THREE.Mesh(
          new THREE.CylinderGeometry(r * 1.22, r * 1.22, 0.14, 24),
          matPipe
        );
        f.rotation.z = Math.PI / 2;
        f.position.set(x, GROUND + r + 0.04, z);
        scene.add(f);
      }
    };

    createPipe(-1.2, 26, 0.24);
    createPipe(-3.1, 26, 0.3);

    const valve = new THREE.Mesh(
      new THREE.BoxGeometry(0.3, 0.3, 0.3),
      new THREE.MeshStandardMaterial({
        color: 0x3a2a12,
        metalness: 0.5,
        roughness: 0.5,
        emissive: 0x3a1d00,
      })
    );
    valve.position.set(LEAK.x, GROUND + 0.52, LEAK.z);
    scene.add(valve);

    const tankMat = new THREE.MeshStandardMaterial({
      color: 0x101922,
      metalness: 0.6,
      roughness: 0.6,
    });

    const tankConfigs = [
      [-5, -7, 2.6, 1.3],
      [4.6, -8, 3.4, 1.5],
      [9, -6.5, 2.2, 1.1],
      [-10, -9, 3.8, 1.6],
    ];

    tankConfigs.forEach((t) => {
      const tank = new THREE.Mesh(
        new THREE.CylinderGeometry(t[3], t[3], t[2], 28),
        tankMat
      );
      tank.position.set(t[0], GROUND + t[2] / 2, t[1]);
      scene.add(tank);

      const beacon = new THREE.Mesh(
        new THREE.SphereGeometry(0.07, 10, 10),
        new THREE.MeshBasicMaterial({ color: 0xff4d4d })
      );
      beacon.position.set(t[0], GROUND + t[2] + 0.12, t[1]);
      beacon.userData.beacon = true;
      scene.add(beacon);
    });

    // Drone Assembly
    const drone = new THREE.Group();
    const matBody = new THREE.MeshStandardMaterial({
      color: 0x22313f,
      metalness: 0.65,
      roughness: 0.32,
    });
    const matDark = new THREE.MeshStandardMaterial({
      color: 0x0b1118,
      metalness: 0.7,
      roughness: 0.5,
    });

    drone.add(new THREE.Mesh(new THREE.BoxGeometry(1.1, 0.26, 0.82), matBody));
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(0.34, 24, 12, 0, Math.PI * 2, 0, Math.PI / 2),
      matBody
    );
    dome.position.y = 0.13;
    drone.add(dome);

    const rotors: THREE.Group[] = [];
    [Math.PI / 4, -Math.PI / 4].forEach((a) => {
      const arm = new THREE.Mesh(new THREE.BoxGeometry(3, 0.07, 0.13), matDark);
      arm.rotation.y = a;
      drone.add(arm);
    });

    [
      [1, 1],
      [-1, 1],
      [1, -1],
      [-1, -1],
    ].forEach((s) => {
      const px = s[0] * 1.06;
      const pz = s[1] * 1.06;
      const motor = new THREE.Mesh(
        new THREE.CylinderGeometry(0.13, 0.15, 0.16, 16),
        matBody
      );
      motor.position.set(px, 0.04, pz);
      drone.add(motor);

      const rg = new THREE.Group();
      rg.position.set(px, 0.17, pz);
      const bladeMat = new THREE.MeshStandardMaterial({
        color: 0x0a0f14,
        metalness: 0.3,
        roughness: 0.6,
      });
      const b1 = new THREE.Mesh(new THREE.BoxGeometry(1.15, 0.012, 0.07), bladeMat);
      const b2 = b1.clone();
      b2.rotation.y = Math.PI / 2;
      rg.add(b1);
      rg.add(b2);

      const disc = new THREE.Mesh(
        new THREE.CircleGeometry(0.58, 32),
        new THREE.MeshBasicMaterial({
          color: 0x2fd4b0,
          transparent: true,
          opacity: 0.07,
          side: THREE.DoubleSide,
          depthWrite: false,
        })
      );
      disc.rotation.x = -Math.PI / 2;
      rg.add(disc);
      drone.add(rg);
      rotors.push(rg);

      const led = new THREE.Mesh(
        new THREE.SphereGeometry(0.06, 10, 10),
        new THREE.MeshBasicMaterial({ color: s[1] > 0 ? 0x2fd4b0 : 0xff4d4d })
      );
      led.position.set(px, -0.06, pz);
      drone.add(led);
    });

    const mast = new THREE.Mesh(new THREE.CylinderGeometry(0.015, 0.015, 0.55, 8), matDark);
    mast.position.set(0.3, 0.5, -0.2);
    drone.add(mast);

    const tip = new THREE.Mesh(
      new THREE.SphereGeometry(0.04, 8, 8),
      new THREE.MeshBasicMaterial({ color: 0xffb020 })
    );
    tip.position.set(0.3, 0.78, -0.2);
    drone.add(tip);

    const gimbal = new THREE.Mesh(
      new THREE.CylinderGeometry(0.22, 0.26, 0.16, 20),
      matDark
    );
    gimbal.position.y = -0.2;
    drone.add(gimbal);

    const lens = new THREE.Mesh(
      new THREE.SphereGeometry(0.17, 20, 16),
      new THREE.MeshBasicMaterial({ color: 0x2fd4b0 })
    );
    lens.position.y = -0.36;
    drone.add(lens);

    const ring = new THREE.Mesh(
      new THREE.TorusGeometry(0.2, 0.012, 8, 32),
      new THREE.MeshBasicMaterial({ color: 0x2fd4b0 })
    );
    ring.rotation.x = Math.PI / 2;
    ring.position.y = -0.3;
    drone.add(ring);

    const coneMat = new THREE.MeshBasicMaterial({
      color: 0x2fd4b0,
      transparent: true,
      opacity: 0.1,
      side: THREE.DoubleSide,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    });
    const cone = new THREE.Mesh(
      new THREE.ConeGeometry(1.15, 3, 40, 1, true),
      coneMat
    );
    cone.position.y = -1.86;
    drone.add(cone);
    scene.add(drone);

    const scanRing = new THREE.Mesh(
      new THREE.RingGeometry(0.85, 0.95, 48),
      new THREE.MeshBasicMaterial({
        color: 0x2fd4b0,
        transparent: true,
        opacity: 0.55,
        side: THREE.DoubleSide,
        depthWrite: false,
      })
    );
    scanRing.rotation.x = -Math.PI / 2;
    scanRing.position.y = GROUND + 0.02;
    scene.add(scanRing);

    // Gas Plume Particles
    const N = 240;
    const pos = new Float32Array(N * 3);
    const vel = new Float32Array(N * 3);
    const life = new Float32Array(N);

    const spawnParticle = (i: number, stagger: boolean) => {
      pos[i * 3] = LEAK.x + (Math.random() - 0.5) * 0.12;
      pos[i * 3 + 1] = LEAK.y;
      pos[i * 3 + 2] = LEAK.z + (Math.random() - 0.5) * 0.12;
      vel[i * 3] = 0.12 + Math.random() * 0.25;
      vel[i * 3 + 1] = 0.45 + Math.random() * 0.55;
      vel[i * 3 + 2] = (Math.random() - 0.5) * 0.25;
      life[i] = stagger ? Math.random() * 3.5 : 2 + Math.random() * 2;
    };

    for (let i = 0; i < N; i++) {
      spawnParticle(i, true);
    }

    const pg = new THREE.BufferGeometry();
    pg.setAttribute("position", new THREE.BufferAttribute(pos, 3));
    const pm = new THREE.PointsMaterial({
      color: 0x7d95a3,
      size: 0.15,
      transparent: true,
      opacity: 0.06,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    });
    const plume = new THREE.Points(pg, pm);
    scene.add(plume);

    const camBase = { x: 0, y: 1.5, z: 8.5 };

    const handleResize = () => {
      const w = window.innerWidth;
      const h = window.innerHeight;
      if (renderer) {
        renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
        renderer.setSize(w, h, false);
      }
      camera.aspect = w / h;
      camBase.z = w / h < 1 ? 13.5 : 8.5;
      camera.updateProjectionMatrix();
    };

    window.addEventListener("resize", handleResize);
    handleResize();

    let mx = 0;
    let my = 0;
    let tx = 0;
    let ty = 0;

    const handlePointerMove = (e: PointerEvent) => {
      tx = (e.clientX / window.innerWidth - 0.5) * 2;
      ty = (e.clientY / window.innerHeight - 0.5) * 2;
    };
    window.addEventListener("pointermove", handlePointerMove);

    let detect = 0;
    let t = 0;
    let last = performance.now();
    let hudTimer = 0;
    let animId = 0;

    const v = new THREE.Vector3();
    const cTeal = new THREE.Color(0x2fd4b0);
    const cAmber = new THREE.Color(0xffb020);
    const cGas0 = new THREE.Color(0x7d95a3);
    const tmp = new THREE.Color();

    const frame = (now: number) => {
      const dt = Math.min((now - last) / 1000, 0.05);
      last = now;
      t += dt;

      const p = t * 0.32;
      const dx = -0.7 + 2.0 * Math.sin(p);
      drone.position.set(
        dx,
        0.55 + Math.sin(t * 1.7) * 0.07,
        -1.2 + Math.cos(p * 0.7) * 0.35
      );
      drone.rotation.y = 0.3 * Math.cos(p) - 0.25;
      drone.rotation.z = -0.07 * Math.cos(p);
      drone.rotation.x = 0.04 * Math.sin(t * 1.3);

      rotors.forEach((r, i) => {
        r.rotation.y += dt * 38 * (i % 2 ? 1 : -1);
      });

      under.position.set(drone.position.x, drone.position.y - 1, drone.position.z);
      scanRing.position.x = drone.position.x;
      scanRing.position.z = drone.position.z;
      scanRing.scale.setScalar(1 + 0.06 * Math.sin(t * 4));

      const d = Math.hypot(drone.position.x - LEAK.x, drone.position.z - LEAK.z);
      const target = d < 0.95 ? 1 : 0;
      detect += (target - detect) * Math.min(1, dt * 3);

      tmp.copy(cTeal).lerp(cAmber, detect);
      coneMat.color.copy(tmp);
      coneMat.opacity = 0.09 + 0.08 * detect;
      (scanRing.material as THREE.MeshBasicMaterial).color.copy(tmp);
      (lens.material as THREE.MeshBasicMaterial).color.copy(tmp);
      (ring.material as THREE.MeshBasicMaterial).color.copy(tmp);
      pm.color.copy(cGas0).lerp(cAmber, detect);
      pm.opacity = 0.06 + 0.6 * detect;
      pm.size = 0.14 + 0.08 * detect;

      for (let i = 0; i < N; i++) {
        life[i] -= dt;
        if (life[i] <= 0) {
          spawnParticle(i, false);
          continue;
        }
        vel[i * 3] += dt * 0.05;
        pos[i * 3] += vel[i * 3] * dt;
        pos[i * 3 + 1] += vel[i * 3 + 1] * dt;
        pos[i * 3 + 2] += vel[i * 3 + 2] * dt;
      }
      pg.attributes.position.needsUpdate = true;

      scene.children.forEach((o) => {
        if (o.userData && o.userData.beacon) {
          o.visible = Math.sin(t * 3 + o.position.x) > 0;
        }
      });

      mx += (tx - mx) * 0.04;
      my += (ty - my) * 0.04;
      camera.position.set(camBase.x + mx * 0.7, camBase.y - my * 0.35, camBase.z);
      camera.lookAt(look);
      camera.updateMatrixWorld();

      // Screen-space HUD Reticle projection
      v.copy(LEAK).project(camera);
      const sx = (v.x * 0.5 + 0.5) * window.innerWidth;
      const sy = (-v.y * 0.5 + 0.5) * window.innerHeight;

      if (reticleRef.current) {
        reticleRef.current.style.transform = `translate(${sx.toFixed(1)}px, ${sy.toFixed(1)}px) scale(${(1.25 - 0.25 * detect).toFixed(3)})`;
        reticleRef.current.style.opacity = Math.max(0, (detect - 0.1) / 0.9).toFixed(2);
      }

      // Telemetry update rate (approx 5Hz)
      hudTimer += dt;
      if (hudTimer > 0.2) {
        hudTimer = 0;
        const n = (a: number) => (Math.random() - 0.5) * a;
        const h2s = Math.max(0, 0.4 + 31 * detect + n(0.6));
        const ch4 = 11 + 19 * detect + n(1.4);
        const co = 4 + 9 * detect + n(0.5);

        if (retLabelRef.current) {
          retLabelRef.current.textContent = `H2S ${h2s.toFixed(0)} ppm`;
        }

        const nowHot = detect > 0.45;
        setTelemetry({
          ch4,
          co,
          h2s,
          isHot: nowHot,
          chipText: nowHot ? "H2S leak detected" : "Scanning pipeline 3B",
          coachMessage: nowHot
            ? "Trainee should stop, check wind direction, and move upwind before isolating the valve."
            : "AI coach is standing by.",
        });
      }

      if (renderer) renderer.render(scene, camera);
      animId = requestAnimationFrame(frame);
    };

    animId = requestAnimationFrame(frame);

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener("resize", handleResize);
      window.removeEventListener("pointermove", handlePointerMove);
      renderer?.dispose();
    };
  }, []);

  // 3. Boot & Startup sequence
  const handleLaunch = () => {
    if (isBooting) return;
    if (isReady) {
      window.location.href = "/app/";
      return;
    }
    setIsBooting(true);
    setBootSteps([]);
    setButtonLabel("Starting up...");

    const steps = [
      "Initializing sensors",
      "Calibrating AI coach",
      "Linking drone telemetry",
      "Mission cockpit ready",
    ];

    steps.forEach((step, idx) => {
      setTimeout(() => {
        setBootSteps((prev) => [...prev, step]);
        if (idx === steps.length - 1) {
          setButtonLabel("Launching cockpit...");
          setIsBooting(false);
          setIsReady(true);
          setTimeout(() => {
            window.location.href = "/app/";
          }, 450);
        }
      }, (idx + 1) * 450);
    });
  };

  const handleDemo = () => {
    setTrainerId("TR-OP-001");
    setPassword("active-pass-01");
    setIsBooting(true);
    setBootSteps([
      "Calibrating AI coach",
      "Linking drone telemetry",
      "Mission cockpit ready",
    ]);
    setButtonLabel("Launching live cockpit...");
    setTimeout(() => {
      window.location.href = "/app/";
    }, 450);
  };

  return (
    <>
      {/* Dynamic Google Fonts Link */}
      {/* eslint-disable-next-line @next/next/no-page-custom-font */}
      <link
        rel="stylesheet"
        href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600&family=Manrope:wght@400;500;600&display=swap"
      />

      <style jsx global>{`
        :root {
          --bg: #070b10;
          --ink: #eaf2f6;
          --ink-2: #9db0bb;
          --ink-3: #62767f;
          --teal: #2fd4b0;
          --teal-deep: #0f9d82;
          --amber: #ffb020;
          --alarm: #ff6a4d;
          --glass: rgba(11, 18, 25, 0.58);
          --line: rgba(255, 255, 255, 0.09);
          --display: 'Sora', 'Segoe UI', system-ui, sans-serif;
          --body: 'Manrope', 'Segoe UI', system-ui, sans-serif;
          color-scheme: dark;
        }

        body {
          margin: 0;
          background: var(--bg);
          color: var(--ink);
          font-family: var(--body);
          font-size: 15px;
          line-height: 1.5;
          -webkit-font-smoothing: antialiased;
          overflow-x: hidden;
        }

        #scene {
          position: fixed;
          inset: 0;
          width: 100%;
          height: 100%;
          display: block;
          z-index: 1;
        }

        .veil {
          position: fixed;
          inset: 0;
          pointer-events: none;
          background: linear-gradient(
            90deg,
            rgba(7, 11, 16, 0.88) 0%,
            rgba(7, 11, 16, 0.4) 52%,
            rgba(7, 11, 16, 0.55) 100%
          );
          z-index: 2;
        }

        .stage {
          position: relative;
          z-index: 3;
          min-height: 100svh;
          display: grid;
          grid-template-columns: minmax(0, 1.2fr) minmax(0, 0.8fr);
          gap: 32px;
          padding: 28px max(5vw, 20px);
        }

        .left {
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          gap: 28px;
          min-width: 0;
        }

        .brand {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .logo {
          width: 36px;
          height: 36px;
          border-radius: 10px;
          background: var(--teal-deep);
          display: grid;
          place-items: center;
        }

        .logo svg {
          width: 20px;
          height: 20px;
        }

        .brand b {
          font-family: var(--display);
          font-weight: 600;
          font-size: 17px;
          letter-spacing: -0.01em;
        }

        .brand small {
          display: block;
          color: var(--ink-2);
          font-size: 12.5px;
        }

        .ver {
          font-size: 11.5px;
          padding: 2px 7px;
          border-radius: 6px;
          background: rgba(47, 212, 176, 0.14);
          color: var(--teal);
          margin-left: 6px;
          font-weight: 500;
        }

        .pitch {
          max-width: 560px;
        }

        .pill {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 6px 14px;
          border-radius: 999px;
          border: 1px solid rgba(47, 212, 176, 0.4);
          background: rgba(15, 157, 130, 0.12);
          color: var(--teal);
          font-size: 13px;
          font-weight: 500;
        }

        .dot {
          width: 7px;
          height: 7px;
          border-radius: 50%;
          background: var(--teal);
          animation: pulse 1.8s ease-in-out infinite;
        }

        @keyframes pulse {
          50% {
            opacity: 0.25;
          }
        }

        h1 {
          font-family: var(--display);
          font-weight: 600;
          font-size: clamp(2.4rem, 5.4vw, 4.4rem);
          line-height: 1.04;
          letter-spacing: -0.035em;
          margin: 22px 0 18px;
        }

        h1 .l2 {
          display: block;
          color: var(--teal);
          min-height: 1.1em;
          transition: opacity 0.45s ease, transform 0.45s ease;
        }

        h1 .l2.out {
          opacity: 0;
          transform: translateY(10px);
        }

        .sub {
          color: var(--ink-2);
          max-width: 470px;
          margin: 0;
        }

        .panel {
          background: var(--glass);
          border: 1px solid var(--line);
          border-radius: 14px;
          backdrop-filter: blur(14px);
          -webkit-backdrop-filter: blur(14px);
        }

        .readouts {
          max-width: 560px;
          padding: 16px 18px;
        }

        .rh {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 12px;
          margin-bottom: 12px;
          font-size: 13px;
          color: var(--ink-2);
        }

        .chip {
          display: inline-flex;
          align-items: center;
          gap: 7px;
          padding: 3px 11px;
          border-radius: 999px;
          font-weight: 500;
          font-size: 12.5px;
          background: rgba(47, 212, 176, 0.12);
          color: var(--teal);
          transition: background 0.3s, color 0.3s;
        }

        .chip.hot {
          background: rgba(255, 106, 77, 0.16);
          color: var(--alarm);
        }

        .chip.hot .dot {
          background: var(--alarm);
          animation-duration: 0.6s;
        }

        .row {
          display: grid;
          grid-template-columns: 54px 1fr 86px;
          align-items: center;
          gap: 12px;
          padding: 5px 0;
        }

        .row span {
          color: var(--ink-2);
          font-size: 13.5px;
        }

        .bar {
          height: 6px;
          border-radius: 3px;
          background: rgba(255, 255, 255, 0.07);
          overflow: hidden;
        }

        .bar i {
          display: block;
          height: 100%;
          border-radius: 3px;
          background: var(--teal);
          transition: width 0.2s ease, background 0.3s;
        }

        .row output {
          font-family: var(--display);
          font-variant-numeric: tabular-nums;
          text-align: right;
          font-size: 14px;
        }

        .row output small {
          color: var(--ink-3);
          font-size: 11.5px;
          font-family: var(--body);
        }

        .row.warn .bar i {
          background: var(--alarm);
        }

        .coach {
          margin: 10px 0 0;
          padding-top: 10px;
          border-top: 1px solid var(--line);
          font-size: 13.5px;
          color: var(--ink-2);
          min-height: 42px;
        }

        .coach b {
          color: var(--amber);
          font-weight: 500;
        }

        .status {
          display: flex;
          align-items: center;
          gap: 9px;
          color: var(--ink-3);
          font-size: 12.5px;
        }

        .status .dot {
          background: #3ddc84;
        }

        .right {
          display: flex;
          align-items: center;
          justify-content: flex-end;
          min-width: 0;
        }

        .card {
          width: 100%;
          max-width: 400px;
          padding: 30px 28px;
        }

        .card h2 {
          font-family: var(--display);
          font-weight: 600;
          font-size: 26px;
          letter-spacing: -0.02em;
          margin: 10px 0 4px;
        }

        .tag {
          display: inline-block;
          font-size: 12.5px;
          padding: 3px 10px;
          border-radius: 6px;
          background: rgba(47, 212, 176, 0.13);
          color: var(--teal);
          font-weight: 500;
        }

        .card p {
          margin: 0 0 20px;
          color: var(--ink-2);
          font-size: 14px;
        }

        label {
          display: block;
          font-size: 13px;
          color: var(--ink-2);
          margin: 0 0 6px;
        }

        .field {
          margin-bottom: 16px;
        }

        input {
          width: 100%;
          height: 46px;
          padding: 0 14px;
          border-radius: 10px;
          border: 1px solid var(--line);
          background: rgba(5, 9, 13, 0.7);
          color: var(--ink);
          font: inherit;
          font-size: 15px;
          transition: border-color 0.2s, box-shadow 0.2s;
        }

        input:focus {
          outline: none;
          border-color: var(--teal);
          box-shadow: 0 0 0 3px rgba(47, 212, 176, 0.2);
        }

        button.go,
        button.demo {
          font: inherit;
          font-weight: 600;
          font-size: 15px;
          height: 46px;
          width: 100%;
          border: 0;
          border-radius: 10px;
          cursor: pointer;
          position: relative;
          overflow: hidden;
          transition: transform 0.15s ease, filter 0.2s;
        }

        button:active {
          transform: scale(0.985);
        }

        button:focus-visible {
          outline: 2px solid #fff;
          outline-offset: 2px;
        }

        .go {
          background: var(--teal-deep);
          color: #04201a;
        }

        .go::after {
          content: "";
          position: absolute;
          top: 0;
          left: -60%;
          width: 40%;
          height: 100%;
          background: rgba(255, 255, 255, 0.28);
          transform: skewX(-20deg);
          transition: left 0.6s ease;
        }

        .go:hover::after {
          left: 130%;
        }

        .demo {
          background: var(--amber);
          color: #2a1a00;
          margin-top: 2px;
        }

        .demo:hover,
        .go:hover {
          filter: brightness(1.07);
        }

        .or {
          display: flex;
          align-items: center;
          gap: 12px;
          margin: 16px 0;
          color: var(--ink-3);
          font-size: 12.5px;
        }

        .or::before,
        .or::after {
          content: "";
          flex: 1;
          height: 1px;
          background: var(--line);
        }

        .boot {
          list-style: none;
          margin: 16px 0 0;
          padding: 0;
          font-size: 13px;
          color: var(--ink-2);
          min-height: 0;
        }

        .boot li {
          padding: 3px 0;
          animation: in 0.35s ease both;
        }

        .boot li::before {
          content: "";
          display: inline-block;
          width: 7px;
          height: 7px;
          border-radius: 50%;
          background: var(--teal);
          margin-right: 10px;
        }

        .boot li.last {
          color: var(--teal);
        }

        @keyframes in {
          from {
            opacity: 0;
            transform: translateX(-6px);
          }
          to {
            opacity: 1;
            transform: none;
          }
        }

        .reticle {
          position: fixed;
          left: 0;
          top: 0;
          width: 128px;
          height: 84px;
          margin: -42px 0 0 -64px;
          pointer-events: none;
          opacity: 0;
          z-index: 4;
          will-change: transform, opacity;
        }

        .reticle i {
          position: absolute;
          width: 16px;
          height: 16px;
          border: 2px solid var(--amber);
        }

        .reticle i:nth-child(1) {
          left: 0;
          top: 0;
          border-right: 0;
          border-bottom: 0;
        }

        .reticle i:nth-child(2) {
          right: 0;
          top: 0;
          border-left: 0;
          border-bottom: 0;
        }

        .reticle i:nth-child(3) {
          left: 0;
          bottom: 0;
          border-right: 0;
          border-top: 0;
        }

        .reticle i:nth-child(4) {
          right: 0;
          bottom: 0;
          border-left: 0;
          border-top: 0;
        }

        .reticle em {
          position: absolute;
          left: 50%;
          top: 100%;
          transform: translateX(-50%);
          margin-top: 8px;
          white-space: nowrap;
          font-style: normal;
          font-family: var(--display);
          font-size: 12.5px;
          color: var(--amber);
          background: rgba(7, 11, 16, 0.75);
          padding: 3px 9px;
          border-radius: 6px;
        }

        @media (max-width: 900px) {
          .stage {
            grid-template-columns: minmax(0, 1fr);
            padding-top: 22px;
          }
          .right {
            justify-content: center;
          }
          .veil {
            background: rgba(7, 11, 16, 0.55);
          }
          .reticle {
            display: none;
          }
        }
      `}</style>

      {/* 3D WebGL Background Scene */}
      <canvas id="scene" ref={canvasRef} aria-hidden="true" />

      {/* Atmospheric Vignette Veil */}
      <div className="veil" />

      {/* 3D HUD Reticle tracking the Gas Leak */}
      <div className="reticle" ref={reticleRef} aria-hidden="true">
        <i />
        <i />
        <i />
        <i />
        <em ref={retLabelRef}>H2S</em>
      </div>

      {/* Main Interactive Stage */}
      <main className="stage">
        {/* Left Column: Brand, Pitch & Telemetry Fusion HUD */}
        <section className="left">
          <div className="brand">
            <div className="logo" aria-hidden="true">
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="#04201a"
                strokeWidth="2"
                strokeLinecap="round"
              >
                <circle cx="12" cy="12" r="8" />
                <circle cx="12" cy="12" r="3" />
                <path d="M12 4v3" />
              </svg>
            </div>
            <div>
              <b>
                SkillSense AI<span className="ver">v1.0</span>
              </b>
              <small>Diagnostic and safety training platform</small>
            </div>
          </div>

          <div className="pitch">
            <span className="pill">
              <span className="dot" />
              Mission profile: AI coach remediation
            </span>
            <h1>
              Train smarter.
              <span className={`l2 ${phraseOut ? "out" : ""}`}>
                {phrases[phraseIndex]}
              </span>
            </h1>
            <p className="sub">
              A diagnostic and safety simulator for skilled industrial trades.
              Live telemetry, simulated hazard injections, and AI-driven coaching.
            </p>
          </div>

          <div>
            <div className="panel readouts" aria-live="polite">
              <div className="rh">
                <span>Multi-sensor telemetry fusion</span>
                <span className={`chip ${telemetry.isHot ? "hot" : ""}`}>
                  <span className="dot" />
                  <span>{telemetry.chipText}</span>
                </span>
              </div>

              {/* CH4 Telemetry Row */}
              <div className={`row ${telemetry.ch4 > 22 ? "warn" : ""}`}>
                <span>
                  CH<sub>4</sub>
                </span>
                <div className="bar">
                  <i style={{ width: `${Math.min(100, (telemetry.ch4 / 60) * 100)}%` }} />
                </div>
                <output>
                  {telemetry.ch4.toFixed(1)} <small>ppm</small>
                </output>
              </div>

              {/* CO Telemetry Row */}
              <div className={`row ${telemetry.co > 10 ? "warn" : ""}`}>
                <span>CO</span>
                <div className="bar">
                  <i style={{ width: `${Math.min(100, (telemetry.co / 30) * 100)}%` }} />
                </div>
                <output>
                  {telemetry.co.toFixed(1)} <small>ppm</small>
                </output>
              </div>

              {/* H2S Telemetry Row */}
              <div className={`row ${telemetry.isHot ? "warn" : ""}`}>
                <span>
                  H<sub>2</sub>S
                </span>
                <div className="bar">
                  <i style={{ width: `${Math.min(100, (telemetry.h2s / 30) * 100)}%` }} />
                </div>
                <output>
                  {telemetry.h2s.toFixed(1)} <small>ppm</small>
                </output>
              </div>

              {/* AI Coach Feedback Strip */}
              <p className="coach">
                {telemetry.isHot ? (
                  <>
                    <b>AI coach:</b> {telemetry.coachMessage}
                  </>
                ) : (
                  telemetry.coachMessage
                )}
              </p>
            </div>

            <p className="status" style={{ margin: "16px 0 0" }}>
              <span className="dot" />
              System operational. Ready for trainer sign-in.
            </p>
          </div>
        </section>

        {/* Right Column: Mission Cockpit Sign-In Card */}
        <section className="right">
          <div className="panel card">
            <span className="tag">Trainer portal</span>
            <h2>Sign in</h2>
            <p>Enter your credentials to open the mission cockpit.</p>

            <div className="field">
              <label htmlFor="tid">Trainer ID</label>
              <input
                id="tid"
                value={trainerId}
                onChange={(e) => setTrainerId(e.target.value)}
                autoComplete="username"
              />
            </div>

            <div className="field">
              <label htmlFor="pw">Security password</label>
              <input
                id="pw"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
              />
            </div>

            <button
              className="go"
              id="launch"
              type="button"
              onClick={handleLaunch}
              disabled={isBooting}
            >
              {buttonLabel}
            </button>

            <div className="or">or instant access</div>

            <button
              className="demo"
              id="demo"
              type="button"
              onClick={handleDemo}
              disabled={isBooting}
            >
              Enter Live Cockpit
            </button>

            {/* Boot Sequence Log */}
            {bootSteps.length > 0 && (
              <ul className="boot" aria-live="polite">
                {bootSteps.map((step, i) => (
                  <li
                    key={i}
                    className={i === bootSteps.length - 1 && isReady ? "last" : ""}
                  >
                    {step}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </section>
      </main>
    </>
  );
}
