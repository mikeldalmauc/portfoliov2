import gulp from 'gulp';
import gulpExec from 'gulp-exec'; 
import { deleteAsync } from 'del';
import sharpResponsive from 'gulp-sharp-responsive';
import rename from 'gulp-rename';
import fs from 'fs';

const { src, dest, watch, series, parallel } = gulp;

// Cargar configuración
const galleryConfigPath = 'assets/content/galleryImages.json';
const galleryConfigData = JSON.parse(fs.readFileSync(galleryConfigPath, 'utf8')).data;

// --- AQUÍ ESTÁ EL CAMBIO CLAVE ---
const paths = {
  html: 'index.html',
  robots: 'robots.txt',
  sitemap: 'sitemap.xml',
  output: 'build',
  elm: 'src/*.elm',
  js: 'src/js/**/*.js',
  assets: 'assets/meta/**',
  playground: 'assets/content/playground/**',
  
  // Usamos llaves {} para listar EXACTAMENTE las carpetas que quieres.
  // Esto procesará: gallery, tab1, tab2, tab3 y tab5. Ignorará tab4 u otras.
  targetImages: 'assets/content/{gallery,tab1,tab2,tab3,tab5}/*.{jpg,jpeg,png}',
  kuskas: 'assets/kuskas/**'
};

function clean() {
  return deleteAsync([paths.output]);
}

// Tarea unificada e inteligente
function processImagesTask() {
  const BREAKPOINTS = galleryConfigData.breakpoints;
  const bps = BREAKPOINTS.map(bp => [Math.round(bp.size), "-" + bp.name]);
  let formatOptions = { quality: galleryConfigData.quality };

  // 'base' es importante: mantiene la carpeta de origen (ej: si viene de tab1, lo guarda en tab1)
  return src(paths.targetImages, { base: 'assets/content' }) 
    
    // Crea subcarpeta por imagen: tab1/foto1.jpg -> tab1/foto1/foto1.jpg
    .pipe(rename(function (path) {
      path.dirname += "/" + path.basename;
    }))

    .pipe(sharpResponsive({
      formats: galleryConfigData.formats.map(format => {
        if ("jpg" === format || "jpeg" === format)
          formatOptions = { quality: galleryConfigData.quality, progressive: true };
        else
          formatOptions = { quality: galleryConfigData.quality };

        return bps.map(([width, suffix]) => ({ 
            width, 
            format: format, 
            rename: { suffix }, 
            formatOptions
        }));
      }).flatMap(f => f)
    }))

    .pipe(dest(`${paths.output}/assets`));
}

// ... (El resto de tareas: elmTask, jsTask, htmlTask... se mantienen igual) ...
function elmTask() {
    return src('.')
      .pipe(gulpExec('elm make src/Main.elm --optimize --output build/main.js'))
      .pipe(src('build/main.js')) 
      .pipe(gulpExec('uglifyjs build/main.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output build/main.min.js'));
}

function jsTask() { return src('.').pipe(gulpExec('npx webpack --config webpack.config.js')); }
function htmlTask() { return src(paths.html).pipe(dest(paths.output)); }
function robotsTask() { return src(paths.robots).pipe(dest(paths.output)); }
function sitemapTask() { return src(paths.sitemap).pipe(dest(paths.output)); }
function assetsTask() { return src(paths.assets).pipe(dest(`${paths.output}/assets`)); }
function playgroundTasks() { return src(paths.playground).pipe(dest(`${paths.output}/playground`)); }
function kuskasTask() { return src(paths.kuskas).pipe(dest(`${paths.output}/kuskas`)); }

function watchTask() {
  watch(
    // Añadimos targetImages al watch para que detecte cambios en esas carpetas
    [paths.elm, paths.html, paths.assets, paths.js, paths.targetImages],
    series(
      parallel(assetsTask, htmlTask, jsTask, elmTask, processImagesTask)
    )
  );
}

const build = series(
  parallel(assetsTask, htmlTask, jsTask, elmTask, robotsTask, sitemapTask)
);

export {
  kuskasTask as kuskas,
  processImagesTask as images,
  build,
  build as default,
  watchTask as watch
};