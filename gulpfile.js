require('coffee-script/register');
require('./build/gulpfile.coffee');

// var gulp = require('gulp');
// var preen = require('preen');
// var manifest = require('gulp-manifest');
// var coffeelint = require('gulp-coffeelint');

// gulp.task('default', ['preen', "manifest"], function() {
//   // place code for your default task here
// });

// gulp.task('preen', function(cb) {
//   preen.preen({}, cb);
// });

// gulp.task('manifest', function(){
//   gulp.src(['css/*', 'js/*', '/learn/*', '/templates/*', 'bower_components/**/*.js', 'bower_components/**/*.css'])
//     .pipe(manifest({
//       hash: true,
//       // preferOnline: true,
//       network: ['http://*', 'https://*', '*'],
//       filename: 'app.appcache',
//       exclude: 'app.appcache'
//      }))
//     .pipe(gulp.dest('./dest'));
// });

// gulp.task('lint', function () {
//     gulp.src('./js/*.coffee')
//         .pipe(coffeelint())
//         .pipe(coffeelint.reporter());
// });
