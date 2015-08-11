// Generated by CoffeeScript 1.9.0
var assets, baseDest, browserSync, changed, coffee, gulp, gulpif, gutil, imagemin, isDev, isProd, jsonminify, manifest, minifyCSS, prefix, reload, rename, sourcemaps, uglify, useref;

gulp = require("gulp");

uglify = require('gulp-uglify');

useref = require("gulp-useref");

manifest = require("gulp-manifest");

coffee = require('gulp-coffee');

imagemin = require('gulp-imagemin');

jsonminify = require('gulp-jsonminify');

changed = require('gulp-changed');

gulpif = require('gulp-if');

minifyCSS = require('gulp-minify-css');

sourcemaps = require('gulp-sourcemaps');

prefix = require('gulp-autoprefixer');

rename = require('gulp-rename');

browserSync = require('browser-sync');

gutil = require('gulp-util');

reload = browserSync.reload;

assets = useref.assets();

baseDest = "dist/";

isDev = true;

isProd = false;

if (gutil.env._[0] === "prod") {
  isDev = false;
  isProd = true;
}

gulp.task("default", ["build"]);

gulp.task("build", ["coffee", "manifest", "minifyCSS", "minifyJS"]);

gulp.task("stage", ["coffee", "manifest", "minifyCSS", "minifyJS"], function() {
  gulp.src(["composer.json", ".htaccess", "favicon.ico"]).pipe(gulp.dest(baseDest));
  return gulp.src(["heroku-gitignore"]).pipe(rename(".gitignore")).pipe(changed(baseDest)).pipe(gulp.dest(baseDest));
});

gulp.task("minifyCSS", ["html"], function() {
  return gulp.src([baseDest + "*.css"]).pipe(prefix({
    browsers: ['last 2 versions'],
    cascade: false
  })).pipe(gulpif(isProd, minifyCSS())).pipe(gulp.dest(baseDest));
});

gulp.task("minifyJS", ["html"], function() {
  return gulp.src([baseDest + "lib.js"]).pipe(gulpif(isProd, uglify())).pipe(gulp.dest(baseDest));
});

gulp.task("manifest", ["html", "images", "json", "templates"], function() {
  return gulp.src([baseDest + "**/*"]).pipe(manifest({
    timestamp: true,
    network: ["http://*", "https://*", "*"],
    preferOnline: true,
    filename: "app.appcache",
    exclude: ["app.appcache", "README.md", "gulpfire.js", "composer.json", "bower.json"],
    cache: ["http://fonts.googleapis.com/css?family=Source+Code+Pro&subset=latin,latin-ext", "http://fonts.gstatic.com/s/sourcecodepro/v6/mrl8jkM18OlOQN8JLgasDy2Q8seG17bfDXYR_jUsrzg.woff2", "http://fonts.gstatic.com/s/sourcecodepro/v6/mrl8jkM18OlOQN8JLgasD9V_2ngZ8dMf8fLgjYEouxg.woff2"]
  })).pipe(gulp.dest("./dist"));
});

gulp.task("coffee", function() {
  return gulp.src("./js/*.coffee").pipe(coffee({
    bare: true
  }).on('error', gutil.log)).pipe(gulp.dest('.js'));
});

gulp.task("html", function() {
  return gulp.src("index.html").pipe(assets).pipe(assets.restore()).pipe(useref()).pipe(gulp.dest("dist"));
});

gulp.task("images", function() {
  var dest;
  dest = "dist/img";
  return gulp.src("img/*.*").pipe(changed(dest)).pipe(imagemin({
    optimizationLevel: 3,
    progressive: true,
    interlaced: true
  })).pipe(gulp.dest(dest));
});

gulp.task("json", function() {
  return gulp.src("learn/*.*").pipe(jsonminify()).pipe(gulp.dest("dist/learn"));
});

gulp.task("templates", function() {
  return gulp.src("templates/*.*").pipe(gulp.dest("dist/templates"));
});