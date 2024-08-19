const gulp       = require('gulp');
const rename     = require('gulp-rename');
const minify     = require('gulp-minify');      //minify js
const uglifycss  = require('gulp-uglifycss');   //minify para css
const fs         = require('fs');


var js_file    = '../../../../OUTROS/plugins/pell/dist/pell.js';
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
    console.log('   Gerado arquivo pell-min.js na pasta ' + dest_min + ', deve alterado para pell.min.js e movido para a pasta do PELL' );
} else { 
  console.log('Arquivo '+ js_file + ' nao encontrado.')
}


