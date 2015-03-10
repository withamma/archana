# https://blog.engineyard.com/2014/frontend-dependencies-management-part-2
# http://www.valdelama.com/useful-gulp-recipes

gulp = require("gulp")
uglify = require('gulp-uglify')
useref = require("gulp-useref")
manifest = require("gulp-manifest")
coffeelint = require("gulp-coffeelint")
coffee = require('gulp-coffee')
imagemin = require('gulp-imagemin')
jsonminify = require('gulp-jsonminify')
changed = require('gulp-changed')
gulpif = require('gulp-if')
minifyCSS = require('gulp-minify-css')
sourcemaps = require('gulp-sourcemaps')
prefix = require('gulp-autoprefixer')
rename = require 'gulp-rename'
browserSync = require('browser-sync')
gutil = require('gulp-util')
spawn = require('child_process').spawn

reload = browserSync.reload
assets = useref.assets()
baseDest = "dist/"


# Set some defaults
isDev = true
isProd = false

# If "production" is passed from the command line then update the defaults
if gutil.env._[0] is "prod"
  isDev = false
  isProd = true

gulp.task "default", ["build"]

gulp.task "build", ["manifest", "minifyCSS", "minifyJS"]

gulp.task "stage", ["manifest", "minifyCSS", "minifyJS"], ->
  gulp.src(["composer.json", ".htaccess"])
    .pipe(gulp.dest(baseDest))
  gulp.src(["heroku-gitignore"])
    .pipe(rename(".gitignore"))
    .pipe(changed(baseDest))
    .pipe(gulp.dest(baseDest))
  # child = spawn("bash", ["build/heroku.sh"], {cwd: process.cwd()})

gulp.task "minifyCSS", ["html"], ->
  gulp.src(["#{baseDest}*.css"])
    .pipe(prefix({
          browsers: ['last 2 versions'],
          cascade: false
    }))
    .pipe(gulpif(isProd, minifyCSS()))
    .pipe(gulp.dest(baseDest))

gulp.task "minifyJS", ["html"], ->
  gulp.src(["#{baseDest}lib.js"])
    .pipe(gulpif(isProd, uglify()))
    .pipe(gulp.dest(baseDest))

gulp.task "manifest", ["html", "images", "json", "templates"], ->
  gulp.src([
    "#{baseDest}**/*"
  ]).pipe(manifest(
    timestamp: true
    network: [
      "http://*"
      "https://*"
      "*"
    ]
    preferOnline: true
    filename: "app.appcache"
    exclude: [
        "app.appcache"
        "README.md"
        "gulpfire.js"
        "composer.json"
        "bower.json"
    ]
  )).pipe gulp.dest("./dist")

gulp.task "coffee", ->
  gulp.src("./js/*.coffee")
    .pipe(coffee())
    .pipe(coffeelint())
    .pipe coffeelint.reporter()

gulp.task "html", ->
  gulp.src("index.html")
    .pipe(assets)
    .pipe(assets.restore())
    .pipe(useref())
    .pipe(gulp.dest("dist"))

gulp.task "images", ->
  dest = "dist/img"
  gulp.src("img/*.*")
    .pipe(changed(dest))
    .pipe(imagemin(optimizationLevel: 3, progressive: true, interlaced: true))
    .pipe(gulp.dest(dest))

gulp.task "json", ->
  gulp.src("learn/*.*")
    .pipe(jsonminify())
    .pipe(gulp.dest("dist/learn"))

gulp.task "templates", ->
  gulp.src("templates/*.*")
    .pipe(gulp.dest("dist/templates"))
