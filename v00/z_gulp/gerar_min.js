const gulp       = require('gulp');
const rename     = require('gulp-rename');
const minify     = require('gulp-minify');      //minify js
const uglifycss  = require('gulp-uglifycss');   //minify para css
const fs         = require('fs');


var js_file    = '../web/default.js';
var css_file   = '../web/default.css';
var h2pdf_file = '../web/html2pdf.js';
var h2can_file = '../web/html2canvas.js';
var jspdf_file = '../web/jspdf.umd.js';
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

// Gerar min das bibliotecas de exportação da tela para pdf
if(fs.existsSync(h2pdf_file)){
    try {
        gulp.src(h2pdf_file).pipe(minify({
            noSource: true
        })).pipe(gulp.dest(dest_min));
    } catch (err) {
        console.log(err);
    }
    console.log('   Gerado arquivo html2pdf-min.js na pasta ' + dest_min );
} else {
    console.log('Arquivo '+h2pdf_file+' nao encontrado.')
}

if(fs.existsSync(h2can_file)){
    try {
        gulp.src(h2can_file).pipe(minify({
            noSource: true
        })).pipe(gulp.dest(dest_min));
    } catch (err) {
        console.log(err);
    }
    console.log('   Gerado arquivo html2canvas-min.js na pasta ' + dest_min );
} else {
    console.log('Arquivo '+h2can_file+' nao encontrado.')
}

if(fs.existsSync(jspdf_file)){
    try {
        gulp.src(jspdf_file).pipe(minify({
            noSource: true
        })).pipe(gulp.dest(dest_min));
    } catch (err) {
        console.log(err);
    }
    console.log('   Gerado arquivo jspdf.umd-min.js na pasta ' + dest_min );
} else {
    console.log('Arquivo '+jspdf_file+' nao encontrado.')
}