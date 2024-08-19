const gulp       = require('gulp');
const { watch }  = require('gulp'); 
const rename     = require('gulp-rename');
const minify     = require('gulp-minify');      //minify js
const uglifycss  = require('gulp-uglifycss');   //minify para css
const prettyData = require('gulp-pretty-data'); //minify para sql
const exec       = require('gulp-exec');
//file system
const fs         = require('fs');

var js_file    = '../web/default.js';
var css_file   = '../web/default.css';
var dest_min   = '../web/' ; 

//var sql_file   = 'fcl.sql';

const watcher_js  = watch(js_file);
const watcher_css = watch(css_file);
//const watcher_sql = watch(sql_file);


gulp.task('default', (done) => { 

     watcher_js.on('change', function(path, stats) {
          //minify de js
          if(fs.existsSync(js_file)){
               try {
                    gulp.src(js_file).pipe(minify({
                         noSource: true
                    })).pipe(gulp.dest(dest_min));
               } catch(err){
                 console.log(err);
               }
          }
          var hora = new Date().toLocaleTimeString();          
          console.log(`${hora} - ${path} - ${dest_min}`);
     });

     watcher_css.on('change', function(path, stats) {
          //minify de css
          if(fs.existsSync(css_file)){
               gulp.src(css_file).pipe(uglifycss()).pipe(rename('default-min.css')).pipe(gulp.dest(dest_min));
          }  
          var hora = new Date().toLocaleTimeString();          
          console.log(`${hora} - ${path} - ${dest_min}`);
     });

     //watcher_sql.on('change', function(path, stats) {
     //     if(fs.existsSync(sql_file)){
     //          exec('wrap_fcl.bat');
     //     }  
     //     console.log(`File ${path} was changed`);
     //});

     done();	
});