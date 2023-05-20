const { src, dest, watch, series, parallel } = require('gulp');
const exec = require('gulp-exec');

const browserSync = require('browser-sync').create();
const sourcemaps = require('gulp-sourcemaps');
const sharpResponsive = require("gulp-sharp-responsive");
const rename = require("gulp-rename");
const replace = require('gulp-replace');
const cssnano = require('cssnano');
const fs = require('fs')


const htmlFiles = 'src/html/**/*.html';
const elmFiles = 'src/*.elm';
const imageFiles = 'src/data/gallery/*.jpg';
const assets = 'assets/**';
// const galleryConfig = JSON.parse(fs.readFileSync('src/data/galleryImages.json')).data;

browserSync.init({
    server: {
        baseDir: "./build",
    }
});


function elmTask() {
    return src('.')
        .pipe(exec('elm make src/Main.elm --output build/main.js')) // Put everything in the build directory
        .pipe(browserSync.stream()); // Update the browser
}

// Gulp task to copy HTML files to output directory
function htmlTask(){
    return src(htmlFiles)
    .pipe(dest('build')) // Put everything in the build directory
    .pipe(browserSync.stream());
}

// Gulp task to copy HTML files to output directory
function assetsTask(){
    return src(assets)
    .pipe(dest('build/assets')) // Put everything in the build directory
    .pipe(browserSync.stream());
}


function watchTask() {
    // Watch for changes in any SCSS or JS files, and run the scssTask,
    // jsTask, and preventCachingTask functions whenever there is a change.
    watch(
        [elmFiles, htmlFiles, assets],
        series(
            parallel(assetsTask, htmlTask, elmTask)
        )
    );
}

// Export everything to run when you run 'gulp'
module.exports = {
    // imageOptimizerTask,
    default: series(
        parallel(elmTask, assetsTask, htmlTask),
        watchTask
    )
  };