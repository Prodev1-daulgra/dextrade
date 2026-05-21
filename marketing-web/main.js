import * as THREE from 'three';

// --- Navbar Scroll Effect ---
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  if (window.scrollY > 50) {
    navbar.classList.add('scrolled');
  } else {
    navbar.classList.add('scrolled'); // keep it for testing, or toggle properly
    if(window.scrollY <= 50) {
        navbar.classList.remove('scrolled');
    }
  }
});

// --- Three.js WebGL Background (Decentralized Node Network) ---
const container = document.getElementById('canvas-container');

// Scene Setup
const scene = new THREE.Scene();
scene.fog = new THREE.FogExp2(0x000000, 0.001);

const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 4000);
camera.position.z = 1000;

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(window.devicePixelRatio);
renderer.setSize(window.innerWidth, window.innerHeight);
container.appendChild(renderer.domElement);

// Network Particles
const particleCount = 400;
const particles = new THREE.BufferGeometry();
const particlePositions = new Float32Array(particleCount * 3);
const particleVelocities = [];

const r = 1200;

for (let i = 0; i < particleCount; i++) {
  const x = Math.random() * r - r / 2;
  const y = Math.random() * r - r / 2;
  const z = Math.random() * r - r / 2;

  particlePositions[i * 3] = x;
  particlePositions[i * 3 + 1] = y;
  particlePositions[i * 3 + 2] = z;

  particleVelocities.push({
    x: (Math.random() - 0.5) * 1,
    y: (Math.random() - 0.5) * 1,
    z: (Math.random() - 0.5) * 1
  });
}

particles.setAttribute('position', new THREE.BufferAttribute(particlePositions, 3));

// Particle Material (Glowing Cyan/Purple)
const pMaterial = new THREE.PointsMaterial({
  color: 0x7c3aed, // Purple
  size: 5,
  blending: THREE.AdditiveBlending,
  transparent: true,
  sizeAttenuation: true,
  opacity: 0.8
});

const particleSystem = new THREE.Points(particles, pMaterial);
scene.add(particleSystem);

// Network Lines
const linesGeometry = new THREE.BufferGeometry();
const linesMaterial = new THREE.LineBasicMaterial({
  color: 0x00f2fe, // Cyan
  transparent: true,
  opacity: 0.15,
  blending: THREE.AdditiveBlending
});

const linesMesh = new THREE.LineSegments(linesGeometry, linesMaterial);
scene.add(linesMesh);

// Post-processing / Animation Loop
let mouseX = 0;
let mouseY = 0;
let targetX = 0;
let targetY = 0;

const windowHalfX = window.innerWidth / 2;
const windowHalfY = window.innerHeight / 2;

document.addEventListener('mousemove', (event) => {
  mouseX = (event.clientX - windowHalfX) * 0.5;
  mouseY = (event.clientY - windowHalfY) * 0.5;
});

// Scroll interaction
let scrollY = 0;
window.addEventListener('scroll', () => {
  scrollY = window.scrollY;
});

function animate() {
  requestAnimationFrame(animate);

  targetX = mouseX * 0.5;
  targetY = mouseY * 0.5;

  camera.position.x += (targetX - camera.position.x) * 0.05;
  camera.position.y += (-targetY - camera.position.y) * 0.05;
  
  // Parallax on scroll
  camera.position.y += scrollY * 0.1;
  camera.lookAt(scene.position);

  // Update particles and lines
  const positions = particleSystem.geometry.attributes.position.array;
  
  const linePositions = [];
  const connectionRadius = 150;

  for (let i = 0; i < particleCount; i++) {
    // Move particles
    positions[i * 3] += particleVelocities[i].x;
    positions[i * 3 + 1] += particleVelocities[i].y;
    positions[i * 3 + 2] += particleVelocities[i].z;

    // Boundary check
    if (Math.abs(positions[i * 3]) > r/2) particleVelocities[i].x *= -1;
    if (Math.abs(positions[i * 3 + 1]) > r/2) particleVelocities[i].y *= -1;
    if (Math.abs(positions[i * 3 + 2]) > r/2) particleVelocities[i].z *= -1;

    // Check connections
    for (let j = i + 1; j < particleCount; j++) {
      const dx = positions[i * 3] - positions[j * 3];
      const dy = positions[i * 3 + 1] - positions[j * 3 + 1];
      const dz = positions[i * 3 + 2] - positions[j * 3 + 2];
      const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);

      if (dist < connectionRadius) {
        linePositions.push(
          positions[i * 3], positions[i * 3 + 1], positions[i * 3 + 2],
          positions[j * 3], positions[j * 3 + 1], positions[j * 3 + 2]
        );
      }
    }
  }

  particleSystem.geometry.attributes.position.needsUpdate = true;
  
  // Update lines
  linesMesh.geometry.setAttribute('position', new THREE.Float32BufferAttribute(linePositions, 3));

  // Rotate entire system slowly
  particleSystem.rotation.y += 0.001;
  linesMesh.rotation.y += 0.001;
  
  // Pulsating color effect over time
  const time = Date.now() * 0.0005;
  pMaterial.color.setHSL((Math.sin(time * 0.5) * 0.1) + 0.75, 0.8, 0.5); // Cycle through purples/pinks

  renderer.render(scene, camera);
}

// Handle window resize
window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

animate();
