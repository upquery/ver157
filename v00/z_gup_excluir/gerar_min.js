const gulp       = require('gulp');
const rename     = require('gulp-rename');
const minify     = require('gulp-minify');      //minify js
const uglifycss  = require('gulp-uglifycss');   //minify para css
const fs         = require('fs');


var js_file    = '../web/default.js';
var css_file   = '../web/default.css';
var dest_min   = '../web/' ; 

console.log(' ');
console.log('Gerado arquivos min .....')

// Gerar arquivo min dos js 
if(fs.existsSync(js_file)){
    try {
         gulp.src(js_file).pipe(minify({
              noSource: true
         })).pipe(gulp.dest(dest_min));
    } catch(err){
      console.log(err);
    }
    console.log('   Gerado arquivo default-min.js na pasta ' + dest_min );
} else { 
  console.log('Arquivo '+ js_file + ' nao encontrado.')
}


// Gerar arquivo min do CSS
if(fs.existsSync(css_file)){
    gulp.src(css_file).pipe(uglifycss()).pipe(rename('default-min.css')).pipe(gulp.dest(dest_min));
    console.log('   Gerado arquivo default-min.css na pasta ' + dest_min );
  } else { 
  console.log('Arquivo '+ css_file + ' nao encontrado.')
 }  
