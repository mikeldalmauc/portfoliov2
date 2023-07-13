import * as THREE from '../../node_modules/three/build/three.module.js';
import {OrbitControls} from '../../node_modules/three/examples/jsm/controls/OrbitControls.js';
import * as dat from '../../node_modules/dat.gui/build/dat.gui.module.js';
import { Perlin, FBM } from '../../node_modules/three-noise/build/three-noise.module.js';
import * as BufferGeometryUtils from '../../node_modules/three/examples/jsm/utils/BufferGeometryUtils.js';

const renderer = new THREE.WebGLRenderer({antialias: true});
renderer.shadowMap.enabled = true;

renderer.domElement.style.position = 'absolute';
renderer.domElement.style.zIndex = 0;
renderer.setSize(window.innerWidth, window.innerHeight);
document.getElementById('canvas').appendChild(renderer.domElement);

// Sets the color of the background
renderer.setClearColor(0x171717);

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(
    45,
    window.innerWidth / window.innerHeight,
    0.1,
    500
);

// const orbit = new OrbitControls(camera, renderer.domElement);
// orbit.update();

// // // Add an event listener to track changes in the camera's position
// orbit.addEventListener('change', function() {
//   // Update the previous position with the camera's current position
//   console.log('Camera position:', camera.position);

// });

// A guide to help you position your camera, 5 is length of axes
// const axesHelper = new THREE.AxesHelper(4);
// scene.add(axesHelper);

// camera.position.set(-13.54, 3, -1.7);
// camera.position.set(-13.21, 1.48, -1.18);
// camera.position.set(-13.27, 1.201, -0.98928);
// camera.position.set(-18.123, 0.937, -1.236);
camera.position.set(-13.927, 0.947, -1.79);
camera.rotation.y -= Math.PI/2
console.log(camera.position);

const camerav2 = new THREE.Vector2(camera.position.x, camera.position.z);

// Create a plane
const planeGeometry = new THREE.PlaneGeometry(20, 40, 100, 200);
const planeMaterial = new THREE.MeshStandardMaterial({
  color: 0xFFFFFF
, side: THREE.DoubleSide
, wireframe: false
});

// planeMaterial.shading = THREE.SmoothShading;

const plane = new THREE.Mesh(planeGeometry, planeMaterial); 

scene.add(plane);


plane.receiveShadow = true;



// Lights 

const ambienLigth = new THREE.AmbientLight(0x171717);
scene.add(ambienLigth);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
scene.add(directionalLight);
directionalLight.position.set(5, 10, 5);
// directionalLight.castShadow = true;
directionalLight.shadow.camera.bottom = -12;

// FOG 
// scene.fog = new THREE.Fog(0xffffff, 0, 200);
scene.fog = new THREE.FogExp2(0x111111, 0.08);


// Gui control
// const gui = new dat.GUI();
// const options = { 
//     rotationX: plane.rotation.x
//   , rotationY: plane.rotation.y
//   , rotationZ: plane.rotation.z
// };

// gui.add(options, 'rotationX', -Math.PI, Math.PI).onChange(function(e){
//   plane.rotation.x = e ;
// });

// gui.add(options, 'rotationY', -Math.PI, Math.PI).onChange(function(e){
//   plane.rotation.y = e;
// });

// gui.add(options, 'rotationZ', -Math.PI, Math.PI).onChange(function(e){
//   plane.rotation.z = e;
// });

// Animation  loop
// let step = 0;
// ;

// Instantiate the class with a seed
// var freq = 1000;
// var lastt = -1;
// if(lastt == -1 ){
//   lastt = time;
// } else if (time - lastt > freq){
//   lastt = time
  
// }

// initial plane
var perlin = new Perlin(Math.random());
var perlin2 = new Perlin(Math.random());

function animate(time){
  // var perlin2 = new Perlin(time);

  for(var i=0; i<plane.geometry.attributes.position.array.length; i=i+3){
    var x = plane.geometry.attributes.position.array[i];
    var z = plane.geometry.attributes.position.array[i+1];
    var y = plane.geometry.attributes.position.array[i+2];
    
    // Perlin noise 
    const pos = new THREE.Vector3(x, y, z);
    pos.y *= 0.3;
    pos.y += time * 0.00012;
    
    // // Camera distance
    const point = new THREE.Vector2(x, z);
    
    const normCam = camerav2.distanceTo(point);
    
    
    plane.geometry.attributes.position.array[i+2] = perlin.get3(pos) + normCam*normCam*0.004;
  }

  for(var i=0; i<plane.geometry.attributes.position.array.length; i=i+3){
    var x = plane.geometry.attributes.position.array[i];
    var z = plane.geometry.attributes.position.array[i+1];
    var y = plane.geometry.attributes.position.array[i+2];
    
    // Perlin noise 
    const pos = new THREE.Vector3(x, y, z);
    pos.y *= 0.3;
    pos.y += time * 0.00012;
    
    // // Camera distance
    const point = new THREE.Vector2(x, 1.3*z);
    
    const normCam = camerav2.distanceTo(point);
    
    
    plane.geometry.attributes.position.array[i+2] = perlin.get3(pos) + normCam*normCam*0.004;
  }


  plane.rotation.x = -0.5 * Math.PI;
  // plane.geometry = BufferGeometryUtils.mergeVertices(plane.geometry, 0.1);
  // plane.geometry.computeVertexNormals(true);
  plane.geometry.attributes.position.needsUpdate = true;

  // Link the scene and the camera
  renderer.render(scene, camera);
}

renderer.setAnimationLoop(animate);

renderer.render(scene, camera);
// orbit.update();
