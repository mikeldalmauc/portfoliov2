const { src, dest, watch, series, parallel } = require('gulp');
const exec = require('gulp-exec');

const browserSync = require('browser-sync').create();
const sourcemaps = require('gulp-sourcemaps');
const sharpResponsive = require("gulp-sharp-responsive");
const rename = require("gulp-rename");
const fs = require('fs')
var argv = require('yargs').argv;

const htmlFiles = 'src/html/**/*.html';
const elmFiles = 'src/*.elm';
const imageFiles = 'assets/content/gallery/*.jpg';
const tabImageFiles = 'assets/content/tab1/*.jpg';

const assets = 'assets/meta/**';
const playground = 'assets/content/playground/**';

const galleryConfig = 'assets/content/galleryImages.json';
const galleryConfigData = JSON.parse(fs.readFileSync(galleryConfig)).data;


browserSync.init({
    server: {
        baseDir: "./build",
    }
});

function imageOptimizerTask(){

    const BREAKPOINTS = galleryConfigData.breakpoints; 

    const bps = BREAKPOINTS.map(bp => [Math.round(bp.size), "-"+bp.name]);
    
    // creates an array of [[1, "-xs"], [2, "-sm"], ... ] (obviously the values are 576/div etc)

    let formatOptions = {quality: galleryConfigData.quality};
    
    return src(imageFiles)
        .pipe(rename(function (path) {
            path.dirname += "/" + path.basename;
        }))
        .pipe(sharpResponsive({
            formats: galleryConfigData.formats.map(format => {
                if("jpg" === format)
                    formatOptions = {quality: galleryConfigData.quality, progressive:true};
                else
                    formatOptions = {quality: galleryConfigData.quality};

                return bps.map(([width, suffix]) => ({ width, format: format, rename: { suffix }, formatOptions}));
            }
            ).flatMap(f => f)
        }))
        .pipe(dest('build/assets/gallery'));
}


function tabImageOptimizerTask(){

    if(argv.tab === undefined){
        return;

    }else{
        const tab = argv.tab        
        
        const BREAKPOINTS = galleryConfigData.breakpoints; 
        
        const bps = BREAKPOINTS.map(bp => [Math.round(bp.size), "-"+bp.name]);
        
        // creates an array of [[1, "-xs"], [2, "-sm"], ... ] (obviously the values are 576/div etc)
        
        let formatOptions = {quality: galleryConfigData.quality};
    
        return src('assets/content/tab'+tab+'/*.jpg')
        .pipe(rename(function (path) {
            path.dirname += "/" + path.basename;
        }))
        .pipe(sharpResponsive({
            formats: galleryConfigData.formats.map(format => {
                if("jpg" === format)
                formatOptions = {quality: galleryConfigData.quality, progressive:true};
                else
                    formatOptions = {quality: galleryConfigData.quality};
                    
                    return bps.map(([width, suffix]) => ({ width, format: format, rename: { suffix }, formatOptions}));
                }
            ).flatMap(f => f)
        }))
        .pipe(dest('build/assets/tab'+tab));
    }
}

    
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

// Gulp task to copy all build files of games to build directory
function playgroundTasks(){
    return src(playground)
    .pipe(dest('build/playground')) // Put everything in the build directory
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
    imageOptimizerTask,
    tabImageOptimizerTask,
    playgroundTasks,
    default: series(
        parallel(elmTask, assetsTask, htmlTask),
        watchTask
    )
  };