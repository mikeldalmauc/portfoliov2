import * as THREE from '../../node_modules/three/build/three.module.js';
import {OrbitControls} from '../../node_modules/three/examples/jsm/controls/OrbitControls.js';
import * as dat from '../../node_modules/dat.gui/build/dat.gui.module.js';
import nebula from '../../assets/content/scene/nebula.jpg';
import stars from '../../assets/content/scene/stars.jpg';


const renderer = new THREE.WebGLRenderer({antialias: true});
renderer.shadowMap.enabled = true;

renderer.domElement.style.position = 'absolute';
renderer.domElement.style.zIndex = 0;
renderer.setSize(window.innerWidth, window.innerHeight);
document.getElementById('canvas').appendChild(renderer.domElement);

// Sets the color of the background
// renderer.setClearColor(0xFEFEFE);

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(
    45,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
);

const orbit = new OrbitControls(camera, renderer.domElement);
orbit.update();

// A guide to help you position your camera, 5 is length of axes
const axesHelper = new THREE.AxesHelper(4);
scene.add(axesHelper);

camera.position.set(-5, 20, 20);

// Create a cube
const boxGeometry = new THREE.BoxGeometry();
const boxMaterial = new THREE.MeshBasicMaterial({color: 0x00ff00});
const box = new THREE.Mesh(boxGeometry, boxMaterial);
scene.add(box);

// Create a plane
const planeGeometry = new THREE.PlaneGeometry(20, 20);
const planeMaterial = new THREE.MeshStandardMaterial({
  color: 0xAAAAAA
, side: THREE.DoubleSide
});
const plane = new THREE.Mesh(planeGeometry, planeMaterial); 
scene.add(plane);
plane.rotation.x = -0.5 * Math.PI;
plane.receiveShadow = true;

// Grid helper
const gridHelper = new THREE.GridHelper();
scene.add(gridHelper);

// Create a sphere
const sphereGeometry = new THREE.SphereGeometry(2, 50, 50);
const sphereMaterial = new THREE.MeshStandardMaterial({
  color: 0x0000ff
, wireframe: false
});
const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
scene.add(sphere);
sphere.position.set(4, 4, 4);
sphere.castShadow = true;

// Lights 

const ambienLigth = new THREE.AmbientLight(0x404040);
scene.add(ambienLigth);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
scene .add(directionalLight);
directionalLight.position.set(5, 10, 5);
directionalLight.castShadow = true;
directionalLight.shadow.camera.bottom = -12;

const dLightHelper = new THREE.DirectionalLightHelper(directionalLight, 3);
scene.add(dLightHelper);

const dLightShadowHelper = new THREE.CameraHelper(directionalLight.shadow.camera);
scene.add(dLightShadowHelper);

const spotLight = new THREE.SpotLight(0xffffff, 0.5);
scene.add(spotLight);
spotLight.position.set(30, 30, 0); 
spotLight.castShadow = true;
spotLight.angle = 0.2;

const sLightHelper = new THREE.SpotLightHelper(spotLight);
scene.add(sLightHelper);


// FOG 
// scene.fog = new THREE.Fog(0xffffff, 0, 200);
scene.fog = new THREE.FogExp2(0xffffff, 0.01);


// Background color
// renderer.setClearColor(0xffea00);

// Texture loading background
const textureLoader = new THREE.TextureLoader();
const cubeTextureLoader = new THREE.CubeTextureLoader();
scene.background = cubeTextureLoader.load([
    nebula
  , nebula
  , stars
  , stars
  , stars
  , stars
]);

// Create a box with texture
const box2Geometry = new THREE.BoxGeometry(4, 4, 4);
const box2Material = new THREE.MeshBasicMaterial({
    // map: textureLoader.load(nebula)
});
const box2MultiMaterial = [
  new THREE.MeshBasicMaterial({map: textureLoader.load(stars)}) 
, new THREE.MeshBasicMaterial({map: textureLoader.load(stars)}) 
, new THREE.MeshBasicMaterial({map: textureLoader.load(nebula)}) 
, new THREE.MeshBasicMaterial({map: textureLoader.load(stars)}) 
, new THREE.MeshBasicMaterial({map: textureLoader.load(nebula)}) 
, new THREE.MeshBasicMaterial({map: textureLoader.load(stars)}) 
]
const box2 = new THREE.Mesh(box2Geometry, box2MultiMaterial);
scene.add(box2);
box2.position.set(8, 4, 4);
box2.material.map = textureLoader.load(nebula);
// scene.background = textureLoader.load(nebula, texture => scene.background = texture  );

// Create a plane to modify its points
const plane2Geometry = new THREE.PlaneGeometry(10, 10, 10, 10);
const plane2Material = new THREE.MeshBasicMaterial({
  color: 0xAAAAAA
  , wireframe: true
});
const plane2 = new THREE.Mesh(plane2Geometry, plane2Material);
scene.add(plane2);
plane2.position.set(5, 5, 10);

// plane2.geometry.attributes.position.array[0] -= 10 * Math.random();
// plane2.geometry.attributes.position.array[1] -= 10 * Math.random();
// plane2.geometry.attributes.position.array[2] -= 10 * Math.random();
const lastPointZ = plane2.geometry.attributes.position.array.length - 1;
// plane2.geometry.attributes.position.array[lastPointZ] -= 10 * Math.random();


// Shader materials

const vShader = `
  void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`
const fShader = `
  void main() {
    gl_FragColor = vec4(0.5, 0.5, 0.0, 1.0);
  }
`

const sphere2Geometry = new THREE.SphereGeometry(2, 50, 50);
const sphere2Material = new THREE.ShaderMaterial({
  vertexShader: vShader,
  fragmentShader: fShader
});
const sphere2 = new THREE.Mesh(sphere2Geometry, sphere2Material);
scene.add(sphere2);
sphere2.position.set(-5, 10, 10);

// Gui control
const gui = new dat.GUI();
const options = { 
    sphereColor: '#0000ff'
  , wireframe: false
  , speed: 0.01
  , angle: 0.2
  , penumbra : 0
  , intensity : 1
};

gui.add(options, 'sphereColor').onChange(function(e){
  sphere.material.color.set(e);
});

gui.add(options, 'wireframe').onChange(function(e){
  sphere.material.wireframe = e;
});

gui.add(options, 'speed', 0, 0.1);

gui.add(options, 'angle', 0, 1);
gui.add(options, 'intensity', 0, 1);
gui.add(options, 'penumbra', 0, 1);


// Mouse position and object selection
const mousePosition =  new THREE.Vector2();
window.addEventListener('mousemove', function(e){
  // normalize mouse position
  mousePosition.x = (e.clientX / window.innerWidth) * 2 - 1;
  mousePosition.y = -(e.clientY / window.innerHeight) * 2 + 1;
});

const raycaster = new THREE.Raycaster();
const sphereId = sphere.id;
box2.name = "theBox";

// Animation  loop
let step = 0;
function animate(time){
  
  box.rotation.x = time / 1000;
  box.rotation.y = time / 1000;
  
  step += options.speed;
  sphere.position.y = 10 * Math.abs(Math.sin(step)); 

  spotLight.angle = options.angle; 
  spotLight.intensity = options.intensity;
  spotLight.penumbra = options.penumbra;  
  sLightHelper.update();

  // change properties of the sphere when the mouse is over it
  raycaster.setFromCamera(mousePosition, camera);
  const intersects = raycaster.intersectObjects(scene.children);
  for(let i = 0; i < intersects.length; i++){
    if(intersects[i].object.id === sphereId)
      intersects[i].object.material.color.set(0xff0000);
    
    if(intersects[i].object.name === "theBox"){
      intersects[i].object.rotation.x = time / 1000;
      intersects[i].object.rotation.y = time / 1000;
    }
      
  }

  // change the plane points
  // plane2.geometry.attributes.position.array[0] = 10 * Math.random();
  // plane2.geometry.attributes.position.array[1] = 10 * Math.random();
  // plane2.geometry.attributes.position.array[2] = 10 * Math.random();
  // plane2.geometry.attributes.position.array[lastPointZ] = 10 * Math.random();
  // plane2.geometry.attributes.position.needsUpdate = true;
  

  // Link the scene and the camera
  renderer.render(scene, camera);
}

renderer.setAnimationLoop(animate);


renderer.render(scene, camera);
orbit.update();
