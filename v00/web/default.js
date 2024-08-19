var arrGerarCustom = [], uploadFile = '', draft = '',
chartAnimation = true, chartRenderer  = 'canvas', sticky = 'N',
ace_editor, timer_rel = '', mousedown = false,
v_shift = false, vision = 'in', touchdrag = 1,
touchdragY = 0, respostaAjax = '', tela = 'DEFAULT', telaAnterior = 'DEFAULT',
textTalk = '', dscript = '', error = 'false',
time = '', msgtime = '', cursorx = '',
cursory = '', colunas = '', timeout = 0,
tr = '', notify = new Object(),
lasturl = '', alpha = '', dashlocation = '',
dashorder = '', projecoes = '', selectedb = '',
refresh_timer = '', refresh_param = ['','','','N']; // procedure, parametros, package, Ativo (S/N) 

var telasup = '', telasup_ant = [], refreshSup_ativo = '', 
    telacustom = ''; 
// teste
const PACKAGES   = ['UPLOAD', 'FCL', 'BRO', 'FUN', 'UPQUERY', 'IMP', 'GBL', 'OBJ', 'UP_REL', 'AUX', 'COM', 'CORE'],
      FILES      = ['JS', 'CSS'];
/* reabrir */  
/*if(typeof document.getElementById('usuario') != "undefined"){
  const USUARIO    = document.getElementById('usuario').value,
  ADMIN      = document.getElementById('admin').value,
  LAYER      = document.getElementById('layer'),
  MAIN       = document.getElementById('main'), 
  PRINCP = document.getElementById('princp');
}*/

/*var tr_off,
TR_AD, tr_tc, tr_cr, TR_AL, TR_EX,
TR_ER, tr_dp, tr_id, TR_ES, tr_ps,
tr_bl, tr_cl, tr_co, tr_ci, tr_vi,
tr_cm, tr_ce, tr_fc_nf, tr_off,
tr_pe, TR_ES_gr, TR_ES_vw, tr_ag_le,
tr_co_le, tr_co_sl, tr_ds_in, TR_DS_LE,
TR_NM_LE, tr_xc, tr_us_fb, tr_cd_le,
tr_qn, tr_se, tr_ob_dp, tr_ob_nm, 
tr_ob_cr, tr_ob_no, tr_ob_ex, tr_us_ex, tr_db;*/
/*function converte(frase){
  if(document.characterSet.indexOf('UTF-8') == -1){
    return decodeURIComponent(escape(frase));
  } else {
    return frase;
  }
}
const TR_OFF   = converte('Sem conexão!'),
TR_AD    = converte('Adicionado com sucesso!'),
TR_TC    = converte('Favor preencher todos os campos corretamente!'),
TR_CR    = converte('Criado com sucesso!'),
TR_AL    = converte('Alterado com sucesso!'),
TR_EX    = converte('Excluido com sucesso!'),
TR_ER    = converte('Erro ao adicionar!'),
TR_DP    = converte('Já cadastrado!'),
TR_ID    = converte('Id já utilizado!'),
TR_ES    = converte('Escolha um valor!'),
TR_PS    = converte('As senhas digitadas são diferentes!'),
TR_BL    = converte('Texto não pode estar e branco!'),
//TR_CL    = converte('FECHAR'),
//TR_CO    = converte('colunas'),
TR_CI    = converte('Valor inválido, apenas letras, números, underscore e espaço são permitidos!'),
TR_VI    = converte('Valor inválido, apenas letras, números e underscore são permitidos!'),
TR_CM    = converte('Tem certeza que gostaria de executar?'),
TR_CE    = converte('Tem certeza que gostaria de excluir?'),
TR_FC_NF = converte('Função não encontrada!'),
TR_PE    = converte('Sem permissão!'),
TR_ES_GR = converte('Escolha o grupo!'),
TR_ES_VW = converte('Escolha uma view!'),
TR_AG_LE = converte('Agrupadores precisam ter pelo menos um item!'),
TR_CO_LE = converte('Coluna precisa ter pelo menos um item!'),
TR_CO_SL = converte('Selecione uma coluna!'),
TR_DS_IN = converte('Descrição inválida!'),

TR_DS_LE = converte('Descrição deve ter mais de 3 caracteres!'),
TR_NM_LE = converte('Nome deve ter mais de 3 caracteres!'),
TR_XC    = converte('Impossível completar a solicitação!'),
TR_US_FB = converte('Usuário não tem permissão para essa ação!'),
TR_CD_LE = converte('Código deve ter mais de 3 caracteres!'),
TR_QN    = converte('Campo da query não pode estar vazio!'),
TR_SE    = converte('Sessão encerrada!'),
TR_OB_DP = converte('Esse objeto já existe nesta tela!'),
TR_OB_NM = converte('nome do objeto'),
TR_OB_CR = converte('Carregando objeto!'),
TR_OB_NO = converte('Nenhum objeto no menu!'),
TR_OB_EX = converte('Remover o objeto de todo o sistema, tem certeza que gostaria de executar?'),
TR_US_EX = converte('Remover o usuario da lista e seu acesso, tem certeza que gostaria de executar?'),
TR_DB    = converte('[query]: mostra ou esconde a query de cada consulta \n[export]: exporta dados das tabelas do tables_to_export, (pipe) seguido da letra do tipo(U usuario, O objeto) para especificar a exportação  \n[rearrange]: realoca todos os objetos pra posição 100/100 \n[clearlog.X]: Limpa log_eventos de dados de X(JS para javascript, EL para error line e PAR para parametro de usu&aacute;rio) \n[screen]: mostra as resoluções de tela \n[rule]: mostra a posição do cursor com reguas \n[grid(px)]: tela dividida em pixels \n[fun.lang]: lista as traduções \n[sandbox]: Libera uso da screen sandbox para testes \n[exec=]: executa comandos \n[dashboard]: Esconde/mostra as linhas do dashboard para o dwu \n[padrao]: Abre a tela de padroes do sistema \n[upload]: Abre a tela de upload \n[admin]: Tela com as permissões de usuários');
*/
var pell;
var xmlhttp;
xmlhttp = new XMLHttpRequest();
var completo = new Array();

var down, up, cliq;

if(document.getElementById('princp')){
  if(document.getElementById('princp').className == 'mobile'){
    down = 'touchstart';
    up   = 'touchend';
    cliq = 'touchend';
  } else {
    down = 'mousedown';
    up   = 'mouseup';
    cliq = 'click';
  }
}

document.addEventListener(cliq, clickStart);

function eventos(obj){

    if(obj.classList.contains('relatorio')){
      clearInterval(timer_rel);
      //var ident = obj.id.replace('trl', '');
      var ident = obj.id.split('trl')[0];

      if(document.getElementById(ident+'_button').innerHTML.indexOf('EXECUTANDO') != -1){

        timer_rel = setInterval(function(){ 
          call('lista_rel', 'prm_objeto='+ident+'&prm_screen='+tela+'&prm_cod=&prm_lista=check', 'up_rel').then(function(resposta2){ 
            document.getElementById(ident+'_button').innerHTML = resposta2;
            if(resposta2.indexOf('EXEC') == -1){ 
              clearInterval(timer_rel);
              setTimeout(function(){ 
                document.getElementById(ident+'_button').classList.remove('loading');
                alerta('feed-fixo', resposta2); 
                if (resposta2.indexOf('EXCEDEU')== -1){                
                  call('lista_rel', 'prm_objeto='+ident+'&prm_screen='+tela+'&prm_cod='+ident+'&prm_lista=file', 'up_rel').then(function(resposta3){ 
                    document.getElementById(ident+'_lista').innerHTML = resposta3; 
                  });
                }
              }, 1000); 
            }  
          });
        }, 1000);  
      }
    }

  if(obj.querySelector('.wd_move')){
    var titulo = obj.querySelector('.wd_move');
    if(obj.id.indexOf('trl') != -1 || obj.id.indexOf('temp') != -1 || obj.getAttribute('data-drill-relatorio') == 'Y'){
      titulo.addEventListener('mousedown', function(){ obj.style.setProperty('opacity', '0.7'); });
      titulo.addEventListener('mouseup', function(){ obj.style.setProperty('opacity', '1'); });
      titulo.addEventListener('touchstart', function(){ obj.style.setProperty('opacity', '0.7'); });
      titulo.addEventListener('touchend', function(){ obj.style.setProperty('opacity', '1'); });
    } else {
      titulo.addEventListener('mousedown', function(){ invisible_touch(this.parentNode.id, 'start'); });
      titulo.addEventListener('mouseup', function(){ invisible_touch(this.parentNode.id, 'stop'); });
      titulo.addEventListener('touchstart', function(){ invisible_touch(this.parentNode.id, 'start'); });
      titulo.addEventListener('touchend', function(){ invisible_touch(this.parentNode.id, 'stop'); });
    }
    
    titulo.addEventListener('dblclick', function(){
      curtain('');
      scale(this.id.replace('_ds', ''));
    });
  }

  /******************** Desabilitado - o tratamento foi corrigido no Backend na obj.consulta 
  if( (obj.classList.contains('front')) && (get(obj.id+'c') != false) ) {
      var visiveis = get(obj.id+'c').querySelector('tbody').children[0].querySelectorAll('.fix:not(.print)').length-2;
      if (get(obj.id+'c').querySelector('.geral')) { 
        var invs = get(obj.id+'c').querySelector('.geral').querySelectorAll('td.inv');
        var invsL = invs.length;
        for(let i=visiveis; i<invsL; i++){
          if(invs[i]){
            invs[i].remove();
          }
        }
      }  
  }
  *****************/ 


}

function appendar(par, dashboard, objeto){

  loading('x');
  var objid = '';

  call('show_objeto', par, 'obj').then(function(resposta){
    var alvo = MAIN; 
    if(dashlocation.length != 0 && par.indexOf('prm_drill=Y') == -1){ 
      alvo = document.getElementById(dashlocation); 
      dashlocation = ''; 
    }

    var etemp = document.createElement('div');
    etemp.innerHTML = resposta;

    if (resposta.toLowerCase().startsWith('<script>')) {   // se o primeiro filho é um script, então pega o próximo 
      objid = etemp.children[1].id; 
      var obj   = etemp.children[1];       
    } else {
      objid = etemp.children[0].id;
      var obj   = etemp.children[0];             
    }  
    var selecionado = MAIN;
    if (par.toLowerCase().indexOf('prm_drill=c') != -1) {   // se foi chamado pela tela de customização de consultas 
      selecionado = document.getElementById('ARTICLE_CUSTOMIZACAO');
      selecionado.innerHTML = '';
    } else {  
      if(dashboard){
        selecionado = document.getElementById(dashboard);
      } else {
        if(objeto.length > 0){
          selecionado = document.getElementById(objeto);
        } else {
          if(document.querySelector('.movingarticle') && par.indexOf('prm_drill=Y') == -1){
            selecionado = document.querySelector('.movingarticle');
          }
        }
      }
    }  

    selecionado.appendChild(obj);  //etemp.children[0] 
    
  }).then(function(){

    // Retira o loading da tela
    if(LAYER){
      if(LAYER.classList.contains('ativo')){
        loading();  
      }
    }

    alerta('feed-fixo', TR_OC);
    
    dashorder = '';

    let elemento = get(objid);

    // Ajusta em tela tabela HTML 
    if(elemento.classList.contains('front') || elemento.classList.contains('file')){
      ajustar(objid); 
    }
    
    // Ajusta em tela gráficos 
    if(elemento.classList.contains('grafico') || elemento.classList.contains('medidor') || elemento.classList.contains('dados')){
      renderChart(objid);
    }
    
    // Ajusta em tela mapa de geo localização 
    if(elemento.classList.contains('mapageoloc') ){
      mapaGeoLoc(objid);    
    }   
    
  }).then(function(){
    let elemento = get(objid);
    if(elemento.classList.contains('front') || elemento.classList.contains('full')){
      topDistance(objid);
    }   
    eventos(elemento);
  }); 
}


function ajustar(obj){
  if(typeof obj != "undefined"){
    if(document.getElementById(obj+'c')){

      document.getElementById(obj+'c').classList.add('sticky');

      if(document.getElementById(obj+'_ds')){
        var titulo = document.getElementById(obj+'_ds');
        var titvalor = titulo.innerHTML;
        titulo.innerHTML = '_';
        titulo.innerHTML = titvalor;

        document.getElementById(obj+'c').addEventListener('click', click_evento);
        document.getElementById(obj+'c').addEventListener('dblclick', dbl_click_evento);
        document.getElementById(obj+'c').addEventListener('mouseenter', function(){
          imgurlOver(obj+'c');  
        });

        var prints = document.getElementById(obj+'c').querySelectorAll('.print');
        for(let p = 0;p<prints.length;p++){ 
          prints[p].parentNode.setAttribute('style', prints[p].innerHTML); 
          if (prints[p].tagName.toUpperCase() == 'TD') { 
            prints[p].parentNode.classList.add('destaqueLinha'); 
          }  
        }
      }
      delete window.obj;
    }
  }
}

function imgurlOver(obj){
  var imgs = document.getElementById(obj).querySelectorAll('[data-url]:not([data-imglinked]');
  for(let i=0;i<imgs.length;i++){
    imgs[i].addEventListener('mouseenter', over_evento);
    imgs[i].addEventListener('mouseleave', out_evento);
    imgs[i].setAttribute('data-imglinked', 'true');
  }
}


function ajustaIframe(x) {
  if(!document.getElementById(x+'header')){
    var start;
    startTimer = setInterval(function() {
      if(document.getElementById(x+'c')!= null) {
        var z = document.getElementById(x+'c').cloneNode(true);
        z.id='';
        var cabecalho = document.getElementById(x+'c').getElementsByTagName('thead');
        if(cabecalho[0]){
          for(let i = 0; i<cabecalho.length;i++) {
            cabecalho[i].style.visibility = 'collapse';
          }
          document.getElementById(x+'header').appendChild(z);
        }
        if(document.getElementById(x+'ds')){
          var titulo = document.getElementById(x+'_ds');
          var titvalor = titulo.innerHTML;
          titulo.innerHTML = '_';
          titulo.innerHTML = titvalor;
        }
        clearInterval(startTimer);
        document.getElementById(x+'c').addEventListener('click', click_evento);
        document.getElementById(x+'c').addEventListener('dblclick', dbl_click_evento);
        smartScroll(x);
      }
    }, 10);
  }
}


function smartScroll(x){
    if(document.getElementById(x+'dv2')){
    var tipos = new Array();
    tipos[0] = document.getElementById(x+'dv2');
    tipos[1] = document.getElementById(x+'fixed');
    tipos[2] = document.getElementById(x+'c');
    tipos[3] = document.getElementById(x+'header');
    tipos[4] = document.getElementById(x);

    var maxwidth = tipos[0].getAttribute('data-maxwidth');

    var ccount = tipos[1].children.length;
    var maxheight = tipos[0].getAttribute('data-maxheight');
    var calc = tipos[0].clientHeight+tipos[3].clientHeight;
    var calc19 = (calc-19)+'px';
    var calc3 = (calc-3)+'px';

    var space = 4;

    if(ccount > 0){
      var uls = tipos[1].querySelectorAll('ul');
      var ullength = uls.length;
      tipos[0].addEventListener('scroll', function(){
        for(let i=0;i<ullength;i++){
          uls[i].style.marginTop = '-'+tipos[0].scrollTop+'px';
        }
      });
    }

    tipos[1].addEventListener('scroll', function(){
      tipos[0].style.setProperty('margin-top', '-'+this.scrollTop+'px');
    });

    if(tipos[2].clientWidth > maxwidth || tipos[2].clientWidth > tipos[0].clientWidth){
      tipos[0].addEventListener('scroll', function(){
        tipos[3].scrollLeft = tipos[0].scrollLeft;

        if(this.scrollLeft > '210' && tipos[0].parentNode.className.indexOf('scaled') == -1){
          if(tipos[1].getAttribute('data-width') > tipos[3].clientWidth){
            tipos[1].style.setProperty('width', tipos[3].clientWidth+'px');
          } else {
            tipos[1].style.setProperty('width', (parseInt(tipos[1].getAttribute('data-width'))+1)+'px');
          }
        } else {
          tipos[1].style.setProperty('width', '0');
        }
      });
      tipos[2].addEventListener('mouseenter', function(){
      tipos[0].classList.add('flow');
      if(maxheight < tipos[2].clientHeight && tipos[4].className.indexOf('expand') == -1){
        tipos[1].style.setProperty('max-height', calc19);
      }
    });
    tipos[4].addEventListener('mouseleave', function(){
      tipos[0].classList.remove('flow');
      if(maxheight < tipos[2].clientHeight && this.className.indexOf('expand') == -1){
        tipos[1].style.setProperty('max-height', calc3);
      }
    });
  }

    if(maxheight < tipos[2].clientHeight){

      tipos[2].addEventListener('mouseenter', function(){

        tipos[0].style.setProperty('overflow-y', 'auto');
        if(PRINCP.className.indexOf('mac') == -1 && PRINCP.className.indexOf('mobile') == -1){
          if(tipos[2].clientWidth ){
            if(maxheight < tipos[2].clientHeight){
              if(tipos[2].clientWidth > maxwidth){
                tipos[0].classList.add('padding');
              }
            }
          }
          if(document.getElementById(x+'dv2').getAttribute('data-maxheight') < tipos[2].clientHeight){
            if(tipos[2].clientWidth < maxwidth){
              tipos[3].classList.add('margin');
            }
          }
        } else {
          //chrome exception
          if(navigator.userAgent.indexOf('Chrome') == -1){
            if(tipos[2].clientWidth < parseInt(tipos[0].style.maxWidth)){
              tipos[0].classList.remove('padding');
            }
          } else {
            if(tipos[2].clientWidth > maxwidth){
              tipos[0].classList.add('padding');
            }
            if(tipos[2].clientWidth < maxwidth){
              tipos[3].classList.add('margin');
            }
          }
        }

      });

      tipos[4].addEventListener('mouseleave', function(){
        tipos[0].style.setProperty('overflow-y', 'hidden');
        tipos[0].classList.remove('padding');
        if(tipos[2].clientWidth < maxwidth){
          tipos[3].classList.remove('margin');
        }
      });
    }
  }
}

function apscreen(url, tipo) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.open("get", url, 'false');
  var objetoscr;
  if(tipo=='in'){ objetoscr = 'in'; } else { objetoscr = tipo; }
  xmlhttp.onreadystatechange = function(){
    if(xmlhttp.readyState==4) {
      if(xmlhttp.responseText.indexOf('LOGOUT') != -1){
        logout(); 
        return;
      }
      MAIN.innerHTML = xmlhttp.responseText;
      icarrega(OWNER_BI +'.fcl.ajscreen?prm_screen='+objetoscr);
      if(MAIN.children[0]){
        if(MAIN.children[0].id == 'data_list'){
          ajustar(MAIN.children[0].className);
        }
      }
      
    }
  }
  xmlhttp.send(null);
}


function apOthers(url, tipo) {
  var xmlhttp = new XMLHttpRequest()
      response = '';
  xmlhttp.open("get", url, 'true');
  xmlhttp.onreadystatechange = function(){
    switch (tipo){
      case 'space':
        if(document.getElementById('space')){
          document.getElementById('space').innerHTML = xmlhttp.responseText;
        } else {
          document.getElementById('space-options').innerHTML = xmlhttp.responseText;
          if(xmlhttp.responseText.length == 0){
            document.getElementById('space-options').parentNode.style.setProperty('display', 'none');
          } else {
            document.getElementById('space-options').parentNode.style.setProperty('display', 'inline');
          }
        }
      break;
    
      case 'others':
        response = xmlhttp.responseText
      break;
      
    }
  }
  xmlhttp.send(null);

}

mac();  // Carrega atributo/classe que define o tipo de dispositivo/navegador 
if(document.getElementById('princp').className != 'mobile') {
  Notification.requestPermission(function(){
    notify.obj = { 'body': '', 'icon': OWNER_BI + '.fcl.download?arquivo=ipad.png' }
    notify.permission = Notification.permission;
  });
} 

// verifica se entrou como mobile e busca a permissao. 
if(document.getElementById('princp').className == 'mobile') {

  var element_value_array = (document.getElementById('mobile-permission').value).split('|');

  var permissao = element_value_array[0];
  var mensagem = element_value_array[1];

  if(permissao != 'S') {
    PRINCP.innerHTML = '<div style="font-weight: bold; font-size: 16px; color: #333; font-family: Tahoma, sans-serif; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: rgba(173, 216, 230, 0.8); padding: 15px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);" id="aviso-tela-principal">' + mensagem +'</div>';
    window.stop();
  }

} 


function mac(){
  var mac = (navigator.userAgent.toString().toLowerCase().indexOf("mac")!=-1) ? true : false;
  if(mac){ PRINCP.setAttribute('class','mac'); }
  var mobile = ((navigator.userAgent.toString().toLowerCase().indexOf("iphone")!=-1) || (navigator.userAgent.toString().toLowerCase().indexOf("ipod")!=-1)) ||   navigator.userAgent.toString().toLowerCase().indexOf('android')!=-1 ? true : false;
  if(mobile){ PRINCP.setAttribute('class','mobile');   }
}


function callnotify(x, y, z){
  notify.obj.body = y;
  //notify.click = window.open();
  new Notification(x, notify.obj);
  //new Notification('Upquery informa!', notify.obj);
}

// comentado 02/05/2017, descomentado 17/05 para usar no browser
function toggleFullScreen() {
  if (!document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement ) {
    if (document.documentElement.requestFullscreen) {
      document.documentElement.requestFullscreen();
    } else if (document.documentElement.msRequestFullscreen) {
      document.documentElement.msRequestFullscreen();
    } else if (document.documentElement.mozRequestFullScreen) {
      document.body.mozRequestFullScreen.call(document.body);
    } else if (document.documentElement.webkitRequestFullscreen) {
      document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
    }
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen();
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen();
    }
  }
}

var orient = "";

window.addEventListener("resize", function(){
  if(window.orientation != orient){
    setTimeout(function(){
      var alldrags = document.querySelectorAll('.dragme');
          var sizer = alldrags.length;
          for(var ig = 0;ig<sizer;ig++){
            if(document.getElementById('dados_'+alldrags[ig].id)){
              renderChart(alldrags[ig].id);
            }
          }
        }, 10);
        orient = window.orientation;
    }
});

// Atualiza mensagens ao Sair ou Retornar do BI - Se o chat estiver ativo 
document.addEventListener("visibilitychange", function() {
  if (get('verify-post')) { 
    if(document.visibilityState == 'hidden' ){
      vision = 'out';
      clearInterval(msgtime);
    } else {
      vision = 'in';
      clearInterval(msgtime);
      ajax('data-', 'check_text_post', '', true, 'verify-post');
    }
  }  
});
  

function toexcel(obj) {
  var excel        = document.createElement('a');
  excel.id = 'excel';
  MAIN.appendChild(excel);
  var uri = 'data:application/vnd.ms-excel;base64,';
  var template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><!--[if gte mso 9]><xml "encoding=utf-8"><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><div id="main"><table id="'+obj+'c">{table}</table></main></body></html>';
  var format = function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) }
  var table = document.getElementById(obj+'dv2');

  // Se não tem tabela então aborta a função 
  if (!table) {  
    return false;
  }

  var virtualtable = document.createElement('table');
  virtualtable.innerHTML = table.innerHTML;
 
  var invisibles = virtualtable.querySelectorAll('.invisible');
  var invisiblelength = invisibles.length;

  for(let i=0;i<invisiblelength;i++){ 
    invisibles[i].parentNode.removeChild(invisibles[i]); 
  }

  // Remove TH com display none 
  var headTags = virtualtable.getElementsByTagName('th');
  var headTagsLength = headTags.length;

  for(let h=headTagsLength-1;h >= 0; --h){ 
    if(headTags[h]){

      let elementoCorrente;
      elementoCorrente = document.getElementById(obj+'c').getElementsByTagName('th')[h];
      if(window.getComputedStyle(elementoCorrente).display == 'none'){
        headTags[h].remove();
      }

    }
  }

  // Remove TD com display none 
  var tags = virtualtable.getElementsByTagName('td');
  var tagslength = tags.length;

  for(let r=tagslength-1;r >= 0;--r){ 
    if(tags[r]){
      let elementoCorrente;
      elementoCorrente = document.getElementById(obj+'c').getElementsByTagName('td')[r]; 
      if(window.getComputedStyle(elementoCorrente).display == 'none'){
        tags[r].remove();
      } 
    } 
  }
  

  // Atenção esse ajuste não pode ser feito antes dos 2 loops anteriores, caso contrário a exclusão dos display none, não funcionarão 
  if(document.getElementById(obj)){

    var styles       = document.getElementById(obj).getElementsByTagName('style');
    var styleslength = styles.length;
    var styleHTML    = '';

    for(let u=0;u<styleslength;u++){ 
      if(styles[u]){ 
        if(styles[u].innerHTML.indexOf('display: none;') != -1){ 
          styleHTML = styleHTML+styles[u].innerHTML; 
        }  
      }
    }

    var stylein = virtualtable.getElementsByTagName('tr');
    var styleinlength = stylein.length;
    for(let v=0;v<styleinlength;v++){ 

      if(stylein[v]){
        
        // Remove primeiro item de cada TR
        if(!stylein[v].children[0].hasAttribute('style') || stylein[v].children[0].getAttribute('colspan') > 1 || stylein[v].className.indexOf('nivel') != 0){
          if((!stylein[v].children[0].hasAttribute('data-ordem') && !stylein[v].children[0].hasAttribute('data-agrupador') && stylein[v].children[0].innerHTML === '' && !stylein[v].classList.contains('total'))
             || (stylein[v].children[0].className.indexOf('seta')!== -1) 
             || (stylein[v].classList.contains('total') && stylein[v].children[0].getAttribute('data-drill')==='N')
            ){
            if (stylein[v].children[0].getAttribute('colspan') < 2 && (!stylein[v].children[0].getAttribute('style') || !stylein[v].children[0].getAttribute('style').includes('!important'))) {
              stylein[v].children[0].remove();
            } else {
              //Foi removido o código abaixo para resolver o card: 879s - Exportação com mais de 1 pivot está se perdendo.

              //stylein[v].children[0].setAttribute('colspan', parseInt(stylein[v].children[0].getAttribute('colspan'))-1);
            }
          }
        }
        
        // Marca para remover linhas de total não mostrados na consulta 
        if(stylein[v].classList.contains('total')){ 
          if(styleHTML.indexOf('li.total { display: none; }') != -1 || styleHTML.indexOf('tr.total { display: none; }') != -1 || stylein[v].classList.contains('st-S')){ 
            stylein[v].className = 'remove';  
          } 
        } else {
          if(stylein[v].classList.contains('total normal')){ 
            if(styleHTML.indexOf('li.total.normal { display: none; }') != -1 || styleHTML.indexOf('tr.total.normal { display: none; }') != -1){ 
              stylein[v].className = 'remove'; 
            } 
          } 
        }
      }
    }
  }
  
  
  // Remove as linhas marcadas com classe .remover
  var remover = virtualtable.querySelectorAll('.remove');
  var removerlength = remover.length;

  for(let r=0;r<removerlength;r++){
    remover[r].remove();
  }


  
  for(let a=0;a<tagslength-1;a++){ 

    if(tags[a]){

      if(tags[a].title.length > tags[a].innerHTML.length && (!tags[a].classList.contains('setadown') || !tags[a].classList.contains('seta'))){ 
        tags[a].innerHTML = tags[a].title; 
      } 

      if(tags[a].innerHTML.indexOf('background') != -1){ 
        tags[a].innerHTML = '';
      } 

      if(get('excel_mask_'+obj).value == 'S'){
        tags[a].innerHTML = tags[a].innerHTML.replace(/\./g, '');
      }

      tags[a].setAttribute('onclick', ''); 
      tags[a].removeAttribute('data-i'); 
      tags[a].removeAttribute('data-p'); 
      tags[a].removeAttribute('data-subquery'); 
      tags[a].removeAttribute('data-ordem'); 
      tags[a].removeAttribute('data-valor'); 
      
      // se a coluna for agrupadora (colagr) , força ser string
      if (tags[a].classList.contains('colagr')) {
        var currentStyle = tags[a].getAttribute('style') || '';
        var newStyle = currentStyle + ' mso-number-format: \\@;';
        tags[a].setAttribute('style', newStyle.trim());
      }

      if(tags[a].innerHTML.indexOf('!important') != -1){ 
        tags[a].parentNode.removeChild(tags[a]); 
      } 

    } 
  }

  for(let a=0;a<tagslength-1;a++){ 
    if(tags[a]){

      if(tags[a].classList.contains('setadown') || tags[a].classList.contains('seta')){
        tags[a].remove();
        continue;
      }

    }
  }


  let formatoExcel = 'HTML',
      dados        = document.getElementById('dados_'+ obj);

  if (dados) { 
    formatoExcel = dados.getAttribute('data-formato_excel').toUpperCase();
  }   

  // XLSX sem formatação 
  if (formatoExcel.toUpperCase() == 'XLSX' ) {

    
    var tags = virtualtable.getElementsByTagName('td');
    var tagslength = tags.length;
  
    for(let r=tagslength-1;r >= 0;--r){ 

      if(tags[r]){
        tags[r].innerHTML = tags[r].innerHTML.replace(/\./g, '').replace(/\,/g, '.').replace(/\%/g,'');   // Substitui o ',' por '.' e '%' por ''
        valor = tags[r].innerHTML; 
        if (!isNaN(tags[r].innerHTML)) { 
          // Tipo de dado Numérico
          tags[r].setAttribute('data-t', 'n');
        } else {   
          // Tipo de dados String 
          tags[r].setAttribute('data-t', 's');
        } 
      } 

    }

    try {
      // Cria um WorkBook em branco  
      var wb = XLSX.utils.book_new();
      // Cria um worksheet a partir da tabela 
      var ws = XLSX.utils.table_to_sheet(virtualtable);
    } 
    catch (ReferenceError) {
      alerta('feed-fixo', 'N&atilde;o foi poss&iacute;vel localizar a fun&ccedil;&atilde;o de exporta&ccedil;&atilde;o de planilhas, entre em contato com o administrador do sistema'); 
    } 
    // adiciona a worksheet na workbook
    XLSX.utils.book_append_sheet(wb, ws, 'Planilha1');
    // Gera e faz o download do arquivo
    XLSX.writeFile(wb, obj.substr(0, obj.length-1)+'.xlsx');

    setTimeout(function(){
      MAIN.removeChild(excel);
    }, 1000);   
    // HTML com formatação 
  } else { 
    var ctx = {worksheet: 'Consulta', table: virtualtable.innerHTML}
    // IE10
    if (navigator.msSaveBlob) { 
      return navigator.msSaveBlob(new Blob([format(template, ctx)], {type: uri}), obj.substr(0, obj.length-1)+'.xls');
    } else {
      document.getElementById('excel').href = uri + window.btoa(unescape(encodeURIComponent(format(template, ctx).replace(/&amp;/g, 'E').replace(/&/g, 'E').replace(/onclick="" class="dir" data-p=""/g, '').replace(/´/g, ' ').replace(/onclick=""/g, '').replace(/class="setadown" data-subquery=""/g, ''))));
      document.getElementById('excel').download = obj.substr(0, obj.length-1)+'.xls';
      document.getElementById('excel').click();
      setTimeout(function(){
        MAIN.removeChild(excel);
      }, 1000);
    }

  }  
} 


function browserToExcel(x) {
  var excel = document.createElement('a');
  excel.id = 'excel';
  main.appendChild(excel);
  var uri = 'data:application/vnd.ms-excel;base64,';
  var template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><!--[if gte mso 9]><xml "encoding=utf-8"><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>';
  var format = function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) }
  var table = document.getElementById(x+'dv2');
  var virtualtable = document.createElement('table');
  virtualtable.innerHTML = table.innerHTML;

  var invisibles = virtualtable.querySelectorAll('.invisible');
  var invisiblelength = invisibles.length;
  for(let i=0;i<invisiblelength;i++){ 
    invisibles[i].parentNode.removeChild(invisibles[i]); 
  }

  if(document.getElementById(x)){

    var nome = document.getElementById(x+'_ds').innerText;

    var styles = document.getElementById(x).getElementsByTagName('style');
    var styleslength = styles.length;
	
		var styleHTML = '';
    for(let u=0;u<styleslength;u++){ 
      if(styles[u]){ 
        if(styles[u].innerHTML.indexOf('display: none;') != -1){ 
          styleHTML = styleHTML+styles[u].innerHTML; 
        }  /*styles[u].parentNode.removeChild(styles[u]);*/ 
      }
    }
	
    var stylein = virtualtable.getElementsByTagName('tr');
    var styleinlength = stylein.length;
    for(let v=0;v<styleinlength;v++){ 
			//if(stylein[v].className == 'total'){ if(totalv == 'true'){ stylein[v].outerHTML = ''; } else { stylein[v].setAttribute('style', ''); } } else { stylein[v].setAttribute('style', '');} 
			if(stylein[v]){
        
        //corta primeiro item do tr
        if(!stylein[v].children[0].hasAttribute('style') || stylein[v].children[0].getAttribute('colspan') > 1 || stylein[v].className.indexOf('nivel') != 0){
          if(!stylein[v].children[0].hasAttribute('data-ordem')){
            if(stylein[v].children[0].getAttribute('colspan') < 2){
              stylein[v].children[0].remove();
            } else {
              stylein[v].children[0].setAttribute('colspan', parseInt(stylein[v].children[0].getAttribute('colspan'))-1);
            }
          }
        }

				if(stylein[v].classList.contains('total')){ 
					if(styleHTML.indexOf('li.total { display: none; }') != -1 || styleHTML.indexOf('tr.total { display: none; }') != -1 || stylein[v].classList.contains('st-S')){ 
						stylein[v].className = 'remove';  
					}
				} else {
					
					if(stylein[v].classList.contains('total normal')){ 
						if(styleHTML.indexOf('li.total.normal { display: none; }') != -1 || styleHTML.indexOf('tr.total.normal { display: none; }') != -1){ 
							stylein[v].className = 'remove'; 
						}  
					} 
				}
			}
    }
	
	}

  //pegar o style da tr para aplicar o destaque linha toda
  var trs = virtualtable.getElementsByTagName("tr");
  
  for (let i = 0; i < trs.length; i++) {

    var tr = trs[i]; // pega a tr atual
    if (tr.lastElementChild.tagName == 'STYLE'){ //verifica se na tr possui a tag style no final
      var cssResult = tr.lastElementChild.innerHTML.split('{')[1].replace('}','');
      tr.setAttribute('style', 'mso-number-format:\\@'); 
      tr.setAttribute('style',cssResult);
    
    }
    
  }

  
  var remover = virtualtable.querySelectorAll('.remove, .inv');
  var removerlength = remover.length;

  for(let r=0;r<removerlength;r++){
    remover[r].remove();
  }



  var tags = virtualtable.getElementsByTagName('td');

  var tagslength = tags.length;

  for(let a=0;a<tagslength-1;a++){ 
    
    if(tags[a]){
      // Verifica se tem input, se tiver, pega o valor do input , remove ele e joga o valor na td
      if(tags[a].children[0]){
       if(tags[a].children[0].tagName == 'INPUT'){ 
          var getValueInput = tags[a].children[0].value;
          var valueInput = getValueInput;
          tags[a].children[0].remove();
          tags[a].innerHTML= valueInput;
        } 
      }

      if(tags[a].title.length > tags[a].innerHTML.length && (!tags[a].classList.contains('setadown') || !tags[a].classList.contains('seta'))){ 
        tags[a].innerHTML = tags[a].title; 
      }

      //if(tags[a].classList.contains('setadown')){ tags[a].remove(); }
      if(tags[a].innerHTML.indexOf('background') != -1){ 
        tags[a].innerHTML = '';
      }

      if(tags[a].innerHTML.indexOf('-') != -1 || tags[a].innerHTML.indexOf('.') != -1){
        tags[a].setAttribute('style', 'mso-number-format:\\@'); 
      } 

      tags[a].setAttribute('onclick', ''); 
      tags[a].removeAttribute('data-i'); 
      tags[a].removeAttribute('data-p'); 
      tags[a].removeAttribute('data-subquery'); 
      tags[a].removeAttribute('data-ordem'); 
      tags[a].removeAttribute('data-valor'); 

      if(tags[a].innerHTML.indexOf('!important') != -1){ 
        tags[a].parentNode.removeChild(tags[a]); 
      } 
      
    } 
  }

  for(let a=0;a<tagslength-1;a++){ 
    if(tags[a]){
      if(tags[a].classList.contains('setadown') || tags[a].classList.contains('seta')){
        tags[a].remove();
        continue;
      }
    }
  }


  var ctx = {worksheet: 'Consulta', table: virtualtable.innerHTML}
  if (navigator.msSaveBlob) { // IE10
  return navigator.msSaveBlob(new Blob([format(template, ctx)], {type: uri}), x.substr(0, x.length-1)+'.xls');
  } else {
    document.getElementById('excel').href = uri + window.btoa(unescape(encodeURIComponent(format(template, ctx).replace(/&amp;/g, 'E').replace(/&/g, 'E').replace(/onclick="" class="dir" data-p=""/g, '').replace(/´/g, ' ').replace(/onclick=""/g, '').replace(/class="setadown" data-subquery=""/g, ''))));

    document.getElementById('excel').download = x.substr(0, x.length-1)+'.xls';
    document.getElementById('excel').click();

    //call('excel_log', 'prm_usuario='+usuario+'&prm_objeto='+nome+'&prm_id='+x, 'PROCEDURE');

    setTimeout(function(){
      main.removeChild(excel);
    }, 1000);
  }
}


function scale(x, y){

    var el = document.getElementById(x);
    if(document.getElementsByTagName('ARTICLE').length > 0 && ADMIN == 'A'){
      if(x.indexOf('trl') == -1){
        //change obj position
        if(MAIN.querySelector('.selected')){
          if(MAIN.querySelector('.selected').id != x){
            if(el.parentNode.id == MAIN.querySelector('.selected').parentNode.id){
              var selected = MAIN.querySelector('.selected');
              var selectedorder = selected.style.getPropertyValue('order');
              var elorder = el.style.getPropertyValue('order');
              el.style.setProperty('order', selectedorder);
              selected.style.setProperty('order', elorder);
              var quant = el.parentNode.children;
              for(let i=0;i<quant.length;i++){
                if (quant[i].style.getPropertyValue('order') !== null && quant[i].style.getPropertyValue('order') !== "") {
                  ajax('fly', 'salva_posicao', 'prm_objeto='+quant[i].id+'&prm_screen='+el.parentNode.id+'&prm_posx='+quant[i].style.getPropertyValue('order')+'&prm_posy=&prm_zindex=', false);
                }
              }
            MAIN.querySelector('.selected').classList.toggle('selected');
            }
          } else {
            el.classList.toggle('selected');
          }
        } else {
          el.classList.toggle('selected');
        }
      }
  } else {
    if(el.className.indexOf('scaled') != -1 || el.className.indexOf('img') != -1 || el.className.indexOf('icone') != -1 || el.className.indexOf('texto') != -1 || el.className.indexOf('float') != -1){
      /*if(el.parentNode.parentNode.tagName == 'SECTION'){
        el.parentNode.parentNode.classList.toggle('scaled');
      }*/
      if(el.getAttribute('data-left')){
        el.style.setProperty("left", el.getAttribute('data-left'));
      }
      if(el.getAttribute('data-top')){
        el.style.setProperty("top", el.getAttribute('data-top'));
      }
      el.classList.remove('scaled');
      el.style.transform = '';
      el.style.webkitTransform = '';
      el.style.zIndex = el.getAttribute('data-zindex');
      localStorage.setItem('pos', 0);
      if(y == 'direct'){
        PRINCP.style.setProperty("overflow", "visible");
        PRINCP.style.removeProperty("height");
        document.getElementById('html').style.setProperty("overflow", "visible");
        document.getElementById('layer3').style.setProperty("height", "0");
        document.getElementById('prev').style.setProperty("display", "none");
        document.getElementById('next').style.setProperty("display", "none");
      }
    } else {
      if(el.className.indexOf('front') != -1){
        //testando expand com recalculo de fixos
        while(document.getElementById(x).lastElementChild.tagName == 'STYLE'){
          document.getElementById(x).lastElementChild.remove();
        }
        setTimeout(function(){
          topDistance(x);
        }, 1000);
        if(el.className.indexOf('expand') == -1){
          el.className = el.className+' expand';
        } else {
          el.className = el.className.replace(' expand', '');
        }
      } else {
        if(el.className.indexOf('relatorio') == -1 && !el.classList.contains('drill')){
          el.classList.add('scaled');
          setTimeout(function(){
            for(let i=35;i>12;i--){
              if((el.offsetWidth*(i/10)+(80*(i/10)) < window.innerWidth) && (el.offsetHeight*(i/10)+15 < window.innerHeight)){
                el.style.transform = "scale("+(i/10)+")";
                el.style.webkitTransform = "scale("+(i/10)+")";
                break;
              }
            }

            el.style.setProperty('left', ((window.innerWidth/2)-(el.offsetWidth/2))+'px');
            el.style.setProperty('top', ((window.innerHeight/2)-(el.offsetHeight/2))+'px');
            el.style.zIndex = '800';
            curtain('only');

            if(y == 'direct'){
              PRINCP.style.setProperty("overflow", "hidden");
              PRINCP.style.setProperty("height", "inherit");
              document.getElementById('html').style.setProperty("overflow", "hidden");
              document.getElementById('layer3').style.setProperty("height", "100%");
              document.getElementById('prev').style.setProperty("display", "flex");
              document.getElementById('next').style.setProperty("display", "flex");
            }
          }, 100);
        }
      }
    }
  }
}

function upload(x){

  var file = document.getElementById(x).files;
  for(let i=0;i<file.length;i++){
    var blob = new Blob([file[i]]);
    var formfile = new FormData;
    //var filename = file.name
    //formfile.append('prm_arquivo', 'teste123');
    formfile.append('prm_arquivo', blob, '123');
    //var reader = new FileReader();
    //reader.readAsText(file[i]);
    ajax('upload', 'painel', formfile, false, file[i].type, file[i].size);
  }

  function send(y, z){
    if(y.readyState != 2){
    setTimeout(function(){ send(y, z); }, 1000);
    } else {
      //var result = [y.result];
      var blob = new Blob([y.result], {size: y.size, type: y.type});
      //blob = y.result;
      //ajax('upload', 'painel', 'prm_arquivo='+z.name+'&prm_data='+y, 'true');
      ajax('fly', 'painel', 'prm_arquivo='+z.name+'&prm_data='+blob);
    }
  }
}

function destaque(counter, alter, id){
  var user = document.getElementById('destaque-usuario-'+counter).title;
  var obj = document.getElementById('destaque-objeto-'+counter).title;
  var coluna = document.getElementById('destaque-coluna-'+counter).title;
  var condicao = document.getElementById('destaque-condicao-'+counter).title;
  var conteudo = encodeURIComponent(document.getElementById('destaque-conteudo-'+counter).title.trim());
  var tipo = document.getElementById('destaque-tipo-'+counter).getAttribute('data-default');
  var corfundo = document.getElementById('destaque-icorfundo-'+counter).getAttribute('data-default');
  var corfonte  = document.getElementById('destaque-icorfonte-'+counter).getAttribute('data-default');
  
  var valor;
  if(alter != 'DELETE'){
    
    var self = document.getElementById(id);
    valor = encodeURIComponent(self.value.trim());
    self.setAttribute('data-default', self.value.trim());
    if(self.tagName == 'SELECT'){
      for(let i=0;i<self.children.length;i++){
        if(self.children[i].value.trim() == self.value.trim()){
          self.children[i].setAttribute('selected', 'selected');
        } else {
          self.children[i].removeAttribute('selected');
        }
      }
    }
  } else {
    valor = ""; 
  }
  
  call('edit_blink','prm_usuario='+user+'&prm_objeto='+obj+'&prm_coluna='+coluna+'&prm_condicao='+condicao+'&prm_conteudo='+conteudo+'&prm_valor='+valor+'&prm_tipo='+tipo+'&prm_corfundo='+corfundo+'&prm_corfonte='+corfonte+'&prm_alter='+alter).then(function(resposta){
    document.getElementById('fechar_sup').setAttribute('data-reloado', obj);
    alerta('feed-fixo', resposta);
    if(resposta.indexOf("FAIL") == -1 && alter == "DELETE"){ document.getElementById('destaque-usuario-'+counter).parentNode.parentNode.remove(); }
  });
}


function input(e, tipo){
  var key = e.which;
  var keycode = e.keyCode;
  var regex;
  switch(tipo){
    //44 virgula 46 ponto
    case 'rotulo':
      //regex = new RegExp('^[a-zA-Z0-9_ \+().\%\\\/\u00C0-\u017F\!\#\@\,\*\?]+$');
      //if ((key == 13) || regex.test(String.fromCharCode(key)) == true) {
        return true;
      //} else {
      //  return false;
      //}

    case 'default':
      if ((key != 92)) {
        return true;
      } else {
        return false;
      }

    case 'integer':
      if(key == 13){
        e.target.blur();
        return false;
      } else {
        if(key == 0 && keycode != 37 && keycode != 39){
          //e.target.blur();
          return true;
        } else {
          if ((key == 0) || (key == 8) || (('0123456789').indexOf(String.fromCharCode(key)) != -1) ) {
            return true;
          } else {
            return false;
          }
        }
      }

    case 'hora':
      if(key == 13){
        e.target.blur();
        return false;
      } else {
        if(key == 0 && keycode != 37 && keycode != 39){
          //e.target.blur();
          return true;
        } else {
          if ((key == 0) || (key == 8) || (('0123456789:').indexOf(String.fromCharCode(key)) != -1) ) {
            return true;
          } else {
            return false;
          }
        }
      }

    case 'volume':
      if ((key == 0) || (key == 8) ||  (key == 46) || (key == 44) || (('0123456789').indexOf(String.fromCharCode(key)) != -1) ) {
        return true;
      } else {
        return false;
      }

    case 'valor':
      if ((key == 0) || (key == 8) ||  (key == 44 || (('0123456789').indexOf(String.fromCharCode(key)) != -1)) ) {
        return true;
      } else {
        return false;
      }

    case 'number':
      var valor = e.target.innerHTML; 
      if (e.target.tagName == 'INPUT') { valor = e.target.value;} ;

      if(key == 13){
        e.target.blur();
        return false;
      } else {
        if(key == 0 && keycode != 37 && keycode != 39){
          e.target.blur();
          return true;
        } else {
          if ((key == 0) || (key == 8) || (key == 44 && valor.indexOf(',') == -1) || (key == 45) || (('0123456789').indexOf(String.fromCharCode(key)) != -1) ) {
            return true;
          } else {
            return false;
          }
        }
      }
    case 'nobr':
      regex = new RegExp('^[<*>]+');
      if ((key == 0) || (key == 8) || (key == 46) || regex.test(String.fromCharCode(key)) == false) {
        return true;
      } else {
        return false;
      }
    case 'email':
      regex = new RegExp('^[a-zA-Z0-9-_@!&#]+');
      if ((key == 0) || (key == 8) || (key == 46) || regex.test(String.fromCharCode(key)) == true) {
        return true;
      } else {
        return false;
      }
    case 'login':
      regex = new RegExp('^[a-zA-Z0-9]+');
      if ((key == 0) || (key == 8) || (key == 46) || regex.test(String.fromCharCode(key)) == true) {
        return true;
      } else {
        return false;
      }
    case 'ID':
      regex = new RegExp('^[a-zA-Z0-9_]+')
      if ((key == 0) || (key == 8) || (key == 46) || regex.test(String.fromCharCode(key)) == true) {
        return true;
      } else {
        return false;
      } 
    case 'nopipe':
      if ((key == 0) || (key == 8) || (key == 46) || (String.fromCharCode(key) != '|') )  {
        return true;
      } else {
        return false;
      }
  }
}

var zindex_abs = 5;

function mask(x, y, z){

  var obj = document.getElementById(x);
  var caracter = String.fromCharCode(y.which);
  var pos = obj.selectionEnd;
  var posi = obj.selectionEnd;
  var poss = obj.selectionStart;
  var regex = new RegExp('^[a-zA-Z0-9]+');
  var mascaras = z.split('');
  var valores = obj.value.split('');
  var ml = mascaras.length
  var retorno = [];
  var r = 0;

    for(let i=0;i<ml;i++){
      if(pos == i){

        if(y.which == '8'){
          if(valores[i-1] != ',' && valores[i-1] != '.'){
            //y.preventDefault();
            //valores[i-1] = ' ';
            posi = posi-1;
            poss = posi;
          } else {
            obj.selectionEnd = obj.selectionEnd-1;
            y.preventDefault();
            return false;
          }
        } else {
          //del
          if(y.which == '46'){
            if(valores[i] != ',' && valores[i] != '.'){
              //y.preventDefault();
              //valores[i] = ' ';
              //posi = posi;
              poss = posi;
            } else {
              obj.selectionEnd = obj.selectionEnd+1;
              obj.selectionStart = obj.selectionStart+1;
              y.preventDefault();
              return false;
            }
          } else {

            if(mascaras[i] == 'G'){
              retorno[i] = '.';
              posi = posi+1;
              poss = posi;
              i = i+1;
            }

            if(mascaras[i] == 'D'){
              retorno[i] = ',';
              posi = posi+1;
              poss = posi;
              i = i+1;
            }

          }

        }

        if(regex.test(caracter)){
          retorno[i] = caracter;
          if(valores[i+1] == ',' || valores[i+1] == '.'){
            posi = posi+2;
            poss = posi;
          } else {
            posi = posi+1;
            poss = posi;
          }
        }  else {
          retorno[i] = valores[i];
          retorno[i-1] = valores[i-1];
        }

      } else {

        retorno[i] = valores[i];

      }

    }

    obj.value = retorno.join('');

    if(y.which < 36 || y.which > 41){
      obj.selectionEnd = posi;
      obj.selectionStart = poss;
    }

}


function mascara(x, um, y, ll, lr, vl, vr, e){
  if(e){ if(e.which == 38 || e.which == 40){ e.preventDefault(); }}
    //length left
    var ll = ll || "999";
    //value left
    var vl = vl || "999999999999"
    //value right
    var vr = vr || "999999999999"
    //length right
    var lr = lr || "2";
    //unidade medida
    var um = um || "R$";
    //pontuação
    var y = y || ",";
    var valor = x.value.replace(y, "").replace(um, "").trim();
    var cursorpos = x.selectionEnd;

    if(valor.length < parseInt(lr)+1){

      if(valor.length <= 1){ x.value = (um+" "+"0"+y+"0"+valor).trim(); } else { x.value = (um+" "+"0"+y+valor).trim(); }
    } else {
      var valorl = valor.slice(0, x.value.replace(um, "").trim().length-(parseInt(lr)+1));
      var valorr = valor.slice(valor.length-parseInt(lr));
      if(valorl == "00" || valorl == ""){ valorl = "0"; }
    if(valorl.length > parseInt(ll)){ valorl = valor.slice(1, valorl.length); }
    if(e){
      if(e.which == 38){
        if(x.selectionEnd > x.value.indexOf(y)){ valorr = ('000000000' +(parseInt(valorr)+1)).substr(-lr); }
        if(x.selectionEnd <= x.value.indexOf(y)){ valorl = parseInt(valorl)+1; }
      }
      if(e.which == 40){
        if(x.selectionEnd > x.value.indexOf(y) && parseInt(valorr) > 0){ valorr = ('000000000' +(parseInt(valorr)-1)).substr(-lr); }
        if(x.selectionEnd <= x.value.indexOf(y) && parseInt(valorl) > 0){ valorl = parseInt(valorl)-1; }
      }
    }
    if(parseInt(valorl) > parseInt(vl)){ valorl = vl; }
    if(parseInt(valorr) > parseInt(vr)){ valorr = vr; }
    x.value = (um+" "+[parseInt(valorl), y, valorr].join("")).trim();
    }
   if(um.trim().length > 0){
    if(cursorpos < um.length+1){
     x.selectionEnd = um.length+1;
     x.selectionStart = um.length+1;
    } else {
      if(valor.length < 1){
        x.selectionEnd = x.value.length;
      } else {
        x.selectionEnd = cursorpos;
      }
    }
    } else {
      x.selectionEnd = cursorpos;
    }

}

function titulo(x,y){
  document.getElementById('titulo').innerHTML = x.title;
  if(x.parentNode.parentNode.id){ if(x.parentNode.parentNode.id != 'prefdrop'){ document.getElementById('info').innerHTML = x.parentNode.parentNode.id; } }
  if(y == 'c'){ document.getElementById('painel').innerHTML = ''; }
}


function enc(x){
  return encodeURIComponent(x.replace(/\\/g, "").replace(/"/g, ""));
}



function carrega(local){
  document.getElementById('content').innerHTML = '';
  if(local.length != 0){
    loader('content');
    var el = document.getElementById('frame');
    var url = OWNER_BI + '.fcl.'+local;
    el.src = url;
  }
}

function carregaTelasup(cont_proc, cont_param, cont_pkg, painel_nome, painel_param, painel_pkg, tela_ant) {
  
  clearInterval(refresh_timer);
  document.getElementById("fakelist").setAttribute("data-campo", "");
  document.getElementById("fakelist").setAttribute("class", "");
  alerta("msg", "");
  curtain();

  // Acumula array de telas anteriores 
  if (typeof tela_ant !== "undefined" && tela_ant !== 'none' && tela_ant.length > 0) {
    telasup_ant.push(tela_ant);
  }  
  // Carrega painel esquerdo (se foi informado)
  if (typeof painel_nome !== "undefined" && painel_nome !== '') { 
    if (painel_nome == 'none') { 
      document.getElementById('painel').innerHTML = '';
    } else {  
      call('menu', 'prm_menu='+painel_nome+'&prm_default='+painel_param, painel_pkg).then(function(resposta){ 
        document.getElementById('painel').innerHTML = resposta; 
      });
    }  
  }   

  // Carrega conteudo da tela
  if (typeof cont_proc !== "undefined" && cont_proc !== '') { 
    call(cont_proc, cont_param, cont_pkg).then(function(resposta) {
      document.getElementById('content').innerHTML = resposta;
      
      if (document.getElementById("refresh_sup")) { document.getElementById("refresh_sup").style.display='block';} 
      else                                        { document.getElementById("refresh_sup").style.display='none'};
      
      if (telasup_ant.length !== 0) { document.getElementById("back_sup").style.display='block';} 
      else                          { document.getElementById("back_sup").style.display='none'};

      refreshSupBtn('O');  // Oculta botão 
      if (document.getElementById('content-atributos')) { 
        let atrib = document.getElementById('content-atributos'); 
        if (atrib.getAttribute('data-refresh') && atrib.getAttribute('data-refresh').length > 1) { 
          
          refreshSupBtn('V');  // Visivel           
          refresh_param[0] = cont_proc;
          refresh_param[1] = cont_param;
          refresh_param[2] = cont_pkg;
          
          if (atrib.getAttribute('data-refresh-ativo') && (atrib.getAttribute('data-refresh-ativo') == 'S')) {  
            refreshSupStart();
          }
          
          // refresh_timer = setInterval( function testedefuncao() { if (refreshSup_ativo=='S') {ajax('list', cont_proc, cont_param, true, 'content','','',cont_pkg); }}, 5000);       
        }    
      }  
    });
  }
  curtain('enabled');
}


function carregaPainel(local, valor, coluna){


  var valor = valor || "";

  call('menu', 'prm_menu='+local+'&prm_default='+valor).then(function(resposta){ 
    document.getElementById('painel').innerHTML = resposta; 

    // Se foi informado a coluna, seleciona a coluna informada  
    if (typeof coluna !== "undefined" && coluna !== '') { 

      // Pega a posicao da coluna selecionada 
      var objDiv = document.getElementById('container-colunas'), 
          objCol = document.getElementById(coluna+'id'), 
          lista  = document.getElementById('ajax-lista').getElementsByTagName('LI'), 
          colnum = 0;
      for(let i=0;i<lista.length;i++){
        if (lista[i].id == coluna + 'id' ) {
          colnum = i ; 
          break;
        }    
      }  
      objDiv.scrollTop = Math.trunc(objDiv.scrollHeight * (colnum / lista.length));  
      objCol.classList.add('used','selected');       
      arrow(this, coluna, 'click');
    }
  });

}

function carregaPainel_frame(local, ident){
  var newframe = document.createElement('iframe');
  newframe.id = 'newframe';
  newframe.src = local;
  if(ident.trim().length > 1){ newframe.className = ident; }
  newframe.style.setProperty('width', '800px');
  newframe.style.setProperty('height', '26px');
  document.getElementById('painel').innerHTML = '';
  document.getElementById('painel').appendChild(newframe);
}

function icarrega(){

  // Monta/ajusta todas as tabelas html da tela
  var divs;                
  var tabela  = '';	
  var x       = document.querySelectorAll('.dragme.front');
  var xlength = x.length;

  for(divs=0;divs<xlength;divs++){ 

    tabela = x[divs].id;

    if(document.getElementById(tabela)){
       
      if(document.getElementById(tabela+'c')){
        var prints = document.getElementById(tabela+'c').querySelectorAll('.print');
        var printsl = prints.length;
        for(let p=0;p<printsl;p++){ 
          prints[p].parentNode.setAttribute('style', prints[p].innerHTML); 
          if (prints[p].tagName.toUpperCase() == 'TD') { 
            prints[p].parentNode.classList.add('destaqueLinha'); 
          }  
        }
      }						
       
        
      if(document.getElementById(tabela+'c')){
        var tabelac = document.getElementById(tabela+'c');
        tabelac.addEventListener('click', click_evento);
        tabelac.addEventListener('dblclick', dbl_click_evento);
        tabelac.addEventListener('mouseenter', function(){
          imgurlOver(this.id);  
        });
      }
    }

    topDistance(tabela);
    
    if(document.getElementById(tabela+'_ds')){
      var titulo = document.getElementById(tabela+'_ds');
      var titvalor = titulo.innerHTML;
      titulo.innerHTML = '_';
      titulo.innerHTML = titvalor;
    }
    
    if(typeof ajuste !== 'undefined'){
      if(ajuste.children[3]){
        var ajuste3 = ajuste.children[3].getElementsByTagName('td');
        var ajuste3l= ajuste3.length;
        for(let c=0;c<ajuste3l;c++){
          ajuste3[c].removeAttribute('id');
          ajuste3[c].removeAttribute('data-valor');
        }

        if(document.getElementById(tabela+'c')){ 
          document.getElementById(tabela+'c').addEventListener('click', click_evento);
          document.getElementById(tabela+'c').addEventListener('dblclick', dbl_click_evento);
          document.getElementById(tabela+'c').addEventListener('mouseleave', out_evento);
          document.getElementById(tabela+'c').addEventListener('dblclick', dbl_click_evento);
        }
        //if(document.getElementById(tabela+'fixed')){ document.getElementById(tabela+'fixed').addEventListener('click', click_evento); }

        smartScroll(tabela);
        if(document.getElementById(tabela+'c')){
          var prints = document.getElementById(tabela+'c').querySelectorAll('.print');
          var printslength = prints.length;
          for(let p=0;p<printslength;p++){ 
            prints[p].parentNode.setAttribute('style', prints[p].innerHTML); 
            if (prints[p].tagName.toUpperCase() == 'TD') { 
              prints[p].parentNode.classList.add('destaqueLinha');
            }  
          }
        }
        var objleft = document.getElementById(tabela).getAttribute('data-left');
        var objtop = document.getElementById(tabela).getAttribute('data-top');
      }
    }

  }

  
  // Monta/Ajusta todos os gráficos da tela 
  if(!document.querySelector('.full')){     //slide não precisa de ajuste
    dashAjuste();
    renderizaGraficos();
  } else {
    setTimeout(fullscreen, 100);
  }


  // Monta/Ajusta todos os mapas de geo localização (Google) da tela 
  var geomapas = document.getElementsByClassName('dragme mapageoloc');
  for(let w=0;w<geomapas.length;w++){
    mapaGeoLoc(geomapas[w].id);
  }

  // Retira o loading da tela 
  try{
    if(LAYER){
      if(LAYER.className == 'ativo'){ loading('x'); }
    }
  } catch (e){
    console.log('nolayer');
  }

}

function renderizaGraficos(){
  var valores = document.querySelectorAll('.dragme.grafico, .dragme.dados, .dragme.medidor');
  var valorl = valores.length;
  for(let v=0;v<valorl;v++){
    renderChart(valores[v].id);
  }
}

function curtain(x) {
  var curtain = document.getElementById('layer2');

  if(x == 'enabled') {
    document.getElementById('msg').style.opacity = 0;
    curtain.classList.add('ativo');
    telasup.style.setProperty('overflow', 'visible');
    telasup.style.setProperty('transform', 'scale(1)');
  } else {
    if(x == 'only'){
      curtain.className = 'ativo';
    } else {
      curtain.classList.remove('ativo');
      telasup.style.setProperty('overflow', 'hidden');
      telasup.style.setProperty('transform', 'scale(0)');
      document.getElementById('content').innerHTML='';
      document.getElementById('painel').innerHTML='';
    }
  }
}

const ABOUT = 'Sistema desenvolvido por, Upquery do Brasil.';

function dashAjuste(x){
  var section;
  if(x){
    section = document.getElementById(x);
    section.addEventListener('mousedown', dashSectionDown);
    section.addEventListener('mouseenter', dashSectionEnter);
    section.addEventListener('mouseleave', dashSectionLeave);
    articleAjuste(x);
  } else {
    section = document.getElementsByTagName('SECTION');
    var sectionl = section.length;
    if(sectionl > 0){
      for(let s=0;s<sectionl;s++){
        if(ADMIN == 'A'){
          section[s].addEventListener('mousedown', dashSectionDown);
          section[s].addEventListener('mouseenter', dashSectionEnter);
          section[s].addEventListener('mouseleave', dashSectionLeave);
        }
        articleAjuste(section[s].id);
      }
    }
  }
}

function articleAjuste(x){
  var dashboard = document.getElementById(x).getElementsByTagName('ARTICLE');
  var dashboardl = dashboard.length;
  for(let d=0;d<dashboardl;d++){
    var ele = dashboard[d];
    if(ADMIN == 'A'){
      ele.addEventListener('mousedown', dashArticleDown);
      ele.addEventListener('mouseenter', dashArticleEnter);
      ele.addEventListener('mouseleave', dashArticleLeave);
    }
  }
  //executando duas vezes, comentado
  //renderizaGraficos();
}

var objatual = "";

function chart(x){
  var gxml = document.getElementById('gxml_'+x);
  var dados = document.getElementById('dados_'+x);
  var divObj = document.getElementById('ctnr_'+x);
  var article = divObj.closest('article');
  var grafico_pivot = false;
  var arr_pivot     = []; 

  if (document.getElementById(x+'-agrupador_pivot')) {
    grafico_pivot = true;
    arr_pivot     = get_agrupador_pivot(x); 
  }



  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      divObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile' && document.getElementById('atributos_' + x).getAttribute('data-zoom').toUpperCase() !== 'S'){
    divObj.style.width = '100%';
  }

  if(get('prm_clear')){
    chartAnimation = false;
  }

  if(!document.getElementById(x+'_ERR')){

    if(document.getElementById('dados_'+x) && document.getElementById('gxml_'+x)){

      var tipo = 'bar';
      var formato;
      if(dados.getAttribute('data-tipoobj') == 'BARRAS'){
        formato = 'bar';
      } else if(dados.getAttribute('data-tipoobj') == 'COLUNAS') {
        formato = 'column';
      } else {
        tipo = 'line';
        formato = 'line';
      }

      var atributos = document.getElementById('atributos_'+x);
      var stack = '';
      var stack_total = '';
      if(atributos.getAttribute('data-stacked')){
        stack = atributos.getAttribute('data-stacked');
      }   
      if(atributos.getAttribute('data-stacked_total')){
        stack_total = atributos.getAttribute('data-stacked_total');
      }

      var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer, height: document.getElementById('ctnr_'+x).clientHeight, width: document.getElementById('ctnr_'+x).clientWidth
     }); 


      if(gxml.children[0]){


        if(!gxml.children[0].classList.contains('err')){
        //var valores = gxml.children[0].innerHTML.trim().replace("|", "").replace(/\r?\n|\r/g, '');
        //var categorias = gxml.children[1].innerHTML.trim().replace("|", "").split("|");
        //var codigos = gxml.children[2].innerHTML.trim().replace("|", "").split("|");


        var jsonLista = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
        jsonLista = jsonLista.substring(0, jsonLista.trim().length-1);

        if (jsonLista.includes(', *|*')) {
          jsonLista = jsonLista.replace(/, *\*\|*\*/g, '');
        }           
        try {
          var jsonParsed = JSON.parse("{"+jsonLista+"}");
        } catch (err){
          alerta('feed-fixo', TR_QR_IN);
          return;
        }

        var valores     = [];
        var categorias  = [];
        var codigos     = [];
        var codi_cate   = [];


        for(let linha in jsonParsed){

          if (jsonParsed[linha] && jsonParsed[linha].valores && Array.isArray(jsonParsed[linha].valores)) {
            jsonParsed[linha].valores.map(function(obj) {
              obj.cod = jsonParsed[linha].cod;
              return obj;
            });
          };

          valores.push(jsonParsed[linha].valores);
          categorias.push(jsonParsed[linha].colunas);
          codigos.push(jsonParsed[linha].cod);
          if ( jsonParsed[linha].cod != jsonParsed[linha].colunas) { 
            codi_cate.push(jsonParsed[linha].cod + '-' + jsonParsed[linha].colunas);
          } else {
            codi_cate.push(jsonParsed[linha].colunas);
          }
        }

        //Cria uma property posicao para o objeto valores 06/12/23
        var posicoesPorSubArray = [];
        
          
          // usado para verificar se há grupos repetidos em cada subarray de objetos (valores)
          try {
            var temGruposRepetidos = valores.some(function (subArray) {
              var grupos = subArray.map(function (item) {
                return item.grupo; //true||false
              });
              return grupos.some(function (grupo, index) {
                return grupos.indexOf(grupo) !== index; //true||false
              });
            });
          } catch (error) {
            temGruposRepetidos = null;
          };
         
        
          for (let i = 0; i < valores.length; i++) {
            let subArray = valores[i];
            let posicoes = {};
            
            for (let j = 0; j < subArray.length; j++) {
              let grupo = subArray[j].grupo;
              
              if (!posicoes[grupo]) {
                posicoes[grupo] = [];
              };
              
              posicoes[grupo].push(j);
            };
            
            posicoesPorSubArray.push(posicoes);
          };
        
          for (let i = 0; i < valores.length; i++) {
            let subArray = valores[i];
            let posicoes = posicoesPorSubArray[i];
            let nomeRepetido = new Set();

            for (let j = 0; j < subArray.length; j++) {
              let grupo = subArray[j].grupo;
              subArray[j].posicao = posicoes[grupo][j];

              if (temGruposRepetidos) {
                // Se o nome já estiver no conjunto, incrementa j concatenado com '_' para torná-lo único
                while (nomeRepetido.has(grupo)) {
                  grupo = grupo + "_" + j;
                }
                nomeRepetido.add(grupo);
                subArray[j].grupo = grupo;
              };
            };
          };

        if (atributos.getAttribute('data-inverte_ordem') && atributos.getAttribute('data-inverte_ordem') == 'S') {
          valores    = valores.reverse();
          categorias = categorias.reverse();
          codigos    = codigos.reverse();
        }
        
        try{  
          var destaque = JSON.parse('{'+gxml.children[1].innerHTML.replace(/(\r\n|\n|\r)/gm, '')+'}');
        }catch(e){
          alerta('feed-fixo','Sem Dados');
          return;
        }

        var coluna      = dados.getAttribute('data-coluna').replace("(BR)", " ").replace("<BR>", " ");
        var agrupadores = dados.getAttribute('data-agrupadores').replace("<BR>", " ").indexOf("|");
        var sec         = dados.getAttribute('data-sec').replace("<BR>", " ");
        var rotacao     = atributos.getAttribute('data-rotacao');
        var decimal     = atributos.getAttribute('data-decimal');
        var abreviacao  = atributos.getAttribute('data-abreviacao');
        var cursor      = atributos.getAttribute('data-cursor');

        //var ymin = ((atributos.getAttribute('data-ymin').length > 0) ? atributos.getAttribute('data-ymin') : undefined);
        var xpos            = atributos.getAttribute('data-xpos');
        var ccoluna         = atributos.getAttribute('data-cor-coluna').split("|");
        var ccoluna_hex     = dados.getAttribute('data-ccoluna-hex').split("|");
        var nodesc          = atributos.getAttribute('data-nodesc');
        var posicao         = atributos.getAttribute('data-posicao');
        var tam_fontSize    = atributos.getAttribute('data-label_size');
        var label_rotate    = atributos.getAttribute('data-label_rotate');
        var label_distance  = atributos.getAttribute('data-label_distance');
        var font_family     = atributos.getAttribute('data-font_family');
        var font_weigth     = atributos.getAttribute('data-font_weigth');
        var cor             = atributos.getAttribute('data-cor');
        var meta            = '';//atributos.getAttribute('data-meta');
        var meta_cor        = '';//atributos.getAttribute('data-meta_cor').split("|");
        var markMax         = atributos.getAttribute('data-mark-max');
        var markMin         = atributos.getAttribute('data-mark-min');
        var markMedia       = atributos.getAttribute('data-mark-media');
        var um              = atributos.getAttribute('data-um');
        var label_conteudo  = atributos.getAttribute('data-label_conteudo');
        var cor_eixo_agrup  = atributos.getAttribute('data-graf_axis_corAgrup');
        var showLineGrid    = atributos.getAttribute('data-showlinegrid');
        var umvl            = atributos.getAttribute('data-graf_axis_umvl');
        var corTextoLegenda = atributos.getAttribute('data-cor_texto_legenda');
        var agrupar_valor   = atributos.getAttribute('data-agrupar-valor');

        var activeZoom = atributos.getAttribute('data-zoom');
        if(activeZoom == 'S'){
          activeZoom = true;
        } else {
          activeZoom = false;
        }

        var vdistance;
        if ((posicao == 'top'|| posicao =='bottom'||posicao =='right'||posicao == 'left') && formato!= 'pie' && formato!='bar'){
          vdistance = label_distance;
        }
        var vrotate;
        //trazer o valor do label na vertical
        if(formato == 'column'){
          
          if(posicao == 'right'){
            posicao = 'top';
          }
          if (posicao == 'left'){
            posicao = 'insideBottom';
          }

          if(label_rotate == 'S'){
          
            vrotate = 90;
          }else{
            vrotate = 0;
          }  
        }else{
          vrotate = 0;
        }

        var labelspace = '';
        if(atributos.getAttribute('data-espacamento')){
          if(atributos.getAttribute('data-espacamento').replace('|||', '').length > 0){
            labelspace = atributos.getAttribute('data-espacamento'); 
          }
        }
        
        var mostrar = atributos.getAttribute('data-hidden');

        var coresvar = ["#87CEFA", "#C1232B", "#B5C334", "#FCCE10", "#E87C25", "#27727B", "#FE8463", "#9BCA63", "#FAD860", "#F3A43B", "#60C0DD", "#D7504B", "#C6E579", "#F4E001", "#F0805A", "#26C0C0", "#FF7F50", "#00D878", "#AAAAAA", "#DDDD55", "#065182", "#DA70D6", "#FF6347", "#AA5511", "#CCCC44", "#DA7400", "#6663BB", "#FAE982", "#F5C65D", "#AAA43B", "#87CEFA", "#C1232B", "#B5C334", "#FCCE10", "#E87C25", "#27727B", "#FE8463", "#9BCA63", "#FAD860", "#F3A43B", "#60C0DD", "#D7504B", "#C6E579", "#F4E001", "#F0805A", "#26C0C0", "#FF7F50", "#00D878", "#AAAAAA", "#DDDD55", "#065182", "#DA70D6", "#FF6347", "#AA5511", "#CCCC44", "#DA7400", "#6663BB", "#FAE982", "#F5C65D", "#AAA43B", "#87CEFA", "#C1232B", "#B5C334", "#FCCE10", "#E87C25", "#27727B", "#FE8463", "#9BCA63", "#FAD860", "#F3A43B", "#60C0DD", "#D7504B", "#C6E579", "#F4E001", "#F0805A", "#26C0C0", "#FF7F50", "#00D878", "#AAAAAA", "#DDDD55", "#065182", "#DA70D6", "#FF6347", "#AA5511", "#CCCC44", "#DA7400", "#6663BB", "#FAE982", "#F5C65D", "#AAA43B", "#87CEFA", "#C1232B", "#B5C334", "#FCCE10", "#E87C25", "#27727B", "#FE8463", "#9BCA63", "#FAD860", "#F3A43B"];
        var corLinha;
        if(tipo == "line"){
          if(agrupadores == -1){
            corLinha = atributos.getAttribute('data-cor_linha') || '#000000';
            coresvar[0] = '#000000';
          } else {
            corLinha = atributos.getAttribute('data-cor_linha') || '#87CEFA';
          }
        }

        //não usar a variavel no topo, problema no mobile
        var cores;
        if(atributos.getAttribute('data-cores').length < 1){
          cores = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
        } else {
          cores = atributos.getAttribute('data-cores').split("|");
        }
        
        /*while(cores.length < 100){
          cores.push(cores[cores.length-1]);
        }*/
        // while estava complentando com a última cor ao invés de refazer o ciclo.      
         
        for (let i=0; cores.length < 500; i++){
          cores.push(cores[i]);
        }

        //barra stack
        var gruposf = (dados.getAttribute('data-agrupadores').replace(/(\r\n|\n|\r)/g, " ")+'|'+dados.getAttribute('data-sec').replace(/(\r\n|\n|\r)/g, " ")).replace("<BR>", " ").split("|"),
            gruposr = dados.getAttribute('data-agrupadoresreal').replace("<BR>", " ").split("|"),
            gruposi = dados.getAttribute('data-visivel').replace("<BR>", " ").split("|"); // Colunas invisiveis/desabilitadas 
        gruposf = gruposf.filter(e => e);

        // usado para verificar se há valores repetidos na variavel ('gruposf').
        var temValoresRepetidos = gruposf.some(function (nome, index) {
          return gruposf.indexOf(nome) !== index; //true||false
        });

        if (temValoresRepetidos) {
          // Transforma o nome do rótulo iguais em únicos diretamente no array gruposf
          var conjuntoNomes = new Set();
          for (var i = 0; i < gruposf.length; i++) {
            var nome = gruposf[i];
            while (conjuntoNomes.has(nome)) {
              nome = nome + "_"+[i];
            }
            conjuntoNomes.add(nome);
            gruposf[i] = nome;
          }
        }
        var nome = '';
        if(agrupadores == -1 && sec.length == 0){
          nome = dados.getAttribute('data-agrupadores').replace("<BR>", " ");
        }

        // Monta a colunas selecionadas/desabilitadas da legenda (propriedade parametrizada por tela,objeto e usuário)
        //----------------------------------------------------------------------------------------
        let selectedCols = {},
            idx          = -1; 

        for (let i=0; i<gruposf.length; i++){
          idx = gruposi.findIndex(element => element == gruposr[i]); 
          if (idx != -1) { 
            selectedCols[gruposf[i]] = false; 
          } else { 
            selectedCols[gruposf[i]] = true; 
          }  
        }  

        
        // Monta arrays com as propriedades do eixo X do valores do gráfico - 20/01/2022 
        //----------------------------------------------------------------------------------------
        var arr_show_n = [],
            arr_show_v = [],
            arr_show   = [],
            arr_posi_n = [],
            arr_posi_v = [],
            arr_posi   = [],
            arr_maxi_n = [],
            arr_maxi_v = [],
            arr_maxi   = [],
            arr_inte_v = [],
            arr_inte_n = [],
            arr_inte   = [],
            arr_offs_n = [],
            arr_offs_v = [],
            arr_offs   = [],
            arr_type_n = [],
            arr_type_v = [],
            arr_type   = [],
            arr_sepo_n = [],
            arr_sepo_v = [],
            arr_sepo   = [],
            arr_eixo_n = [],
            arr_eixo_v = [],
            arr_eixo   = [],
            arr_sesi_n = [],
            arr_sesi_v = [],
            arr_sesi   = [],
            arr_umvl   = [],
            arr_umvl_n = [],
            arr_umvl_v = [];



        if (atributos.getAttribute('data-graf_axis_show_n') && atributos.getAttribute('data-graf_axis_show')) {
           arr_show_n = atributos.getAttribute('data-graf_axis_show_n').split("|");
           arr_show_v = atributos.getAttribute('data-graf_axis_show').split("|");
        }	            
        if ( atributos.getAttribute('data-graf_axis_position_n') && atributos.getAttribute('data-graf_axis_position')) {
          arr_posi_n = atributos.getAttribute('data-graf_axis_position_n').split("|");
          arr_posi_v = atributos.getAttribute('data-graf_axis_position').split("|");
        }     
        if (atributos.getAttribute('data-graf_axis_max_n') && atributos.getAttribute('data-graf_axis_max')) {   
          arr_maxi_n = atributos.getAttribute('data-graf_axis_max_n').split("|");
          arr_maxi_v = atributos.getAttribute('data-graf_axis_max').split("|");
        }
        if (atributos.getAttribute('data-graf_axis_intervalo_n') && atributos.getAttribute('data-graf_axis_intervalo'))  {
          arr_inte_n = atributos.getAttribute('data-graf_axis_intervalo_n').split("|");
          arr_inte_v = atributos.getAttribute('data-graf_axis_intervalo').split("|");
        }  
        if (atributos.getAttribute('data-graf_axis_offset_n') && atributos.getAttribute('data-graf_axis_offset'))  {
          arr_offs_n = atributos.getAttribute('data-graf_axis_offset_n').split("|");
          arr_offs_v = atributos.getAttribute('data-graf_axis_offset').split("|");
        }  
        if (atributos.getAttribute('data-graf_series_type_n') && atributos.getAttribute('data-graf_series_type'))  { 
          arr_type_n = atributos.getAttribute('data-graf_series_type_n').split("|");
          arr_type_v = atributos.getAttribute('data-graf_series_type').split("|");
        } 
        if (atributos.getAttribute('data-graf_series_label_pos_n') && atributos.getAttribute('data-graf_series_label_pos'))  { 
          arr_sepo_n = atributos.getAttribute('data-graf_series_label_pos_n').split("|");
          arr_sepo_v = atributos.getAttribute('data-graf_series_label_pos').split("|");
        } 
        if (atributos.getAttribute('data-graf_axis_nro_n') && atributos.getAttribute('data-graf_axis_nro'))  { 
          arr_eixo_n = atributos.getAttribute('data-graf_axis_nro_n').split("|");
          arr_eixo_v = atributos.getAttribute('data-graf_axis_nro').split("|");
        }
        if (atributos.getAttribute('data-graf_series_label_size_n') && atributos.getAttribute('data-graf_series_label_size'))  { 
          arr_sesi_n = atributos.getAttribute('data-graf_series_label_size_n').split("|");
          arr_sesi_v = atributos.getAttribute('data-graf_series_label_size').split("|");
        }  
        if (atributos.getAttribute('data-graf_axis_umvl_n') && atributos.getAttribute('data-graf_axis_umvl'))  { 
          arr_umvl_n = atributos.getAttribute('data-graf_axis_umvl_n').split("|");
          arr_umvl_v = atributos.getAttribute('data-graf_axis_umvl').split("|");
        }  


        for(let i=0;i<gruposr.length;i++){   
          var v_idx_show = arr_show_n.findIndex(element => element == gruposr[i] ),
        		  v_idx_posi = arr_posi_n.findIndex(element => element == gruposr[i] ),
		      	  v_idx_maxi = arr_maxi_n.findIndex(element => element == gruposr[i] ),
			        v_idx_inte = arr_inte_n.findIndex(element => element == gruposr[i] ),
			        v_idx_offs = arr_offs_n.findIndex(element => element == gruposr[i] ),
			        v_idx_type = arr_type_n.findIndex(element => element == gruposr[i] ),
              v_idx_sepo = arr_sepo_n.findIndex(element => element == gruposr[i] ),
              v_idx_eixo = arr_eixo_n.findIndex(element => element == gruposr[i] ),
              v_idx_sesi = arr_sesi_n.findIndex(element => element == gruposr[i] ),
              v_idx_umvl = arr_umvl_n.findIndex(element => element == gruposr[i] );

          if (v_idx_show != -1) {arr_show[i] = arr_show_v[v_idx_show]; } 
          if (v_idx_posi != -1) {arr_posi[i] = arr_posi_v[v_idx_posi]; } 
          if (v_idx_maxi != -1) {arr_maxi[i] = arr_maxi_v[v_idx_maxi]; } 
          if (v_idx_inte != -1) {arr_inte[i] = arr_inte_v[v_idx_inte]; } 
          if (v_idx_offs != -1) {arr_offs[i] = arr_offs_v[v_idx_offs]; } 
          if (v_idx_type != -1) {arr_type[i] = arr_type_v[v_idx_type]; } 
          if (v_idx_sepo != -1) {arr_sepo[i] = arr_sepo_v[v_idx_sepo]; } 
          if (v_idx_eixo != -1) {arr_eixo[i] = arr_eixo_v[v_idx_eixo]; }
          if (v_idx_sesi != -1) {arr_sesi[i] = arr_sesi_v[v_idx_sesi]; } 
          if (v_idx_umvl != -1) {arr_umvl[i] = arr_umvl_v[v_idx_umvl]; }    
       
        } 

        var arr_eixo_valor   = new Array;

        for(let i=0;i<gruposf.length;i++){   
          var veixo    = new Object; 

          if (arr_show[i] && arr_show[i].length > 0 )  { 
            if ( arr_show[i] == 'true' ) { 
              if (i == 0) { 
                veixo.axisLine  = { show: true, lineStyle: { color: cor_eixo_agrup }  } ;
                veixo.axisLabel = { interval: 0, textStyle: { fontSize: tam_fontSize } };
              } else { 
                veixo.axisLine  = { show: true, lineStyle: { color: cores[i] } } ;
                veixo.axisLabel = { interval: 0, textStyle: { fontSize: tam_fontSize } };
                veixo.name = gruposf[i]; 
                arr_eixo_valor[0].name = gruposf[0]; // Se mostra label do eixo 1,2,3, mostra também do eixo 0.
                if(tipo == 'bar' && formato == 'bar') {
                  arr_eixo_valor[0].nameLocation = xpos;
                  if (xpos == 'end') {
                    arr_eixo_valor[0].nameGap = 20; 
                  } else {
                    arr_eixo_valor[0].nameGap = 30; 
                  }        
                }   
              }   
            } else {
              veixo.axisLine  = { lineStyle: { color: cor_eixo_agrup } } ;
              veixo.axisLabel = { interval: 0, textStyle: { fontSize: tam_fontSize } };
            } 
          }else{
            veixo.axisLine  = { lineStyle: { color: cor_eixo_agrup } } ;
            veixo.axisLabel = { interval: 0, textStyle: { fontSize: tam_fontSize } };
          } 

          if (arr_posi[i] && arr_posi[i].length    != 0)  {veixo.position  = arr_posi[i]; }  
          if (arr_maxi[i] && parseInt(arr_maxi[i]) != 0)  {veixo.max       = arr_maxi[i] ; } 
          if (arr_inte[i] && parseInt(arr_inte[i]) != 0)  {veixo.interval  = parseInt(arr_inte[i]); } 
          if (arr_offs[i] && parseInt(arr_offs[i]) != 0)  {veixo.offset    = parseInt(arr_offs[i]); } 

                    
          if (showLineGrid == 'N'){
            veixo.splitLine = {show: false};
          }else{
            veixo.splitLine = {show: true};            
          }

          if(atributos.getAttribute('data-ymin').trim().length > 0){
            const reg_math = /(?:(?:^|[-+_*/])(?:\s*-?\d+(\.\d+)?(?:[eE][+-]?\d+)?\s*))+$/
            var ymin_data = atributos.getAttribute('data-ymin').trim();
            if (ymin_data.startsWith('dataMin') && reg_math.test(ymin_data.substring(7))) {
              veixo.min = (function(value){
                return eval(value.min+ymin_data.substring(7))
              });
            } else {
              veixo.min = atributos.getAttribute('data-ymin');
            }
          }


          arr_eixo_valor.push(veixo); 
          
        }  

        // Sem somente um valor/agrupador, coloca o label desse valor no primeiro eixo
        if (gruposf.length == 1) {
          arr_eixo_valor[0].name = gruposf[0]; 
          if(tipo == 'bar' && formato == 'bar') {
            arr_eixo_valor[0].nameLocation = xpos; 
            if (xpos == 'end') {
              arr_eixo_valor[0].nameGap = 20; 
            } else {
              arr_eixo_valor[0].nameGap = 30; 
            }  
          }
        } 
        
        //aqui começa a definir os eixos, inverte dependendo do tipo
        var arr_yaxis = new Array;
        var arr_xaxis = new Array;
        var yaxis = new Object;
        var xaxis = new Object;

        if(atributos.getAttribute('data-ymin').trim().length > 0){
          const reg_math = /(?:(?:^|[-+_*/])(?:\s*-?\d+(\.\d+)?(?:[eE][+-]?\d+)?\s*))+$/
          var ymin_data = atributos.getAttribute('data-ymin').trim();
          if (ymin_data.startsWith('dataMin') && reg_math.test(ymin_data.substring(7))) {
            yaxis.min = (function(value){
              return eval(value.min+ymin_data.substring(7))
            });
          } else {
            yaxis.min = atributos.getAttribute('data-ymin');
          }
        }

        // Alterado para utilizar novo atributo <CONTEUDO LABEL> - 17/01/2022 
        var desc_valor;
        if (!(label_conteudo) || label_conteudo == '' || label_conteudo == 'D') {
          desc_valor = categorias; 
        } else if (label_conteudo == 'C') {
          desc_valor = codigos;  
        } else { 
          desc_valor = codi_cate;
        } 

        // Alterado para permitir propriedades diferentes para cada coluna/valor - 10/01/2022 
        // -------------------------------------------------------------------------------------
        if(tipo == 'bar' && formato == 'bar'){
          yaxis.type         = 'category';
          yaxis.name         = coluna;
          yaxis.nameLocation = 'end';
          yaxis.nameGap      = 20;
          // if (xpos == 'end') { 
          //  yaxis.nameGap      = 20;
          //} else { 
          //  yaxis.nameGap      = 50;
          //} ;
          yaxis.axisLabel    = { interval: 0, rotate: rotacao, textStyle: { fontSize: tam_fontSize } };
          yaxis.axisLine     =  {lineStyle:{color:cor_eixo_agrup}};
          yaxis.data         = desc_valor;

          arr_yaxis.push(yaxis);
          arr_xaxis = arr_eixo_valor;
        } else {
          xaxis.type         = 'category';
          xaxis.name         = coluna;
          xaxis.nameLocation = xpos;
          if (xpos == 'end') { 
            xaxis.nameGap      = 20;
          } else { 
            xaxis.nameGap      = 35;
          } ;

          xaxis.axisLabel    = { interval: 0, rotate: rotacao, textStyle: { fontSize: tam_fontSize }/*, formatter: function(v) { return v.replace('/', '/ ').replace(' ', '\n'); }*/ };  //comentado por bug onde gerava uma quebra de linha na data ... cod #1//
          xaxis.axisLine     =  {lineStyle:{color:cor_eixo_agrup}};
          xaxis.data         = desc_valor;
          
          arr_xaxis.push(xaxis);          
          arr_yaxis = arr_eixo_valor;
          
        }
      
        // Define o Grid/margens do grafico
        //-----------------------------------------------------------------------------
        var arrgrid;
        if (grafico_pivot) { 
          arrgrid = [40, 80, 40, 60];
        } else if(parseInt(rotacao) > 80) {
          arrgrid = [30, 80, 120, 80];
        } else {
          if(parseInt(rotacao) > 40) {
            arrgrid = [30, 80, 80, 80];
          } else {
            arrgrid = [30, 80, 40, 80];
          }
        }
      
        var labelsplit = labelspace.split("|");
        if(labelspace.length > 0 && labelsplit.length < 5){
          for(let i=0;i<labelsplit.length;i++){
            if(i == 2 && activeZoom == true){
              arrgrid[i] = parseInt(labelsplit[i])+50;
            } else {
              arrgrid[i] = labelsplit[i];
            }
          }
        }
        

        // comentado para não somar mais mas margens, as margens devem ser alteradas direto nas propriedades do objeto 
        //arrgrid[1] = parseInt(arrgrid[1]) + vgrid_soma_right; 
        //arrgrid[3] = parseInt(arrgrid[3]) + vgrid_soma_left; 

        // Monta array com as propriedades das series referente aos valores  (20/01/2022) 
        // ---------------------------------------------------------------------- 
        var arr_serie_prop  = new Array;
        
        for(let i=0;i<gruposf.length;i++){   
          
          var vserie    = new Object; 
          if (arr_type[i] && arr_type[i].length != 0)  {
            vserie.type       = arr_type[i] ;
          }
          else { 
            
            vserie.type   = formato; 
            if (formato == 'column') { 
               vserie.type   = 'bar';        
            }     
          }

          // Define a qual eixo a coluna deve fazer referencia, se a coluna existiver parametrizada para mostrar o eixo, ela deve ter seu próprio eixo  
          if (i > 0 && arr_show[i] && arr_show[i] == 'true')  { 
            vserie.AxisIndex = i ; 
          } else if (arr_eixo[i] && parseInt(arr_eixo[i]) > 0 && parseInt(arr_eixo[i]) <= gruposf.length ) { 
            vserie.AxisIndex = parseInt(arr_eixo[i] - 1) ;  // Diminui 1 porque os eixos do gráfico começam com 0
          }
          
          vserie.label = { position:         ((arr_sepo[i] && arr_sepo[i].length != 0) ? arr_sepo[i]: posicao), 
                           fontSize:         ((arr_sesi[i] && arr_sesi[i].length != 0) ? arr_sesi[i] :tam_fontSize),
                           unidadeMedida:    ((arr_umvl[i] && arr_umvl[i].length != 0) ? arr_umvl[i] :''),
                           
                         }; 
                        
          //if (arr_sesi[i] && arr_sesi[i].length != 0)         { vserie.label = { fontSize: arr_sesi[i] } ; }  

          arr_serie_prop.push(vserie); 
        } 



        var arr = [stack, mostrar, formato, decimal, cores, ccoluna_hex, sec, atributos.getAttribute('data-cascata'), destaque, corLinha, abreviacao, posicao, meta, meta_cor, markMax, markMin, markMedia, cor, um, arr_serie_prop, label_conteudo,tam_fontSize,arr_umvl, agrupar_valor];
          
        if (decimal.includes('|')) {
          decimal = decimal.split('|')[0];
        }
        
        // Monta a legenda para casos de gráfico com 2 agrupadores (pivotado)
        if (grafico_pivot) {
          legenda = arr_pivot.map(function(item) {
            return item.ds;
          });
        } else {
          var legenda = false;
        }


        var tooltipFormatter = function(param) {
                          
          var arrtip = []; 
          var total = 0;
          
          if ( grafico_pivot) {
            arrtip.push(param.name);
            arrtip.push(labelTooltip(param.seriesName, {value: param.value}, decimal, abreviacao, 'N', 0, 'S', um) );
          } else if (agrupar_valor == 'S') {

            arrtip.push(param[0].name);
            for (let i = 0; i < valores.length; i++) {
              for (let j = 0; j < valores[i].length; j++) {
                if(parseInt(param[0].data) == parseInt(valores[i][0].valor)) {
                  var obj = {value: valores[i][j].valor};
                  var num = labelTooltip('', obj, decimal, abreviacao, 'N', 0, 'N');
                  arrtip.push(valores[i][j].grupo + ': ' + num.toLocaleString(undefined,{ minimumFractionDigits: parseInt(decimal) }))
                }
              }
            }
            
          } else {

            if(param.length > 1){
              arrtip.push(param[0].name);
              for(let i=0;i<param.length;i++){  
                if (param[i].data == 0 || param[i].value == 0) {
                  arrtip.push(param[i].seriesName+": " + '0');
                } else {
                  arrtip.push(param[i].seriesName+": " + labelTooltip(param[i].name, param[i], decimal, abreviacao, 'N', 0, 'N', um));
                  total = total+parseFloat(param[i].value);
                }                    }
              if(stack_total.length > 0){
                arrtip.push(stack_total+": "+Number(total).toLocaleString(undefined,{ minimumFractionDigits: parseInt(decimal) }));
                //arrtip.push(stack_total+": "+Number(parseFloat(total).toFixed(decimal)).toLocaleString());
              }
            } else { 
              if(param[0]){
                //arrtip.push(param[0].name+": "+Number(param[0].data).toLocaleString(undefined, { minimumFractionDigits: parseInt(decimal) }));
                arrtip.push(param[0].name+": " + labelTooltip(param[0].name, param[0], decimal, abreviacao, 'N', 0, 'N', um));
              }
            }

          }

          arrtip = '<span style="text-align: left; display: block;">' + arrtip.join("<br>") + '</span>';

          return arrtip;
        }
        



        var option = {
          dataZoom : { 
            show: activeZoom, 
            bottom: '6px', 
            handleIcon: 'path://M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z' 
            //handleIcon: '<svg enable-background="new 0 0 24 24" height="512" viewBox="0 0 24 24" width="512" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="3"/><path d="m23.629 11.214-5-4c-.027-.022-.057-.042-.086-.06-.687-.406-1.543.105-1.543.846v8c0 .551.449 1 1 1 .189 0 .367-.05.542-.154.03-.018.059-.038.086-.06l5.064-4.058c.199-.2.308-.458.308-.728s-.109-.528-.371-.786z"/><path d="m5.458 7.154c-.03.018-.059.038-.086.06l-5.064 4.058c-.199.2-.308.458-.308.728s.109.528.371.786l5 4c.027.022.057.042.086.06.176.104.354.154.543.154.551 0 1-.449 1-1v-8c0-.741-.855-1.253-1.542-.846z"/></svg>'
          },
          textStyle:{
            fontFamily:font_family,
            fontWeight:font_weigth
          },
          grid: { 
            y: arrgrid[0], 
            x2: arrgrid[1], 
            y2: arrgrid[2], 
            x: arrgrid[3] 
          },
          color: cores,
          tooltip : {
                trigger: (grafico_pivot ? 'item': 'axis'),
                //confine: true,
                //showDelay: 100,
                //hideDelay: 0,
                //alwaysShowContent: false,
                formatter: tooltipFormatter,
                axisPointer: {
                  type: cursor
                }
          },
          legend: {
            data: legenda  ? legenda : gruposf,
            selected: selectedCols,
            textStyle: {
             color: corTextoLegenda
            }
          },
          noDataLoadingOption: { text: "inválido", effect: 7 },
          xAxis : arr_xaxis,  // [xaxis],
          yAxis : arr_yaxis,  // [yaxis],
          bottom: 10,
          series: stackLista(valores, agrupadores, gruposf, formato, codigos, ccoluna, coluna, desc_valor, arr, x),
          label: {rotate: vrotate ,
                    distance:vdistance,
                    verticalAlign:'middle'
                   }//possibilidade de transformar esse vertical align em uma variavel na padrões?
                   
        };

      if(document.getElementById(x+'more')){
      
        var a = document.createElement('a');
        a.classList.add('download_button');
        
        if(document.getElementById(x.split('trl')[0]+'_ds')){
          a.setAttribute('download', document.getElementById(x.split('trl')[0]+'_ds').innerText.replace(/ /g, "_").toLowerCase());
        } else {
          a.setAttribute('download', document.getElementById(x+'_ds').innerText.replace(/ /g, "_").toLowerCase());
        }

        // Geração do PNG (com título) - Aguarda 5 segundos para garantir que o gráfico já tenha sido montado 
        //---------------------------------------------------------------
        setTimeout(function(){

          // Adiciona um título para sair no PNG 
          option.title = {
              text: document.getElementById(x+'_ds').innerText,
              left: 'center',
              top: 0
          };
          option.grid.y            = parseInt(arrgrid[0]) + 25 ;  // Aumenta a margem superior para caber o título 
          option.legend.top        = 25;                          // Desce a legenda para caber o título 
          for(let a=0; a < option.series.length; a++){            // Retira a aminação das colunas para o redimensionamento do gráfico não seja captado pela geração do PNG       
            option.series[a].animation = false; 
          }  
          myChart.setOption(option, { notMerge: true }); 

          // Gera o PNG 
          a.href = myChart.getDataURL({
              type: 'png',
              pixelRatio: 1,
              backgroundColor: '#fff'
          });

          // Retira o título, volta os parâmetros(visual) original do gráfico 
          option.title      = {}; 
          option.grid.y     = arrgrid[0];
          option.legend.top = 0;
          myChart.setOption(option, { notMerge: true });   // Atualiza o gráfico sem o título         
          for(let a=0; a < option.series.length; a++){     // Recoloca a animação das colunas 
            option.series[a].animation = chartAnimation; 
          } 
          myChart.setOption(option, { notMerge: true }); 


        }, 1500);
        
        if(document.getElementById(x+'more')){
          document.getElementById(x+'more').querySelector('.page_png').appendChild(a);
        }
      }
      myChart.setOption(option, { notMerge: true });
      myChart.on('click', clicker);
      myChart.on('legendselectchanged', clickerLegend);
      
      }

    }

    document.getElementById('ctnr_'+x).style.setProperty('max-width', '100%');
    //document.getElementById('ctnr_'+x).style.setProperty('max-height', '100%');


  }

  } else {
    document.getElementById('ctnr_'+x).innerHTML = document.getElementById(x+'_ERR').innerHTML;
  }

  //});

}

function get_agrupador_pivot(x) {
  let arr_aux = [];
  if (document.getElementById(x+'-agrupador_pivot')) {
    arr_aux = document.getElementById(x+'-agrupador_pivot').innerHTML.split('|').map(function(item) {
      let obj = new Object,
          ar  = item.split('#$DIV$#');
      obj.cd = ar[0].trim();
      obj.ds = (ar.length >= 1 ? ar[1].trim() : ar[0].trim());
      return obj;
    });
  }
  return arr_aux; 
}
async function clickerLegend(e){ 
  let invisiveis = '',
  idx            = 0; 
  let objid      = this._dom.id.replace('ctnr_',''); 
  let dados      = document.getElementById('dados_'+objid);
  let gruposr    = dados.getAttribute('data-agrupadoresreal').replace("<BR>", " ").split("|");
  
  for (const [key, value] of Object.entries(e.selected)) {
    if (value == false) { 
      invisiveis = invisiveis + '|' + gruposr[idx]; // usa o nome real da coluna  
    }  
    idx = idx + 1; 
  }
  // Atualiza o atributo VISIVEL do usuário/objeto/tela 
  let resposta = await call('alter_agrupadores','prm_objeto='+objid+'&prm_agrupadores='+invisiveis+'&prm_tipo=VISIVEL&prm_screen='+tela);
  

  if (resposta.split('|')[0] == 'OK'){
    alerta('feed-fixo','Atributo alterado com sucesso'); 
  }else{
    alerta('feed-fixo',resposta.split('|')[1]);
  }
}


function clicker(e){ 

  if(!isNaN(e.value) || (e.seriesType && (e.seriesType.toLowerCase() == 'scatter' || e.seriesType.toLowerCase() == 'heatmap')) || (e.seriesType && e.seriesType.toLowerCase() == 'radar') ){
    setTimeout(function(){

      var dados = document.getElementById('dados_'+objatual);
      var gxml = document.getElementById('gxml_'+objatual);
      var atributos = document.getElementById('atributos_'+objatual);
      var cod;
      var drill = '';
      var parametros = '';
      
      if (e.seriesType && e.seriesType.toLowerCase() == 'radar') {
        drill = dados.getAttribute('data-drill');
        if (e.data.col.length > 0) {
          parametros = e.data.col+ '|' + e.data.cod;
        }  
      } else if (e.seriesType && e.seriesType.toLowerCase() == 'scatter') {
        drill = dados.getAttribute('data-drill');
        parametros = e.data[7]+ '|' + e.data[3];
        if (e.data[8].length > 0) {
          parametros = parametros + '|' + e.data[8]+ '|' + e.data[5];
        }
      } else if (e.seriesType && e.seriesType.toLowerCase() == 'sankey') {

        if (e.dataType.toLowerCase() == 'edge') {
          drill = dados.getAttribute('data-drill');
          var origem  = e.name.split(' > ')[0].trim(),
              destino = e.name.split(' > ')[1].trim();
          parametros = origem.split('|')[0]+ '|' + origem.split('|')[1] + '|' + destino.split('|')[0]+ '|' + destino.split('|')[1];
        }   

      } else {

        var parametrosComPivot = '';
        var grafico_pivot = false;
        var arr_pivot     = [];

        if (document.getElementById(gxml.id.replace('gxml_','') + '-agrupador_pivot') ) { 
          grafico_pivot = true;
          arr_pivot    = get_agrupador_pivot(gxml.id.replace('gxml_','')); 
        }

        if(e.data.sigla){
          cod = e.data.sigla;
        } else {

          
          var jsonLista = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");

          if (e.seriesType && e.seriesType.toLowerCase() == 'heatmap') {
            jsonLista = jsonLista.replace(',]', ']');
            var jsonParsed = JSON.parse(jsonLista);
            var codigos = [];

            for(let linha in jsonParsed){

              let dateString = jsonParsed[linha].date;
              let parts = dateString.split("-");
              let formattedDate = `${parts[2]}/${parts[1]}/${parts[0]}`;

              codigos.push(formattedDate);
            }

          } else {
            jsonLista = jsonLista.substring(0, jsonLista.trim().length-1);
            var jsonParsed = JSON.parse("{"+jsonLista+"}");
            var codigos = [];

            for(let linha in jsonParsed){
              codigos.push(jsonParsed[linha].cod);
            }

            if (atributos.getAttribute('data-inverte_ordem') && atributos.getAttribute('data-inverte_ordem') == 'S'){
              codigos.reverse();
            }

          }

          cod = codigos[e.dataIndex];

          // Quando o click é no marcador max/min e só tem grupo no gráfico, o e.dataIndex vem como 1, corrigido para 0 para não gerar erro na drill 
          if (codigos.length == 1 && e.dataIndex == 1 ) { 
            cod = codigos[0];
          }

          if (grafico_pivot) { 
            let cod2 = arr_pivot[e.seriesIndex].cd;
            temparr = dados.getAttribute('data-colunareal').split('|');
            parametrosComPivot = temparr[0] + '|' + cod + '|' +  temparr[1] + '|' + cod2 + '|' + dados.getAttribute('data-filtro');
          }
        }

        if (e.seriesType && e.seriesType.toLowerCase() == 'heatmap') {
          var [day, month, year] = cod.split('/');
          var date = new Date(`${month}/${day}/${year}`);
          var monthAbbreviation = date.toLocaleString('en-US', { month: 'short' }).toUpperCase();
          var yearLastTwoDigits = year.slice(-2);
          cod = `${day}-${monthAbbreviation}-${yearLastTwoDigits}`;
        }
        
        if (grafico_pivot) {
          parametros = parametrosComPivot;
        } else {
          parametros = dados.getAttribute('data-colunareal')+'|'+cod+'|'+dados.getAttribute('data-filtro');
        }

        parametros = parametros.replace('||', '|');
        drill      = dados.getAttribute('data-drill');

        if(parametros.indexOf('ACUMULADO') != -1){  

            let codigos = [];
            let jsonParsed = JSON.parse('{'+document.getElementById('gxml_'+objatual).children[0].innerText.substr(0, document.getElementById('gxml_'+objatual).children[0].innerText.trim().length-1)+'}');
            for(let linha in jsonParsed){
              if(jsonParsed[linha].cod != 'ACUMULADO'){
                codigos.push(jsonParsed[linha].cod);
              }
            }
            
            var arr_valores = [];
            let coluna_real = dados.getAttribute('data-colunareal');
            codigos.forEach(function(a){
              arr_valores.push(coluna_real+'|$[DIFERENTE]'+a);
            });
            parametros = arr_valores.join('|');
        }
      } 

      if(drill.indexOf('MULTI') == -1){ 
        if(drill > 0){
          get('drill_go').value = parametros;
          drillfix(e, objatual, parametros); 
        }
      } else {
        if(drill.length > 0){
          remover(drill+'trl');
          loading();
          ajax('append', 'show_objeto', 'prm_drill=Y&prm_objeto='+drill+'&prm_posx='+cursorx+'px&prm_zindex='+zindex_abs+'&prm_posy='+cursory+'px&prm_parametros='+encodeURIComponent(parametros.replace(/%2D/g, '-').replace(/%2B/g, '+'))+'&prm_screen='+tela+'&prm_track='+drill+'&prm_objeton=', true, 'main', '', drill.split('trl')[0]+'trl', 'obj');
        }

      }
    }, 100);
  }
}

/* monta um case das condições do destaque */ 
function efeitoCondicoes(destaque, colunas, valor, def, nome, cod, vlCategoria, codCategoria,dataIndex,valores){ /*destaqueAtux: array com coluna e valor*/

  //teste para ver se a variável é um array (barras,colunas...) ou normal (pizza)
  if (Array.isArray(codCategoria)) {
    for (let i = 0; i < codCategoria.length; i++) {
      codCategoria[i] = codCategoria[i].replace(/\s/g, ''); 
    }
  } else {
    codCategoria = codCategoria.replace(/\s/g, ''); 
  }

  for(let d in destaque){

    let listadest = valores;
    
    let valordest= '';

    if (listadest !== undefined) {
      for (let i = 0; i < listadest.length; i++) {
          
          for (let j = 0; j < listadest[i].length; j++) { 
              // Remoção dos espaços em branco e quebras de linha para garantir que ambos valores estejam iguais.
              listadest[i][j].grupo = listadest[i][j].grupo.replace(/\s/g, ''); 
              destaque[d].valor     = destaque[d].valor.replace(/\s/g, '');     
              if (listadest[i][j].grupo === destaque[d].valor.replace('AUX=', '') && i === dataIndex) {
                  valordest = listadest[i][j].valor.replace('AUX=', '');
              }
          }
      }
    }
  
    if (valordest === '' || valordest === undefined) {
      valordest = destaque[d].valor.replace('AUX=', '');
    }

    let colunaDestaque = destaque[d].coluna.replace(/\s/g, ''); // Remove os espaços do nome da coluna
    let colunaComparativa = colunas.map(coluna => coluna.replace(/\s/g, '')); // Remove espaços dos nomes das colunas
    let colunaCategoria = cod.replace(/\s/g, ''); // Remove espaços do nome da categoria

    //compara com a coluna
    if (colunaComparativa.includes(colunaDestaque)) {
      let valorComparativo;
      //if(isNaN(parseInt(destaque[d].valor, 1))){
      if(isNaN(parseInt(valordest, 1))){
        //valorComparativo = destaque[d].valor;
        valorComparativo = valordest;
      } else {
        //valorComparativo = parseFloat(destaque[d].valor);
        valorComparativo = parseFloat(valordest);
      }

      //let valor = parseFloat(valor);

      function encontrarPosicao(valor, valorComparativo) {
        let valorStr = valor.toString();
        let valorComparativoStr = valorComparativo.toString();
        let posicao;
        // Qdo gráfico de pizza não consegue identificar o destaque do agrupador... comparado o codCategoria com a coluna do destaque para receber o nome na posicao.
        if (codCategoria.includes(colunaDestaque)){
          posicao = nome.indexOf(valorComparativoStr);
        } else {
          posicao = valorStr.indexOf(valorComparativoStr);
        }

        return posicao;
      }
      let posicao = encontrarPosicao(valor, valorComparativo);
      
      switch(destaque[d].condicao){

        case 'IGUAL':
          //REMOVIDO o "|| nome.indexOf(valorComparativo)!= -1" . Quando o valor era igual a zero o indexOf quando encontrado a posição do valorComparativo no nome(agrupador) aplicava o destaque... 
          //Não faz sentido essa condição para coluna de valor, apenas para agrupador que ja é tratado no próximo case. 
          if(valorComparativo == valor ){
            return destaque[d].cor;
          }
        break;

        case 'MAIOR':
          if(valor > valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'MENOR':
          if(valor < valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'DIFERENTE': 
          if(valor != valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'MAIOROUIGUAL': 
          if(valor >= valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'MENOROUIGUAL': 
          if(valor <= valorComparativo){
            return destaque[d].cor;
          }
        break;
        
        case 'LIKE':
          if(posicao!= -1 ){
            return destaque[d].cor;
          }
        break;
        
        case 'NOTLIKE':

          if(posicao == -1 ){
            return destaque[d].cor;
          }
        break;

        case 'COLUNA': 
          return destaque[d].cor;
        break;
      }

    }

    //compara com a categoria cod, vlCategoria
    if (colunaCategoria.includes(colunaDestaque) || codCategoria.includes(colunaDestaque)) {
      let valorComparativo;
      
      //if(isNaN(parseInt(destaque[d].valor, 1))){
      if(isNaN(parseInt(valordest, 1))){
        //valorComparativo = destaque[d].valor;
        valorComparativo = valordest;
      } else {
        //valorComparativo = parseFloat(destaque[d].valor);
        valorComparativo = parseFloat(valordest);
      }

      let valor = vlCategoria;

      function encontrarPosicao(valor, valorComparativo) {
        let valorStr = valor.toString();
        let valorComparativoStr = valorComparativo.toString();
        let posicao;
        // Qdo gráfico de pizza não consegue identificar o destaque do agrupador... comparado o codCategoria com a coluna do destaque para receber o nome na posicao.
        if (codCategoria.includes(colunaDestaque)){
          posicao = nome.indexOf(valorComparativoStr);
        } else {
          posicao = valorStr.indexOf(valorComparativoStr);
        }

        return posicao;
      }
      let posicao = encontrarPosicao(valor, valorComparativo);

      function tratarDatas(valor, mascara){
        if (mascara===undefined){
          return 'NOMASC'
        }
        var dest_mascara = ''
        if(mascara.indexOf('YYYY')!==-1 && mascara.indexOf('YYYY')<valor.length){
          dest_mascara += valor.substring(mascara.indexOf('YYYY'),mascara.indexOf('YYYY')+4)
        } else if(mascara.indexOf('YY')!==-1 && mascara.indexOf('YY')<valor.length){
          dest_mascara += '20'+valor.substring(mascara.indexOf('YY'),mascara.indexOf('YY')+2)
        } else if(mascara.indexOf('RRRR')!==-1 && mascara.indexOf('RRRR')<valor.length){
          dest_mascara += valor.substring(mascara.indexOf('RRRR'),mascara.indexOf('RRRR')+4)
        } else if(mascara.indexOf('RR')!==-1 && mascara.indexOf('RR')<valor.length){
          dest_mascara += '20'+valor.substring(mascara.indexOf('RR'),mascara.indexOf('RR')+2)
        }
        if(mascara.indexOf('MON')!==-1 && mascara.indexOf('MON')<valor.length){
          if(dest_mascara.length>0){dest_mascara+='-'}
          dest_mascara += valor.substring(mascara.indexOf('MON'),mascara.indexOf('MON')+3)
        } else if(mascara.indexOf('MM')!==-1 && mascara.indexOf('MM')<valor.length){
          if(dest_mascara.length>0){dest_mascara+='-'}
          dest_mascara += valor.substring(mascara.indexOf('MM'),mascara.indexOf('MM')+2)
        }
        if(mascara.indexOf('DD')!==-1 && mascara.indexOf('DD')<valor.length){
          if(dest_mascara.length>0){dest_mascara+='-'}
          dest_mascara += valor.substring(mascara.indexOf('DD'),mascara.indexOf('DD')+2)
        }
        var extra = 0;
        if(mascara.indexOf('HH24')!==-1 && mascara.indexOf('HH24')<valor.length){
          if(dest_mascara.length>0){dest_mascara+=' '}
          extra = 2;
          dest_mascara += valor.substring(mascara.indexOf('HH24'),mascara.indexOf('HH24')+2)
        } else if(mascara.indexOf('HH')!==-1 && mascara.indexOf('HH')<valor.length){
          if(dest_mascara.length>0){dest_mascara+=' '}
          dest_mascara += valor.substring(mascara.indexOf('HH'),mascara.indexOf('HH')+2)
        }
        if(mascara.indexOf('MI')!==-1 && mascara.indexOf('MI')-extra<valor.length){
          if(dest_mascara.length>0){dest_mascara+=':'}
          dest_mascara += valor.substring(mascara.indexOf('MI')-extra,mascara.indexOf('MI')+2-extra)
        }
        if(mascara.indexOf('SS')!==-1 && mascara.indexOf('SS')-extra<valor.length){
          if(dest_mascara.length>0){dest_mascara+=':'}
          dest_mascara += valor.substring(mascara.indexOf('SS')-extra,mascara.indexOf('SS')+2-extra)
        }
        return Date.parse(dest_mascara)
      }
      
      if(destaque[d].tipo === 'DATE'){
        valor = tratarDatas(valor.replace(/\s/g, ''), destaque[d].mascara.replace(/\s/g, ''));
        valorComparativo = tratarDatas(valorComparativo.replace(/\s/g, ''), destaque[d].mascara.replace(/\s/g, ''))
      }
      switch(destaque[d].condicao){
      
        case 'IGUAL':
          
          if(valorComparativo == valor ){
            return destaque[d].cor;
          }
        break;

        case 'MAIOR': 
          if(valor > valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'MENOR':
          if(valor < valorComparativo){
            
            return destaque[d].cor;
          }
        break;

        case 'DIFERENTE': 
          if(valor != valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'MAIOROUIGUAL': 
          if(valor >= valorComparativo){
            return destaque[d].cor;
          }
        break;

        case 'MENOROUIGUAL': 
          if(valor <= valorComparativo){
            return destaque[d].cor;
          }
        break;
        
        case 'LIKE':
          if(posicao != -1 ){
            return destaque[d].cor;
          }
        break;
       
        case 'NOTLIKE':
          if(posicao == -1 || nome.indexOf(valorComparativo)== -1 ){
            return destaque[d].cor;
          }
        break;

        case 'COLUNA': 
          return destaque[d].cor;
        break;
      }
    }
       
  }

  return def;
}

function stackLista(valores, agrupadores, grupos, formato, codigos, ccoluna, coluna, categorias, arr, x){
  //stack, mostrar, formato, decimal, cores, ccoluna_hex, sec, atributos.getAttribute('data-cascata'), destaque, corLinha, abreviacao
  var stack = arr[0], 
  mostrar = arr[1], 
  formato = arr[2], 
  decimal = arr[3],
  cores = arr[4], 
  ccoluna_hex = arr[5], 
  sec = arr[6], 
  cascata = arr[7],
  destaque = arr[8], 
  corLinha = arr[9], 
  abreviacao = arr[10],
  posicao = arr[11] 
  meta = arr[12],
  meta_cor  = arr[13],
  markMax   = arr[14],
  markMin   = arr[15],
  markMedia = arr[16],
  cor       = arr[17],
  um        = arr[18];
  arr_serie_prop = arr[19];
  label_conteudo = arr[20];
  tam_fontSize   = arr[21];
  umvl           = arr[22];

  mostrar = mostrar.replace(/(\r\n|\n|\r)/g, " ")+'|';

  var grafico_pivot = false,
      arr_pivot     = [];
  if (document.getElementById(x+'-agrupador_pivot')) {
    grafico_pivot = true;
    arr_pivot     = get_agrupador_pivot(x); 
  } 


  //stack = stack.replace("<BR>", " ");
  var position;
  var fontSize;
  var unidadeColuna= [];
  
  if (decimal.includes('|')) {
    decimal = decimal.split('|')[0];
  }

  if(formato == "line"){
    position = "top";
  } else {
    if(formato != 'column'){
      position = posicao || "inside";
    } else {
      if(stack == "S"){
        position = "inside";
      } else {
        position = posicao || "top";
      }
    }
  }
  fontSize = tam_fontSize || "12";


  // Se foi informado o atributo e posição, assumi o valor informado 
  if (arr_serie_prop[0].label && arr_serie_prop[0].label.position && arr_serie_prop[0].label.position.length != 0)  {
    position = arr_serie_prop[0].label.position ;
  } 
  if (arr_serie_prop[0].label && arr_serie_prop[0].label.fontSize && arr_serie_prop[0].label.fontSize.length != 0)  {
    fontSize = arr_serie_prop[0].label.fontSize ;
  }

  if (arr_serie_prop[0].label.unidadeMedida.length>1){

    for(i=0;i<arr_serie_prop.length;i++){
        unidadeColuna.push(arr_serie_prop[i].label.unidadeMedida);
    }

  }

  var normalLabel = function(mostrar, position, abreviacao, formato, agrupadores, sec,fontSize){
    let obj   = {};
    obj.label = {};
  

    if(formato != "line" && grafico_pivot == false ){
      
      if(agrupadores == -1 && sec.length == 0 ) {   
        obj.color = function(params) {
          var colorList = cores[params.dataIndex];
          let valor = parseFloat(params.data);
          let nome = [];
          nome.push(params.name);
          nome.push(codigos[params.dataIndex]);
          let colunas = [];
          colunas.push(...grupos);
          colunas.push(coluna);
          colorList = efeitoCondicoes(destaque, colunas, valor, colorList, nome, coluna, categorias[params.dataIndex], codigos);
          return colorList;
        }
      } else {
        obj.color = function(params) {
          let colorList = cores[params.dataIndex];
          let grupo = [params.seriesName];
          let valor = parseFloat(params.data);
          let nome  = params.name;  

          colorList = efeitoCondicoes(destaque, grupo, valor, cores[params.seriesIndex], nome, coluna, categorias[params.dataIndex], codigos,params.dataIndex,valores);
          return colorList;   
        }
      }
    }

    obj.barBorderColor = '#333';
    obj.barBorderWidth = 1;

    obj.label.formatter = function(params){
      // Necessário buscar o atributo do objeto novamente, porque esse evento é executado em momento que as variáveis já foram alteradas 
      let atrib   = document.getElementById('atributos_'+x);
      let unidmed;
      let agrupar_valor1 = arr[23] == 'S' && valores.length > 0 && Array.isArray(valores[0]);

      // comentado para mostrar a unidade de medida mesmo quando o valor for 0
      // if (params.data == 0 || params.value == 0) {
      //   return '0';
      // }

      if (unidadeColuna.length > 1){
        unidmed = unidadeColuna; 

        var resultado = []; // array auxiliar
        for (var i = 0; i < unidmed.length; i++) {
          um = unidmed[i]; 
          resultado.push(labelTooltip(params.name, params, decimal, abreviacao, 'N', 0, 'N', um,'')); // adiciona o valor ao array auxiliar
        };
        return labelTooltip(params.name, params, decimal, abreviacao, 'N', 0, 'N', unidmed[params.seriesIndex],'');
      }else{

        unidmed = atrib.getAttribute('data-um');

        if (agrupar_valor1 && grafico_pivot == false) {

          var partsDecimal = [];
          if (arr[3].includes('|')) {
            partsDecimal = arr[3].split('|');
          } else {
            partsDecimal[0] = decimal;
            partsDecimal[1] = decimal;
          }

          for (let i = 0; i < valores.length; i++) {
            for (let j = 0; j < valores[i].length; j ++) {
              if (parseInt(params.data.replace(',', '')).toString().slice(0, -1) == parseInt(valores[i][j].valor).toString().slice(0,-1)) {
                var val = valores[i][1].valor;
                break;
              }
            }
          }

          var value = {
            value: val
          }
          
          var partsUnidmed = [];
          if (unidmed.includes('|')) {
            partsUnidmed = unidmed.split('|');
          } else {
            partsUnidmed[0] = unidmed;
            partsUnidmed[1] = unidmed;
          }

          if (val != null) {
            return (labelTooltip(params.name, params, partsDecimal[0], abreviacao, 'N', 0, 'N', partsUnidmed[0])) + ' / ' + labelTooltip(val, value, partsDecimal[1], abreviacao, 'N', 0, 'N', partsUnidmed[1]);
          } else {
           return labelTooltip(params.name, params, decimal, abreviacao, 'N', 0, 'N', unidmed,'');
          }
      
        } else {

         return labelTooltip(params.name, params, decimal, abreviacao, 'N', 0, 'N', unidmed);
        
        }
      }  
    } 

    obj.label.show = mostrar; 
    obj.label.position = position; 
    obj.label.textStyle = { color: cor, fontWeight: 'bold',fontSize:fontSize };
    return obj;
  }


  var emphasisLabel = function(mostrar, position){
    let obj   = {}; 
    obj.label = {}; 
    obj.label.show = mostrar; 
    obj.label.position = position; 
    obj.label.textStyle = { color: cor, fontWeight: 'bold' }; 
    return obj;
  }
  let agrupar_valor = arr[23] == 'S' && valores.length > 0 && Array.isArray(valores[0]);



  // Grafico com 2 agrupadores (pivotado) - monta as serie com os dados 
  if (grafico_pivot) {
    var series  = [],
        legenda = [];
   
    legenda = arr_pivot; 
    for(let i=0;i<Object.keys(legenda).length;i++){
      var ar    = new Object,
          lista = valores.flat(), 
          dado  = [];
      const codigosConst = codigos;

      for(let g=0;g<codigosConst.length;g++) {
        dado.push(0);
      }
      for(let a=0;a<lista.length;a++){
        if (lista[a].grupo == legenda[i].cd) {
          index = codigosConst.findIndex(element => element === lista[a].cod);
          if (index !== -1) {
            dado[index] = parseFloat(lista[a].valor).toFixed(decimal);
          }
        }
      }
      
      ar.dataZoom = {};
      //ar.name = legenda[i].cd.replace("[", "").replace("]", "");
      ar.cod  = legenda[i].cd.replace("[", "").replace("]", "");   
      ar.name = legenda[i].ds.replace("[", "").replace("]", "");

      let show = false;
      if(mostrar){
        if(mostrar.indexOf('|'+ar.cod+'|') != -1 || mostrar.indexOf('TODOS') != -1){
          show = false;
        } else {
          show = true;
        }
      }

      if(formato == "bar"){
        ar.barMinHeight = "1";
      }

      if(formato == "bar" || formato == 'column'){

        if(formato == "column"){
          position = 'top';
          ar.type = 'bar';
        }else {
          ar.type = arr[2];
        }

        if(stack == "S"){
          if(grupoAnterior != ar.type && grupoAnterior != 'first'){
            agrupadorUnico += agrupadorUnico;
          }
          ar.stack = "GROUP_"+agrupadorUnico;
        } else {
          ar.stack = legenda[i].cd.replace("[", "").replace("]", "");
        }
      } else {
        ar.type = arr[2];
      }

      grupoAnterior = ar.type;

      ar.data = dado;
      if(formato != "line"){
      
        ar.itemStyle =  {
          normal:  normalLabel(show, position, abreviacao, formato, agrupadores, sec,fontSize),
          emphasis: emphasisLabel(show, position)
        };

      } else {
        
        if(cascata == 'S'){
          ar.areaStyle = {
            normal: {
              opacity: '0.2'
            }
          } 
        }

        if(agrupadores == -1){
          ar.lineStyle = {
            normal: {
              color: corLinha
            }
          }
        }
        
        ar.itemStyle =  {
          normal: normalLabel(show, position, abreviacao, formato, agrupadores, sec,fontSize),
          emphasis: emphasisLabel(show, position)
        }

      }
      ar.animation = chartAnimation;
      series.push(ar);
    }
    
    var dado = [];
    return series;
  } else if ((agrupadores == -1 && sec.length == 0) || agrupar_valor){

    var series = [];
    var ar = new Object;
        
    ar.type = arr_serie_prop[0].type;   // Alterado em 10/01/2022 - para utilizar parametrização da coluna/serie 
    //if(formato == 'column'){
    //  ar.type = 'bar';
    //} else {
    //  ar.type = formato;
    // }
    
    if (agrupar_valor){
      lista = valores.map((x) => x[0].valor);
    }else {
      lista = valores;
    }

    for(let a=0;a<lista.length;a++){
      lista[a] = parseFloat(lista[a]).toFixed(decimal);
    }
    ar.data = lista;

    if(cascata == 'S'){
      ar.areaStyle = '{}';
    }

    ar.dataZoom = {};
    ar.dataZoom.type = 'slider';
       
    var corFundoTema = '';

    if(get('menup')){
      corFundoTema = window.getComputedStyle(get('menup')).getPropertyValue('background-color');
    } 
    
    var markPointArr = [];

    var maxobj = {};
    if(markMax == 'S'){
      maxobj.type = 'max';
      maxobj.label = { formatter: 'MAX', color: '#FFF' }
      markPointArr.push(maxobj);
      /*maxobj.symbol = 'roundRect';
      maxobj.symbolOffset = [0, '200px']*/
    }

    var minobj = {};
    if(markMin == 'S'){
      minobj.type = 'min';
      minobj.label = { formatter: 'MIN', color: '#FFF' }
      markPointArr.push(minobj);
      /*minobj.symbol = 'roundRect';
      minobj.symbolOffset = [0, '-50px']*/
    }

    var mediaobj = {};
    if(markMedia == 'S'){
      mediaobj.type = 'average';
      mediaobj.symbol = 'none';
      mediaobj.emphasis = {
        label: {
          show: true
        },
      },
      mediaobj.label = { 
          show: false, 
          position: 'insideStartTop',
          formatter: function(par){ return "MED: "+par.data.value;  } 
      };
    }

    let show = false;

    if(mostrar){
      if(mostrar.indexOf(grupos+'|') != -1 || mostrar.indexOf('TODOS') != -1){
        show = false;
      } else {
        show = true;
      }
    }

    ar.markPoint = {
      itemStyle: { color: corFundoTema },
      data: markPointArr
    };


    if(markMedia == 'S'){
      ar.markLine = { 
        lineStyle: { type: 'dashed'/*, opacity: 0.5*/ },
        itemStyle: { color: corFundoTema },
        symbol: 'none',
        data: [mediaobj/*, mediaobj2*/]
      };
    }
               
    if(formato != "line"){
      ar.itemStyle =  {
        normal:  normalLabel(show, position, abreviacao, formato, agrupadores, sec,fontSize),
          emphasis: emphasisLabel(show, position)
        }
    } else {
      if(agrupadores == -1){
        ar.lineStyle = { normal: { color: corLinha  } }
      }

      if(cascata == 'S'){
        ar.areaStyle = {
          normal: {
            color: corLinha,
            opacity: '0.2'
          }
        }
      }

      ar.itemStyle =  {
        normal: normalLabel(show, position, abreviacao, formato, agrupadores, sec,fontSize),
        emphasis: emphasisLabel(show, position)
      }
    }

    ar.animation = chartAnimation;

    series.push(ar)

    return series;

  } else {

    //desconsidera primeiro nulo
    var grupoAnterior = 'first';
    //contador para aninhar grupos diferentes com stack
    var agrupadorUnico = 1;
    var series = [];
    
    for(let i=0;i<grupos.length;i++){

      var ar = new Object;
      var dado = [];
      var lista = valores.flat();
      for(let a=0;a<lista.length;a++){

        if((lista[a].grupo) == (grupos[i]) ){
          dado.push(parseFloat(lista[a].valor).toFixed(decimal));
        }

      }

      ar.dataZoom = {};
      ar.name = grupos[i].replace("[", "").replace("]", "");
   
      
      let show = false;

      if(mostrar){
        if(mostrar.indexOf('|'+ar.name+'|') != -1 || mostrar.indexOf('TODOS') != -1){
          show = false;
        } else {
          show = true;
        }
      }


      if(sec.replace(/(\r\n|\n|\r)/g, " ").split('|').indexOf(grupos[i].replace(/(\r\n|\n|\r)/g, " ")) != -1){

        if(formato == "bar" || formato == "column"){
          position = 'top';
          ar.type = "line";
        } else {
          ar.type = "bar";
        }
      } else {
        ar.type = arr_serie_prop[i].type;   // Alterado em 10/01/2022 - para permitir tipos diferentes para por valores  
      }

      if (i > 0 && arr_serie_prop[i].AxisIndex)  { 
         if (formato == 'column' || formato == 'line' ) { 
           ar.yAxisIndex = arr_serie_prop[i].AxisIndex;
         } else if (formato == 'bar') {
           ar.xAxisIndex = arr_serie_prop[i].AxisIndex;
         }  
      }

      if (arr_serie_prop[i].label && arr_serie_prop[i].label.position && arr_serie_prop[i].label.position.length != 0)  {
        position = arr_serie_prop[i].label.position; 
      } 
      if (arr_serie_prop[i].label && arr_serie_prop[i].label.fontSize && arr_serie_prop[i].label.fontSize.length != 0)  {
        fontSize = arr_serie_prop[i].label.fontSize; 
      } 


      if(formato == "bar"){
        ar.barMinHeight = "1";
      }

      if(formato == "bar" || formato == 'column'){

        if(stack == "S"){
          if(grupoAnterior != ar.type && grupoAnterior != 'first'){
            agrupadorUnico += agrupadorUnico;
          }
          ar.stack = "GROUP_"+agrupadorUnico;
        } else {
          ar.stack = grupos[i].replace("[", "").replace("]", "");
        }
      }


      //pega o grupo para não dar stack em grupos diferentes
      grupoAnterior = ar.type;
      //legenda em cima de linha?
      ar.data = dado;
      if(formato != "line"){
      
        ar.itemStyle =  {
          normal:  normalLabel(show, position, abreviacao, formato, agrupadores, sec,fontSize),
          emphasis: emphasisLabel(show, position)
        };

      } else {
        
        if(cascata == 'S'){
          ar.areaStyle = {
            normal: {
              opacity: '0.2'
            }
          } 
        }

        if(agrupadores == -1){
          ar.lineStyle = {
            normal: {
              color: corLinha
            }
          }
        }
        
        ar.itemStyle =  {
          normal: normalLabel(show, position, abreviacao, formato, agrupadores, sec,fontSize),
          emphasis: emphasisLabel(show, position)
        }

      }
      ar.animation = chartAnimation;

      series.push(ar);
    }
    return series;
  }
}

function labelTooltip(desc, valor, decimal, abreviacao, fracao, pct, hint, unidmed, decimal_pl){ 

  var desc = desc.replace('&amp;', '&');
  if (typeof decimal_pl == "undefined" || decimal_pl.toString().length == 0 ) { 
    decimal_pl = decimal;
  }

  if ((valor.value) && (valor.value != "NaN")){
    let valueStr = ""+valor.value; // converte para string  
    var um = ""; 
    if (typeof unidmed != "undefined") {
      um=unidmed;
    }
    var abreviado = abreviacaoNumerica(valor, abreviacao);
    
    var textField = '';

    if(hint == 'S' && desc.length > 0) {
      if (desc.toUpperCase().indexOf('[QUEBRA_LINHA]') >= 0 ) {
        textField = desc.replace(/\[QUEBRA_LINHA\]/gi,'') + String.fromCharCode(10);
      } else {
        textField = desc + ': ';
      }  
    }
    
    if(fracao == "A"){
      if(decimal == 0){

        if(um.indexOf('>') != -1){
          um = um.replace('>', '');
          return textField+abreviado+um+' - '+parseFloat((Number(valor.value/(pct/100)))).toFixed(decimal_pl)+"%";
        }else{
          um = um.replace('<', '');
          return textField+um+abreviado+' - '+parseFloat((Number(valor.value/(pct/100)))).toFixed(decimal_pl)+"%";          
        }
      
      } else {

        if(um.indexOf('>') != -1){
          um = um.replace('>', '');
          return textField+abreviado+","+valueStr.replace(/-/g, "").split(".")[1]+um+' - '+parseFloat((Number(valor.value/(pct/100)))).toFixed(decimal_pl)+"%";
        }else{
          um = um.replace('<', '');
          return textField+um+abreviado+","+valueStr.replace(/-/g, "").split(".")[1]+' - '+parseFloat((Number(valor.value/(pct/100)))).toFixed(decimal_pl)+"%";          
        }

      }

    } else {
      if(fracao == "S"){
        //quando desc vem nula é total , removido para não aparecer o  :valor
        if (!desc){

          return parseFloat((Number(valor.value/(pct/100)))).toFixed(decimal)+"%";

        }else{

          return desc+": "+parseFloat((Number(valor.value/(pct/100)))).toFixed(decimal)+"%";
        }

      } else {
        var valor_decimal = "",
            casas_decimal = parseInt(decimal);
        
        if (valueStr.replace(/-/g, "").split(".")[1] && (casas_decimal > 0) ) {
          valor_decimal = ","+valueStr.replace(/-/g, "").split(".")[1]; 
          valor_decimal = valor_decimal.substring(0,casas_decimal+1)
        }
        if(um.indexOf('>') != -1){
          um = um.replace('>', '');
          //if(decimal == 0){
          //  return textField+abreviado+um;
          //} else {
          //  return textField+abreviado+valor_decimal+um;
         // }
          return textField+abreviado+valor_decimal+um;
        }else{
          um = um.replace('<', '');
          //if(decimal == 0 || (!(valor.value)) ){       
          //  return textField+um+abreviado;  
          //} else {
          //  return textField+um+abreviado+valor_decimal;
          //} 
          return textField+um+abreviado+valor_decimal;          
        }
      }
    }
  } else if (valor.value === 0) {
    return "" 
  } else {
    return desc; 
  }

   
}

function abreviacaoNumerica(val, abreviacao){
  
  var sinal = '';
  if(!val.value){
    return '';
  }
  var valor = val.value.toString();
  if(valor.indexOf('-') != -1){ sinal = '-'; }
  var valor    = Number(valor).toLocaleString().replace(/-/g, "").split(",")[0];
  var tamanho  = valor.replace(/\./g, "").length;
  var subvalor = '';

  if(abreviacao == 'S'){
    if(valor.indexOf(".") != -1 ){
      valor = parseFloat(valor.substr(0, valor.indexOf(".")+2))+subvalor;
    } else {
      valor = parseFloat(valor)+subvalor;
    }
    if(tamanho > 12){
      valor = valor+"T";
    } else if(tamanho > 9){
      valor = valor+"B";
    } else if(tamanho > 6){
      valor = valor+"M";
    } else if(tamanho > 3){
      valor = valor+"K";           
    }
  }

  return sinal+valor;
}

function chartSlice(x, funil){

  var gxml = document.getElementById('gxml_'+x);
  var dad = document.getElementById('dados_'+x);

  var divObj = document.getElementById('ctnr_'+x);
  var article = divObj.closest('article');
  
  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      divObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile' ){
    divObj.style.width = '100%';
  }

  
  let cd_goto     = ''; 
  if (x.split('trl').length > 1) {
    cd_goto = x.split('trl')[1]; 
  } 

  //call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dad.getAttribute('data-visao')+'&prm_objeto='+x+'&prm_screen='+tela+'&prm_usuario='+USUARIO+'&prm_cd_goto='+cd_goto).then(function(resposta){
    //  gxml.innerHTML = resposta;
  //}).then(function(){
    
  if(!document.getElementById(x+'_ERR')){
  
  if(dad && document.getElementById('gxml_'+x)){
    var myChart   = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer });
    var gxml      = document.getElementById('gxml_'+x);
    var atributos = document.getElementById('atributos_'+x);
    var font_weigth  = atributos.getAttribute('data-font_weigth');
    var font_family  = atributos.getAttribute('data-font_family');
    
    if(gxml.children[0]){

      var destaque = JSON.parse('{'+gxml.children[1].innerHTML.replace(/(\r\n|\n|\r)/gm, '')+'}');
      // var jsonLista = gxml.children[0].innerHTML;
      var jsonLista = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
      jsonLista = jsonLista.substr(0, jsonLista.trim().length-1);
      var jsonParsed = JSON.parse("{"+jsonLista+"}");

      var valores = [];
      var grupos  = [];
      var codigos = [];

      for(let linha in jsonParsed){
        valores.push(jsonParsed[linha].valores);
        grupos.push(jsonParsed[linha].colunas);
        codigos.push(jsonParsed[linha].cod);
      }

      var coluna         = dad.getAttribute('data-coluna');
      var agrupador      = dad.getAttribute('data-agrupadores');
      var largura        = document.getElementById('ctnr_'+x).clientWidth;
      var altura         = document.getElementById('ctnr_'+x).clientHeight;
      var ccoluna        = atributos.getAttribute('data-cor-coluna').split("|");
      let ccoluna_hex    = dad.getAttribute('data-ccoluna-hex').split("|");
      var nodesc         = atributos.getAttribute('data-nodesc');
      var abreviacao     = atributos.getAttribute('data-abreviacao');
      var cor            = atributos.getAttribute('data-cor');
      var tipo           = atributos.getAttribute('data-tipo');
      var funil_sort     = dad.getAttribute('data-funil-sort');
      var label_conteudo = atributos.getAttribute('data-label_conteudo');      
      var labelspace     = '';
      var um             = atributos.getAttribute('data-um');
      var gruposr        = dad.getAttribute('data-agrupadoresreal').replace("<BR>", " ").split("|");
      var fontSize       = atributos.getAttribute('data-label_size');
      var totalCentral   = atributos.getAttribute('data-total_central');
      var totalCentralTxt= atributos.getAttribute('data-total_central_texto');

      if(dad.getAttribute('data-labelspace')){ 
        labelspace = dad.getAttribute('data-labelspace'); 
      }
       

      var arr_decimal  = atributos.getAttribute('data-decimal').split('|'),
          decimal_vl   = 0,
          decimal_pl   = 0;

      decimal_vl   = arr_decimal[0];
      decimal_pl   = (arr_decimal.length > 1 ? arr_decimal[1] : arr_decimal[0]) ;
      
      var mostrar;
      if(atributos.getAttribute('data-hidden')){
        if(atributos.getAttribute('data-hidden').indexOf('S') != -1 ){
          mostrar = false;
        } else {
          mostrar = true;
        }
      }

      var fracao = 'N';
      if(atributos.getAttribute('data-fracao')){
        fracao = atributos.getAttribute('data-fracao');
      }

      var dados  = [];
      var totalpct = 0; 
      var formato;

      if(tipo == 'donut'){
        formato = 'pie';
      } else {
        formato = tipo;
      }

      switch(tipo){
        case 'funnel': 
          
          for(let i=1;i<valores.length+1;i++){
            var objeto = new Object;
            if (label_conteudo == '' || label_conteudo == 'D' || grupos[i-1] == codigos[i-1]) {
              objeto.name = grupos[i-1]; 
            } else if (label_conteudo == 'C') {
              objeto.name = codigos[i-1];   
            } else { 
              objeto.name = codigos[i-1] + '-' + grupos[i-1];   
            } 
            // objeto.name = grupos[i-1];
            objeto.value = parseFloat(valores[i-1]).toFixed(decimal_vl);
            objeto.order = i*5;
            dados.push(objeto);
            totalpct = parseFloat(valores[i-1])+parseFloat(totalpct);
          }

          dados.sort(function(a, b){
            if(a.order > b.order){
              return 1;
            } else {
              return -1;
            }
          });

          break;

        default:

          for(let i=0;i<valores.length;i++){
            let objeto = new Object;
            //objeto.name = grupos[i];
            if (label_conteudo == '' || label_conteudo == 'D' || grupos[i] == codigos[i]) {
              objeto.name = grupos[i]; 
            } else if (label_conteudo == 'C') {
              objeto.name = codigos[i];   
            } else { 
              objeto.name = codigos[i] + '-' + grupos[i];   
            } 

            objeto.value = parseFloat(valores[i]).toFixed(decimal_vl);
            dados.push(objeto);
            totalpct = parseFloat(valores[i])+parseFloat(totalpct);
          }

      }

      var tooltipf = function(param){
        if(param){
          return labelTooltip(param.name, param, decimal_vl, abreviacao, fracao, totalpct, 'S',um,decimal_pl);
        }
      }

      var labelf = function(params){
        
        return labelTooltip(params.name, params, decimal_vl, abreviacao, fracao, totalpct, 'S',um,decimal_pl);
      }

      var labelf_total = function(params){

        return labelTooltip(params.name, params, decimal_vl, abreviacao, 'N', totalpct, 'S',um,'',decimal_pl);     
      }
      var arrgrid = [30, 80, 50, 80]
      var labelsplit = labelspace.split("|");
      if(labelspace.length > 0 && labelsplit.length < 5){
        for(let i=0;i<labelsplit.length;i++){
          arrgrid[i] = labelsplit[i];
        }
      }

      var colorList;

      if(atributos.getAttribute('data-cores').length < 1){
      //colorList = ["#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B","#60C0DD","#D7504B","#C6E579","#F4E001","#F0805A","#26C0C0","#FF7F50","#00D878","#AAAAAA","#DDDD55","#065182","#DA70D6","#FF6347","#AA5511","#CCCC44","#DA7400","#6663BB","#FAE982","#F5C65D","#AAA43B","#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B","#60C0DD","#D7504B","#C6E579","#F4E001","#F0805A","#26C0C0","#FF7F50","#00D878","#AAAAAA","#DDDD55","#065182","#DA70D6","#FF6347","#AA5511","#CCCC44","#DA7400","#6663BB","#FAE982","#F5C65D","#AAA43B","#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B","#60C0DD","#D7504B","#C6E579","#F4E001","#F0805A","#26C0C0","#FF7F50","#00D878","#AAAAAA","#DDDD55","#065182","#DA70D6","#FF6347","#AA5511","#CCCC44","#DA7400","#6663BB","#FAE982","#F5C65D","#AAA43B","#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B"];
      //nova paleta de cores BI
      colorList = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
      
    } else {
        colorList = atributos.getAttribute('data-cores').split("|");
      }  
       
      for (let i=0; colorList.length < 500; i++){
        colorList.push(colorList[i]);
      }

      /*var colorList;
      if(atributos.getAttribute('data-cores').length < 1){
        colorList = ["#87CEFA", "#C1232B", "#B5C334", "#FCCE10", "#E87C25", "#27727B", "#FE8463", "#9BCA63", "#FAD860", "#F3A43B", "#60C0DD", "#D7504B", "#C6E579", "#F4E001", "#F0805A", "#26C0C0", "#FF7F50", "#00D878", "#AAAAAA", "#DDDD55", "#065182", "#DA70D6", "#FF6347", "#AA5511", "#CCCC44", "#DA7400", "#6663BB", "#FAE982", "#F5C65D", "#AAA43B", "#6055DD", "#81CE55", "#A9532B", "#5BC114", "#CFCE19", "#E23C85", "#42227B", "#EE7443", "#9B9113", "#F1D890", "#53A49B"];
      } else {
        colorList = atributos.getAttribute('data-cores').split("|");
      }

      //cor pela coluna
      for(let i=0;i<codigos.length;i++){
        for(let c=0;c<ccoluna.length;c++){
          if(codigos[i] == ccoluna[c]){
            colorList[i] = ccoluna_hex[c];
          } 
        } 
      }*/

      // Posição do label no gráfico 
      var arr_sepo_n = [],
          arr_sepo_v = [],		  
			    arr_sepo   = [];
      if (atributos.getAttribute('data-graf_series_label_pos_n') && atributos.getAttribute('data-graf_series_label_pos'))  { 
        arr_sepo_n = atributos.getAttribute('data-graf_series_label_pos_n').split("|");
        arr_sepo_v = atributos.getAttribute('data-graf_series_label_pos').split("|");
      } 
      arr_sepo[0] = 'outside';  // Colocar como outside se não defindo o attributo
      for(let i=0;i<gruposr.length;i++){   
        var v_idx_sepo = arr_sepo_n.findIndex(element => element == gruposr[i] );
        if (v_idx_sepo != -1) {arr_sepo[i] = arr_sepo_v[v_idx_sepo]; } 
      } 
      
    var ar = [];

    var arColor = [];

    for(let i = 0; i< dados.length; i++){
      //let temp = {};
      let arrCol = [];
      arrCol.push(coluna);
      arrCol.push(agrupador);
      let temp = efeitoCondicoes(destaque, arrCol, dados[i].value, colorList[i], dados[i].name, codigos[i], codigos[i], coluna);

      arColor.push(temp);

    }

    var obj = {};
    obj.itemStyle = {};

    obj.itemStyle.normal = {};
    obj.itemStyle.emphasis = {};
    obj.itemStyle.normal.borderWidth = 2;
    obj.itemStyle.normal.label = {};
    obj.itemStyle.normal.label.textStyle = {};
    obj.itemStyle.normal.label.textStyle.color = '#333';
    obj.itemStyle.normal.label.show = mostrar;
    obj.itemStyle.normal.label.formatter = labelf;
    obj.itemStyle.normal.label.position = arr_sepo[0];
    obj.itemStyle.normal.labelLine = {};
    obj.itemStyle.normal.labelLine.show = mostrar;

    obj.itemStyle.emphasis.itemStyle = {};
    obj.itemStyle.emphasis.itemStyle.shadowBlur = 5;
    obj.itemStyle.emphasis.itemStyle.shadowOffsetX = 0;
    obj.itemStyle.emphasis.itemStyle.shadowColor = 'rgba(0, 0, 0, 0.5)';

    obj.data = dados;
    obj.type = formato;

    ar.push(obj);

    var option = {

      legendHoverLink: true,  
      grid: {
        y: arrgrid[0], 
        x2: arrgrid[1], 
        y2: arrgrid[2], 
        x: arrgrid[3] 
      },

      tooltip: { 
        show: true, 
        confine: true,
        trigger: 'item' ,
        formatter: tooltipf
      },

      noDataLoadingOption: { 
        text: "inválido", 
        effect: 7 
      },
      textStyle: {
        fontFamily: font_family,
        fontWeight: font_weigth
      },

      color:  arColor,
      series : [{
            type: formato, /* pie, funnel, donut*/
            data : dados,
            
            itemStyle : {
              normal : {
                label : {
                  textStyle: {  color: cor }, 
                  show: mostrar,
                  formatter: labelf,
                  position: arr_sepo[0],
                  fontSize: fontSize
                },
                labelLine : {
                  show: mostrar
                }, 
              },
              emphasis : {
                label : {
                  textStyle : {
                    borderColor: '#333' 
                  }
                }
              }
            }
      }]
    };


      switch(tipo){
        case 'funnel':
          option.series[0].width = '50%';
          option.series[0].left = '25%';
          option.series[0].sort = funil_sort; 
          option.series[0].itemStyle.fontSize = fontSize;
        case 'donut':
          option.series[0].radius = ["30%", ((largura+altura)/10.56)+"px"];
          option.series[0].itemStyle.borderRadius = 20;
          option.series[0].itemStyle.borderColor = '#FFF';
          option.series[0].itemStyle.borderWidth = 4;
          option.series[0].itemStyle.fontSize = fontSize;

          if (totalCentral == 'S') {
            let series_tot = {
              type: formato, 
              color: 'transparent',
              data : [ {name: totalCentralTxt, value: parseFloat(totalpct).toFixed(decimal_vl)}],
              radius : ["0", "0"],
              itemStyle : {
                normal : {
                  label : {
                    textStyle: { color: cor }, 
                    show: mostrar,
                    formatter: labelf_total,
                    position: 'inside',
                    fontSize: fontSize
                  },
                  labelLine : {
                    show: mostrar
                  }, 
                }
              }
            }
            option.series.push(series_tot);
          }    
          break;
        default:
          option.series[0].radius = ((largura+altura)/10.56)+"px";
      }

      myChart.setOption(option);
      myChart.on('click', clicker);
      
      // Geração do PNG (com título) - Aguarda 5 segundos para garantir que o gráfico já tenha sido montado 
      //---------------------------------------------------------------
      setTimeout(function(){
        if(document.getElementById(x+'more')){
          var a = document.createElement('a');
          a.classList.add('download_button');
          a.setAttribute('download', document.getElementById(x+'_ds').innerText.replace(/ /g, "_").toLowerCase());

          // Adiciona um título para sair no PNG 
          option.title = {
            text: document.getElementById(x+'_ds').innerText,
            left: 'center',
            top: 0
          };
          option.grid.y     = parseInt(arrgrid[0]) + 25 ;  // Aumenta a margem superior para caber o título 
          myChart.setOption(option, { notMerge: true }); 

          // Gera o PNG 
          a.href = myChart.getDataURL({
            type: 'png',
            pixelRatio: 1,
            backgroundColor: '#FFF'
          });

          // Retira o título, volta os parâmetros(visual) original do gráfico 
          option.title      = {}; 
          option.grid.y     = arrgrid[0];
          myChart.setOption(option, { notMerge: true });   // Atualiza o gráfico sem o título         

          if(document.getElementById(x+'more')){
            document.getElementById(x+'more').querySelector('.page_png').appendChild(a);
          }
        }
      }, 1500);
    }
  }

  } else {
    document.getElementById('ctnr_'+x).innerHTML = document.getElementById(x+'_ERR').innerHTML;
  }

  //});

}

function chartDonut(x) {
  var dados = document.getElementById('dados_'+x);
  var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer });
  var gxml = document.getElementById('gxml_'+x);
  var valores = gxml.children[0].innerHTML.replace("|", "").split("|");
  var grupos = gxml.children[1].innerHTML.replace("|", "").split("|");
  var limite = parseInt(dados.getAttribute('data-meta'));
  var coluna = dados.getAttribute('data-coluna'); 
  

  if(atributos.getAttribute('data-hidden')){
    if(atributos.getAttribute('data-hidden').indexOf('S') != -1 ){
      var mostrar = false;
    } else {
      var mostrar = true;
    }
  }

  var dado = [];

  //donut tipo pizza
  for(let i=0;i<valores.length;i++){
    var objeto = new Object;
    objeto.name = grupos[i];
    objeto.value = parseFloat(valores[i]).toFixed(2);
    dado.push(objeto);
  }

  var labelFormatter = {};

  var cores;

    if(atributos.getAttribute('data-cores').length < 1){
      //cores = ["#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B","#60C0DD","#D7504B","#C6E579","#F4E001","#F0805A","#26C0C0","#FF7F50","#00D878","#AAAAAA","#DDDD55","#065182","#DA70D6","#FF6347","#AA5511","#CCCC44","#DA7400","#6663BB","#FAE982","#F5C65D","#AAA43B","#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B","#60C0DD","#D7504B","#C6E579","#F4E001","#F0805A","#26C0C0","#FF7F50","#00D878","#AAAAAA","#DDDD55","#065182","#DA70D6","#FF6347","#AA5511","#CCCC44","#DA7400","#6663BB","#FAE982","#F5C65D","#AAA43B","#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B","#60C0DD","#D7504B","#C6E579","#F4E001","#F0805A","#26C0C0","#FF7F50","#00D878","#AAAAAA","#DDDD55","#065182","#DA70D6","#FF6347","#AA5511","#CCCC44","#DA7400","#6663BB","#FAE982","#F5C65D","#AAA43B","#87CEFA","#C1232B","#B5C334","#FCCE10","#E87C25","#27727B","#FE8463","#9BCA63","#FAD860","#F3A43B"];
      //Nova paleta de cores do BI
      cores = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
    } else {
      cores = atributos.getAttribute('data-cores').split("|");
    }  
         
    for (let i=0; cores.length < 500; i++){
      cores.push(cores[i]);
    }

  var option = {
    tooltip: { show: true, confine: true, trigger: 'item' },
    noDataLoadingOption: { text: "inválido", effect: 7 },
    color:cores,
    series : [{
         type:"pie",
         radius :['50%', '70%'],
         data : dado,
          itemStyle : labelFormatter
    }]
  }

  myChart.setOption(option);
  myChart.on('click', clicker);

}

function chartMap(x) {

  var gxml  = document.getElementById('gxml_'+x);
  var dados = document.getElementById('dados_'+x);

  let cd_goto     = ''; 
  if (x.split('trl').length > 1) {
    cd_goto = x.split('trl')[1]; 
  } 


  call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dados.getAttribute('data-visao')+'&prm_objeto='+x+'&prm_screen='+tela+'&prm_usuario='+USUARIO+'&prm_cd_goto='+cd_goto).then(function(resposta){
      gxml.innerHTML = resposta;
  }).then(function(){

    var divObj = document.getElementById('ctnr_'+x);
    var article = divObj.closest('article');
  
  
  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      divObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile'){
    divObj.style.width = '100%';
  }

    
  if(!document.getElementById(x+'_ERR')){
  
  var myChart   = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer });
  //var gxml      = document.getElementById('gxml_'+x);
  if(gxml.children[0] && !gxml.children[1].classList.contains('err')){
    
    var jsonLista = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
        jsonLista = jsonLista.substr(0, jsonLista.trim().length-1);
        try {
          var jsonParsed = JSON.parse("{"+jsonLista+"}");
        } catch (err){
          alerta('feed-fixo', TR_QR_IN);
          return;
        }

    var valores = [];
    var grupos  = [];
    var sigla   = [];
    var mais_valores = [];

    for (let linha in jsonParsed) {
      if (Array.isArray(jsonParsed[linha].valores)) {
          var mais_valores_obj = []; 
          for (let value in jsonParsed[linha].valores) {
              var mais_valores_obj_outer = new Object();
              mais_valores_obj_outer.grupo = jsonParsed[linha].valores[value].grupo;
              mais_valores_obj_outer.value = parseFloat(jsonParsed[linha].valores[value].valor);
              mais_valores_obj.push(mais_valores_obj_outer);
          }
          mais_valores.push(mais_valores_obj);
          valores.push(jsonParsed[linha].valores[0].valor);
      } else {
        valores.push(jsonParsed[linha].valores);
      }
      grupos.push(jsonParsed[linha].colunas);
      sigla.push(jsonParsed[linha].cod);
    }


    //var valores     = gxml.children[0].innerHTML.replace("|", "").split("|");
    //var grupos      = gxml.children[1].innerHTML.replace("|", "").split("|");

    var minimo        = 0; 
    var atributos     = document.getElementById('atributos_'+x);
    if(atributos.getAttribute('data-max') == 'S'){
      var maximo      = 0;
    } else {	
      var maximo      = parseInt(dados.getAttribute('data-maximo'));
    }
    var coluna        = dados.getAttribute('data-agrupadores');
    //var sigla       = gxml.children[2].innerHTML.replace("|", "").split("|");
    var formato       = dados.getAttribute('data-formato');
    var heatmap       = dados.getAttribute('data-heatmap');
    var decimal       = atributos.getAttribute('data-decimal');
    
    var datanome      = [];
    var datasigla     = [];
    var geo           = [];
    var dado          = [];
    var jason         = {};
    var mostrar       = true;
    var abreviacao    = atributos.getAttribute('data-abreviacao');
    var lista, tipo, labs;
    var font_weigth   = atributos.getAttribute('data-font_weigth');
    var font_family   = atributos.getAttribute('data-font_family');
    
    if(atributos.getAttribute('data-hidden')){
      if(atributos.getAttribute('data-hidden').indexOf('S') != -1 ){
        mostrar = false;
      }
    }

    if(get(x).querySelector('.lista_cidades')){
      lista = get(x).querySelector('.lista_cidades').children;
      tipo  = 'cidade';
      labs  = false;
    } else if(get(x).querySelector('.lista_regioes')) {
      lista = get(x).querySelector('.lista_regioes').children;
      tipo  = 'regioes';
      labs  = mostrar;
    } else { 
      lista = get(x).querySelector('.lista_estados').children;
      tipo  = 'estado';
      labs  = mostrar;
    }
    
    /*for(a=0;a<valores.length;a++){
      var objeto   = new Object;
      objeto.name  = grupos[a];
      objeto.value = parseFloat(valores[a]).toFixed(2);
      dado.push(objeto);
    }*/
    
    for(let i=0;i<lista.length;i++){
      var objeto   = new Object;
      if(isNaN(sigla[0]) && tipo == 'cidade'){
        geo.push(lista[i].innerHTML.trim().replace('name', 'cod').replace('nome', 'name'));
      } else {
        geo.push(lista[i].innerHTML.trim());
      }
      //datanome.push(lista[i].getAttribute('data-nome'));
      //datasigla.push(lista[i].getAttribute('data-sigla'));
      
      var siglav  = lista[i].getAttribute('data-sigla');
      var siglav2 = lista[i].getAttribute('data-sigla2');
      var nome    = lista[i].getAttribute('data-nome');

      if(isNaN(sigla[0]) && tipo == 'cidade'){
        objeto.name  = siglav2;
        if(sigla.indexOf(siglav2) != -1){
          objeto.value = parseFloat(valores[sigla.indexOf(siglav2)]).toFixed(2);
          objeto.mais_valores = mais_valores[sigla.indexOf(siglav2)];
        } 
        objeto.sigla = siglav2;
      } else {
        objeto.name  = siglav;
        objeto.value = parseFloat(valores[sigla.indexOf(siglav)]).toFixed(2);
        objeto.mais_valores = mais_valores[sigla.indexOf(siglav)];

        objeto.sigla = siglav;
      }

      objeto.nome  = nome;

      if (!isNaN(objeto.value)) {
        if (atributos.getAttribute('data-max') == 'S') {
          if (parseInt(objeto.value) > maximo) {
            maximo = parseInt(objeto.value); // parseInt(valores[sigla.indexOf(siglav)]);
          }
        }
        if (parseInt(objeto.value) < minimo) {
          minimo = parseInt(objeto.value);
        }
      }  
      dado.push(objeto);
    }

      if (minimo > 0) {
        minimo = 0;
      }

      var geoCoordMap = {};

      var json_map = '{ "type": "FeatureCollection", "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } }, "features": ['+geo.join(',').replace(/[\n\t]+/g,'')+'], "UTF8Encoding":false }';

      //var arr = abdon.match(/-[0-9.,\s\-]+/g);
      echarts.registerMap('mapa', json_map);

      //var dado = [];
      var coorx = '';
      var coory = '';
      var repeat = 0;

      var cores = atributos.getAttribute('data-cores').split('|');
      var ncores = cores.length;
      
      if(ncores < 2){
        cores = '#87CEFA|#B5C334|#FF6347|#C1232B'.split("|");
        ncores = cores.length;
      }

        //option do mapa regular
        
        var option = {
          textStyle:{
            fontFamily:font_family,
            fontWeight:font_weigth
          },
          tooltip: { 
            show: true, 
            trigger: 'item',
            formatter: function(params){ 
              if(params){
                if(params.data.nome){
                  if(params.data.mais_valores) {
                    var string = '<p style="text-align: left;">';

                    let decimal2 = decimal.split('|');
                    var decimal_aux = null;

                    for(let i=0;i<params.data.mais_valores.length;i++){
                      if (decimal.length > i) {
                        decimal_aux = decimal2[i];
                      } else {
                        decimal_aux = decimal2[0];
                      }

                      string += labelTooltip(params.data.mais_valores[i].grupo, params.data.mais_valores[i], parseFloat(decimal_aux), abreviacao, 'N', 0, 'S','','');
                      string += '<br>';
                    }
                    string +='</p>';
                    return string;
                  }
                  return labelTooltip(params.data.nome, params.data, decimal, abreviacao, 'N', 0, 'S','','');
                } else {
                  return labelTooltip(params.name, params, decimal, abreviacao, 'N', 0, 'S','','');
                } 
              }
            } 
          },
          noDataLoadingOption: { text: "inválido", effect: 7 },
        
          dataRange: {
              left: 'left',
              top: 'bottom',
              min: minimo,
              max: maximo,
              splitNumber: ncores,
              inRange: {
                  color: cores
              },
              text: [coluna.split('|')[0], ''],
              calculable : true
          },
          visualMap: {
              min: minimo,
              max: maximo,
              splitNumber: ncores,
              inRange: {
                  color: cores
              },
              text: [coluna, ''],
              
              calculable : true,
              formatter : function (valor){ return valor.toLocaleString(); },
          },
          //usar com scatter
          /*geo: {
              map: 'mapa',
              roam: true,
              emphasis:{
                  itemStyle: {
                      areaColor: null,
                      shadowOffsetX: 0,
                      shadowOffsetY: 0,
                      shadowBlur: 1,
                      borderWidth: 1
                  }
              }
            },*/
          series : [
            //precisa da versão mais nova da biblioteca
            /*{
              name: 'scat',
              type: 'scatter',
              showEffectOn: 'render',
              coordinateSystem: 'geo',
              symbolSize: function(a){
                return a[2];
              },
              data: [{name: "SP", value: [-48.693127, -22.174880, 39, "green"] }, {name: "PR", value: [-51.629591, -24.627788, 27, "red"] }, {name: "RS", value: [-53.364345, -29.711867, 31, "red"]}, {name: "SC", value: [-50.242942, -27.264091, 44, "red"]}],
              itemStyle: { 
                color: 'purple'
              },
              
              label: {
                color: 'red',
                formatter: function(d){
                  return 'Infectados: '+d.data.value[2]; 
                },
                position: 'right',
                show: true
              }
              
            },*/
            {
              name: 'coluna',
              type: 'map',
              map: 'mapa',
              /*geoIndex: 0,*/
              roam: true,
              // não usar label com scatter
              label: {
                  normal: {
                      show: labs,
                      formatter: function(codigo) {
                          if (tipo == 'regioes') {
                              return codigo.data.nome;
                          } else {
                              return codigo.data.sigla;
                          }
                      }
                  },
                  emphasis: {
                      show: labs,
                      formatter: function(codigo) {
                          if (tipo == 'estado') {
                              if (codigo.data.sigla) {
                                  return codigo.data.sigla;
                              } else {
                                  return codigo.data.nome;
                              }
                          } else if (tipo == 'regioes') {
                              return codigo.data.nome;
                          } else {
                              return '';
                          }
                      }
                  }
              },
              // criar atributo para esconder nome/código da cidade ao selecionar
              /*select: {
                  label: { show: false }
              }*/
              data: dado
          }

          ]
        };

      myChart.setOption(option);
      

      myChart.on('click', clicker);
      //myChart.on('finished', mapa_zoom);
      myChart.dispatchAction({
        type: 'dataZoom'    
      });

    if(document.getElementById(x+'more')){
      var a = document.createElement('a');
      a.style.setProperty('width', '18px');
      a.style.setProperty('height', '18px');
      a.style.setProperty('float', 'left');
      a.style.setProperty('margin', '4px 0 0 4px');
      a.setAttribute('download', document.getElementById(x+'_ds').innerText.replace(/ /g, "_").toLowerCase());

      // Adiciona um título para sair no PNG 
      option.title = {
        text: document.getElementById(x+'_ds').innerText,
        left: 'center',
        top: 0
      };
      myChart.setOption(option, { notMerge: true } ); 

      // Gera o PNG 
      a.href = myChart.getDataURL({
        type: 'png',
        pixelRatio: 1,
        backgroundColor: '#fff'
      });

      // Retira o título, volta os parâmetros(visual) original do gráfico 
      option.title      = {}; 
      myChart.setOption(option, { notMerge: true });   // Atualiza o gráfico sem o título         


      if(document.getElementById(x+'more')){
        document.getElementById(x+'more').querySelector('.page_png').appendChild(a);
      }
    }

  }		

  } else {
    document.getElementById('ctnr_'+x).innerHTML = document.getElementById(x+'_ERR').innerHTML;
  }

  });

}

function chartMapMultiplo(x) {
  
  var dados = document.getElementById('dados_'+x);
  var myChart = echarts.init(document.getElementById('ctnr_'+x));
  var gxml = document.getElementById('gxml_'+x);
  if(gxml.children[1]){
    var valores = gxml.children[0].innerHTML.replace("|", "");
    var grupos = gxml.children[1].innerHTML.replace("|", "").split("|");
    var maximo = parseInt(dados.getAttribute('data-maximo'));
    //var coluna = dados.getAttribute('data-agrupadores');
    var json = dados.getAttribute('data-json'); 
    var sigla = gxml.children[2].innerHTML.replace("|", "").split("|");
    var agrupadores = dados.getAttribute('data-agrupadores').replace("<BR>", " ").indexOf("|");
    
    if(atributos.getAttribute('data-hidden')){
      if(atributos.getAttribute('data-hidden').indexOf('S') != -1 ){
        var mostrar = false;
      } else {
         var mostrar = true;
      }
    }

    if(agrupadores != -1){
      
      var agrupadores = valores.match(/\[[a-zA-Z0-9$_ ().\%\\\/\u00C0-\u017F]+\]/g);
      var gruposf = [];
      var gf = 0;

      for(let g=0;g<agrupadores.length;g++){
        if(gruposf.indexOf(agrupadores[g].replace("[", "").replace("]", "")) == -1){
          gruposf[gf] = agrupadores[g].replace("[", "").replace("]", "").replace("(BR)", " ").replace("<BR>", " ");
          gf = gf+1;
        }
      }

    }

    ajax('return', 'download', 'arquivo='+json+'.json', false);
    echarts.registerMap('mapa', respostaAjax);

    var listag = [];

    for(let g=0;g<gruposf.length;g++){
      var dado = [];
      
      for(let i=0;i<valores.length;i++){
         var objeto = new Object;
         objeto.agrupador = gruposf[g];
         objeto.name = grupos[i];
         objeto.value = parseFloat(valores[i]).toFixed(2);
         dado.push(objeto);
      }
      listag.push(dado);
    }

    var option = {
      tooltip: { 
        show: true, 
        confine: true,
        trigger: 'item',
        formatter: function(param){ 
          if(param){
            if(Number(param.value).toLocaleString() != "NaN"){
              return param.name+": "+Number(param.value).toLocaleString();
            } else {
              return param.name;
            }
          } 
        }, 
      },
      noDataLoadingOption: { text: "inválido", effect: 7 },
      /*legend: {
          orient: 'vertical',
          left: 'left',
          calculable: true
      },*/
      dataRange: {
          left: 'left',
          top: 'bottom',
          min: 0,
          max: maximo,
          calculable : true
      },
      series : [
        {
          name: gruposf,
          type: 'map',
          map: 'mapa',
          roam: false/*'scale' para zoom*/,
          label: {
              normal: {
                  show: true,
                  formatter : function (codigo){ if(sigla[codigo.dataIndex]) { return sigla[codigo.dataIndex]; } else { return ' ' } }
              },
              emphasis: {
                  show: true
              }
          },  
          data: dado
        }]
    };

    myChart.setOption(option);
    myChart.on('click', clicker);
  }

}


function chartPercent(x){

  if(document.getElementById('valores_'+x).getAttribute('data-meta').length > 0){
    var dados   = document.getElementById('valores_'+x);
    
    var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer });
    var gxml    = document.getElementById(x+'_vl');
    var limite  = parseInt(dados.getAttribute('data-meta').replace(/\'/g, ''));
    if(limite == 0){ limite = 1; }
    var coluna  = '';
    var color   = dados.getAttribute('data-color');
    var color_destaque = document.getElementById(x+'_mt').style.getPropertyValue('color');

    var valor   = parseInt(dados.getAttribute('data-valor'));
    var dado    = [];

    if(color_destaque.trim().length == 0){
      color_destaque = color; 
    }

    //donut de porcentagem
    var labelBottom = {
      normal : {
        color: '#dedede',
        borderColor: '#777',
        borderWidth: 1,
        label : {
          textStyle: { color: color_destaque, fontWeight: 'bold', fontSize: 1, baseline : 'top' },
          show : false,
          position : 'top'
        },
        labelLine : {
          show : false
        }
      },
      emphasis: {
        color: '#cdcdcd'
      }
    };

    var labelTop = {
      normal : {
        color: color_destaque,
        borderColor: '#777',
        borderWidth: 1,
        label : {
          show : true,
          position : 'center',
          formatter : '{c}%',
          textStyle: { color: color_destaque, fontWeight: 'bold', fontSize: 15, baseline : 'top' },
        },
          labelLine : {
          show : false
        }
      }
    };

    var labelFormatter = {
      normal : {
        color: color_destaque,
        label : {
          formatter : function (params){
            return parseFloat(params.value).toFixed(2) + '%'
          },
          textStyle: {
            baseline : 'top'
          }
        }
      },
    }

    var outro = new Object;
    outro.name = 'outro';
    if(valor < limite){
      outro.value = 100-parseFloat((valor/limite)*100).toFixed(2);
    } else {
      outro.value = 0;
    }
    
    outro.itemStyle = labelBottom;
    dado.push(outro);

    var objeto = new Object;
    objeto.name = coluna;
    objeto.value = parseFloat((valor/limite)*100).toFixed(2);
    objeto.itemStyle = labelTop;
    dado.push(objeto);

    var option = {
      noDataLoadingOption: { text: "inválido", effect: 7 },
      //color: ['#87CEFA', '#C1232B','#B5C334','#FCCE10','#E87C25','#27727B', '#FE8463','#9BCA63','#FAD860','#F3A43B','#60C0DD', '#D7504B','#C6E579','#F4E001','#F0805A','#26C0C0', '#FF7F50', '#00D878', '#AAAAAA', '#DDDD55', '#065182', '#DA70D6', '#FF6347', '#F3A82F', '#4A95C6', '#9F9F9f', '#3984A5', '#CC9900', '#115599'],
      series : [{
        type:"pie",
        radius :['50%', '70%'],
        data : dado,
        itemStyle : labelFormatter
      }]
    };

    myChart.setOption(option);

  }
}

function chartGauge(x) {
    var ctnr = document.getElementById('ctnr_'+x);
    //var myChart = echarts.init(ctnr, null, { renderer: chartRenderer });
    var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer, height: document.getElementById('ctnr_'+x).clientHeight, width: document.getElementById('ctnr_'+x).clientWidth }); 

    //var dados = document.getElementById('dados_'+x);
    var atributos = document.getElementById('atributos_'+x);
    var valor   = parseFloat(document.getElementById('valor_'+x).title);
    var raio    = parseInt(atributos.getAttribute('data-raio'));
    var min     = parseFloat(atributos.getAttribute('data-min'));
    var max     = parseFloat(atributos.getAttribute('data-max'));
    var valores = atributos.getAttribute('data-valores').split("|");
    var cores   = atributos.getAttribute('data-cores').split("|");
    var colorList = ["#87CEFA", "#C1232B", "#B5C334", "#FCCE10", "#E87C25", "#27727B", "#FE8463", "#9BCA63", "#FAD860", "#F3A43B", "#60C0DD", "#D7504B", "#C6E579", "#F4E001", "#F0805A", "#26C0C0", "#FF7F50", "#00D878", "#AAAAAA", "#DDDD55", "#065182", "#DA70D6", "#FF6347", "#AA5511", "#CCCC44", "#DA7400", "#6663BB", "#FAE982", "#F5C65D", "#AAA43B", "#6055DD"];
    var hidden  = atributos.getAttribute('data-hidden');
    var font_weigth  = atributos.getAttribute('data-font_weigth');
    var font_family  = atributos.getAttribute('data-font_family');
    var showValue = true;
    var valor_um       = atributos.getAttribute('data-um'); 
    var cor_meta       = atributos.getAttribute('data-meta_cor'); 
    var val_meta_ini   = parseFloat(atributos.getAttribute('data-meta_inicio')); 
    var val_meta_fim   = parseFloat(atributos.getAttribute('data-meta_fim'));
    var nome_meta      = atributos.getAttribute('data-meta_nome'); 
    var marcador_meta  = atributos.getAttribute('data-meta_marcador'); 
    var alinhamentoRaio = atributos.getAttribute('data-alinhamento_raio');

    var divObj = document.getElementById('ctnr_'+x);
    var article = divObj.closest('article');


    if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
      if (article != null) {
        if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
          var alturaElemento = 500;
        }else{
          var alturaElemento = article.clientHeight;
        }
        divObj.style.height = alturaElemento - 40 + 'px'; 
      }
    }

    var checkMobile = mobilecheck();
    if (checkMobile == 'mobile' ){
      divObj.style.width = '100%';
    }
  

    if(hidden == 'S'){
      showValue = false;
    }

    var split = 5;
    if(valores.length > 0){
      split = valores.length;
    }

    var axisColor = [];
    
    var comb = [];
    var axisValor;

    if(atributos.getAttribute('data-valores').length == 0){
      comb = [0.25, colorList[0]];
      axisColor.push(comb);
      comb = [0.50, colorList[1]];
      axisColor.push(comb);
      comb = [0.75, colorList[2]];
      axisColor.push(comb);
      comb = [1, colorList[3]];
      axisColor.push(comb);
    } else {
      //let multiplicador = 100/(valores[split-1]);
      let multiplicador = 100/(valores[split-1]-(min));
      var total = 0;
      //var desconto = 0;
      for(let i=0;i<split;i++){
        if(i == 0){
          axisValor = (parseFloat(valores[i]-(min))*multiplicador);
          //desconto  = split/valores[i];
        } else {
          axisValor = (parseFloat(valores[i]-valores[i-1])*multiplicador);
        }

        total = total+axisValor;

        //axisValor = parseFloat(valores[i]);
        comb = (cores[i]) ? [total/100, cores[i]] : [total/100, colorList[i]];
        axisColor.push(comb);
      }
    }

    if(axisValor < 1){
      comb = [1, '#999'];
      axisColor.push(comb);
    }

    var medida;
    var outside;
    var invertido = 'N'; 

    if(raio < 190){
      medida = ctnr.clientWidth/3;
      outside = '70%';
    } else {
      medida = ctnr.clientWidth/4;
      outside = '50%';
    }
    
    if ( min > max ) { 
      invertido = 'S'; 
    }





    // Definições montagem da META 
    // -----------------------------------------------------------
    if (isNaN(val_meta_ini) ) { val_meta_ini = 0; }  
    if (isNaN(val_meta_fim) ) { val_meta_fim = 0; }  

    if (val_meta_fim == 0 && val_meta_ini != 0) { 
      val_meta_fim = max;
    } 

    if (val_meta_fim < val_meta_ini) {
        val_meta_fim = val_meta_ini; 
    }

    if ( !cor_meta || cor_meta.length == 0) { 
      cor_meta = '#000000';  // Preto  
    } 

    if (nome_meta && nome_meta.length > 0) { 
      nome_meta = nome_meta + '\n'; 
    } else {
      nome_meta = "";
    }  

    var pos_meta_ini     = 0,
        pos_meta_fim     = max,
        pos_meta_ini_ant = 0, 
        lab_meta_ini     = "",
        lab_meta_fim     = "",
        width_linha      = 0; 

    if (invertido == 'S') { 
      pos_meta_fim = min; 
    }

    var raioInicial;
    var raioFinal;

    if (alinhamentoRaio == 'S' && raio > 180 && raio <= 360) {
        raioInicial = 180 + ((raio - 180) / 2)
        raioFinal = 0 - ((raio - 180) / 2)
    } 
    else {
      raioInicial = raio;
      raioFinal = 0;
    }

    // Monta os labels da meta, e define a posição da meta no ponteiro  

    /******************************
    if (!valor_um) { 
      valor_um = ""; 
    }         
    if (val_meta_ini != 0 ) { 
      pos_meta_ini = (val_meta_ini - min) / (max - min); 
      lab_meta_ini = nome_meta + val_meta_ini.toString() + valor_um;
    }
    
    if (val_meta_fim != 0) {     
      pos_meta_fim = (val_meta_fim - min) / (max - min);
      lab_meta_fim = nome_meta + val_meta_fim.toString() + valor_um;
      if ( val_meta_fim == max) {   
        lab_meta_fim = '';
      }   
    }
    **************/ 
    if (val_meta_ini != 0) {
      pos_meta_ini = (val_meta_ini - min) / (max - min);
      lab_meta_ini = nome_meta + val_meta_ini.toString() + valor_um;
    }
    if (val_meta_fim != 0) {
          pos_meta_fim = (val_meta_fim - min) / (max - min);
          lab_meta_fim = nome_meta + val_meta_fim.toString() + valor_um;
          if (val_meta_fim == max) {
            lab_meta_fim = '';

      }
    }

    if (invertido == 'S') { // Inverte as posições da meta 
      pos_meta_ini_ant = pos_meta_ini; 
      pos_meta_ini     = pos_meta_fim;  
      pos_meta_fim     = pos_meta_ini_ant;  
    }   

    // Define os values da meta para colocar os labels na posição certar 
    var fracao             = ((max - min) / 10 / 10), 
        val_meta_ini_value = 0,
        val_meta_fim_value = 0; 

    if (fracao != 0) { 
      /***** 
      var intervalos_ini = Math.round((val_meta_ini - min) / fracao), 
          intervalos_fim = Math.round((val_meta_fim - min) / fracao);
      val_meta_ini_value   = parseFloat((min + (intervalos_ini * fracao)).toFixed(10)),
      val_meta_fim_value   = parseFloat((min + (intervalos_fim * fracao)).toFixed(10));
      ****************/ 
      var intervalos_ini = Math.round((val_meta_ini - min) / fracao), 
          intervalos_fim = Math.round((val_meta_fim - min) / fracao);
      val_meta_ini_value   = parseFloat((min + (intervalos_ini * fracao)).toFixed(10)),
      val_meta_fim_value   = parseFloat((min + (intervalos_fim * fracao)).toFixed(10));
    }    

    // Define o marcador, ponto, linha ou nenhum 
    var meta_medida = 5,
        width_linha = 3; 
    if (!marcador_meta) { 
      marcador_meta = 'NENHUM'; 
    }
    if (marcador_meta == 'PONTO' || marcador_meta == 'TRACO') { 
      meta_medida = 2;
      lab_meta_fim = "";  //Quando é ponto não pode ter meta final 
      if (invertido == "N") { 
        pos_meta_fim = pos_meta_ini + 0.005; 
      } else {
        pos_meta_ini = pos_meta_fim - 0.005; 
      }
      if (marcador_meta == 'TRACO') { 
        width_linha = width_linha + 50;  
      } 
    } else if (marcador_meta == 'NENHUM') {   
      meta_medida = 0;       
      cor_meta    = 'transparent';
    }  

    // Define a distancia do label do marcador 
    var label_distance = 0;
    if (nome_meta.length > 0) {  // Se tem texto da meta 
      label_distance = -40; 
    } else {
      label_distance = -30;       
    }      
    if (marcador_meta == 'NENHUM') {   // Se não mostrar marcador 
      label_distance = label_distance + meta_medida;
    }    

    if (pos_meta_ini == 0) {   // Se não tem meta inicial, não mostra dados de meta 
      pos_meta_ini   = 0 ;
      pos_meta_fim   = 0 ;  
      lab_meta_ini   = "";
      lab_meta_fim   = "" ; 
      width_linha    = 0; 
      label_distance = 0;
    }


    var option = {
      textStyle:{
        fontFamily: font_family,
        fontWeight: font_weigth
      },
      series : [
      { // Primeira série - principal do gráfico 
        splitNumber: split,
        type:'gauge',
        //startAngle: raio,
        //endAngle: 0,
        startAngle: raioInicial,
        endAngle:  raioFinal,
        center : ['50%', outside],
        radius : medida,
        min: min,
        max: max,
        axisLine: {
          lineStyle: {
            width: 50,
            color: axisColor
          }
        },
        //pequenos traços
        axisTick: {
          distance: -30,
          length: 8,
          lineStyle: {
            color: '#EEE',
            width: 2,
            opacity: '0.5'
          },
          show: false
        },
        //traços grandes
        splitLine: {
          distance: -30,
          length: 40,
          lineStyle: {
            color: '#EEE',
            width: 4,
            opacity: '0.2'
          },
          show: false
        },
        axisLabel: {
          color: 'auto',
          distance: 46,
          fontSize: 12,
          formatter: function(value){
            return Number(parseFloat(value)).toLocaleString();
          },
          show: showValue
        },
        
        pointer: {
          icon: 'triangle',
          itemStyle: {
            color: '#333'
          },
          length: '80%',
          width: 14,
          offsetCenter: [0, '0%']
        },
        anchor: {
            show: true,
            showAbove: true,
            size: 16,
            itemStyle: {
              borderWidth: 7,
              color: '#333',
              borderColor: '#333'
            }
        },
        detail : {
          show: false
        },
        data:[
          { 
            value: valor, 
            name: ''
          }
        ]
      } , 
      { // Segunda série - meta 
        type:'gauge',  
        //startAngle: raio,
        //endAngle: 0,
        startAngle: raioInicial,
        endAngle:  raioFinal,
        center : ['50%', outside],
        radius : medida + meta_medida,
        min: min,
        max: max,
        splitNumber: 100, 
        splitLine: { length: 0},
        axisTick:  { length: 0},
        axisLine: {          
          lineStyle: {
            width: width_linha, 
            color: [ [pos_meta_ini, 'transparent'],
                     [pos_meta_fim, cor_meta],
                     [1, 'transparent']
                   ]
          }
        },
        axisLabel: {
          distance: label_distance,
          color: '#1C1C1C',
          fontSize: 12,
          formatter: function (value) {
            if (value == val_meta_ini_value) {
              return lab_meta_ini;
            } else if (value == val_meta_fim_value) {
              return lab_meta_fim;
            } else { 
              return '';
            }  
          }
        }
      }        
  ]};

  //setTimeout(function(){
  myChart.setOption(option);
  //}, 100);

}

function chartSankey(x){

  var gxml      = document.getElementById('gxml_'+x);
  var dados     = document.getElementById('dados_'+x);
  var atributos = document.getElementById('atributos_'+x); 

  var divObj  = document.getElementById('ctnr_'+x);
  var article = divObj.closest('article');
  
  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      divObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile'  ){
    divObj.style.width = '100%';
  }

  
  let cd_goto     = ''; 
  if (x.split('trl').length > 1) {
    cd_goto = x.split('trl')[1]; 
  } 

  // Valida os dados enviados parao Gráfico 
  //-------------------------------------------------------------------------------
  if(document.getElementById(x+'_ERR')){  
    document.getElementById('ctnr_'+x).innerHTML = document.getElementById(x+'_ERR').innerHTML;
    return false;
  } 
  if(!dados || !gxml) {
    document.getElementById('ctnr_'+x).innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }

  eData = gxml.children[0];
  eLink = gxml.children[1];
  if (!eData || !eLink ){
    document.getElementById('ctnr_'+x).innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }

  try {
    var jsonAgru = JSON.parse(eData.innerHTML.replace(/(\r\n|\n|\r)/g, " "));
  } catch (err){
    document.getElementById('ctnr_'+x).innerHTML = 'Erro no formado dos dados dos agrupadores gerados para o gr&aacute;fico.';
    return false;
  }

  try {
    var jsonLink = JSON.parse(eLink.innerHTML.replace(/(\r\n|\n|\r)/g, " ")); 
  } catch (err){
    document.getElementById('ctnr_'+x).innerHTML = 'Erro no formado dos dados dos links gerados para o gr&aacute;fico.';
    return false;
  }

  var cores = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
      
  // Pega os atributos do gráfico 
  //----------------------------------------------------------------------------------
  var orientacao     = atributos.getAttribute('data-orientacao');
  var linhaCor       = atributos.getAttribute('data-linha_cor');  
  var linhaCurvatura = parseInt(atributos.getAttribute('data-linha_curvatura'))/100;
  var linhaOpacidade = atributos.getAttribute('data-linha_opacidade').replace(',','.'); 
  var espaco_dim     = parseInt(atributos.getAttribute('data-espaco_dim'));
  var alinhamento    = atributos.getAttribute('data-alinhamento');
  var labelPosicao   = atributos.getAttribute('data-label_posicao');  
  var labelConteudo  = atributos.getAttribute('data-label_conteudo');  
  var labelValor      = atributos.getAttribute('data-label_valor');  
  var labelRotacao    = atributos.getAttribute('data-label_rotacao');
  var labelFontSize   = atributos.getAttribute('data-label_fontSize');
  var labelFontFamily = atributos.getAttribute('data-label_fontFamily');
  var valorUM         = atributos.getAttribute('data-um');
  var valorDecimal    = atributos.getAttribute('data-decimal');
  var valorAbreviacao = atributos.getAttribute('data-abreviacao');
  var coresDimensao   = atributos.getAttribute('data-cores'); 
  if(coresDimensao.length > 1){
    cores = coresDimensao.split("|");
  }

  // Define as margens internas (causa erro no layout do gráfico, resolvido em novas versões do eChart  )
  //var arrgrid = [0, 0, 0, 0]
  //for(let i=0;i<espacamento.length;i++){
  //  if (i <= 3) { arrgrid[i] = espacamento[i]; }  
  // }
  
  // Formata o label das dimensões
  var labelFormatter = function(valorUM, valorDecimal, valorAbreviacao, jsonLink ){
    let obj   = {};
    obj = function(params){
      let desc = '';
      if (labelConteudo == 'C' || params.name.split('|')[2].trim().length == 0) { 
        desc = params.name.split('|')[1];
      } else if (labelConteudo == 'D') { 
        desc = params.name.split('|')[2];
      } else { 
        desc = params.name.split('|')[1] + '-' + params.name.split('|')[2];
      } 
      if (labelValor == 'N') { 
        return desc; 
      } else {
        return labelTooltip(desc, params, valorDecimal, valorAbreviacao, 'N', 0, 'S', valorUM,'');
      }  
    } 
    return obj;
  }

  // Formata o tooltip das dimensões/data  
  var dataTooltipFormatter = function(valorUM, valorDecimal, valorAbreviacao ){
    let obj   = {};
    obj.formatter = function(params){
      let desc = '';
      if (labelConteudo == 'C' || params.name.split('|')[2].trim().length == 0) { 
        desc = params.name.split('|')[1];
      } else if (labelConteudo == 'D') { 
        desc = params.name.split('|')[2];
      } else { 
        desc = params.name.split('|')[1] + '-' + params.name.split('|')[2];
      } 
      return labelTooltip(desc, params, valorDecimal, valorAbreviacao, 'N', 0, 'S', valorUM,'');
    } 
    return obj;
  }

  // Formata o tooltip das ligações/linha 
  var tooltipFormatter = function(valorUM, valorDecimal, valorAbreviacao ){
    let obj   = {};
    obj = function(params){
      let origem  = params.name.split('>')[0].trim(), 
          destino = params.name.split('>')[1].trim();

      if (labelConteudo == 'C' || origem.split('|')[2].trim().length == 0) { 
        origem  = origem.split('|')[1];
      } else if (labelConteudo == 'D') {
        origem  = origem.split('|')[2];
      } else { 
        origem  = origem.split('|')[1] + '-' + origem.split('|')[2];
      } 

      if (labelConteudo == 'C' || destino.split('|')[2].trim().length == 0) { 
        destino = destino.split('|')[1];
      } else if (labelConteudo == 'D') {
        destino = destino.split('|')[2];
      } else { 
        destino = destino.split('|')[1] + '-' + destino.split('|')[2];
      } 

      origem = origem + ' => ' + destino;
      return labelTooltip(origem, params, valorDecimal, valorAbreviacao, 'N', 0, 'S', valorUM,'');
    } 
    return obj;
  }
  
  // MOnta algumas propriedades dos dados 
  //------------------------------------------------------------------------------------------------
  var i_cores = 0;
  for(let i=0;i<jsonAgru.length;i++){
    if (i_cores > cores.length) { i_cores = 0;} else {i_cores = i_cores + 1;}
    jsonAgru[i].itemStyle = { color: cores[i_cores]} ;
    jsonAgru[i].tooltip   = dataTooltipFormatter(valorUM, valorDecimal, valorAbreviacao); 
  }

  //var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer });
  var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer, height: document.getElementById('ctnr_'+x).clientHeight, width: document.getElementById('ctnr_'+x).clientWidth }); 


  var option = {
    tooltip: {
      trigger: 'item',
      triggerOn: 'mousemove'
    },
    animation: true,
    series :{
      type:   'sankey',
      orient: orientacao,
      nodeAlign: alinhamento,
      // nodeWidth: largura_dim,
      nodeGap: espaco_dim,
      tooltip: {
        formatter : tooltipFormatter(valorUM, valorDecimal, valorAbreviacao)
      },      
      label: {
        position: labelPosicao,
        rotate: labelRotacao, 
        fontSize: labelFontSize,
        fontFamily: labelFontFamily,
        backgroundColor: 'transparent',
        formatter: labelFormatter(valorUM, valorDecimal, valorAbreviacao, jsonLink)
      },
      lineStyle: {
        color: linhaCor,
        curveness: linhaCurvatura,
        opacity: linhaOpacidade
      },
      emphasis: {
        focus: 'adjacency'
      },
      data: jsonAgru,
      links: jsonLink
    }  
  }

  myChart.setOption(option);
  myChart.on('click', clicker);
  
  // Geração do PNG (com título) - Aguarda 5 segundos para garantir que o gráfico já tenha sido montado 
  //---------------------------------------------------------------
  setTimeout(function(){
    if(document.getElementById(x+'more')){
      var a = document.createElement('a');
      a.classList.add('download_button');
      a.setAttribute('download', document.getElementById(x+'_ds').innerText.replace(/ /g, "_").toLowerCase());

      // Adiciona um título para sair no PNG 
      option.title = {
        text: document.getElementById(x+'_ds').innerText,
        left: 'center',
        top: 0
      };
      myChart.setOption(option, { notMerge: true }); 

      // Gera o PNG 
      a.href = myChart.getDataURL({
        type: 'png',
        pixelRatio: 1,
        backgroundColor: '#FFF'
      });

      // Retira o título, volta os parâmetros(visual) original do gráfico 
      option.title  = {}; 
      myChart.setOption(option, { notMerge: true });   // Atualiza o gráfico sem o título         

      if(document.getElementById(x+'more')){
        document.getElementById(x+'more').querySelector('.page_png').appendChild(a);
      }
    }
  }, 1500);

}

function chartScatter(x){

  var gxml      = document.getElementById('gxml_'+x);
  var dados     = document.getElementById('dados_'+x);
  var atributos = document.getElementById('atributos_'+x); 

  var divObj  = document.getElementById('ctnr_'+x);
  var article = divObj.closest('article');
  
  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      divObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile' ){
    divObj.style.width = '100%';
  }

  
  let cd_goto     = ''; 
  if (x.split('trl').length > 1) {
    cd_goto = x.split('trl')[1]; 
  } 

  var colunas     = dados.getAttribute('data-coluna').replace("(BR)", " ").replace("<BR>", " ").split('|');
  var agrupadores = dados.getAttribute('data-agrupadores').replace("(BR)", " ").replace("<BR>", " ").split('|');

  // Valida os dados enviados parao Gráfico 
  //-------------------------------------------------------------------------------
  if(document.getElementById(x+'_ERR')){  
    document.getElementById('ctnr_'+x).innerHTML = document.getElementById(x+'_ERR').innerHTML;
    return false;
  } 
  if(!dados || !gxml) {
    document.getElementById('ctnr_'+x).innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }

  if (!gxml.children[0] || !gxml.children[1]){
    document.getElementById('ctnr_'+x).innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }
  
  var jsonLista    = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
  var jsonListaAux = gxml.children[1].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
  try {
    var jsonParsed = JSON.parse("{"+jsonLista+"}");
    var jsonAux    = JSON.parse(jsonListaAux);
  } catch (err){
    alerta('', TR_QR_IN);
    return;
  }
  
  var maiorX   = jsonAux.maior_x,
      menorX   = jsonAux.menor_x,
      maiorY   = jsonAux.maior_y,
      menorY   = jsonAux.menor_y, 
      maiorDim = jsonAux.maior_dim; 

      var cores_ponto = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
  
  // Pega os atributos do gráfico 
  //----------------------------------------------------------------------------------
  var labelYpos     = atributos.getAttribute('data-label_ypos');
  var labelXpos     = atributos.getAttribute('data-label_xpos');
  var labelDisYpos = atributos.getAttribute('data-label_dis_ypos');
  var labelDisXpos = atributos.getAttribute('data-label_dis_xpos');
  var legendaExibir  = atributos.getAttribute('data-legenda_exibir');
  var axisXmax       = atributos.getAttribute('data-axis_x_max');  
  var axisXmin       = atributos.getAttribute('data-axis_x_min');  
  var axisYmax       = atributos.getAttribute('data-axis_y_max');  
  var axisYmin       = atributos.getAttribute('data-axis_y_min');  
  var labelPosicao   = atributos.getAttribute('data-label_posicao');  
  var labelConteudo  = atributos.getAttribute('data-label_conteudo');  
  var pontoDimensao  = parseInt(atributos.getAttribute('data-ponto_dimensao'));    
  var labelRotacao    = atributos.getAttribute('data-label_rotacao');
  var labelFontSize   = atributos.getAttribute('data-label_fontSize');
  var labelCor        = atributos.getAttribute('data-label_cor');  
  var labelFontFamily = atributos.getAttribute('data-label_fontFamily');
  var valorUM         = atributos.getAttribute('data-um').split('|');
  var valorDecimal    = atributos.getAttribute('data-decimal');
  var valorAbreviacao = atributos.getAttribute('data-abreviacao');
  var espacamento     = atributos.getAttribute('data-espacamento').split('|');
  var grade           = atributos.getAttribute('data-grade');  
  var sombraPonto     = atributos.getAttribute('data-sombra_ponto');    
  var coresPonto      = atributos.getAttribute('data-cores_ponto');
  if(coresPonto.length > 1){
    cores_ponto = coresPonto.split("|");
  }
  
  // Monta as cores de sobra e degrade dos pontos 
  var cores_degrade = [], 
      cores_sombra  = [], 
      pl_sombra  = 0.80,
      pl_degrade = 1.30; 
  for(let i in cores_ponto){
    var color = cores_ponto[i];
    var R = parseInt(color.substring(1,3),16);
    var G = parseInt(color.substring(3,5),16);
    var B = parseInt(color.substring(5,7),16);
    // Escurece (SOBRA)
    RR = parseInt(R * pl_sombra);
    GG = parseInt(G * pl_sombra);
    BB = parseInt(B * pl_sombra);
    RR = Math.round((RR>0)?RR:0);  
    GG = Math.round((GG>0)?GG:0);  
    BB = Math.round((BB>0)?BB:0);  
    cores_sombra.push('rgba('+RR+','+GG+','+BB+',0.3)');
    // Clareia ponto (efeito degrade)
    RR = parseInt(R * pl_degrade);
    GG = parseInt(G * pl_degrade);
    BB = parseInt(B * pl_degrade);
    RR = Math.round((RR<255)?RR:255);  
    GG = Math.round((GG<255)?GG:255);  
    BB = Math.round((BB<255)?BB:255);  
    cores_degrade.push('rgba('+RR+','+GG+','+BB+')');    
  }  

  // Margens internas do gráfico 
  let arrgrid = [];
  if(espacamento.length > 0 && espacamento.length < 5){
    for(let i=0;i<espacamento.length;i++){
      arrgrid[i] = espacamento[i];
    }
  }
   
  // Define configuração dos eixos, exibição das linhas de grade e max e min, label 
  let axisX = {splitLine: { show: false }},
      axisY = {splitLine: { show: false }};
  if  (grade != 'N') {
    if (grade == 'A' || grade == 'V') { axisX.splitLine = { lineStyle: { type: 'dashed'} } ; }
    if (grade == 'A' || grade == 'H') { axisY.splitLine = { lineStyle: { type: 'dashed'} } ; }
  }   
  if (axisXmax.length > 0) { axisX.max = Math.round(eval(axisXmax.toUpperCase().replace('[MAIORVALOR]',maiorX)) ); }  
  if (axisYmax.length > 0) { axisY.max = Math.round(eval(axisYmax.toUpperCase().replace('[MAIORVALOR]',maiorY)) ); }  
  if (axisXmin.length > 0) { axisX.min = Math.round(eval(axisXmin.toUpperCase().replace('[MENORVALOR]',menorX)) ); }  
  if (axisYmin.length > 0) { axisY.min = Math.round(eval(axisYmin.toUpperCase().replace('[MENORVALOR]',menorY)) ); } 
  if (labelYpos != 'ocultar') {
    axisY.name = agrupadores[0];
    axisY.nameLocation = labelYpos;  
    if (labelDisYpos.length > 0) {
      try {axisY.nameGap = parseInt(labelDisYpos); } 
      catch {}
    }  
  }
  if (labelXpos != 'ocultar') {
    axisX.name = agrupadores[1];
    axisX.nameLocation = labelXpos;
    if (labelDisXpos.length > 0) {
      try {axisX.nameGap = parseInt(labelDisXpos); } 
      catch {}
    }  
 }


  // Conteúdo do label dos pontos 
  var labelFormatter = function(){
    let obj   = {};
    obj = function(params){
      let desc = '';
      if (labelConteudo == 'C' || params.data[6].length == 0) { 
        desc = params.data[5];
      } else if (labelConteudo == 'D') { 
        desc = params.data[6];
      } else { 
        desc = params.data[5] + '-' + params.data[6];
      } 
      return desc;
    } 
    return obj;
  }

  // Conteúdo do tooltip dos pontos 
  var TooltipFormatter = function(){
    let obj   = {};
    obj = function(params){
      let desc   = '',
          valor  = {},
          valform = ''; // Valor formatado 
      let TooltipColunas = [],
          TooltipValores = [];
      TooltipColunas = colunas.concat(agrupadores);

      desc = params.data[3];
      if (params.data[4].length > 0 && params.data[3] != params.data[4] ) {
        desc = desc + ' - ' + params.data[4];
      }       
      TooltipValores.push(desc);

      if (params.data[5].length > 0) {
        desc = params.data[5];
        if (params.data[6].length > 0 && params.data[5] != params.data[6]) {
          desc = desc + ' - ' + params.data[6];
        }  
        TooltipValores.push(desc);        
      } 

      if (valorUM.length >= 1) { um = valorUM[0];} else { um = '';}
      valor.value = params.data[0]; 
      valform = labelTooltip('', valor, valorDecimal, valorAbreviacao, 'N', 0, 'S', um, '');
      TooltipValores.push(valform);
      
      if (valorUM.length >= 2) { um = valorUM[1];} else { um = '';}
      valor.value = params.data[1];       
      valform = labelTooltip('', valor, valorDecimal, valorAbreviacao, 'N', 0, 'S', um,'');
      TooltipValores.push(valform);      
      //desc = desc + ' x ' + valform;      

      if (params.data[2].length > 0) {
        if (valorUM.length >= 3) { um = valorUM[2];} else { um = '';}
        valor.value = params.data[2];       
        valform = labelTooltip('', valor, valorDecimal, valorAbreviacao, 'N', 0, 'S', um,'');
        TooltipValores.push(valform);      
        // desc = desc + ' x ' + valform;  
      } 

      desc = '<table class="tooltip-grafico">';
      desc = desc + '<thead><tr>';
      for(let i=0;i<TooltipColunas.length;i++){
        desc = desc + '<th>' + TooltipColunas[i] + '</th>';
      }          
      desc = desc + '</tr></thead>';
      desc = desc + '<tbody><tr>';
      for(let i=0;i<TooltipColunas.length;i++){
        desc = desc + '<td>' + TooltipValores[i] + '</td>';
      }          
      desc = desc + '</tr></tbody>';
      desc = desc + '</table>';

      return desc;
    } 
    return obj;    
  }

  // Define a largura/dimensão dos pontos
  var serieSymbolSize = function(){
    let obj   = {};
    obj = function(data){
      let dim = 0;
      if (pontoDimensao > 0) {
        if (maiorDim > 0) { 
          dim = pontoDimensao / maiorDim * parseFloat(data[2]); 
        } else {
          dim = pontoDimensao;
        }  
      }  
      return dim;
    } 
    return obj;    
  }

  
  // Monta as series do gráfico 
  //-------------------------------------------------------------------
  let serie         = {},
      series        = [],
      label_legend  = [],
      name          = '';
  for(let grupo in jsonParsed){
    serie = {}; 
    if (labelConteudo == 'N' || labelConteudo == 'C' || jsonParsed[grupo].name.length == 0) {
      name = jsonParsed[grupo].cod;
    } else if (labelConteudo == 'D') {
      name = jsonParsed[grupo].name;
    } else {
      name = jsonParsed[grupo].cod + '-' + jsonParsed[grupo].name;
    }
    label_legend.push(name);
    serie.name = name; 
    serie.type = 'scatter',
    serie.data = jsonParsed[grupo].valores;
    serie.symbolSize = serieSymbolSize();  // define a dimensão de cada ponto
    if (sombraPonto == 'S') {
      serie.itemStyle = {
        shadowBlur: 8,
        shadowColor: cores_sombra[grupo], // rgba(0, 0, 0, 0.5)',
        shadowOffsetY: 5,
        color: new echarts.graphic.RadialGradient(0.4, 0.3, 1, [
          {
            offset: 0,
            color: cores_ponto[grupo]
          },
          {
            offset: 1,
            color: cores_ponto[grupo+1]
          }
        ])
      };   
    } else {
      serie.itemStyle = {color: cores_ponto[grupo] }; 
    }  

    if (labelConteudo != 'N')  {
      serie.label = {
        show: true,
        rotate: labelRotacao, 
        color: labelCor,
        fontSize: labelFontSize,
        fontFamily: labelFontFamily,
        formatter: labelFormatter(labelConteudo),  // Define o conteúdo do label de cada ponto 
        position: labelPosicao.toLowerCase().replace('margin',''),
        minMargin: 2
      }
    }  
    
    if (labelPosicao.toLowerCase().indexOf('margin') == 0) {
      serie.labelLine = { show: true, length2: 5, lineStyle: { color: labelCor } };   // Cria linha entre o ponto e o label 
      if (labelPosicao.toLowerCase() == 'margintop') {
        serie.labelLayout = { y: 30, align: 'center', hideOverlap: true, moveOverlap: 'shiftX'} ;         
        arrgrid[0] + 20;
      } else {
        serie.labelLayout = function () { return { x: myChart.getWidth() - 100, moveOverlap: 'shiftY' } }; 
      } 
    }

    series.push(serie);
  }

  if (legendaExibir == 'N') {
    label_legend = [];
  }

  // Monta o Gráfico 
  //var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer });
  var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer, height: document.getElementById('ctnr_'+x).clientHeight, width: document.getElementById('ctnr_'+x).clientWidth }); 

  var option = {
    xAxis: axisX,
    yAxis: axisY,
    grid: { 
      y: arrgrid[0], 
      x2: arrgrid[1], 
      y2: arrgrid[2], 
      x: arrgrid[3] 
    },
    legend: {
      data: label_legend
    },    
    tooltip: {
      showDelay: 0,
      formatter: TooltipFormatter(),
    },
    animation: true,
    series: series
  };
  
  myChart.setOption(option);
  myChart.on('click', clicker);
  
  // Geração do PNG (com título) - Aguarda 5 segundos para garantir que o gráfico já tenha sido montado 
  //---------------------------------------------------------------
  setTimeout(function(){
    if(document.getElementById(x+'more')){
      var a = document.createElement('a');
      a.classList.add('download_button');
      a.setAttribute('download', document.getElementById(x+'_ds').innerText.replace(/ /g, "_").toLowerCase());

      // Adiciona um título para sair no PNG, e move legend e posição do grid para não sobrepor o título  
      option.title = {
        text: document.getElementById(x+'_ds').innerText,
        left: 'center',
        top: 0
      };
      option.legend.top = 20;
      option.grid.y = 50; // arrgrid[0] + 20;
      myChart.setOption(option, { notMerge: true }); 

      // Gera o PNG 
      a.href = myChart.getDataURL({
        type: 'png',
        pixelRatio: 1,
        backgroundColor: '#FFF'
      });

      // Retira o título, volta os parâmetros(visual) original do gráfico 
      option.title  = {}; 
      option.legend.top = '';
      option.grid.y = arrgrid[0];      
      myChart.setOption(option, { notMerge: true });   // Atualiza o gráfico sem o título         

      if(document.getElementById(x+'more')){
        document.getElementById(x+'more').querySelector('.page_png').appendChild(a);
      }
    }
  }, 1500);

}


function chartRadar(x){

  var gxml      = document.getElementById('gxml_'+x);
  var dados     = document.getElementById('dados_'+x);
  var atributos = document.getElementById('atributos_'+x); 

  var ctnrObj  = document.getElementById('ctnr_'+x);
  var article = ctnrObj.closest('article');

  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      ctnrObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile' ){
    ctnrObj.style.width = '100%';
  }

  
  let cd_goto     = ''; 
  if (x.split('trl').length > 1) {
    cd_goto = x.split('trl')[1]; 
  } 

  // Valida os dados enviados parao Gráfico 
  //-------------------------------------------------------------------------------
  if(document.getElementById(x+'_ERR')){  
    ctnrObj.innerHTML = document.getElementById(x+'_ERR').innerHTML;
    return false;
  } 
  if(!dados || !gxml) {
    ctnrObj.innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }

  if (!gxml.children[0]){
    ctnrObj.innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }
  
  var jsonIndLista  = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
  var jsonLista = gxml.children[1].innerHTML.replace(/(\r\n|\n|\r)/g, " ");

  try {
    var jsonInd    = JSON.parse(jsonIndLista);
    var jsonParsed = JSON.parse(jsonLista);
  } catch (err){
    ctnrObj.innerHTML = 'Erro carregando dados, sem dados ou formato de dados inconsistente.';
    return;
  }

  var cores = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
  
  // Pega dados do objeto 
  var agrupadoresReal = dados.getAttribute('data-agrupadoresreal').split('|');

  // Pega os atributos do gráfico 
  //----------------------------------------------------------------------------------
  var labelConteudo  = atributos.getAttribute('data-label_conteudo');  
  var labelFontSize   = atributos.getAttribute('data-label_fontSize');
  var labelCor        = atributos.getAttribute('data-label_cor');  
  var labelFontFamily = atributos.getAttribute('data-label_fontFamily');
  var valorUM         = atributos.getAttribute('data-um').split('|');
  var valorDecimal    = atributos.getAttribute('data-decimal');
  var valorAbreviacao = atributos.getAttribute('data-abreviacao');
  var radarForma      = atributos.getAttribute('data-radar_forma');    
  var radarRaio       = atributos.getAttribute('data-radar_raio');    
  var areaPreencher   = atributos.getAttribute('data-area_preencher');    
  var mostrarTooltip = atributos.getAttribute('data-mostrar_tooltip');
  var faixasQtd       = atributos.getAttribute('data-faixas_qtd');    
  var coresArea       = atributos.getAttribute('data-cores');
  var coresFaixa      = atributos.getAttribute('data-faixas_cores');
  var corLinhas       = atributos.getAttribute('data-linhas_cor');
  var dataMax         = atributos.getAttribute('data-max');

  
  if (radarRaio.length == 0) { 
    radarRaio = '75'; 
  } else{ 
    radarRaio = radarRaio.match(/[0-9]+/)[0]
  };

  if (coresArea.length > 1)  { 
    cores = coresArea.split("|"); 
  };
    
  // Monta as cores das faixas
  var cores_faixa = []
  if(coresFaixa.length > 0){
    cores_faixa = coresFaixa.split("|");
  }
  // Monta as cores das áreas internas
  var cores_area = []
  for(let i in cores){
    cores_area.push(hexToRgba (cores[i], '0.7', 0));  // Clareia a cor 
  }  

  // Monta as series do gráfico 
  let data          = {},
  serie_data        = [],
  name              = '';
  dataMaxima        = 0;
  for(let area in jsonParsed){
    data = {}; 
    name = '';  //dados[0] - código subgrupo , dados[1]=Descrição subgrupo , dados[2]=nome coluna subgrupo,  dados[3]=nome coluna de valor 
    if (jsonParsed[area].dados[0].length > 0) { // tem sub grupo referente a área do gráfico 
      if (labelConteudo == 'N' || labelConteudo == 'C' || jsonParsed[area].dados[1].length == 0) {
        name = jsonParsed[area].dados[0];
      } else if (labelConteudo == 'D') {
        name = jsonParsed[area].dados[1];
      } else {
        name = jsonParsed[area].dados[0] + '-' + jsonParsed[area].dados[1];
      }
    }
    data.cod   = jsonParsed[area].dados[0];
    data.col   = jsonParsed[area].dados[2];
    data.name  = (name.length>0?name + '-':'') + jsonParsed[area].name;
    data.value = jsonParsed[area].valores;
    
    if (dataMaxima < Number(Math.max(...data.value).toFixed(2))) {
      data.max = Number(Math.max(...data.value).toFixed(2));
      dataMaxima = Number(Math.max(...data.value).toFixed(2));
    } else {
      data.max = dataMaxima;
    } 
    
    if (areaPreencher == 'S') { 
      data.areaStyle = { color: cores_area[area] } ;
    }  
    
    data.um = '';
    for (let j in agrupadoresReal) {
      if (agrupadoresReal[j] == jsonParsed[area].dados[3]) {
        if (j < valorUM.length) {
          data.um = valorUM[j];
        }  
      }
    }
    
    if (dataMax.toUpperCase() !== 'AUTO') {
      data.value = data.value.map((value) => {
        if (value > dataMax) {
          return null; 
        }
        return value; 
      });
    }
    
    serie_data.push(data);
  }
  try {
    //validando se o atributo possuí valor setado pelo usuário
    if(dataMax.toUpperCase() !== 'AUTO'){
      data.max = dataMax;
    };
  } catch (e) {
    console.log('Erro ao atribuir dataMax: '+e)
  }

  
  // Monta os indicadores 
  for(let i in jsonInd){
    if (labelConteudo == 'C' || jsonInd[i].name.length == 0) {
      jsonInd[i].name = jsonInd[i].cod;
    } else if (labelConteudo == 'A') {
      jsonInd[i].name = jsonInd[i].cod + '-' + jsonInd[i].name;
    }
    jsonInd[i].max = data.max;
  }  
  
  // Conteúdo do tooltip das áreas 
  var tooltipFormatter = function(params) {
    
    if (mostrarTooltip == 'S') {

      let desc = '',
      um = '',
      valform = '',
      valor = {};
    
      //montando a div do cabeçalho (botão fechar e título)
      desc =       '<div>';
      desc = desc +   '<a class="fechar-tooltip"></a>';
      desc = desc +   '<span class="tooltip-radar-title">'+params.data.name +'</span>';
      desc = desc +'</div><br/>';
      //abrindo a tabela
      desc = desc + '<table class="tooltip-radar">';
      //percorrendo as tr e tds da tabela
      for (let i in params.value) {
        valor.value = params.value[i];
        valform = labelTooltip('', valor, valorDecimal, valorAbreviacao, 'N', 0, 'S', params.data.um,'');

        if (valform == null || valform == '') {
          valform = 'Excede o valor máximo';
        };

        desc = desc + '<tr><td align=left cellspacing=0>' + jsonInd[i].name + '</td><td align=right>' + valform + '</td></tr>';
      };
      desc = desc + '</table>';
      //cria um div e adiciona uma classe para inserir a tabela dentro.
      var tableContainer = document.createElement('div');
      tableContainer.classList.add('tooltip-radar');
      tableContainer.innerHTML = desc;
    
      if (ctnrObj) {
        // verifica se ja existe a tabela no html e remove.
        var existingTable = ctnrObj.querySelector('.tooltip-radar');
        if (existingTable) {
          ctnrObj.removeChild(existingTable);
        };
        //evento para "fechar" pelo botão
        tableContainer.addEventListener('click', function(event) {
          if (event.target.classList.contains('fechar-tooltip')) {
            ctnrObj.removeChild(tableContainer);
          }
        });
        //adiciona a tabela.
        ctnrObj.appendChild(tableContainer);
      };
    
      return desc;

    }
  };

  // Monta o Gráfico 
  //var myChart = echarts.init(ctnrObj, null, { renderer: chartRenderer });
  var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer, height: document.getElementById('ctnr_'+x).clientHeight, width: document.getElementById('ctnr_'+x).clientWidth }); 

  var option = {
    color: cores, 
    legend: {},      
    tooltip: {
      show: (mostrarTooltip == 'S'),
      trigger: 'axis',
      position: 'absolute',
      extraCssText: 'max-height: 98%; overflow-y: auto; font:8px',
      formatter: tooltipFormatter,
    },
    
    radar: {
      radius : radarRaio+'%',
      shape: radarForma,
      indicator: jsonInd,
      startAngle: 90,
      splitNumber: faixasQtd,
      splitArea: {
        areaStyle: {
          color: cores_faixa,
          shadowColor: 'rgba(0, 0, 0, 0.2)',
          shadowBlur: 10
        }
      },
      axisName: {
        formatter: '{value}',
        color: labelCor,
        fontFamily: labelFontFamily,
        fontSize: labelFontSize,

      },
      axisLine:  { lineStyle: { color: corLinhas } },
      splitLine: { lineStyle: { color: corLinhas } }      
    },    
    series: [{
      type: 'radar', 
      emphasis: {
        lineStyle: {
          width: 4
        },
        focus: 'none'
      },
      data: serie_data,
      // Remova o 'clickable' daqui
    }],
  };
  
  myChart.setOption(option);

  myChart.on('click', function(params) {
    // Verifique se o clique ocorreu na série do radar
    if (params.componentType === 'series' && params.seriesType === 'radar') {
      // Chame a função tooltipFormatter com os parâmetros corretos
      myChart.setOption({
        tooltip: {
          formatter: tooltipFormatter(params),
        },
      });
    }
  });
 




  // Geração do PNG (com título) - Aguarda 5 segundos para garantir que o gráfico já tenha sido montado (na versão atual do echarts não tem como alterar a margem superior, então se colocar o título vai ficar por baixo da legenda)
  //---------------------------------------------------------------
  setTimeout(function(){
    if(document.getElementById(x+'more')){
      var a = document.createElement('a');
      a.classList.add('download_button');
      a.setAttribute('download', document.getElementById(x+'_ds').innerText.replace(/ /g, "_").toLowerCase());

      // Gera o PNG 
      a.href = myChart.getDataURL({
        type: 'png',
        pixelRatio: 1,
        backgroundColor: '#FFF'
      });

      if(document.getElementById(x+'more')){
        document.getElementById(x+'more').querySelector('.page_png').appendChild(a);
      }
    }
  }, 1500);
}

function chartCalendario(x) {

  var gxml      = document.getElementById('gxml_'+x);
  var dados     = document.getElementById('dados_'+x);
  var atributos = document.getElementById('atributos_'+x); 

  var ctnrObj  = document.getElementById('ctnr_'+x);
  var article = ctnrObj.closest('article');

  if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO') {  
    if (article != null) {
      if(document.getElementById('atributos_'+x).getAttribute('data-altura').toUpperCase() == 'AUTO' && article.clientHeight < 500 ){
        var alturaElemento = 500;
      }else{
        var alturaElemento = article.clientHeight;
      }
      ctnrObj.style.height = alturaElemento - 40 + 'px'; 
    }
  }

  var checkMobile = mobilecheck();
  if (checkMobile == 'mobile' ){
    ctnrObj.style.width = '100%';
  }

  
  let cd_goto     = ''; 
  if (x.split('trl').length > 1) {
    cd_goto = x.split('trl')[1]; 
  } 

  // Valida os dados enviados parao Gráfico 
  //-------------------------------------------------------------------------------
  if(document.getElementById(x+'_ERR')){  
    ctnrObj.innerHTML = document.getElementById(x+'_ERR').innerHTML;
    return false;
  } 
  if(!dados || !gxml) {
    ctnrObj.innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }

  if (!gxml.children[0]){
    ctnrObj.innerHTML = 'Erro buscando dados para geração do gráfico.';
    return false;
  }
  
  var jsonLista = gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
  var range = gxml.children[1].innerHTML.replace(/(\r\n|\n|\r)/g, " ");
  try {
    jsonLista = jsonLista.replace(',]', ']');
    var jsonParsed = JSON.parse(jsonLista);
  } catch (err){
    ctnrObj.innerHTML = 'Erro carregando dados, sem dados ou formato de dados inconsistente.';
    return;
  }

  var cores = ["#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8","#67BAE9","#2F85C6","#D7BD75","#EE8D3D","#5A965A","#88C2C0","#205FAA","#3199B7","#EDC664","#F79C5E","#55AA55","#117A72","#CC5A0D","#F5A721","#45BCC1","#D2C6C9","#3199B7","#369867","#67BAE9","#045E9B","#DD722A","#8CD0E5","#9ACC99","#F4E626","#026536","#1FB5A3","#F6D136","#257E9E","#E87D34","#F6E537","#0A4680","#4F792F","#4A68D8","#45BCC1","#F98F38","#CCB636","#1686A8","#228B22","#1D5C96","#ED6000","#0C9696","#E8C73F","#507944","#3A7BD8","#C66620","#69AFF4","#63AF61","#CCD649","#D1A14B","#4D72CE","#00AFD8"];
  
  // Pega dados do objeto 
  var agrupadores = dados.getAttribute('data-agrupadores').split('|');

  // Pega os atributos do gráfico 
  //----------------------------------------------------------------------------------
  var orientacaoCalendario  = atributos.getAttribute('data-orientacao_calendario');  
  var valorNoCalendario  = atributos.getAttribute('data-valor_no_calendario');  

  var mostrarMes  = atributos.getAttribute('data-mostrar_mes');  
  var mostrarSemana  = atributos.getAttribute('data-mostrar_semana');  
  var mostrarAno  = atributos.getAttribute('data-mostrar_ano');  
  var tamFonteMes  = atributos.getAttribute('data-tam_fonte_mes');  
  var tamFonteSemana  = atributos.getAttribute('data-tam_fonte_semana');  
  var tamFonteAno  = atributos.getAttribute('data-tam_fonte_ano');  
  var tamFonteGeral  = atributos.getAttribute('data-tam_fonte_geral');  

  var corFracaCalendario  = atributos.getAttribute('data-corfraca_calendario');  
  var corForteCalendario  = atributos.getAttribute('data-corforte_calendario');  
  var decimal = atributos.getAttribute('data-decimal');  

  var largura        = document.getElementById('ctnr_'+x).clientWidth;
  var altura         = document.getElementById('ctnr_'+x).clientHeight;

  try {
    decimal = parseInt(decimal);
  } catch (error) {
    
  }
 
  // Monta o Gráfico 
  var myChart = echarts.init(document.getElementById('ctnr_'+x), null, { renderer: chartRenderer, height: document.getElementById('ctnr_'+x).clientHeight, width: document.getElementById('ctnr_'+x).clientWidth }); 

  let firstSetValues = jsonParsed.map(item => {
    if (isNaN(item.values[0].value)){
      return 0;
    } else {
      return item.values[0].value;
    }
  });
  let min = Math.min(...firstSetValues);
  let max = Math.max(...firstSetValues);

  const dateList = jsonParsed;
  
  const heatmapData = [];
  var lunarData = [];
  for (let i = 0; i < dateList.length; i++) {
    if (isNaN(dateList[i].values[0].value)){
      heatmapData.push([dateList[i].date, 0]);
    } else {
      heatmapData.push([dateList[i].date, dateList[i].values[0].value]);
    }
    lunarData.push([dateList[i].date, dateList[i].values]);
  }

  var rangeArr = JSON.parse(range);

  if (rangeArr[0] == rangeArr[1]) {
    var [year, month] = rangeArr[0].split('-').map(Number);
    var startDate = new Date(year, month - 1, 1);
    var endDate = new Date(year, month, 0); 
  } else {
    var [year, month] = rangeArr[0].split('-').map(Number);
    var startDate = new Date(year, month - 1, 1); 
    var [year, month] = rangeArr[1].split('-').map(Number);
    var endDate = new Date(year, month, 0); 

    var year = endDate.getFullYear();
    var month = String(endDate.getMonth() + 1).padStart(2, '0'); 
    var date = String(endDate.getDate()).padStart(2, '0'); 
    
    var formattedDate = year + '-' + month + '-' + date;
    rangeArr[1] = formattedDate; 
  }

  const allDates = [];
  let currentDate = new Date(startDate);

  while (currentDate <= endDate) {
    allDates.push(currentDate.toISOString().slice(0,10));
    currentDate.setDate(currentDate.getDate() + 1);
  }

  const formattedLunarData = allDates.map(date => {
    const found = lunarData.find(item => item[0] === date);
    if (found) {
      return [found[0], found[1]];
    } else {
      return [date, [{value: ''}]];
    }
  });

  lunarData = formattedLunarData;
  
  option = {
    textStyle: {
      fontSize: tamFonteGeral,
    },
    tooltip: {
      formatter: function (params) {
    
      const lunarDataPoint = lunarData.find(dataPoint => dataPoint[0] === params.data[0]);
      const lunarValue = lunarDataPoint ? lunarDataPoint[1] : '';

      let tooltip = '<div style="text-align: left;">';
      
      for (let i = 0; i < lunarValue.length; i++) {

        if (decimal != '' && Number.isInteger(decimal)) { 
          if (typeof lunarValue[i].value === 'number' && !isNaN(lunarValue[i].value)) {
            try{
              lunarValue[i].value = parseFloat(lunarValue[i].value).toFixed(decimal);
            } catch (e){}
          }
        }

        tooltip += agrupadores[i] + ' : ' + lunarValue[i].value + '<br>';

      }
      
      tooltip += '</div>';

      return tooltip;
      }
    },
    visualMap: {
      show: false,
      min: min,
      max: max,
      calculable: true,
      seriesIndex: [1],
      orient: 'horizontal',
      left: 'center',
      bottom: 20,
      inRange: {
        color: [corFracaCalendario, corForteCalendario],
        opacity: 0.3
      },
      controller: {
        inRange: {
          opacity: 0.5
        }
      }
    },
    calendar: [
      {
        left: 'center',
        top: 'middle',
        height: (altura - 200),
        width:  (largura - 200), 
        yearLabel: {  
          show: mostrarAno != 'N' ? true : false,
          fontSize: tamFonteAno
        },
        orient: orientacaoCalendario,
        dayLabel: {
          show: mostrarSemana != 'N' ? true : false,
          fontSize: tamFonteSemana,
          firstDay: 1,
          nameMap: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
        },
        monthLabel: {
          show: mostrarMes != 'N' ? true : false,
          fontSize: tamFonteMes,
          nameMap: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']
        },
        range: rangeArr[0] == rangeArr[1] ? rangeArr[0] : rangeArr
      }
    ],
    series: [
      {
        type: 'scatter',
        coordinateSystem: 'calendar',
        symbolSize: 0,
        label: {
          show: true,
          formatter: function (params) {
            var d = echarts.number.parseDate(params.value[0]);

            if (decimal !== '' && Number.isInteger(decimal) && params.value[1][0].value !== '') { 
              try{
                params.value[1][0].value = params.value[1][0].value.toFixed(decimal);
              } catch(e) {}
            }

            if (valorNoCalendario != 'N') {
              return d.getDate() + '\n\n' + params.value[1][0].value;
            } else {
              return d.getDate();
            }

          },
          color: '#000'
        },
        data: lunarData,
        silent: true
      },
      {
        name: 'valor',
        type: 'heatmap',
        coordinateSystem: 'calendar',
        data: heatmapData
      }
    ]
  };

  myChart.setOption(option);
  myChart.on('click', clicker);



}


var resizerDelay = 0;

window.addEventListener("resize", function(){
  resizerDelay = resizerDelay+1;
    if(resizerDelay > 10){
      var alldrags = document.querySelectorAll('.dragme');
        var sizer = alldrags.length;
        for(var ig = 0;ig<sizer;ig++){
            if(document.getElementById('dados_'+alldrags[ig].id)){
              //não redimensiona bug
              renderChart(alldrags[ig].id);
            }
            if(document.getElementById(alldrags[ig].id).classList.contains('front')){
              topDistance(alldrags[ig].id);
            }
        }
    resizerDelay = 0;
  }
});

function renderChart(obj){
  if(document.getElementById(obj) && document.getElementById('dados_'+obj)){
    var tipo = document.getElementById('dados_'+obj).getAttribute('data-tipo');
    switch(tipo){
      case 'ORGANOGRAMA': chartGauge(obj); activeorga(obj, '',''); break;
      case 'PONTEIRO': chartGauge(obj); break;
      case 'BARRAS': chart(obj); break;
      case 'COLUNAS': chart(obj); break;
      case 'LINHAS': chart(obj); break;
      case 'PIZZA': chartSlice(obj); break;
      case 'ROSCA': chartDonut(obj); break;
      case 'VALOR': chartPercent(obj); break;
      case 'MAPA': chartMap(obj); break;
      case 'SANKEY': chartSankey(obj); break;
      case 'SCATTER': chartScatter(obj); break;
      case 'RADAR': chartRadar(obj); break;
      case 'CALENDARIO': chartCalendario(obj); break;
    }
  }
}


function renderChartDirect(obj){
  
  if(document.getElementById(obj) && document.getElementById('dados_'+obj)){
    var tipo = document.getElementById('dados_'+obj).getAttribute('data-tipo');
    var gxml, dados;

    // Tratamento para agrupadores de troca de coluna - 28/01/2022 
    var param_troca = ''
        ordem       = ''; 
    if (document.getElementById('dados_'+obj)) { 
      dados = document.getElementById('dados_'+obj)
      if (dados.getAttribute('data-agrupador_troca') && dados.getAttribute('data-agrupador_troca').length != 0 && dados.getAttribute('data-agrupador_troca') != 'null' && dados.getAttribute('data-agrupador_troca') != 'N/A' ) { 
        ordem = ' 1 ASC'; 
        if ( document.getElementById(obj).querySelector('.ordem') && document.getElementById(obj).querySelector('.ordem').value != 'N/A') { 
          ordem = document.getElementById(obj).querySelector('.ordem').value ;
        }
        param_troca = '&prm_agrupador_troca='+dados.getAttribute('data-agrupador_troca')+'&prm_ordem_troca='+ordem ;
      } 
    }  
    let cd_goto     = ''; 
    if (obj.split('trl').length > 1) {
      cd_goto = obj.split('trl')[1]; 
    } 

    switch(tipo){
      case 'ORGANOGRAMA': 
        chartGauge(obj); 
        activeorga(obj, '',''); 
      break;
      case 'PONTEIRO': 
        chartGauge(obj); 
      break;
      case 'BARRAS': 
        gxml  = document.getElementById('gxml_'+obj);
        dados = document.getElementById('dados_'+obj);     
        call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dados.getAttribute('data-visao')+'&prm_objeto='+obj+'&prm_screen='+tela + param_troca + '&prm_cd_goto='+cd_goto ).then(function(resposta){
          gxml.innerHTML = resposta;
        }).then(function(){ 
          chart(obj); 
        }); 
      break;
      case 'COLUNAS': 
        gxml  = document.getElementById('gxml_'+obj);
        dados = document.getElementById('dados_'+obj);    
        call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dados.getAttribute('data-visao')+'&prm_objeto='+obj+'&prm_screen='+tela + param_troca + '&prm_cd_goto='+cd_goto ).then(function(resposta){
          gxml.innerHTML = resposta;
        }).then(function(){ 
          chart(obj); 
        }); 
      break;
      case 'LINHAS': 
        gxml  = document.getElementById('gxml_'+obj);
        dados = document.getElementById('dados_'+obj);    
        call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dados.getAttribute('data-visao')+'&prm_objeto='+obj+'&prm_screen='+tela + param_troca + '&prm_cd_goto='+cd_goto ).then(function(resposta){
          gxml.innerHTML = resposta;
        }).then(function(){ 
          chart(obj);
        }); 
      break;
      case 'PIZZA': 
        gxml  = document.getElementById('gxml_'+obj);
        dados = document.getElementById('dados_'+obj);    
        call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dados.getAttribute('data-visao')+'&prm_objeto='+obj+'&prm_screen='+tela + param_troca + '&prm_cd_goto='+cd_goto ).then(function(resposta){
          gxml.innerHTML = resposta;
        }).then(function(){ 
          chartSlice(obj); 
        });      
      break;
      case 'ROSCA': 
        gxml  = document.getElementById('gxml_'+obj);
        dados = document.getElementById('dados_'+obj);    
        call('charout', 'prm_parametros='+gxml.getAttribute('data-parametros')+'&prm_micro_visao='+dados.getAttribute('data-visao')+'&prm_objeto='+obj+'&prm_screen='+tela + param_troca + '&prm_cd_goto='+cd_goto ).then(function(resposta){
          gxml.innerHTML = resposta;
        }).then(function(){ 
          chartDonut(obj);  
        });      
      break;
      case 'VALOR': 
        chartPercent(obj); 
      break;
      case 'MAPA': 
        chartMap(obj); 
      break;
      case 'SANKEY': 
        chartSankey(obj); 
      break;
      case 'SCATTER': 
        chartScatter(obj); 
      break;
      case 'RADAR': 
        chartScatter(obj); 
      break;
    }
  }
}


function heatmap(x){
  if(document.getElementById(x)){
    var mapa = {};
    
    mapa.objeto     = document.getElementById(x);
    //var valores   = mapa.getAttribute('data-valores').split('|');
    mapa.valores    = document.getElementById('gxml_'+x).children[0].innerHTML.replace('|', '').split('|');
    mapa.zoom       = 3; //parseInt(mapa.objeto.getAttribute('data-zoom'));
    mapa.coluna     = mapa.objeto.getAttribute('data-colunavalor');
    mapa.colunadesc = mapa.objeto.getAttribute('data-colunadesc');
    mapa.tipo       = 'HEATMAP'; //mapa.objeto.getAttribute('data-tipo');
    mapa.centro     = '-28.680601666666668,-49.365805'; //mapa.objeto.getAttribute('data-center');
    mapa.coor       = [];
    mapa.lastx      = '';
    mapa.lasty      = '';
    
    
    var coorx = '';
    var coory = '';
    
    if(mapa.tipo.indexOf('MARCADOR') == -1){
    
      for(let i=0;i<mapa.valores.length;i++){
        coorx = mapa.valores[i].split(',')[1];
        coory = mapa.valores[i].split(',')[0];
        if(coorx.length > 0 && coory.length > 0){
          mapa.coor.push(new google.maps.LatLng(coory, coorx));
        }
        mapa.lastx = parseFloat(coorx);
        mapa.lasty = parseFloat(coory);
      }
      
      var heatmapData = (mapa.coor);
      
    }
    
    if(mapa.centro.length == 0){
      mapa.centro = new google.maps.LatLng(mapa.lastx, mapa.lasty);
    } else {
      mapa.centro = new google.maps.LatLng(mapa.centro.split(",")[0], mapa.centro.split(",")[1]);
    }

    map = new google.maps.Map(mapa.objeto.children[mapa.objeto.children.length-1], {
      center: mapa.centro,
      zoom: mapa.zoom,
      //hybrid, satellite, terrain
      mapTypeId: 'terrain',
      panControl: false,
      streetViewControl: false,
      zoomControl: false
    });
    
    map.addListener('zoom_changed', function(){
      setTimeout(function(){
        mapa.zoom = map.getZoom();
        mapa.objeto.setAttribute('data-zoom', mapa.zoom);
      //map.getZoom();
      }, 2000); 
    });
    
    map.addListener('center_changed', function(){
      setTimeout(function(){
        mapa.centro = (''+map.getCenter()).replace(/[\)\(]/g, "");
        mapa.objeto.setAttribute('data-center', mapa.centro);
      }, 2000); 
    });

    
    var heatmap = new google.maps.visualization.HeatmapLayer({
      data: mapa.coor
    });
    heatmap.setMap(map);
    
  } 
}

function removeTrash(){
  var trash = document.querySelectorAll('._SmartLabel_Container')
  var trashlength = trash.length;
  for(let i=0;i<trashlength;i++){ trash[i].parentNode.removeChild(trash[i]); }
  //var ptrash = document.querySelectorAll('.block-fusion');
  //var ptrashlength = ptrash.length;
  //for(a=0;a<ptrashlength;a++){ if(ptrash[a].firstElementChild){ ptrash[a].firstElementChild.dispose(); }}
}

function dashboard(screen, x, y, z){
  switch(x){
    case 'insert':
      call('inserir_objeto', 'prm_objeto=ARTICLE&prm_screen='+y+'&prm_screen_ant='+document.getElementById(y).getElementsByTagName('article').length).then(function(resultado){
        var div = document.createElement('div');
        div.innerHTML = resultado;
        document.getElementById(y).appendChild(div.children[0]);
      }).then(function(){
        if(document.querySelector('.moving')){ document.querySelector('.moving').className = ''; }
      }).then(function(){
        dashAjuste(y);
      });
    break;
    case 'insertnv1':
      var ordemAnt = parseInt(document.querySelector('.movingarticle').style.getPropertyValue('order'))+1;
      call('inserir_objeto_ant', 'prm_article=ARTICLE&prm_section='+y+'&prm_pos_ant='+ordemAnt+'&prm_pos_atual='+document.getElementById(y).getElementsByTagName('article').length).then(function(resultado){
        var div = document.createElement('div');
        div.innerHTML = resultado;
        document.getElementById(y).appendChild(div.children[0]);  
        shscr(tela)
        if(document.querySelector('.moving')){ document.querySelector('.moving').className = '';}
      }).then(function(){
        /* dashAjuste(y); */
      });
    break;
    case 'insertnv2':
      ajax('main', 'inserir_objeto', 'prm_objeto=ARTICLENV2&prm_screen='+y+'&prm_screen_ant='+document.getElementById(y).getElementsByTagName('article').length, false, y);
      shscr(tela);
      if(document.querySelector('.moving')){ document.querySelector('.moving').className = ''; }
      setTimeout(function(){ dashAjuste(); }, 100);
    break;
    case 'rowcolumn':
      ajax('fly', 'salva_posicao', 'prm_objeto='+y+'&prm_screen='+screen+'&prm_posx=&prm_posy=&prm_zindex='+z, false);
      document.getElementById(y).style.setProperty('-webkit-flex-direction', z);
      document.getElementById(y).style.setProperty('flex-direction', z);
       if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
    break;
    case 'porcentagem':
      document.getElementById(y).style.setProperty('-webkit-flex-basis', 'calc('+z+' - 6px)');
      document.getElementById(y).style.setProperty('flex-basis', 'calc('+z+' - 6px)');
      ajax('fly', 'salva_posicao', 'prm_objeto='+y+'&prm_screen='+screen+'&prm_posx=&prm_posy=&prm_zindex='+encodeURIComponent(z)+'&prm_tipo=porcentagem', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }
      if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
    break;
    case 'ordem':
      
      document.getElementById(y).style.setProperty('order', z);
      ajax('fly', 'salva_posicao', 'prm_objeto='+y+'&prm_screen='+screen+'&prm_posx='+encodeURIComponent(z)+'&prm_posy=&prm_zindex=&prm_tipo=ordem', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }
      if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
    break;
    case 'newsection':
      call('inserir_objeto', 'prm_objeto=SECTION&prm_screen='+screen+'&prm_screen_ant='+document.getElementsByTagName('section').length).then(function(resultado){
        var div = document.createElement('div');
        div.innerHTML = resultado;
        MAIN.appendChild(div.children[0]);
      }).then(function(){
        dashAjuste(MAIN.lastElementChild.id);
      });
    break;
    case 'align':
      ajax('fly', 'salva_posicao', 'prm_objeto='+y+'&prm_screen='+screen+'&prm_posx=&prm_posy='+z+'&prm_zindex=', false);
      document.getElementById(y).style.setProperty('justify-content', z);
      document.getElementById(y).style.setProperty('align-items', z);
       if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
    break;
    case 'background_article':
      //document.getElementById(y).style.setProperty('background', z);
      ajax('fly', 'alter_attrib', 'prm_objeto='+y+'&prm_prop=BGCOLOR_ARTICLE'+'&prm_value='+z+'&prm_usuario=DWU', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }
      if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
    break;
    case 'background_section':
      //document.getElementById(y).style.setProperty('background', z);
      ajax('fly', 'alter_attrib', 'prm_objeto='+y+'&prm_prop=BGCOLOR_SECTION'+'&prm_value='+z+'&prm_usuario=DWU', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }
      if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
    break;
    case 'posicao_section':
      
      ajax('fly', 'alter_attrib', 'prm_objeto='+y+'&prm_prop=POSICAO_SECTION'+'&prm_value='+z+'&prm_usuario=DWU', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }

    break;
    case 'altura_section':

      ajax('fly', 'alter_attrib', 'prm_objeto='+y+'&prm_prop=ALTURA_SECTION'+'&prm_value='+z+'&prm_usuario=DWU', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }

    break;
      
    case 'padding_section':

      ajax('fly', 'alter_attrib', 'prm_objeto='+y+'&prm_prop=PADDING_SECTION'+'&prm_value='+z+'&prm_usuario=DWU', true);
      if(error == 'false'){
        alerta('feed-fixo', TR_AL);
      }
    
    break;
  }
}

function dashSectionDown(e){
  if(e.which != 3 && this.className != 'noline'){
  if(this.className != 'moving' ){
    if(this.className == 'hoverchange'){
      var thisorder = this.style.getPropertyValue('order');
      var that = document.querySelector('.moving');
      var thatorder = that.style.getPropertyValue('order');
      that.style.setProperty('order', thisorder);
      that.style['-webkit-order'] = thisorder;
      this.style.setProperty('order', thatorder);
      this.style['-webkit-order'] = thatorder;
      ajax('fly', 'dashboardmove', 'prm_objeto='+that.id+'&prm_target='+this.id+'&prm_last='+tela, false);
      that.className = '';
      this.className = '';
    } else {
      if(document.querySelector('.movingarticle')){ document.querySelector('.movingarticle').classList.remove('movingarticle'); }
      this.className = 'moving';
    }
  } else {
    this.className = '';
  }
  }
}

function dashSectionEnter(){
  if(this.className != 'moving' && this.className != 'noline'){
    if(document.querySelector('.selectedcolumn')){
      this.className = 'hover';
    }
    if(document.querySelector('.moving')){
      this.className = 'hoverchange';
    }
  }
}

function dashSectionLeave(){
  if(this.className != 'moving' && this.className != 'noline'){ this.className = ''; }
}

function dashArticleDown(e){
  e.stopPropagation();
  if(e.which != 3 && this.parentNode.className != 'noline'){
  if(this.className != 'movingarticle'){
    var articleLargura = e.target.closest('article').clientWidth;
    if(articleLargura < 250) {
      var article = e.target.closest('article');
      var fecharDash = document.getElementById(article.id + 'fechar');
        if(articleLargura < 250) {
          fecharDash.classList.remove('fechardash')
          fecharDash.classList.add('fechardddash');
        }
    }
    if(MAIN.querySelector('.selected')){
      //insere objeto dentro do article
      var ele = MAIN.querySelector('.selected');
      var screen;
      if(ele.parentNode.id == 'main'){
        screen = tela;
      } else {
        screen = ele.parentNode.id;
      }
      
      var eleid = ele.id;
      var eleparent = ele.parentNode;
        var bloco = e.target;
        
        //mesmo bloco
        if(eleparent.id == bloco.id){
          var quantn = bloco.children;
          var ordem = 1;
          for(let i=1;i<quantn.length;i++){
            //window.getComputedStyle(dobj).getPropertyValue('left')
              
              if(parseInt(window.getComputedStyle(quantn[i]).getPropertyValue('order')) > ordem){ 
                ordem = parseInt(window.getComputedStyle(quantn[i]).getPropertyValue('order'))+1;
              }
              if(quantn[i].style.getPropertyValue('order')){
                ordem = parseInt(quantn[i].style.getPropertyValue('order'))+1;        
              }
          }
          ele.style.setProperty('order', ordem+1);
          ajax('fly', 'salva_posicao', 'prm_objeto='+eleid+'&prm_screen='+bloco.id+'&prm_posx='+(ordem+1)+'&prm_posy=&prm_zindex=', true);
          MAIN.querySelector('.selected').classList.remove('selected');
        } else {
          ele.remove();
          
          ajax('fly', 'dashboardmove', 'prm_objeto='+eleid+'&prm_target='+bloco.id+'&prm_last='+screen, true);
          call('show_objeto', 'prm_objeto='+eleid+'&PRM_ZINDEX=&prm_posx=99&prm_posy=&prm_screen='+tela+'&prm_dashboard=true', 'obj').then(function(resposta){
            var novo = document.createElement('div');
            novo.innerHTML = resposta;
            bloco.appendChild(novo.children[0]);
            //if(navigator.userAgent.indexOf('Chrome/6') != -1 || navigator.userAgent.indexOf('Firefox/58') != -1){
            if(sticky == 'N'){
              if(document.getElementById('dados_'+eleid)){
                renderChart(eleid);
              } else {
                ajustar(eleid);
              }
            } else {
              document.getElementById(eleid+'c').classList.add('sticky');
              //document.getElementById(eleid+'dv2').style.setProperty('overflow', 'auto');
            }
          }).then(function(){
            eventos(document.getElementById(eleid));
          }).then(function(){
            
            var quantn = bloco.children;
            var ordem = 1;
            for(let i=1;i<quantn.length;i++){
              if(quantn[i].id != eleid){
                if(parseInt(quantn[i].style.getPropertyValue('order')) < ordem){
                  ordem = parseInt(quantn[i].style.getPropertyValue('order'));
                }
              
                ajax('fly', 'salva_posicao', 'prm_objeto='+quantn[i].id+'&prm_screen='+bloco.id+'&prm_posx='+ordem+'&prm_posy=&prm_zindex=', true);
              } else {
                ajax('fly', 'salva_posicao', 'prm_objeto='+quantn[i].id+'&prm_screen='+bloco.id+'&prm_posx='+quantn.length+1+'&prm_posy=&prm_zindex=', true);
              }
              ordem = ordem+1;
            }
          });
        }
          
    } else {
      //troca ordem do article
      if(this.className == 'hoverchangearticle'){
        var thisorder = this.style.getPropertyValue('order');
        var that = document.querySelector('.movingarticle');
        var thatorder = document.querySelector('.movingarticle').style.getPropertyValue('order');
        document.querySelector('.movingarticle').style.setProperty('order', thisorder);
        document.querySelector('.movingarticle').style['-webkit-order'] = thisorder;
        document.getElementById(document.querySelector('.movingarticle').id+'ordem').value = thisorder;
        this.style.setProperty('order', thatorder);
        document.getElementById(this.id+'ordem').value = thatorder;
        if(PRINCP.className == 'mac'){
          this.style['-webkit-order'] = thatorder;
        }
        ajax('fly', 'dashboardmove', 'prm_objeto='+that.id+'&prm_target='+this.id+'&prm_last='+this.parentNode.id, false);
        that.className = '';
        this.className = '';
      } else {
        //foco no article
        if(document.querySelector('.moving')){ document.querySelector('.moving').classList.remove('moving'); }
        this.className = 'movingarticle';
      }
    }

    } else {
      //remove foco se mesmo article
      this.className = '';
    }
  }
}

function dashArticleEnter(e){
  if(this.className != 'movingarticle' && this.parentNode.className != 'noline'){
    if(document.querySelector('.movingarticle')){
      if(document.querySelector('.movingarticle').parentNode.id == this.parentNode.id){
        this.className = 'hoverchangearticle';
      }
    }
  }
  e.stopPropagation(e);
}

function dashArticleLeave(e){
  if(this.className != 'movingarticle' && this.parentNode.className != 'noline'){
    this.className = '';
  }
  e.stopPropagation();
}

function debug(x){
  if(x == '13'){ 
    var y = document.getElementById('debug').firstElementChild.value.toLowerCase();
    if(y.indexOf('query') != -1){ 
      let fakes = document.getElementsByClassName('faketitle'); 
      if(fakes[0]){
        if(fakes[0].style.display=='inline'){ 
          for(let i=0;i<fakes.length;i++){ 
            fakes[i].style.display='none'; 
          }  
        } else { 
          for(let i=0;i<fakes.length;i++){ 
            fakes[i].style.display='inline'; 
          }
        }
      }
    }
    if(y.indexOf('json') != -1){ 
      
      if(document.querySelector('.fakedados')){
        var boxes = document.querySelectorAll('.fakedados');
        for(let b=0;b<boxes.length;b++){
          boxes[b].remove();
        }
      } else {

        let fakes = document.createElement('textarea');
        fakes.classList.add('fakedados');

        var jsons = document.querySelectorAll('.json');
        for(let i=0;i<jsons.length;i++){
          let clone = fakes.cloneNode(true);
          let valor = jsons[i].innerHTML.trim();
          clone.value = '{'+valor.substring(0, valor.length-1)+'}';
          jsons[i].parentNode.parentNode.appendChild(clone);
        }
      }
      
    }
   if(y.indexOf('rearrange') != -1){
      var objs = MAIN.children; 
      for(let i=0;i<objs.length;i++){ 
        if(objs[i].tagName == 'DIV'){ 
          objs[i].style.left='100px'; 
          objs[i].style.top='100px'; 
        } else {  
          if(objs[i].tagName == 'SPAN'){ 
            objs[i].firstElementChild.style.left='100px'; 
            objs[i].firstElementChild.style.top='100px';
          }  
        } 
      }
   }
   if(y.indexOf('clearlog') != -1){
     var programa = y.split('.')[1];
     ajax('fly', 'clearlog', 'prm_programa='+programa, false);
   }
   if(y.indexOf('screen') != -1){
     if(document.getElementById('screenres').style.display == 'inline'){
       document.getElementById('screenres').style.display='none';
     } else {
       document.getElementById('screenres').style.display='inline';
     }
   }
   if(y.indexOf('lang') != -1){
     curtain('enabled');
     carrega('lang_table');
     document.getElementById('debug').setAttribute('class', '');
   }

   if(y.indexOf('padrao') != -1){
     call_save('');
     document.getElementById('titulo').innerHTML = 'OBJECT PADRAO';
     curtain('enabled');
     carregaPainel('');
     carrega('object_padrao');
     document.getElementById('debug').setAttribute('class', '');
   }
   if(y.indexOf('upload') != -1){
     document.getElementById('titulo').innerHTML = 'UPLOAD';
     call_save('');
     curtain('enabled');
     carregaPainel('upload');
     carrega('uploaded');
     document.getElementById('debug').setAttribute('class', '');
   }
   if(y.indexOf('help') != -1){
     alert('[query]: mostra ou esconde a query de cada consulta \n[export]: exporta dados das tabelas do tables_to_export, (pipe) seguido da letra do tipo(U usuario, O objeto) para especificar a exportação  \n[rearrange]: realoca todos os objetos pra posição 100/100 \n[clearlog.X]: Limpa log_eventos de dados de X(JS para javascript, EL para error line e PAR para parametro de usu&aacute;rio) \n[screen]: mostra as resoluções de tela \n[rule]: mostra a posição do cursor com reguas \n[grid(px)]: tela dividida em pixels \n[lang]: lista as traduções \n[sandbox]: Libera uso da screen sandbox para testes \n[exec=]: executa comandos \n[dashboard]: Esconde/mostra as linhas do dashboard para o dwu \n[padrao]: Abre a tela de padroes do sistema \n[upload]: Abre a tela de upload '/*\n[admin]: Tela com as permissões de usuários'*/);
   }
   if(y.indexOf('rule') != -1){
     var rule = document.getElementById('rule');
     if(rule.className == 'visible'){
       rule.className = 'invisible';
       document.removeEventListener("mousemove", rulemove, false);
     } else {
       rule.className = 'visible';
       document.addEventListener("mousemove", rulemove, false);
     }
   }
   if(y.indexOf('find') != -1){
     var objeto = y.replace('find(', '');
     var objeto = objeto.replace(')', '');
     ajax('list', 'screen_list', 'prm_objeto='+objeto, true, 'floatops');
   }
   if(y.indexOf('painel') != -1){
     call_save('');
     curtain('enabled');
     carrega('painel');
   }

   /* Decidido em reunião 20/01/23 ocultar a opção admin
    if(y.indexOf('admin') != -1){
      call_save('');
      document.getElementById('titulo').innerHTML = 'OPÇÕES DE ADMINISTRAÇÃO';
      curtain('enabled');
      carrega('admin_options');
      document.getElementById('debug').setAttribute('class', '');
    }
  */

   if(y.indexOf('dashboard') != -1){
     var dashlines = document.getElementsByTagName('SECTION');
     if(dashlines[0].className == 'noline'){
       for(let i=0;i<dashlines.length;i++){
         dashlines[i].className = '';
       }
     } else {
       for(let i=0;i<dashlines.length;i++){
         dashlines[i].className = 'noline';
       }
     }
   }


   if(y.indexOf('grid') != -1){
     var apagar = document.querySelectorAll('.rlinha');
     for(let i=0;i<apagar.length;i++){
       apagar[i].parentNode.removeChild(apagar[i]);
     }
     var pixel = y.replace('grid(', '');
     pixel = pixel.replace(')', '');
     pixel = parseInt(pixel);
     if(typeof pixel == 'number'){
       pixel = Math.abs(parseInt(pixel));
       if(pixel != 0){
         altura = document.getElementById('html').clientHeight;
         largura = document.getElementById('html').clientWidth;
         line = document.createElement('div');
         for(let i=pixel;i<largura;){
           let linha1 = line.cloneNode('true');
           linha1.style.setProperty('left', i+'px');
           linha1.className = 'rlinha horizontal';
           document.body.appendChild(linha1);
           i = i+pixel;
         }
         for(let i=pixel;i<altura;){
           let linha2 = line.cloneNode('true');
           linha2.style.setProperty('top', i+'px');
           linha2.className = 'rlinha vertical';
           document.body.appendChild(linha2);
           i = i+pixel;
         }
       }
     }
   }
   if(y.indexOf('sandbox') != -1){
     var sandbox = document.getElementById('floatops').lastElementChild;
     if(sandbox.style.getPropertyValue('display') == 'none'){
       sandbox.style.setProperty('display', 'inline');
     } else {
       sandbox.style.setProperty('display', 'none');
     }
   }
   if(y.indexOf('exec=') != -1){
     if(confirm(TR_CM)){
       var executar = y.replace('exec=', '');
       ajax('fly', 'executar', 'prm_acao='+executar, false);
     }
   }
  if(y.indexOf('prefixo') != -1){
    call_save('');
    document.getElementById('titulo').innerHTML = 'PREFIXO DE COLUNA';
    curtain('enabled');
    carregaPainel('prefixo');
    carrega('prefixo_lista');
    document.getElementById('debug').setAttribute('class', '');
  }
  
  document.getElementById('debug').firstElementChild.value='';
 }
}

rulemove = function(event){
  rule.style.setProperty('left', cursorx-10+'px');
  rule.style.setProperty('top', cursory-10+'px');
  rule.innerHTML = '&nbsp;&nbsp;&nbsp;&nbsp;X = '+cursorx+'px'+' '+'Y = '+cursory+'px';
}


function fakeValue(x, y){
  document.getElementById(x).innerHTML = y.innerHTML;
  var title = y.getAttribute('title');
  document.getElementById(x).setAttribute('title', title);
}


function nova_customizada(btn){
  //var objCustom = document.getElementById('lista-custom-fav').getAttribute('data-adicional'), 
  //    werro    = false,
  //    pergunta = true;  

  ajax('quick_custom', 'quick_create', 'prm_nome=&prm_tipo=OBJETO&prm_parametros=&prm_visao=&prm_coluna=&prm_grupo=&prm_obj_ant=&prm_filtro=&prm_screen='+tela, false);					         

  /*    
  ajax('return', 'checkCustomizado', 'prm_objeto='+objCustom+'&prm_tela='+tela, false);
  if(respostaAjax.indexOf('NAOEXISTE') != -1){ 
    pergunta = false; 
  }

  if (pergunta == true) { 
    if (!confirm('A criação de uma nova consulta irá excluir a CONSULTA ATUAL ainda não salva, deseja continuar?')) {
      werro = true;
    } 
  }  

  // Exclui o objeto (se existir)
  if (werro == false) { 
    call('excluiCustomizado', 'prm_objeto='+objCustom+'&prm_custom='+objCustom+'&prm_tela=' + tela ).then(function(res){ 
      if(res.indexOf('OK') == -1){ 
        alerta("msg", TR_ER_EX);
        alerta("msg", res);         				   
        werro = true; 
      } else { 
        ajax('quick_custom', 'quick_create', 'prm_nome='+objCustom+'&prm_tipo=OBJETO&prm_parametros=&prm_visao=&prm_coluna=&prm_grupo=&prm_obj_ant=&prm_filtro=&prm_screen='+tela, false);					   
      }
    });
  } 
  */ 

} 

/**** 
function salva_customizada (dis){
  var objCustom = document.getElementById('lista-custom-fav').getAttribute('data-adicional'),
      objAtual  = document.getElementById('lista-custom-fav').getAttribute('title');


  if ( objCustom != objAtual) { 
    alerta("msg", 'Fun&ccedil;&atilde;o dispos&iacute;vel somente para CONSULTA ATUAL');    
  } else { 
    call('adicionaCustomizado', 'prm_objeto='+objCustom).then(function(resposta){
      if(resposta.indexOf('ok') == -1){
        alerta('feed', resposta);
      } else {
        let ObjNovo = resposta.split('|')[1], 
            ObjNome = resposta.split('|')[2]; 
        alerta('feed', TR_ER_CS);
        // Atualiza o item selecionanda da lista de consultas salvas 
        document.getElementById('lista-custom-fav').setAttribute('title', ObjNovo);						 
        document.getElementById('lista-custom-fav').children[0].innerHTML = ObjNome; 
        appendar('prm_drill=C&prm_objeto='+ObjNovo+'&prm_zindex=1&prm_posx=&prm_posy=&prm_screen='+ tela + '&prm_dashboard=false', '', '');

      }
    });
     
  }   
}
*******/ 

function exclui_customizada (dis){
  
  let objAtual   = document.getElementById('lista-custom-fav').getAttribute('title');
  let nmConsulta = document.getElementById('lista-custom-fav').querySelector('.input').innerHTML.replace(/\r?\n|\r/g,''); 

  if (!nmConsulta) { 
    nmConsulta = ''; 
  }

  if (objAtual.length == 0) { 
    alerta("msg", "Nenhuma consulta selecionada"); 
  } else { 
    if (confirm('Confirma a exclus\u00e3o da consulta: '+ nmConsulta +' ?')) {
      call('excluiCustomizado', 'prm_objeto='+objAtual+'&prm_tela='+ tela ).then(function(res){ 
        if(res.indexOf('OK') == -1){ 
          alerta("msg", res); 
        } else {        
          document.getElementById('lista-custom-fav').setAttribute('title','');						 
          document.getElementById('lista-custom-fav').children[0].innerHTML = document.getElementById('lista-custom-fav').children[0].getAttribute('data-placeholder'); 
          document.getElementById('ARTICLE_CUSTOMIZACAO').innerHTML = ''; 
          alerta("msg", TR_EX); 
        }
      });	    
    }   
  }  

}



function remover(objeto, effect){
  var tem_call = false;
  var sucesso = false;
  var elemento;
  if(document.getElementById(objeto+'trl')){
    elemento = document.getElementById(objeto+'trl');
  } else {
    elemento = document.getElementById(objeto);
  }

  if(effect == 'excluir' && typeof effect !== "undefined"){
    tem_call = true;
    var telaAlvo = elemento.parentNode.id; //elemento.parentNode.id;
    if(elemento.parentNode.id == 'main' || elemento.parentNode.id == 'space-options'){ 
      telaAlvo = tela;
    }
    call('dl_obj', 'prm_cod='+objeto+'&prm_tela='+telaAlvo).then(function(res){ 
      if(res.indexOf('OK') != -1){ 

        sucesso = true;
        alerta("msg", TR_EX); 
      } else {
        sucesso = false;
        alerta("msg", res.split('|')[1],'', res.split('|')[0]); 
      } 
    }).then(()=>{tira_da_tela()});
  } else {
    tira_da_tela();
  }

  function tira_da_tela(){
    if(elemento && (!tem_call || (tem_call && sucesso))){
      if(document.getElementById('filterlist').title == elemento.id+'-filterlist'){
        document.getElementById('filterlist').className = 'filtro hidden';
      }

      if((typeof effect === "undefined" || effect == 'excluir')){

        elemento.style.setProperty('opacity', '0');
        setTimeout(function(){
          if(elemento.parentNode){
            elemento.style.setProperty('display', 'none');
            elemento.remove();
          }
        }, 200);

      } else {
        if(elemento.parentNode){
          elemento.remove();
        }
      }
    }
  }
}

function loading(x, y){
  /*var y = y || "CARREGANDO DADOS ";*/
  //var layer = document.getElementById('layer');
  var layer1 = LAYER.children[1];
  var layer0 = LAYER.children[0];
  if(LAYER.className == ''){
    if(document.querySelector('.slide-N')){
      MAIN.style.setProperty('filter', 'blur(14px)');
    }
    LAYER.classList.add('ativo');
    //if((typeof x !== 'undefined') && (x.length != 0 )){
      setTimeout(function(){
        layer0.classList.add('open');
        //layer.children[2].classList.add('open');
      }, 100);
      if(!document.querySelector('.slide-S')){
        setTimeout(function(){
          LAYER.children[1].classList.add('visivel');
          LAYER.children[2].classList.add('visivel');
          LAYER.children[3].classList.add('visivel');
          LAYER.children[4].classList.add('visivel');
          LAYER.children[5].classList.add('visivel');
        }, 100);
      }
    
    if(get('jumpdrill'))      { get('jumpdrill').remove(); }
    if(get('anotacao_show'))  { get('anotacao_show').remove(); }

  } else {
    
    layer1.classList.remove('open');
    if(document.querySelector('.slide-N')){
      MAIN.style.setProperty('filter', 'blur(14px)');
    }
    setTimeout(function(){ 
      MAIN.style.removeProperty('filter'); 
    }, 300);
    if(typeof x !== 'undefined'){
        setTimeout(function(){
          layer1.classList.remove('visivel');
          layer0.classList.remove('open');
          //layer.children[2].classList.remove('open')
          //setTimeout(function(){ 
            LAYER.classList.remove('ativo'); 
          //}, 300); 
          
          
          
        }, 500);
    } else {
      LAYER.classList.remove('ativo');
    }
    if(get('jumpdrill'))      { get('jumpdrill').remove();  }
    if(get('anotacao_show'))  { get('anotacao_show').remove(); }
  }
  
}

function loadAttrib(x, y, pkg){
  var package = pkg || 'FCL'
  document.getElementById('attriblist').classList.remove('horizontal');
  if(document.getElementById(x)){
    document.getElementById('attriblist').classList.remove('open');
  }

  setTimeout(function(){ document.getElementById('attriblist').innerHTML = ""; }, 200);
  if(y.indexOf('grafico') != -1 && y.split('prm_tipo_graf=')[1].length == 0){ //Foi feito para quando for a 1x criando o gráfico, ele abra somente após clique em algum gráfico 
    loader('attriblist');
    ajax('list', x, y, true, 'attriblist', '', '', package);
    return;
  }
  setTimeout(function(){
    if(!document.getElementById(x)){
      document.getElementById('attriblist').classList.add('open');
      document.getElementById('attriblist').classList.add('vertical');
    } else {
      document.getElementById('attriblist').classList.toggle('open');
      document.getElementById('attriblist').classList.toggle('vertical');
    }
    loader('attriblist');
    ajax('list', x, y, true, 'attriblist', '', '', package);
    if(document.querySelector('.destacada')){
      document.querySelector('.destacada').classList.remove('destacada');
    }
  }, 400);
}

//adicionado esse evendo para validar se existe mensagem do alerta na tela antes de fechar.
var target = document.getElementById('fechar_sup');

if (target) {

  target.addEventListener('click', function() {
    var verifAlerta = document.getElementById('feed-fixo');

    if (verifAlerta) {
      var showAlert = verifAlerta.querySelectorAll('.show');
      showAlert.forEach(function(el){
        el.remove();
      })
    }
  });

}

function alerta(x, msg, mais, tipo){

  var obterhora = obterHoraAtualizada();

  if(msg){
    var mensagem;
    var imp;
    var msgImp;
    var template;

    if(notify.permission == 'granted' && vision == 'out'){
      mensagem = msg.split("!");
      for(let i=0;i<mensagem.length;i++){
        callnotify('ATENÇÃO', mensagem[i]);
      }
    } else {
      if(x == "alert"){ 
        alert(msg); 
      } else {
        mensagem = msg.split("!");
        //loop insert
        for(let i=0;i<mensagem.length;i++){
          if(mensagem[i].trim().length > 0){
                   
            template = document.getElementById("alerta-template").children[0].cloneNode(true);
            if (mensagem[i].indexOf('IMP')!== -1){
              msgImp = ". Erro gerado às "+obterhora;
              if(mensagem[i].indexOf('sucesso') !== -1){
                template.children[0].innerHTML = mensagem[i].replace('IMP','')+ msgImp.replace('. Erro gerado às','. Importação gerada as');
                
              }else{
                template.children[0].innerHTML = mensagem[i].replace('IMP','')+ msgImp;
              }
              imp=true;
            }else{
              template.children[0].innerHTML = mensagem[i]+"!";
            }
            if(mais){
              template.children[2].style.setProperty('display', 'initial');
              template.children[3].innerHTML = mais;
            }

            if ((tipo) && (tipo.toUpperCase() == 'ERRO')) { 
              template.classList.add("erro"); 
            }

            document.getElementById("feed-fixo").appendChild(template);
   
            (function(o){

              setTimeout(function(){ 
                o.classList.add("show"); /*o.classList.add(x.toLowerCase());*/ 
              }, 100);

              if(!imp){

                setTimeout(function(){ 
                  if(o){ 
                    o.classList.remove("show"); 
                  } 
                }, 4700);

                setTimeout(function(){ 
                  if(o && o.parentNode){ 
                    o.remove(); } 
                  }, 5000);

              } else {
                var verifMsgAnt = document.querySelectorAll('.show');
          
                for (let i = 0; i < verifMsgAnt.length; i++) {
                  verifMsgAnt[i].classList.remove("show");
                  verifMsgAnt[i].remove();
                }
              }
            })(template);
            
          }
        }
        
      }
    }
  }
}

function invisible_touch(x, y) {
  var obj = document.getElementById(x);
  var a, b;
  if(MAIN.getElementsByTagName('section').length == 0){
  //if(obj.getAttribute('data-left').length > 0){
    if(obj.className.indexOf('scaled') == -1){
      if(y == 'start') {
        var startTimer = setTimeout(function(){ obj.classList.add('dragging'); }, 200);
      } else {
        clearTimeout(startTimer);
        setTimeout(function(){ obj.classList.remove('dragging'); }, 200);
        var toppos = obj.style.top;
        var leftpos = obj.style.left;
        if((toppos != obj.getAttribute('data-top')) || (leftpos != obj.getAttribute('data-left'))){
          if(parseInt(leftpos)%5 != 0){
            a = parseInt(leftpos)/10; a = Math.round(a); a = a*10;
          } else {
            a = parseInt(leftpos);
          }
          if(parseInt(toppos)%5 != 0){
            b = parseInt(toppos)/10; b = Math.round(b); b = b*10;
          } else {
            b = parseInt(toppos);
          }
          ajax('pos', 'salva_posicao', 'prm_objeto='+x+'&prm_screen='+tela+'&prm_posx='+a+'px&prm_posy='+b+'px&prm_zindex=', true);
          obj.setAttribute('data-top', toppos);
          obj.setAttribute('data-left', leftpos);
        }
      }
   // }
  }}
}

function fakeClickScript(){
  if(document.querySelector('.fakelistbox.open')){
    if(document.querySelector('.fakelistbox.open').previousElementSibling.contentEditable == false){
      document.querySelector('.fakelistbox.open').click();
    }
  }
}

function logout(sessao){
  if(!sessao){
    ajax('fly', 'xlogout', '', true);
    alerta('x', TR_SE);
    setTimeout(function(){ window.location.reload(true); }, 20000);
  } else {
    ajax('fly', 'xlogout', 'prm_sessao='+sessao, true);
    alerta('x', TR_SE);
  }
}

// Na entrada do BI atualiza a data de atividade da sessão do usuário 
call('refresh_session', '');                                              

//  Na entrada do BI verifica se tem mensagens e ativa verificação de mensagens a cada 15 segundos - Se o chat estiver ativo no cliente 
var msgs = 0;
if (get('verify-post')) {   
  call('countCheckPost', '').then((res) => { msgs = parseInt(res); });         
  const TICK = setInterval(function(){
    checkTextPost();
  }, 15000);
}   

const LOGGED = setInterval(function(){
  if(!get('login-menu')){
    if( document.cookie.length == 0 && get('xe').value == 'N') {   // Se não tem cookie da sessão e não é XE então faz o logout;  
      logout();
      return false;
    }
    call('valida_session', '').then(function(resposta){    // Verifica se a sessão do usuário expirou ou se o sistema está bloqueado 
      if( resposta.indexOf("0") != -1){
        logout();
        return false;
      }
      if(resposta.indexOf("1") != -1){
        window.location.reload(true); 
      }
      if (resposta.indexOf("5")!= -1){
        window.location.href = window.location.href;
      }
    });
  }
}, 60000); 

//verifica msgs do sistema
function checkTextPost(){
  if(!get('login-menu')){
    if(get('verify-post')){
      call('countCheckPost', '').then(function(res){
        get('verify-post').setAttribute('data-ajax', res.trim());
        if(parseInt(res) > 0 && get('text-talk').classList.contains('open') && parseInt(res) != msgs){
          let selecionado = get('text-talk').querySelector('.selected');
          call('listContainer', '').then(function(res2){
            document.querySelector('.list_container').innerHTML = res2;
          }).then(function(){
            selecionado.click();
          });
        }
      });
    }
  }
}

//var password;
function call(req, par, proc, tipo/*, username, password*/){

    var tipo = tipo || 'POST';

    fakeClickScript();

    return new Promise(function(resolve, reject){
      var request = new XMLHttpRequest();

      if(proc == 'PROCEDURE'){
        request.open(tipo, OWNER_BI + '.'+req, true);
      } else {
        var pkg = proc || 'fcl';
        if(tipo == 'POST'){
          request.open(tipo, OWNER_BI + '.'+pkg+'.'+req, true);
        } else {
          request.open(tipo, OWNER_BI + '.'+pkg+'.'+req+'?'+par, true);
        }  
      }

      //request.setRequestHeader('X-Password', password);
      //request.setRequestHeader('Http_authorization', "Basic " + btoa(password));
      //request.setRequestHeader('Authorization', "Basic " + btoa(username.toUpperCase() + password.toUpperCase()));
      //request.setRequestHeader('Http_authorization', password);
      //request.setRequestHeader('Authorization', password.toUpperCase());
      //document.cookie = 'PASSWORD= '+btoa(password.toUpperCase());
      if(tipo == 'POST'){
        request.send(par);
      } else {
        request.send(null);
      }

      request.onload = function(){
        //request.setRequestHeader('Authorization', btoa(password.toUpperCase()));
        if(request.status == 200){
          resolve(request.responseText.trim());
          if(document.getElementById('content')){
            document.getElementById('content').classList.remove('loading');
          }  
          //return request.responseText.trim();
        } else {
          document.getElementById('content').classList.remove('loading');
          reject(alerta('feed-fixo', TR_XC));
        }
      }

      request.onerror = function(){
        document.getElementById('content').classList.remove('loading');
        if(navigator.onLine == false){
          alerta('msg', TR_OFF);
        }
      }

    });

}

// Executa URL externo e retorno 
function callExt(url){

  return new Promise(function(resolve, reject){
    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.send(null);

    request.onload = function(){
      if(request.status == 200){
        resolve(request.responseText.trim());        
      } else {
        reject('#ERRO#|' + request.responseText.trim());
      }
    }
    request.onerror = function(){
      reject('#ERRO#|Falha na chamada da requisicao externa');
    }
  });
}



var slice = [];
//w = ajax que chama, x = url ,y = param da url, async = sincronia(default = sincrono), z = document.getElementById, pos = posicao, par = parametros.

function ajax(w, x, y, async, z, pos, par, pkg){

  var pkg = pkg || "fcl";
  var param = par;
  var ajaxRequest = new XMLHttpRequest();

  ajaxRequest.onerror = ajaxError;
  ajaxRequest.onreadystatechange = function(){
    if(ajaxRequest.readyState == 4){
      if(ajaxRequest.status == 200){

    switch(w){
      case 'return': respostaAjax = ajaxRequest.responseText.trim(); break;
      case 'data-': if(ajaxRequest.responseText.trim() != 'LOGOFF'){ if (document.getElementById(z)) {document.getElementById(z).setAttribute('data-ajax', ajaxRequest.responseText.trim()); }} break;
      case 'append': if(ajaxRequest.responseText.indexOf('#alert') == -1){
        var elemento;
        elemento = document.createElement('div');
        var resposta = ajaxRequest.responseText;
        elemento.innerHTML = resposta;

        var obj = elemento.children[0];
        obj.style.setProperty('order', document.getElementById(z).children.length+1);
        var pro = new Promise(function(resolve, reject){ resolve(resposta); });
        pro.then(function(){
          if(param){
            if (obj.getAttribute('data-drill-relatorio') == 'Y') {
              obj.style.setProperty('opacity', '1');
            } else {
              obj.style.setProperty('opacity', '0');
            }
            
          }
        }).then(function(){
          document.getElementById(z).appendChild(obj);
        }).then(function(){
          eventos(obj);
          setTimeout(function(){
            if(param){
              if(document.getElementById(param)){
                document.getElementById(param).style.setProperty('opacity', '');
              }
            }
            if(LAYER.classList.contains('ativo')){
              loading();
            }
            topDistance(param);

            if(obj.classList.contains('mapageoloc') ){  // Ajusta em tela mapa de geo localização 
              mapaGeoLoc(obj.id);    
            }             
          }, 100);

          if(param){
            centerDrill(param);
            ajustar(param);
            renderChart(param);
          }
        });
      }
      break;
    case 'input': document.getElementById(z).className = ajaxRequest.responseText.trim(); break;
    case 'value': document.getElementById(z).value = ajaxRequest.responseText.trim(); break;
    case 'list': 
        document.getElementById(z).innerHTML = ajaxRequest.responseText; 
        if(lasturl.length < 3){ if(y){ lasturl = y;} } 
    break;
    case 'inject': 
      if(ajaxRequest.responseText.length > 0){ 
        var tbd = document.createElement('tbody'); 
        //var tbd2 = document.createElement('tbody'); 
        tbd.innerHTML = ajaxRequest.responseText; 
        var lgt = tbd.children.length; 
        for(let i=0;i<lgt;i++){ 
          document.getElementById(z).parentNode.insertBefore(tbd.lastElementChild, document.getElementById(z).nextElementSibling); 
        }
        var tbl = document.getElementById(z).parentNode.parentNode.parentNode.parentNode.parentNode; // pegar o objeto pai de todos
        ajustar(tbl.id) 
      } else { 
        alerta('feed-fixo', TR_NR); 
      } 
      loading(); 
      break;
    case 'script': dscript = document.createElement('script'); dscript.innerHTML = ajaxRequest.responseText; document.head.appendChild(dscript); break;
    case 'lang': tr = ajaxRequest.responseText; break;
    case 'time': countdown = ajaxRequest.responseText; break;
    case 'double':
          //document.getElementById('count').innerHTML = '';
        document.getElementById(z+'2').innerHTML = ajaxRequest.responseText;
        document.getElementById(z).innerHTML = ajaxRequest.responseText;
        if(document.getElementById('count-result')){ document.getElementById('count').innerHTML = document.getElementById('count-result').children[0].innerHTML; }
    break;
    case 'slice': 
        if(ajaxRequest.responseText.length > 1){ 
          slice[pos] = ajaxRequest.responseText; 
        }
        
        if(pos == 20){
          //document.getElementById('texto').value = valor; 
          ace_editor.setValue(slice.join());
        } 
    break;
    case 'order':
        var delfit = document.getElementById(z);  
        if(delfit == null) {
          document.getElementById(z+'trl').parentNode.setAttribute('name','');
          var delfit = document.getElementById(z+'trl');
          if(delfit.style.getPropertyValue('order')){
            dashorder = '&prm_dashboard=true';
            dashlocation = delfit.parentNode.id;
          }
          var posx = delfit.offsetLeft;
          var posy = delfit.offsetTop;

          delfit.parentNode.removeChild(delfit);   

          appendar('prm_drill=N&prm_objeto='+z+'&PRM_ZINDEX=&prm_posx='+posx+'px&prm_posy='+posy+'px&prm_parametros='+par+'&prm_zindex='+pos+'&prm_screen='+tela+dashorder);
        } else {
          if(delfit.style.getPropertyValue('order')){
            dashorder = '&prm_dashboard=true';
            dashlocation = delfit.parentNode.id;
          }
          if(delfit.parentNode.getAttribute('data-parent')){
            shscr(tela);
          } else {
            delfit.parentNode.setAttribute('name','');
            posx = delfit.getAttribute('data-left');
            posy = delfit.getAttribute('data-top');
            if(delfit){ delfit.parentNode.removeChild(delfit); }
            document.getElementById('drill_obj').setAttribute('value', z);

            appendar('prm_drill=N&prm_objeto='+z+'&PRM_ZINDEX=&prm_posx='+posx+'&prm_posy='+posy+'&prm_screen='+tela+dashorder);
            remover(z+'trl'); 
          }
        }
      break;
      case 'query':
        if(document.getElementById(z)){
          document.getElementById(z).parentNode.innerHTML = (ajaxRequest.responseText);
          ajustar(z);
        } else {
          obj = document.getElementById(z+'trl');  
          obj.parentNode.removeChild(obj);
        }
        LAYER.setAttribute('class','');
      break;
      
      case 'main':
        if(ajaxRequest.responseText.indexOf('#alert') == -1){
          if(document.getElementById(z)){
            var ajaxDisplay = document.getElementById(z);
            ajaxDisplay.innerHTML = (ajaxDisplay.innerHTML+ajaxRequest.responseText);
          }
        }
      break;
      case 'quick':
        var obj = ajaxRequest.responseText.trim();
        if(obj != 'NONE'){

          if(document.querySelector('.movingarticle')){
            var selecionado = document.querySelector('.movingarticle').id;
            var ordem_maior  = document.querySelector('.movingarticle').querySelectorAll('.dragme');
            var ordem = 3;
            for(let o=0;o<ordem_maior.length;o++){
              if(parseInt(ordem_maior[o].style.getPropertyValue('ordem')) >= ordem){
                ordem = parseInt(ordem_maior[o].style.getPropertyValue('ordem'))+1;
              }
            }
            var dash = '&prm_dashboard=true';
            
          } else {  
            var selecionado = tela;
            var ordem = cursorx+'px'; 
            var dash = '&prm_dashboard=false';
          }	

          ajax('fly', 'inserir_objeto', 'prm_objeto='+obj+'&prm_screen='+selecionado, false);
          appendar('prm_objeto='+obj+'&prm_zindex=999&prm_posx='+ordem+'&prm_posy='+cursory+'px&prm_screen='+tela+dash, '', '');

          if(document.getElementById(obj)){
            if(document.getElementById(obj).className.indexOf('texto') != -1){ 
              var texto = document.getElementById(obj);
              var x = (window.innerWidth/2-texto.clientWidth-60)+'px';
              var y = (window.innerHeight/2-texto.clientHeight-60)+'px';
              texto.style.setProperty('left', x);
              texto.style.setProperty('top', y);
            }
          }
        
          carrega('ajobjeto?prm_objeto='+obj);
          
          var titulo = document.getElementById(obj+'_ds');
          
          if(get('jumpdrill')){
            get('jumpdrill').innerHTML = '';
            get('jumpdrill').style.removeProperty('opacity');
          }
        }
      break;
      case 'quick_custom':
        var obj = ajaxRequest.responseText.trim();
        
        ajax('fly', 'inserir_objeto', 'prm_objeto='+obj+'&prm_screen='+tela, false);                                // Insere o objeto na tela customizada 
        appendar('prm_drill=C&prm_objeto='+obj+'&prm_zindex=999&prm_posx=&prm_posy=&prm_screen='+ tela , '', '');   // Monta o conteúdo do objeto 

        // Atualiza o item selecionanda da lista de consultas cricadas 
        document.getElementById('lista-custom-fav').setAttribute('title',obj);						 
        document.getElementById('lista-custom-fav').children[0].innerHTML = 'NOVA CONSULTA'; 
        
        // Abre menu de atributos do objeto 
        loadAttrib('ed_gadg', 'ws_par_sumary='+obj+'&prm_tipo=consulta');       // Abre o menu de atributos para preenchimento do usuário 

      break;
      }
    } else {
      if(telasup){
        if(navigator.onLine == false){
          alerta('msg', TR_OFF);
        } else {
          if(parseInt(telasup.style.getPropertyValue('height')) != 0){
            alerta('msg', TR_FC_NF);
            if(document.querySelector('.load')){ setTimeout(function(){ document.querySelector('.load').innerHTML = TR_XC; }, 500); }
          } else {
            alerta('feed-fixo', TR_FC_NF);
          }
        }
      }
    }
  }
}

  ajaxRequest.open("POST", OWNER_BI + '.'+pkg+'.'+x, async);
  ajaxRequest.send(y);


  var msg = ajaxRequest.responseText;
  //tester onreadystatechange 09/08/23
  if (x == 'save_prop'){
    ajaxRequest.onreadystatechange = function () {
      if (ajaxRequest.readyState === 4 && ajaxRequest.status === 200 ) {
        var resposta = ajaxRequest.responseText; 
        alerta('msg', resposta.substr(resposta.indexOf('#aviso_prop')+11,500));
      }
    };
  }

  if(msg.indexOf('!alert') != -1){ 
    alerta('feed-fixo', msg.substr(msg.indexOf('!alert')+6,100)); 
    error = 'true';  
  } else { 
    if(msg.indexOf('#alert') != -1){ 
      alerta('msg', msg.substr(msg.indexOf('#alert')+6,100)); error = 'true'; 
    } else { 
      error = 'false';  
    }
  }
}

function ajaxExt(x){
  call('load_external', 'prm_screen='+x).then(function(url){
    if(url.trim().length > 0){
      var ajaxRequestExt;
      ajaxRequestExt = new XMLHttpRequest();
      ajaxRequestExt.onreadystatechange = function(){
        if(ajaxRequestExt.readyState == 4){
          if(ajaxRequestExt.status == 200){

            document.getElementById("main-ext").innerHTML = ajaxRequestExt.responseText;
            eval(document.getElementById("main-ext").getElementsByTagName("DIV")[0].getAttribute("data-scriptload"))
          }
        }
      }
      ajaxRequestExt.open("GET",  OWNER_BI + "."+url, false);
      ajaxRequestExt.send(null);
    }
  });
}

function ajaxError(erro){
  console.log('ERRO: '+erro+'!!!');
}

function noerror(x,y,z){
  if(error == 'false'){
    if(x){ 
      x.parentNode.parentNode.setAttribute('class', 'removing'); 
      setTimeout(function(){ 
        x.parentNode.parentNode.style.display='none'; 
        x.parentNode.parentNode.id=''; 
        x.parentNode.id='';
      }, 200); 
    }
    alerta(z, y);
  }
}

async function agrupadorChange(obj, coluna, valor){
  remover('jumpmed'); 
  if(valor!= 'N/A'){

    document.getElementById('drill_obj').value = obj; 
    
    var pai, parametros, colunas, dash, ordem, drill;
    let objeto, cd_goto;
    
    pai        = document.getElementById(obj).parentNode.id;
    parametros = document.getElementById('par_'+obj).value;
    colunas    = document.getElementById('agp_'+obj).value;
    objeto     = obj;
    cd_goto    = '';

    if(document.getElementById(obj).classList.contains('drill')){ 
      drill = 'Y';
      dash  = '&prm_dashboard=false'; 
      vleft = document.getElementById(obj).offsetLeft+'px';      
      
      if (obj.split('trl').length > 1) {   // Pega a sequencia do objeto no cadastro de drills 
        objeto  = obj.split('trl')[0];
        cd_goto = obj.split('trl')[1];
      }  
    } else { 
      drill = 'N';      
      dash = '&prm_dashboard=true'; 
      vleft = document.getElementById(obj).style.getPropertyValue('order'); 
    } 
    var troca = colunas.replace(coluna, valor);
    
    remover(obj); 
    appendar('prm_drill='+drill+'&prm_objeto='+objeto+'&prm_zindex=&prm_parametros='+parametros+'&prm_posx='+vleft+'&prm_posy=&prm_screen='+tela+'&prm_track='+obj+'&prm_objeton='+obj+'&prm_alt_med='+troca+dash+'&prm_cd_goto='+cd_goto, false, pai);

    setTimeout(function(){  // Aguarda 0,1 segundo e centraliza Drill 
        centerDrill(obj); 
    }, 100); 
    
    setTimeout(function(){  // Aguarda 1 segundo e ajusta os eventos do objeto  
      ajustar(obj); 
    }, 1000); 
    
  }
}

//fixador de header:html feito em js sem sticky:css, fallback se der problemas no topDistance:js
function fixCol(objeto){

  if(document.getElementById(objeto+'fixed') && document.getElementById(objeto+'c').children.length > 1){
    document.getElementById(objeto+'fixed').innerHTML = '';
    
    var copia = ''; var max = 1; var cell = 1; var loop = 0; var p = 0; var size = 0; var linha = 0; var span = new Array(); var vtbody = ''; var cross = 0; var ph = '';
    if(document.getElementById(objeto)){
      if(document.getElementById(objeto+'c').children[0]){
        vtbody = document.getElementById(objeto+'c').children[0];
      } else {
        if(document.getElementById(objeto+'c').children[1].tagName == 'TBODY'){ vtbody = document.getElementById(objeto+'c').children[1]; cross = 1; } else { return; }
      }
      var coluns = vtbody.getElementsByTagName('th');
      var colunslength = coluns.length;
      if(parseInt(document.getElementById(objeto+'fixed').getAttribute('data-number')) > 0){
        if(parseInt(document.getElementById(objeto+'fixed').getAttribute('data-number')) <= document.getElementById(objeto+'c').children[0].children[0].childElementCount){
          loop = parseInt(document.getElementById(objeto+'fixed').getAttribute('data-number'));
        } else {
          loop = document.getElementById(objeto+'c').children[1].children[0].childElementCount;
        }
        if(cross == 1){ loop = 2; minus = 0; }
        for(let t=0;t<loop-1;t++){
          p = p+1;
          //if(cross == 0){ if(document.getElementById(objeto+p+'h')){ ph = document.getElementById(objeto+p+'h'); } else { ph = document.getElementById(objeto+(p+1)+'h'); } } else { ph = document.getElementById(objeto+'header').children[0].children[1].children[0].children[p]; }
          ph      = document.getElementById(objeto+'c').children[0].children[0].children[t+1];
          cell    = parseInt(ph.colSpan)+parseInt(cell);
          span[t] = document.createElement('span');
          span[t].className   = 'fixed';
          span[t].innerHTML   = ph.innerHTML;
          span[t].style.color = ph.parentNode.style.color;
          if(t == 0){
            span[t].style.width = (ph.clientWidth+13)+'px';
          } else {
            span[t].style.width = (ph.clientWidth-5)+'px';
          }
          if(cross == 1){
             span[t].style.padding = '0 4px';
             span[t].style.lineHeight = (ph.clientHeight)+'px';
             span[t].style.setProperty('min-height', (ph.clientHeight-8)+'px');
             span[t].style.textAlign = 'left';
          } else {
            span[t].style.backgroundColor = ph.parentNode.style.backgroundColor;
            span[t].style.height = (ph.clientHeight-8)+'px';
            span[t].style.lineHeight = (ph.clientHeight-8)+'px';
          }
          if(parseInt(ph.clientWidth)+parseInt(size) < document.getElementById(objeto+'dv2').clientWidth){
            size = parseInt(ph.clientWidth)+parseInt(size);
          }
          p = p+parseInt(ph.colSpan)-1;
          document.getElementById(objeto+'fixed').innerHTML = document.getElementById(objeto+'fixed').innerHTML+span[t].outerHTML;
        }
        if(navigator.userAgent.indexOf('Trident') == -1){
          document.getElementById(objeto+'fixed').setAttribute('data-width', size-1);
        } else {
          document.getElementById(objeto+'fixed').setAttribute('data-width', size+1);
        }
        document.getElementById(objeto+'fixed').style.setProperty('white-space', 'nowrap');

        //colunas fixas
        for(var cl=max;cl<cell;cl++){
          for(var i=0;i<colunslength;i++){
            if((linha > 1 && cross == 1) || (cross == 0)){
            if(coluns[i].className != 'total duplicado' || li.className != 'total geral'){

            if(coluns[i].cellIndex == cl){
              var li = document.createElement('li');
              li.innerHTML = coluns[i].outerHTML;

              if(coluns[i].parentNode.style.background.length > 2){
                li.style.background = coluns[i].parentNode.style.background;
              } else {
                document.getElementById(objeto+'fixed').style.background = document.getElementById(objeto+'dv2').style.background;
              }
              if(coluns[i].className != 'seta'){
                li.className = coluns[i].parentNode.className;
              } else {
                li.className = coluns[i].className+' '+coluns[i].parentNode.className;
              }

              if(li.className == 'total duplicado' || li.className == 'total geral'){
                li.innerHTML = '';
              }

              if(coluns[i-1].getAttribute('data-valor') != null){ li.setAttribute('data-valor', coluns[i-1].getAttribute('data-valor')); }
              if(coluns[i-1].getAttribute('data-ordem') != null){ li.setAttribute('data-ordem', coluns[i-1].getAttribute('data-ordem')); }
              li.style.backgroundImage = coluns[i].style.backgroundImage;
              li.style.paddingLeft = coluns[i].style.paddingLeft;
              if(cl == max){
                if(parseInt(coluns[i].style.paddingLeft) == 13){
                  li.style.width = (coluns[cl].clientWidth+2)+'px';
                  if(coluns[i-1].className.indexOf('nivel') != -1){ li.style.setProperty('width', (coluns[i].clientWidth+18)+'px'); }
                } else {
                  li.style.width = (coluns[cl].clientWidth+10)+'px';
                  if(coluns[i-1].className.indexOf('nivel') != -1){ li.style.setProperty('width', (coluns[i].clientWidth+18)+'px'); }
                }
              } else {
                if(parseInt(coluns[i].style.paddingLeft) == 13){
                  li.style.width = (coluns[cl].clientWidth-16)+'px';
                  if(coluns[i-1].className.indexOf('nivel') != -1){ li.style.setProperty('width', (coluns[i].clientWidth)+'px'); }
                } else {
                  li.style.width = (coluns[cl].clientWidth-8)+'px';
                  if(coluns[i-1].className.indexOf('nivel') != -1){ li.style.setProperty('width', (coluns[i].clientWidth)+'px'); }
                }
              }
              if(coluns[i].parentNode.className == 'total' && cl == 0){
                li.style.height = (coluns[cl].clientHeight-8)+'px';
              } else {
                li.style.height = (coluns[cl].clientHeight-8)+'px';
              }
              li.style.paddingLeft = coluns[i].style.paddingLeft;
              if(coluns[i].getAttribute('onclick') != null){ li.setAttribute('onclick', coluns[i].getAttribute('onclick')); }
              li.setAttribute('data-linha', linha);
              linha = linha+1;
              copia = copia+li.outerHTML;

            }}
            } else { linha = linha+1; }

          }
          var ul = document.createElement('ul'); 
          ul.className = 'fixed'; 
          ul.setAttribute('data-i', cl); 
          ul.style.setProperty('margin-top', 0); 
          ul.innerHTML = copia;
          document.getElementById(objeto+'fixed').innerHTML = document.getElementById(objeto+'fixed').innerHTML+ul.outerHTML;
          copia = ''; linha = 0;
        }
        max = cl;
        document.getElementById(objeto+'fixed').style.maxHeight = (document.getElementById(objeto+'dv2').clientHeight+document.getElementById(objeto+'header').clientHeight)-2+'px';
        if(document.getElementById(objeto+'fixed').clientWidth > document.getElementById(objeto+'dv2').clientWidth){
          alerta('feed-fixo', TR_LCF);
          document.getElementById(objeto+'fixed').innerHTML = '';
        }
      }
    }
  }
}

sessionStorage.clear();

function popupmenu(tipo, cond, dist){
  
  if(document.getElementById('popupmenu')){
    var menu = document.getElementById('popupmenu');
    //fecha se aberto
    if (document.getElementById('sub-screenlist')) {
      document.getElementById('sub-screenlist').remove();
    }
    if(menu.classList.contains('visible') && cond.length == 0){
      menu.classList.remove('visible');
      menu.innerHTML = '';
    } else {

      if (tipo == 'sub-screenlist') {

        call('popupMenu', 'prm_tipo='+tipo+'&prm_cond='+cond).then(function(resultado){
          var ele = document.createElement('ul');
          ele.innerHTML = resultado;
          ele.id = 'sub-screenlist';

          menu.appendChild(ele);

          var dist1 = document.getElementById('screenlist').style.top;
          var dist2 = document.getElementById('screenlist').children[dist-1].offsetTop-document.getElementById('screenlist').scrollTop;

          document.getElementById('sub-screenlist').style.setProperty('top', (parseFloat(dist1) + dist2)+'px');

          ele.classList.add('show');

        });

      } else {
        
        //abre o primeiro nivel - CATEGORIAS 

        if(cond.length == 0){
          menu.classList.add('visible');

          
          if ( (!sessionStorage.getItem('popupMenu')) || (document.getElementById('id_atualizar_menu').value == 'S') )  {

            call('popupMenu', 'prm_tipo='+tipo+'&prm_cond='+cond).then(function(resultado){
              sessionStorage.setItem('popupMenu', resultado);
              var ele = document.createElement('div');
              ele.innerHTML = resultado;
              menu.innerHTML = '';
              menu.appendChild(ele.children[0]);
              document.getElementById('id_atualizar_menu').value = 'N'; 

              var ele = document.createElement('ul');
              ele.id = 'screenlist';
              menu.appendChild(ele);

            });
          } else {
            var ele = document.createElement('div');
            ele.innerHTML = sessionStorage.getItem('popupMenu');
            menu.innerHTML = '';
            menu.appendChild(ele.children[0]);

            var ele = document.createElement('ul');
            ele.id = 'screenlist';
            menu.appendChild(ele);

          }
        
        } else {
          //abre o segundo nivel - TELAS 
          var dist2 = document.getElementById('screengroup').children[dist-1].offsetTop-document.getElementById('screengroup').scrollTop;

          if (document.getElementById('screenlist')) {
            document.getElementById('screenlist').classList.remove('show');
            setTimeout(function(){

              if ( (!sessionStorage.getItem(tipo+'-'+cond)) || (cond == '###menu_grupo_favoritos###') ) {

                call('popupMenu', 'prm_tipo='+tipo+'&prm_cond='+cond).then(function(resultado){
                  sessionStorage.setItem(tipo+'-'+cond, resultado);
                  document.getElementById('screenlist').remove();

                  var ele = document.createElement('div');
                  ele.innerHTML = resultado;
                  menu.appendChild(ele.children[0]);
                  setTimeout(function(){
                    document.getElementById('screenlist').style.setProperty('top', (dist2)+'px');
                    document.getElementById('screenlist').classList.add('show');
                  }, 200);
                });
              } else {
                document.getElementById('screenlist').remove();

                var ele = document.createElement('div');
                ele.innerHTML = sessionStorage.getItem(tipo+'-'+cond);
                menu.appendChild(ele.children[0]);
                setTimeout(function(){
                  document.getElementById('screenlist').style.setProperty('top', (dist2)+'px');
                  document.getElementById('screenlist').classList.add('show');
                }, 200);
              }
              
            }, 100);
          } else {
            if ((!sessionStorage.getItem(tipo+'-'+cond)) || (cond == '###menu_grupo_favoritos###') ) {
              call('popupMenu', 'prm_tipo='+tipo+'&prm_cond='+cond).then(function(resultado){
                sessionStorage.setItem(tipo+'-'+cond, resultado)
                menu.innerHTML = menu.innerHTML+resultado;
                setTimeout(function(){
                  document.getElementById('screenlist').style.setProperty('top', (dist2)+'px');
                  document.getElementById('screenlist').classList.add('show');
                }, 200);
              });
            } else {
              //erro aqui
              menu.innerHTML = menu.innerHTML+sessionStorage.getItem(tipo+'-'+cond);
              setTimeout(function(){
                document.getElementById('screenlist').style.setProperty('top', (dist2)+'px');
                document.getElementById('screenlist').classList.add('show');
              }, 200);
            }
            
          }
        }

      }


    }

  }

}

function fakeOption(ident, titulo, campo, visao, ref){
  var fakelist = document.getElementById('fakelist');
  
  //fakelist.innerHTML = '';
  
  if(document.getElementById('attriblist').classList.contains('open')){
    fakelist.classList.remove('noattrib');
    fakelist.classList.add('attrib');
  } else {
    fakelist.classList.remove('attrib');
    fakelist.classList.add('noattrib');
  }
  
  //if(fakelist.className != 'visible'){ loader('fakelist'); }

  document.getElementById('fakelist').classList.toggle('visible');

  if(fakelist.classList.contains('visible')){
    call('fakelist', 'prm_ident='+ident+'&prm_titulo='+titulo+'&prm_campo='+campo+'&prm_visao='+visao+'&prm_ref='+ref).then(function(resultado){
      var closer = document.querySelector('.closer').cloneNode(true);
      fakelist.innerHTML = resultado;
      fakelist.appendChild(closer);
    }).then(function(){
      if(document.getElementById('filter-value')){ document.getElementById('filter-value').focus(); }
      if(document.getElementById(ident).parentNode.hasAttribute('data-v')){
        var valores = document.getElementById(ident).parentNode.getAttribute('data-v');
        var lista = document.getElementById('fake_ajax');
        lista.parentNode.parentNode.setAttribute('data-multi', valores);
        var descricao = [];
        for (item of lista.children){
          if (valores.split('|').includes(item.title)){
            descricao.splice(valores.split('|').indexOf(item.title),0,item.innerHTML.substr(0,5)+'...');
            item.classList.add('selected');
          }
        }
        lista.parentNode.parentNode.setAttribute('data-multi-desc', descricao.join('|'));
      }
    });
  } else {
    if(fakelist.hasAttribute('data-multi')){
      document.getElementById(ident).parentNode.setAttribute('data-v', 
        fakelist.getAttribute('data-multi'));
      var desc = fakelist.getAttribute('data-multi-desc');
      if (desc.length >= 30) {
        desc = desc.substring(0,30)+'[...]';
      }
      document.getElementById(ident).innerHTML = desc;
    }
  }
}

function fakeOptionChange(prm_elemento){
  var span = prm_elemento.getElementsByClassName('fakeoption')[0];
  var titulo = span.getAttribute('title');
  prm_elemento.setAttribute('data-v', titulo);
}

function selecionaFakeList(prm_browser, itemLista){
  var fakelist = document.getElementById('fakelist');

  if (document.getElementById(prm_browser).classList.contains('multi')){
    var selecao = fakelist.getAttribute('data-multi');
    var descricao = fakelist.getAttribute('data-multi-desc');
    if (selecao !== null && selecao.trim().length > 0){
      var salvos = selecao.split('|');
      var salvos_desc = descricao.split('|')
      if (salvos.includes(itemLista.title)){
        var index = salvos.indexOf(itemLista.title);
        salvos.splice(index,1);
        salvos_desc.splice(index,1);
        selecao = salvos.join('|');
        descricao = salvos_desc.join('|');
      } else {
        selecao = selecao+'|'+itemLista.title;
        descricao = descricao+'|'+itemLista.innerHTML.trim().substr(0,5)+'...';
      }
    } else {
      selecao = itemLista.title;
      descricao = itemLista.innerHTML.trim().substr(0,5)+'...';
    }
    if(itemLista.classList.contains('selected')){
      itemLista.classList.remove('selected');
    } else {
      itemLista.classList.add('selected');
    }
    fakelist.setAttribute('data-multi',selecao);
    fakelist.setAttribute('data-multi-desc',descricao);
    if (descricao.length >= 30){
      descricao = descricao.substring(0,30)+'[...]'
    }
    fakelist.lastChild.setAttribute('onclick', 
      "document.getElementById('"+prm_browser+"').parentNode.setAttribute('data-v', '"+selecao+"');"
      +"document.getElementById('"+prm_browser+"').innerHTML = '"+descricao+"';"
      +"document.getElementById('fakelist').classList.toggle('visible');"
      +"if (this.parentNode.firstChild.getAttribute('data-ref').indexOf('bEC') != -1) {"
        +"document.getElementById('"+prm_browser+"').onblur();"
      +"}"
    );
  } else {
    document.getElementById(prm_browser).parentNode.setAttribute('data-v', itemLista.title); 
    document.getElementById(prm_browser).innerHTML = itemLista.innerHTML.trim();
    document.getElementById('fakelist').classList.toggle('visible');
    if (document.getElementById('fakelist').firstChild.getAttribute('data-ref').indexOf('bEC') != -1) {
      document.getElementById(prm_browser).onblur(); 
    }
  }
}

document.addEventListener('mousedown', function(e){
  mousedown = true;  
});

document.addEventListener('mouseup', function(e){

    mousedown = false;  
    if(e.target.parentNode){
      if(!e.target.classList.contains('opt') && !e.target.classList.contains('group') && !e.target.classList.contains('search') && !e.target.parentNode.classList.contains('search') && !e.target.parentNode.classList.contains('custom')){
        var fbopen = this.querySelectorAll('.fakelistbox.open');

        for(let i=0;i<fbopen.length;i++){
          let parente = fbopen[i].parentNode;
          if(parente.id != e.target.id && parente.id != e.target.parentNode.id && parente.parentNode.id != e.target.parentNode.id && !e.target.classList.contains('opt')){
            //if(parente.previousElementSibling.classList.contains('script')){
              parente.click();
            //}
            fbopen[i].classList.remove('open');
            fbopen[i].style.removeProperty('height');
            let primo = fbopen[i].previousElementSibling;
            if(primo.innerHTML.length == 0){
              primo.innerHTML = primo.getAttribute('data-placeholder');
              primo.setAttribute('data-custom', 'N'); 
            }
          }
        }
      }
    }

    //resize em tempo real
    /*if(e.target.classList.contains('grafico') || e.target.classList.contains('medidor')){
      let obj = e.target;
      let altura  = parseInt(window.getComputedStyle(obj).getPropertyValue('height').replace('px', ''))-60;
      let largura = window.getComputedStyle(obj).getPropertyValue('width').replace('px', '');
      ajax('fly', 'alter_attrib', 'prm_objeto='+obj.id+'&prm_prop=ALTURA&prm_value='+altura+'&prm_usuario=DWU', true); 
      ajax('fly', 'alter_attrib', 'prm_objeto='+obj.id+'&prm_prop=LARGURA&prm_value='+largura+'&prm_usuario=DWU', true); 
      let mychart = echarts.init(document.getElementById('ctnr_'+obj.id));
      mychart.resize(); 
    }*/
    
    /*if(e.target.className != 'fakeoption' && e.target.parentNode.className != 'fakeoption'){
      if(this.querySelector('.fakelistbox.open')){
        var fakebox = this.querySelector('.fakelistbox.open');
        
        fakebox.classList.remove('open');  
        if(fakebox.previousElementSibling.innerHTML.length == 0){
          fakebox.previousElementSibling.innerHTML = fakebox.previousElementSibling.getAttribute('data-placeholder'); 
        }
      }
    }*/
});

var fake_conteudo     = '',
    ws_erro_selecao   = false;

function fakeListBox(ident, campo, selected, multi, visao, adicional, reverse, e, custom){

  /*teste de campo nulo, passar para parametro */

  var nullabel = 'false';
  var fakeobj = document.getElementById(ident);

  var fixedl       = fakeobj.children[0].getAttribute('data-fixed').length,
      fixedl_val   = fakeobj.children[0].getAttribute('data-fixed'),
      opcao_add    = 'N',
      opcao_search = 'N';

  if (fakeobj.querySelector('.fakelistbox').querySelector('.custom')) { 
    if (fakeobj.querySelector('.fakelistbox').querySelector('.custom').querySelector('.add')) { 
      opcao_add    = 'S';   
    }
    if (fakeobj.querySelector('.fakelistbox').querySelector('.custom').querySelector('.search')) {     
      opcao_search = 'S';
    }   
  }

  if(fakeobj.querySelector('.fakelistbox').classList.contains('open')){
    
    ws_erro_selecao   = false;

    if((fakeobj.title != fakeobj.getAttribute('data-default'))){

      // Valida a lista de seleção multipla - Se for lista de seleção que grava no Backend (Oracle) 
      if(fakeobj.previousElementSibling){
        if(fakeobj.previousElementSibling.className == 'script'){
          if (fakeobj.title.split('|').length > 1000) {   // Mais de 1000 itens gera erro na cláusula IN do Oracle 
            alerta('feed-fixo','N&atilde;o &eacute; poss&iacute;vel selecionar mais de 1000 itens, foram selecionados ' + fakeobj.title.split('|').length.toString() + ' itens');
            ws_erro_selecao = true;
          } else if (fakeobj.title.length > 8000) {        // Não é permitir mais de 8177 na chamada URL 
            alerta('feed-fixo','N&uacute;mero de itens selecionados superior ao permitido');
            ws_erro_selecao = true;
          }
        }
      }
      if (ws_erro_selecao == false ) { 
        if(fakeobj.getAttribute('data-children')){
          var filhos = fakeobj.getAttribute('data-children');
          if(filhos.length > 0){
            fakeReset(filhos.split('|'));
          }
        }
        // Executa o script para gravar no banco de dados 
        fakeobj.setAttribute('data-default',     fakeobj.title);
        if(fakeobj.previousElementSibling){
          if(fakeobj.previousElementSibling.classList.contains('script')){  
            fakeobj.previousElementSibling.click();                         // Chama procedure do backend que também atualiza a variável ws_erro_selecao
          }
        }
      }  
    } 

    // Se não houver erro na gravação, atualiza a descrição do campo com os itens selecionandos e fixos/manual da lista
    if (ws_erro_selecao == false ) {

      fakeobj.classList.remove('open');

      if(fakeobj.querySelector('.fakelistbox').querySelector('.selected')){
        var selecionado = fakeobj.querySelector('.fakelistbox').querySelector('.selected').title;
        var descricao = fakeobj.querySelector('.fakelistbox').querySelector('.selected').textContent;
      }
      
      if(!fakeobj.children[0].getAttribute('contentEditable') || e.type == 'mouseleave'){
          
        fakeobj.querySelector('.fakelistbox').style.removeProperty('height');
        fakeobj.querySelector('.fakelistbox').classList.remove('open');  

        if(fakeobj.children[0].innerHTML.trim().length == 0 && nullabel == 'false' && multi == 'N'){
          if(fixedl == 0){
            
            if(typeof selecionado === "undefined"){
              fakeobj.children[0].innerHTML = fakeobj.children[0].getAttribute('data-placeholder');
            } else {
              fakeobj.children[0].innerHTML = descricao;
              fakeobj.children[0].title     = selecionado;
              fakeobj.title                 = selecionado;
            }
          } 
          fakeobj.children[0].blur();
        }
      }

      let selecionados = fakeobj.querySelector('.fakelistbox').querySelectorAll('.selected, .reverse'); 
      // Somente multi selecao  
      if(multi == 'S' && e.type == 'click' ){
        var texto = [], 
            itens = [],
            vnot  = '';

        if(selecionados.length > 0){
          // ordena os selecionados conforme a ordem da seleção 
          // ------------------------------------------------------------------------------
          var sel_ordenado = [],
              sel_anterior = {};
          for(let i=0;i<selecionados.length;i++){
            sel_ordenado[i] = selecionados[i];      // Adiciona no final do array 
            sel_ordenado[i].ordem = parseInt(sel_ordenado[i].getAttribute('data-ordem')); 
            ordem = parseInt(sel_ordenado[i].getAttribute('data-ordem')); 
            for(let j=i;j>0;j--){ // Ordena o novo array 
              if (sel_ordenado[j].ordem < sel_ordenado[j-1].ordem) { // Se a ordem do anterior for menor, troca de posição 
                sel_anterior      = sel_ordenado[j-1];
                sel_ordenado[j-1] = sel_ordenado[j]; 
                sel_ordenado[j]   = sel_anterior; 
              }
            }  
          }
          selecionados = sel_ordenado; 
          vnot = ''; 
          if (fakeobj.title.indexOf('$[NOT]') != -1) { vnot = '$[NOT]'; };    // Se os itens selecionandos forem reverse (NOT)

          for(let i=0;i<selecionados.length;i++){
            texto.push(selecionados[i].innerHTML);
            itens.push(vnot+selecionados[i].title);              
          }

          //fakeobj.children[0].innerHTML = texto.join(', ');
          //if (opcao_search == 'N') {  // Só atualiza se não tem search no fake list, o search pode ter filtrado a lista e nem todos os itens selecionados estão na lista  
          //  fakeobj.title = itens.join('|');   
          //}    
        }

        // Adiciona item fixo/manual, se foi informado 
        if (fixedl != 0) {
          texto.unshift(fixedl_val);
          itens.unshift(vnot+fixedl_val);              
        }
        if ( itens.length == 0 ) { 
          fakeobj.children[0].innerHTML = '';
          fakeobj.title                 = '';   
        } else {  
          fakeobj.children[0].innerHTML = texto.join(', ');
          if (opcao_search == 'N') {  // Só atualiza se não tem search no fake list, o search pode ter filtrado a lista e nem todos os itens selecionados estão na lista  
            fakeobj.title = itens.join('|');   
          }  
        }    

      }  else {  // se não for multipla seleção 

        if (selecionados.length >= 1) {                               // Se tem algum item selecionando 
          //if (selecionados[0].title == fakeobj.title) { 
          if (selecionados[0].title == fakeobj.title || selecionados[0].innerHTML == fakeobj.title ) {
            fakeobj.children[0].innerHTML = selecionados[0].innerHTML; 
          } else {
            fakeobj.children[0].innerHTML = fakeobj.children[0].getAttribute('data-fixed');            
          }
        } else if(fixedl != 0){                                       // Se tem item fixo/manual 
          fakeobj.children[0].innerHTML = fakeobj.children[0].getAttribute('data-fixed');
        } else {                                                      // Se não tem itens selecionandos e nem manual 
            fakeobj.children[0].innerHTML = '';
            fakeobj.title                 = '';
        } 
      }
      
      // Despois de gravado atualiza os atributos ANT 
      fakeobj.children[0].setAttribute('data-fixed-ant', fakeobj.children[0].getAttribute('data-fixed')); 
      fakeobj.setAttribute('data-ant', fakeobj.title); 

      if (fakeobj.title.indexOf('$[NOT]') != -1) { 
        fakeobj.classList.add('reverse'); 
      } else { 
        fakeobj.classList.remove('reverse'); 
      }  

    }  
  } else {

    fakeobj.classList.add('open');
    
    var v_search = ''; 
    if (fixedl != 0) { 
      v_search = fakeobj.children[0].getAttribute('data-fixed')
    }
    
    fakeboxevent(ident, campo, selected, multi, visao, adicional, fakeobj, fixedl, v_search, reverse, custom);

  }
}

function fakeReset(objarr){
  for(let i=0;i<objarr.length;i++){
    let objeto = document.getElementById(objarr[i]);
    let filho = objeto.children[0];
    objeto.title = '';
    objeto.setAttribute('data-default', '');
    objeto.setAttribute('data-ant', '');
    if(filho.getAttribute('data-placeholder')){
      filho.innerText = filho.getAttribute('data-placeholder');
    } else {
      filho.innerText = '';
    }
  }
}

function fakeboxReorder(dis, ident, removido, fixedl, reverse, evento, todos){

  var cond        = '';
  var tem_not     = (dis.parentNode.parentNode.title.indexOf('$[NOT]') == -1 ? 'N' : 'S') ;
  var data_min    = parseInt(dis.parentNode.parentNode.getAttribute('data-min')); 
  var qtd_inside  = 0;
  var qtd_marcado = 0; 
  if (dis.parentNode.parentNode.title.length != 0) { 
    qtd_inside = dis.parentNode.parentNode.title.split('|').length; 
  }  
  
  if (isNaN(data_min)) { data_min = 0}; 
 
  //verifica se ctrl esta pressionado
  if(todos){
    var linhas = dis.parentNode.querySelectorAll('.opt');
  }

  // Está setado para marcar ou desmarcar TODOS 
  //-----------------------------------------------------------------------------
  if(todos){ 
    //Não tem itens selecionando e não é obrigatório, ou tem 1 item selecionando e é obrigatório -- MARCA TODOS 
    if ((data_min == 0 && qtd_inside == 0) || (data_min > 0 && qtd_inside <= 1)) {    // if(dis.parentNode.parentNode.title.length == 0){
      var titulo = [];
      for(let i=0;i<linhas.length;i++){
        if (linhas[i].classList.contains('opt-unico')) { // desmarca os que são do tipo único 
          linhas[i].classList.remove('selected');
          linhas[i].classList.remove('reverse');
        } else {    
          linhas[i].classList.add('selected');
          titulo.push(linhas[i].title);
          qtd_marcado = qtd_marcado + 1;
        }  
      }
      dis.parentNode.parentNode.title = titulo.join('|');
    } else {  // DESMARCA TODOS 
      for(let i=0;i<linhas.length;i++){
        linhas[i].classList.remove('selected');
        linhas[i].classList.remove('reverse');
      }
      qtd_marcado = 0;
      dis.parentNode.parentNode.title = '';
    }
    if (qtd_marcado == 0 && data_min >= 1) {  // Obrigatório pelo menos 1 
      dis.classList.add('selected');  
      dis.parentNode.parentNode.title = dis.title; 
    }  
    return false;      
  }


  // Quando não for seleção TODOS 
  //--------------------------------------------------------
  var result = [];
  if(!dis.classList.contains('selected') && !dis.classList.contains('reverse') ){   // Se não estiver marcado, então marca 
    cond = 'add';
    result = dis.parentNode.parentNode.title.split('|');
    dis.classList.add('selected');    
    if (tem_not == 'S') { 
      dis.classList.add('reverse');  
    }
  } else if (dis.classList.contains('reverse')) {  // Se já estiver selecionando como revertido 
    if(tem_not == 'S' && qtd_inside == 1 && data_min >= 1 ) {       // Se só existir ele como selecionando e for obrigatoio, então deixa ele selecionado 
      cond = 'add';
      result = [] ; 
      tem_not = 'N';
      dis.classList.remove('reverse');
      dis.classList.add('selected');
    } else { 
      cond = 'remove';
      dis.classList.remove('reverse');
      dis.classList.remove('selected');
    }  
  } else {   // Já está  Selecionado   
    if(reverse.indexOf('true') != -1 && qtd_inside == 1){  // Se permite reversão e só tem ele, então reverte 
      cond = 'add';
      result = [];
      tem_not = 'S';
      dis.classList.add('selected');
      dis.classList.add('reverse');
    } else {   
      if(qtd_inside == 1 && data_min >= 1 ) {       // Se só existir ele como selecionando e for obrigatorio, não faz nada 
        return false;
      } else { 
        cond = 'remove';
        dis.classList.remove('selected');
      }  
    }  
  }   

  // Tratamento para listas que possuem itens Únicos - (Executa só na seleção de itens) 
  //----------------------------------------------------------------------------------
  if (cond == 'add') { 
    // se o item selecionado for um item ÚNICO, desmarca todos os outros, e limpa o conteúdo atual  
    if (dis.classList.contains('opt-unico')){     
      let linhas = dis.parentNode.querySelectorAll('.selected');
      for(let i=0;i<linhas.length;i++){
        if (dis.title != linhas[i].title) { 
          linhas[i].classList.remove('selected');
          linhas[i].classList.remove('reverse');
        }  
      }
      dis.parentNode.parentNode.title = '';  // Limpa conteúdo selecionando anteriormente, para adicinar somente o item selecionando (único)
      result = [];
    } else {    // Se o item selecionando NÃO for um item único e tem item unico selecionando, limpa o conteudo para adicionar somente o item selecionando 
      let linhas = dis.parentNode.querySelectorAll('.opt-unico.selected');
      for(let i=0;i<linhas.length;i++){
        linhas[i].classList.remove('selected');
        linhas[i].classList.remove('reverse');
        dis.parentNode.parentNode.title = '';  // Limpa conteúdo selecionando anteriormente, para adicinar somente o item selecionando (único)
        result = [];
      }
    }
  }  
 
  var elementos = dis.parentNode.querySelectorAll('.selected');
  var reorder   = false;
  
  if(dis.getAttribute('data-ordem')){
    if(dis.classList.contains('selected')){
      //hexa de ordem de colunas para bolha não ocupar dois espaços
      switch (elementos.length){
        case 10:
          dis.setAttribute('data-ordem', 'A'); break;
        case 11:
          dis.setAttribute('data-ordem', 'B'); break;
        case 12:
          dis.setAttribute('data-ordem', 'C'); break;
        case 13:
          dis.setAttribute('data-ordem', 'D'); break;
        case 14:
           dis.setAttribute('data-ordem', 'E'); break;
        case 15:
           dis.setAttribute('data-ordem', 'F'); break;
        default:     
           dis.setAttribute('data-ordem', elementos.length); break;
      } 
                
    } else {
      removido = parseInt(dis.getAttribute('data-ordem'));
      dis.setAttribute('data-ordem', 0);
      reorder = true;
    }
  }

  var ordem    = '';
  var arrinner = [];
  var arrtitle = [];
  var arrvalores = dis.parentNode.parentNode.title.split('|');
  var varnot;
  
  //testa reverse do elemento atual
  if(tem_not == 'S' || dis.classList.contains('reverse') ){
    varnot = '$[NOT]';
  } else {
    varnot = '';
  }
  
  if(cond == 'remove'){
    for(let v=0;v<arrvalores.length;v++){
      if(arrvalores[v].replace('$[NOT]', '') != dis.title){
        result.push(arrvalores[v]);        
      }
    }
  } else {
    if(dis.classList.contains('selected')){
      result.push(varnot+dis.title);      
    }
  }

  var elementos = dis.parentNode.querySelectorAll('.selected');
  for(let i=0;i<elementos.length;i++){
    
    if(reorder == true){       
      //reordena superior ao valor removido, sem alterar a ordem
      if(elementos[i].getAttribute('data-ordem') >= removido){
        elementos[i].setAttribute('data-ordem', elementos[i].getAttribute('data-ordem')-1);
      }
    } else {
      if(elementos[i].getAttribute('data-ordem')){
        ordem = elementos[i].getAttribute('data-ordem')+'#';
      }
    }
    
    arrinner.push(ordem+elementos[i].textContent);
    
    //testa reverse, se tiver adiciona o not na condição
    arrtitle.push(ordem+varnot+elementos[i].title);
    
  }
  
  arrinner = arrinner.sort();
  //arr para jogar no title, onde ficam os valores
  arrtitle = arrtitle.sort();
  
  //testa se a desc é fixa, se não for troc pelos valores
  if(fixedl == 0){
    if(document.getElementById(ident).children[0].innerHTML.length == 0){
      document.getElementById(ident).children[0].innerHTML = ''; 
    }
  }

  // Se for multi seleção, atualiza o item fixo/manual (se foi informado)
  if (document.getElementById(ident).classList.contains("multi")) { 
    let fixed_vlr = document.getElementById(ident).children[0].getAttribute('data-fixed'); 
    if (fixed_vlr.length != 0) { 
      result = result.filter( val => val != fixed_vlr);         // Retira o valor manual (caso já esteja na seleção)
      result.unshift(varnot + fixed_vlr);                                  // Adiciona no inicio 
    }  
  }

  //pega o resultado em vez de a soma dos campos atuais, isso inclui os que não estão visiveis
  document.getElementById(ident).title = result.filter(n => n).join('|').replace(/[0-9A-Z]+#/g, '');

}



function fakeboxAdd(dis){
  let fake  = dis.parentNode.parentNode.parentNode,
      valor = dis.previousElementSibling.value, 
      ant   = fake.children[0].getAttribute('data-fixed-ant'); 
      if (valor === ant) {
        return; 
      }
  if (fake.classList.contains("multi")) {  // Se for multipla seleção
    let arrvalores = fake.title.split('|'),
        vnot    = (fake.title.indexOf('$[NOT]') != -1 ? '$[NOT]' : '') ;

    arrvalores = arrvalores.filter( val => val != ant);         // Retira o valor manual anterior (se houver)
    arrvalores.unshift(vnot+valor);                                  // Adiciona no inicio 
    fake.title = arrvalores.filter(e => e).join('|');
    fake.children[0].setAttribute('data-fixed', valor); 

  } else {   
    fake.children[0].setAttribute('data-fixed', valor); 
    fake.title = valor;
  }  
}  


var holdoption = '';
var reversingoption = '';

function fakeboxevent(ident, campo, selected, multi, visao, adicional, fakeobj, fixedl, search, reverse, custom){

  fakeobj.classList.remove('errorinput');
  
  fakeobj.classList.add('loading');
  var view = '';

  if(visao.length > 0){
    if(document.getElementById(visao)){
      view = document.getElementById(visao).title;
    } else {
      view = visao;
    }
  }
  
  if(adicional.length > 0){
    if(document.getElementById(adicional)){
      if(!document.getElementById(adicional).classList.contains("dragme")){
        adicional = document.getElementById(adicional).title;		
      } 
    }
  }
  
  var  linhai ='';

  //se tiver $ na passagem de parametro do campo, ele pega estaticamente do js do contrario requisita do banco
  if(campo.split('$').length > 1){

    fakeobj.querySelector('.fakelistbox').innerHTML = '';
    var jsonValue = fakeListCustom[campo.replace('$', '')];
    var jsonLista = JSON.parse(jsonValue);

    for(let lista in jsonLista){
      fakeobj.querySelector('.fakelistbox').appendChild(fakeTag(jsonLista[lista].value, jsonLista[lista].text, jsonLista[lista].type, selected));
    }

    fakeEvent(fakeobj, ident, selected, multi, visao, adicional, fixedl, search, reverse);
    fakeobj.classList.remove('loading');

  } else {

    // somente para browser
    try {
      var obj = document.getElementById('data_list').getAttribute('data-objeto');
    } catch (error) {
      var obj = '';
    }

    call('fakelistoptions', 'prm_ident='+ident+'&prm_campo='+campo+'&prm_visao='+view+'&prm_ref='+encodeURIComponent(selected)+'&prm_adicional='+encodeURIComponent(adicional)+'&prm_search='+search+'&prm_obj='+obj).then(function(resultado){
      fakeobj.querySelector('.fakelistbox').innerHTML = resultado;
    }).then(function(){
      fakeEvent(fakeobj, ident, selected, multi, visao, adicional, fixedl, search, reverse);     
    }).then(function(){
      fakeobj.classList.remove('loading');
    });
  }

}

function fakeTag(valor, texto, tipo, selected){
  var tag = document.createElement('li');
  tag.className = tipo;
  
  if(selected == valor){
    tag.className = tipo+' selected';
  }

  tag.title     = valor;
  tag.innerHTML = texto || valor;
  return tag;
}

//fakeobj estava duplicado
function fakeEvent(fakeobj, ident, selected, multi, visao, adicional, fixedl, search, reverse){

  if(fakeobj.querySelector('.fakelistbox').children[0]){

    /* calc posição do fake */
      //if(!document.querySelector('.mobile') || PRINCP.classList.contains('paisagem')){
        var itens_count = fakeobj.querySelector('.fakelistbox').children.length;
        if(itens_count > 7){ itens_count = 7; }
        if(fakeobj.id == 'fake-usuario-permissao') { itens_count = 3; }  // Se for essse fake reduz a altura para 3 linhas somente 
        var hbloco    = fakeobj.querySelector('.fakelistbox').children[0].clientHeight+2; 
        var altura    = itens_count*hbloco;
        var posicao   = fakeobj.getBoundingClientRect().top;
        var distancia = fakeobj.clientHeight;
        
        if(fakeobj.parentNode.id == 'painel' ){    // || fakeobj.parentNode.id == 'quick-anotacao'
          var espaco = fakeobj.parentNode.clientHeight;
        } else {
          var espaco = PRINCP.clientHeight;
        }

        var espaco_sup = posicao - get('menup').clientHeight,
            espaco_inf = espaco - posicao - hbloco;

        if (altura > espaco_inf && fakeobj.id != 'fake-usuario-permissao') {    // se não cabe na parte inferior 
          // Se tem mais espaço na parte superior, joga lista para cima e ajusta a altura da lista (se necessário)
          if (espaco_sup > espaco_inf) { 
            fakeobj.querySelector('.fakelistbox').style.setProperty('bottom', distancia+'px');
            if (altura > espaco_sup) { 
              altura = espaco_sup; 
            }
          // se tem mais espaço na parte inferior, joga lista para baixa e ajusta a altura da lista (se necessário)   
          } else {  
            fakeobj.querySelector('.fakelistbox').style.setProperty('top', distancia+'px');
            if (altura > espaco_inf) { 
              altura = espaco_inf; 
            }
          }
        } else { 
          fakeobj.querySelector('.fakelistbox').style.setProperty('top', distancia+'px');
        }  

        fakeobj.querySelector('.fakelistbox').style.setProperty('height', altura+'px', 'important');

        /***************** 
        // teste abre pra cima se caixa for maior que parte inferior
        if(altura+posicao+hbloco > espaco && !document.querySelector('.mobile') && fakeobj.id != 'fake-usuario-permissao') {
          // se parte superior for menor que tamanho da caixa, caixa recebe altura igual tamanho menos tamanho fake 
          if(posicao < altura){
            altura = posicao-distancia;
            fakeobj.querySelector('.fakelistbox').style.setProperty('bottom', distancia+'px');
          } else {
            fakeobj.querySelector('.fakelistbox').style.setProperty('bottom', distancia+'px');
          }
        } else {
          fakeobj.querySelector('.fakelistbox').style.setProperty('top', distancia+'px');
        }
        fakeobj.querySelector('.fakelistbox').style.setProperty('height', altura+'px');
        ***************************/ 

      //}

      if(fakeobj.querySelector('.search')){
        if(search.length > 0){
          fakeobj.querySelector('.search').value = search;
          fakeobj.querySelector('.search').focus();
        }
      }

      // Se tem valor fixo/manual atualiza os atributos fixed do fakelist
      if(fakeobj.querySelector('.add')){
        let fixed_val = fakeobj.querySelector('.add').previousElementSibling.value; 
        if (fixed_val.length != 0) { 
          fakeobj.children[0].setAttribute('data-fixed-ant',fixed_val);    
          fakeobj.children[0].setAttribute('data-fixed',    fixed_val);    
        }
      }

      fakeobj.classList.remove('loading');
      fakeobj.querySelector('.fakelistbox').classList.add('open');
      
      var linhas  = fakeobj.querySelector('.fakelistbox').querySelectorAll('.opt');

      var linhasl = linhas.length; 
      for(let l=0;l<linhasl;l++){
        linhai = linhas[l];
        
        if(multi == 'S' && !document.querySelector('.mobile')){
          linhai.addEventListener('mouseover', function(e){
            var removido = 0;
            
            if(mousedown == true){
              fakeboxReorder(this, ident, removido, fixedl, reverse, 'mouseover', false);
            } 
          });
        }
        
        document.getElementById(ident).children[0].setAttribute('data-custom', 'N');
        
        if(multi == 'S'){
          
          linhai.addEventListener('click', function(e){
            e.stopPropagation();
          });
          
          var mouseevent = down; 

        } else {
          var mouseevent = up;
        }

        //evento do reverso/not de option
        /*if(reverse.indexOf('true') != -1){
          linhai.addEventListener('dblclick', function(e){
  
            if(this.classList.contains('reverse')){
              this.classList.remove('selected');
              this.classList.remove('reverse');
            } else {
              var lista = this.parentNode.querySelectorAll('.selected');
              for(let i=0;i<lista.length;i++){
                if(!lista[i].classList.contains('reverse')){
                  lista[i].classList.remove('selected');
                }
              }
              //this.classList.add('selected');
              this.classList.add('reverse');
            }
          });
        }*/

        //evento regular de option
        linhai.addEventListener(mouseevent, function(e){

          var dis = this;
          
          var removido = 0;
          if(e.which == 1){
            mousedown = true;  
          }

          //mais de uma opção
          if(multi == 'S'){

            var todos;
            if(PRINCP.classList.contains('mac')){
              try {
                todos = e.metaKey;
              } catch(err) {
                todos = e.ctrlKey;
              }
            } else {
              todos = e.ctrlKey;
            }

            fakeboxReorder(this, ident, removido, fixedl, reverse, mouseevent, todos);
            
          } else {

            //minimo força, ter uma opção não nula
            if(this.parentNode.parentNode.getAttribute('data-min') > 0){
              if(this.parentNode.querySelector('.selected')){
                this.parentNode.querySelector('.selected').classList.remove('selected');
              }
              this.classList.add('selected');
            } else {

              if(this.classList.contains('selected')){
                this.classList.remove('selected');
              } else {
                if(this.parentNode.querySelector('.selected')){
                  this.parentNode.querySelector('.selected').classList.remove('selected');
                }
                this.classList.add('selected');
              }
            }
            //removivel

            if(this.parentNode.querySelector('.selected')){
              if(fixedl == 0){
                document.getElementById(ident).children[0].innerHTML = this.parentNode.querySelector('.selected').innerHTML; 
              }
              document.getElementById(ident).title = this.parentNode.querySelector('.selected').title;
            } else {
              if(fixedl == 0){
                document.getElementById(ident).children[0].innerHTML = ''; 
              }
              document.getElementById(ident).title = '';
            }

            document.getElementById(ident).setAttribute('data-ant', document.getElementById(ident).title);


            if(this.classList.contains('opt')){
              if(document.querySelector('.custom')){
                document.querySelector('.custom').children[0].value == '';
                document.querySelector('.custom').children[0].removeAttribute('value');
              }
              this.parentNode.parentNode.click();
            }
          }
        }); 
      }
     
    } else {
      alerta('feed-fixo', TR_NR);
    }
}

function loader(x){
  if(!document.getElementById(x).querySelector('.load')){
    var obj = document.getElementById(x);
    if(obj.tagName == 'TBODY'){
    var load = document.createElement('td');
    load.setAttribute('colspan', '99');
     load.style.setProperty('text-align', 'center');
    } else {
    var load = document.createElement('div');
    }
    obj.innerHTML = "";
    load.className = 'load';
    load.innerHTML = LAYER.children[1].innerHTML;
    document.getElementById(x).appendChild(load);
  }
  document.getElementById('content').classList.add('loading');

}

function ordem(obj,screen, ord){
  var screen = document.getElementById('current_screen').value;
  if(document.getElementById(obj)){
    ajax('order', 'alterorder', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_valor='+ord, false, obj);
    document.getElementById(obj).style.zindex = '';
  } else {
    parametro = document.getElementById(obj+'trl').value; 
    ajax('order', 'alterorder', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_valor='+ord, false, obj, document.getElementById(obj+'trl').style.zIndex, parametro);
    document.getElementById(obj+'trl').style.zindex = '';
  }
}

function menuLink(obj, objn){
  if(this.parentNode.className != 'FILE'){
    var obj = this.parentNode.id.replace('menu', '');
    objn = this.innerHTML;
    remover(obj+'trl'); 
    //loading();
      if(obj.indexOf('ORG') == -1){
          if(document.getElementById(obj)){
            if(document.getElementById(obj).className.indexOf('relatorio') != -1){
              document.getElementById(obj).remove();
            }
          }
          document.getElementById('drill_obj').value = obj;
          cleardrill();
          appendar('prm_drill=Y&prm_objeto='+obj+'&PRM_POSX=200PX&PRM_POSY=100PX&PRM_ZINDEX=2&prm_screen='+tela+'&prm_track='+obj+'&prm_objeton='+objn+'&prm_cd_goto=13062309', '', '');
          centerDrill(obj);
          carrega('ajobjeto?prm_objeto='+obj+'trl');
      } else {
        appendar('prm_drill=Y&prm_objeto='+obj+'&PRM_POSX='+cursorx+'PX&PRM_POSY='+cursory+'PX&PRM_ZINDEX=2&prm_screen='+tela+'&prm_track='+obj+'&prm_objeton='+objn+'&prm_cd_goto=13062309', '', '');
        setTimeout(function(){ carrega('ajobjeto?prm_objeto='+obj); }, 6000);
      }
  }
}

function donut(event){
  if ( (PRINCP.className != "slide-S") && (tela != 'SCR_CUSTOMIZACAO') ) {
 
    event.stopPropagation();
    var parente = event.target;
    var donut = document.getElementById('donut');

    if(donut.classList.contains('open')){
      donut.classList.remove('open');
    } else {

      if(event.clientY+donut.clientHeight > window.innerHeight){
        if (event.clientY < donut.clientHeight) {  
          donut.style.setProperty('top', '1px');
        } else {
          donut.style.setProperty('top', event.clientY-donut.clientHeight+'px');
        }  
      } else {
        donut.style.setProperty('top', event.clientY+'px');
      }
      donut.style.setProperty('left', event.clientX+10+'px');

      donut.classList.add('open');
    }
  }
}

function cycle(obj, dir){
  //if(!objsa){
    var objsa = new Array();
    var objs = MAIN.querySelectorAll('.dragme.dados, .dragme.grafico, .dragme.medidor');
    var objslength = objs.length;
    for(let i=0;i<objslength;i++){
      objsa[i] = objs[i].id;
    }
  //}
  scale(obj, 'indirect');
  setTimeout(function(){
  var ipos = objsa.indexOf(obj);

  if(dir == 'next'){
    if(parseInt(ipos)+1 < objs.length){ ipos = parseInt(ipos)+1; } else { ipos = 0; }
  } else {
    if(parseInt(ipos)-1 > -1){ ipos = parseInt(ipos)-1; } else { ipos =  objs.length-1; }
  }
  scale(objs[parseInt(ipos)].id, 'indirect');
  }, 100);
}

function savepwd(){
  document.getElementById('salvar').setAttribute('class',''); 
  document.getElementById('salvar').setAttribute("onclick","var senha1 = document.getElementById('senha1').value;  ajax('fly', 'save_pwd', 'prm_senha='+encodeURIComponent(senha1)+'&prm_email='+document.getElementById('email').value+'&prm_number='+document.getElementById('number').value+'&prm_nome='+document.getElementById('completo').value); curtain(); setTimeout(function(){ window.location.reload(true); },4000); ");
}

function send_textPost(obj, line){
  var filtro = '';
  var campo = get('campo');
  if(document.getElementById('par_'+obj)){ filtro = document.getElementById('par_'+obj).value; }
  if(document.getElementById('par_'+obj+'trl')){ filtro = document.getElementById('par_'+obj+'trl').value; }   
  var visao = '';
  if(document.getElementById('mvs_'+obj)){ visao = document.getElementById('mvs_'+obj).value; }
  if(document.getElementById('mvs_'+obj+'trl')){ visao = document.getElementById('mvs_'+obj+'trl').value; }
  var msg = document.getElementById('fieldmsg').value.replace(/<.*?>/g, '');
  if(msg.length > 1){
    var msg = encodeURIComponent(msg);
    //if(document.getElementById('fieldemail').checked){ email = 'S'; } else { email = 'N'; }
    //if(document.getElementById('fieldsms').checked){ sms = 'S'; } else { sms = 'N'; }
    if(document.getElementById('sendmail').classList.contains('selected')){ email = 'S'; } else { email = 'N'; }
    if(document.getElementById('sendsms').classList.contains('selected')){ sms = 'S'; } else { sms = 'N'; }
    //var usuario_msg = document.getElementById('usuario-msg').title;
    var usuario_msg = document.querySelector('.list_container').querySelector('.selected').title;
    call('insert_post', 'prm_objeto='+obj+'&prm_screen='+tela+'&prm_visao='+visao+'&prm_usuario='+usuario_msg+'&prm_msg='+msg+'&prm_time='+document.getElementById('tempo-msg').title+'&prm_line='+line+'&prm_email='+email+'&prm_sms='+sms+'&prm_filtro='+filtro).then(function(resposta){
      if(resposta.indexOf('FAIL') == -1){
        call('text_post', 'prm_objeto=&prm_line=&prm_group='+usuario_msg).then(function(res){
          campo.innerHTML = res;
          campo.scrollTop = campo.scrollHeight;
        });
      } else {
        alerta('msg', TR_ER_MS);
      }  
    });
    document.getElementById('fieldmsg').value = '';
  }
}

function selectTextPost(dis){
  if(dis.parentNode.querySelector('.selected')){ 
    dis.parentNode.querySelector('.selected').classList.remove('selected'); 
  } 
  dis.classList.add('selected'); 
  dis.classList.remove('msgs'); 
  call('text_post', 'prm_objeto=&prm_line=&prm_group='+dis.title).then(function(res){ 
    let campo = get('campo'); 
    campo.innerHTML = res; 
    campo.scrollTop = campo.scrollHeight;  
  });
}

function fakeLang(x, y, z){
  
  var fakelist = document.getElementById('fakelist');
  
  if(fakelist.className == ''){
    
    if(document.getElementById('attriblist').className == 'open'){
      fakelist.style.setProperty('left', '330px');
    }

    let fun = function(){
        ajax('list', 'fakelist', 'prm_ident='+x+'&prm_titulo='+z+'&prm_campo=lang&prm_visao='+y, false, 'attriblist'); 
    }
    attReopen(fun, 'attriblist');
    
  }
  
  fakelist.classList.toggle('visible');
}

var fallback = '';

if(typeof ADMIN != "undefined"){
  if(ADMIN == 'A'){
    if(typeof ace === 'undefined'){
      fallback = fallback+'<script src="' + OWNER_BI + '.fcl.download?arquivo=ace.js">\x3C/script>';
    }
    fallback = fallback+'<script src="' + OWNER_BI + '.fcl.download?arquivo=mode-sql.js">\x3C/script>';
  }
  

  document.write(fallback);
}

paste = '';

var clickGlobal = new Object;
//var clickStart  = new Object;

function start(){
  //window.status = 'ready_to_print';
  var cd_tela_inicial;

  window.addEventListener('scroll', function(){
    if(get('jumpdrill')){ get('jumpdrill').remove(); }
    if(get('jumpmed')){ get('jumpmed').remove(); }
    if(get('anotacao_show'))  { get('anotacao_show').remove(); }
    if(get('selecteddata')){ get('selecteddata').id = ''; }
    if(document.querySelector('.optionbox.obsbox.open')){ 
      document.querySelector('.optionbox').classList.remove('open'); 
      setTimeout(function(){ document.querySelector('.optionbox').remove(); }, 200);
    }
  });
  
  document.addEventListener('mousedown', selectmouse);
  document.addEventListener('touchstart', selectmouse);
  document.addEventListener('mouseup', function(){ isdrag = false; xdrag = 0; ydrag = 0; });
  document.addEventListener('touchend', function(){ isdrag = false; xdrag = 0; ydrag = 0; });
  document.addEventListener('mousemove', movemouse);
  document.addEventListener('touchmove', movemouse);
  
  if(document.getElementById('show_comandos')){
    
    document.getElementById('show_comandos').addEventListener('click', function(e){
      
      if(e.target.className == 'backward' || e.target.parentNode.className == 'backward' || e.target.parentNode.parentNode.className == 'backward'){
        clearInterval(sobbar);
        clearTimeout(activeshow);
        document.getElementById('show_only_bar').style.setProperty('width', 0);
        var prevp = document.getElementById('active-show').previousElementSibling;
        if(prevp.className == 'show_only'){
          document.getElementById('active-show').id = '';
          prevp.id = 'active-show';
          removeTrash();
          shscr(prevp.value);
        } else {
          document.getElementById('active-show').id = '';
          projecoes[projecoes.length-1].id = 'active-show';
          removeTrash();
          shscr(projecoes[projecoes.length].value);
        }
      } 
      
      if(e.target.className == 'forward' || e.target.parentNode.className == 'forward' || e.target.parentNode.parentNode.className == 'forward'){
        clearInterval(sobbar);
        clearTimeout(activeshow);
        document.getElementById('show_only_bar').style.setProperty('width', 0);
        var nextp = document.getElementById('active-show').nextElementSibling;
        if(nextp.className == 'show_only'){
          document.getElementById('active-show').id = '';
          nextp.id = 'active-show';
          removeTrash();
          shscr(nextp.value);
        } else {
          document.getElementById('active-show').id = '';
          projecoes[0].id = 'active-show';
          removeTrash();
          shscr(projecoes[0].value);
        }
      }
      
      if(e.target.className == 'pause'){
        /*if(document.getElementById('show_only_bar').classList.contains('pause')){
          var largura = parseFloat(document.getElementById('show_only_bar').style.getPropertyValue('width'));
          var tempototal = document.getElementById('active-show').getAttribute('data-time');
          
          document.getElementById('show_only_bar').classList.remove('pause');
          var valor = 100/largura;
          sobbar = setInterval(function(){
            var sob = document.getElementById('show_only_bar');
            var widthbar = parseFloat(sob.style.getPropertyValue('width'));
            sob.style.setProperty('width', (widthbar+valor)+'%');
          }, 1000);
          
          var nextp = document.getElementById('active-show').nextElementSibling;
          
          activeshow = setTimeout(function(){
                shscr(nextp.value);
            }, parseInt(tempototal-(largura/(100/tempototal))+'000')+1000 );
          
        } else {
          clearInterval(sobbar);
          clearTimeout(activeshow);
          document.getElementById('show_only_bar').classList.add('pause');
        }*/
      }
           
    });
  
    document.addEventListener('keyup', function(e){
      if(!LAYER.classList.contains('ativo')){    
          var tecla = e.keyCode;
          //39 direita 37 esquerda 32 espaço
          if(tecla == '39'){
            if(document.getElementById('show_only_bar')){
              clearInterval(sobbar);
              clearTimeout(activeshow);
              document.getElementById('show_only_bar').style.setProperty('width', 0);
              var nextp = document.getElementById('active-show').nextElementSibling;
              if(nextp.className == 'show_only'){
                document.getElementById('active-show').id = '';
                nextp.id = 'active-show';
                removeTrash();
                shscr(nextp.value);
              } else {
                document.getElementById('active-show').id = '';
                projecoes[0].id = 'active-show';
                removeTrash();
                shscr(projecoes[0].value);
              }
            }
           
          }
          
          if(tecla == '37'){
            if(document.getElementById('show_only_bar')){
              clearInterval(sobbar);
              clearTimeout(activeshow);
              document.getElementById('show_only_bar').style.setProperty('width', 0);
              var nextp = document.getElementById('active-show').previousElementSibling;
              if(nextp.className == 'show_only'){
                document.getElementById('active-show').id = '';
                nextp.id = 'active-show';
                removeTrash();
                shscr(nextp.value);
              } else {
                document.getElementById('active-show').id = '';
                projecoes[projecoes.length].id = 'active-show';
                removeTrash();
                shscr(projecoes[projecoes.length].value);
              }
            }
           
          }
        }
    });
  }
 
  //
  //global events on objects
  //

  document.removeEventListener(up, clickGlobal);
  
  clickGlobal = (function(e){ 
    var alvo = e.target;
    
    if(alvo.classList.contains('options')){ 
      if(up == 'touchend'){
        e.stopPropagation;
        alvo.classList.toggle('hover'); 
      }
    }

    if(alvo.classList.contains('fechar')){ 
      alvo.parentNode.remove(); 
      if(document.querySelector('.'+alvo.parentNode.id+'_jump')){
        document.querySelector('.'+alvo.parentNode.id+'_jump').remove();
      }
    }

    if(alvo.classList.contains('removeobj')){ 
      if(confirm('Excluir objeto da tela?')){ 
        remover(alvo.parentNode.parentNode.id, 'excluir'); 
      } 
    }
  
    if(alvo.classList.contains('preferencias')){ 
      closeSideBar('saveap');
      if(alvo.parentNode.parentNode.classList.contains('front') || alvo.parentNode.parentNode.classList.contains('grafico') || alvo.parentNode.parentNode.classList.contains('dados') || alvo.parentNode.parentNode.classList.contains('marquee') || alvo.parentNode.parentNode.classList.contains('texto') || alvo.parentNode.parentNode.classList.contains('medidor') || alvo.parentNode.parentNode.classList.contains('file') || alvo.parentNode.parentNode.classList.contains('relatorio') || alvo.parentNode.parentNode.classList.contains('generico') || alvo.parentNode.parentNode.classList.contains('mapageoloc') ){
        loadAttrib('ed_gadg', 'ws_par_sumary='+alvo.parentNode.parentNode.id.split('trl')[0]); 
      }
      if(alvo.parentNode.parentNode.parentNode.classList.contains('icone') ){
        loadAttrib('ed_gadg', 'ws_par_sumary='+alvo.parentNode.parentNode.parentNode.id.split('trl')[0]); 
      }
      if(alvo.parentNode.parentNode.classList.contains('pro6')){
        loadAttrib('ed_call', 'prm_object='+alvo.parentNode.parentNode.id.split('trl')[0]+'&prm_screen='+tela);
      }                                       
    }

    if(alvo.classList.contains('filtros')){
      closeSideBar('saveap');
      openFilter(alvo.parentNode.parentNode.id+'-filterlist');
    }

    if(alvo.classList.contains('destaques')){
      closeSideBar('saveap');
      openDestaque(alvo.parentNode.parentNode.id+'-destaquelist');
    }
    
    if(alvo.classList.contains('talk')){
      var texttalk = document.getElementById('text-talk');
      if(texttalk.classList.contains('open')){
        texttalk.classList.remove('open');
      } else {
        var drillgo  = document.getElementById('drill_go').value;
        texttalk.classList.remove('open'); 
        texttalk.setAttribute('data-line', drillgo); 
        texttalk.setAttribute('data-objeto', alvo.parentNode.parentNode.id); 
        ajax('list', 'text_post', 'prm_objeto='+alvo.parentNode.parentNode.id+'&prm_line='+drillgo, false, 'campo'); 
        texttalk.classList.add('open'); 
        document.getElementById('campo').scrollTo(0,100000); 
        textTalkint = setInterval(function(){ 
          if( document.getElementById('campo')){ 
          ajax('list', 'text_post', 'prm_objeto='+alvo.parentNode.parentNode.id.split('trl')[0]+'&prm_line='+drillgo, true, 'campo'); 
          } else { 
            clearInterval(textTalkint); 
          }
          document.getElementById('campo').scrollTo(0,100000); 
        }, 5000); 
        if(get('jumpdrill')){
          get('jumpdrill').style.setProperty('opacity', '0'); 
          setTimeout(function() { get('jumpdrill').innerHTML = '' }, 100);
        }
      }
    }
    if(alvo.classList.contains('excel')){
      toexcel(alvo.parentNode.parentNode.id);
    }
    if(alvo.classList.contains('data_table')){
      if(ADMIN == 'A'){
        let ident = alvo.parentNode.id.replace('more', '');
        let visao = get('dados_'+ident).getAttribute('data-visao');
        document.getElementById('titulo').innerHTML = alvo.title; 
        call_save('consulta'); 
        carregaPainel('data_table', visao+'|'+ident.split('trl')[0]); 
        carrega('consulta?prm_objeto='+ident.split('trl')[0]+'&prm_visao='+visao); 
        curtain('enabled');
      }
    }

    if(alvo.classList.contains('lightbulb')){
      closeSideBar('saveap');
      let ident = alvo.parentNode.id.replace('more', '');
      //if(alvo.parentNode.parentNode.classList.contains('front')){
        if(alvo.parentNode.parentNode.classList.contains('pro6')){
          telaSup('objeto', ident.split('trl')[0]); 
          titulo(alvo, 'c'); 
          curtain('enabled'); 
          carregaPainel('list_call', alvo.parentNode.parentNode.id); 

          if(ADMIN == 'A'){
            carrega('list_call?prm_objeto='+ident.split('trl')[0]+'&prm_screen='+tela); 
          } else {
            carrega('list_call_end?prm_objeto='+ident.split('trl')[0]+'&prm_screen='+tela); 
          }
          if (get('attriblist').querySelector('.closer')) { 
            get('attriblist').querySelector('.closer').click();
          }  
          
          call_save('');
        } else {
          titulo(alvo, 'c'); 
          call_save(''); 
          telaSup('objeto', ident.split('trl')[0]); 
          carregaPainel('list_go', ident.split('trl')[0]); 
          carrega('list_go?prm_objeto='+ident.split('trl')[0]); 
          curtain('enabled');
        }
     
    }

    if(alvo.classList.contains('filter')){
      closeSideBar('saveap');
      let ident = alvo.parentNode.id.replace('more', '');
      let visao = get('dados_'+ident).getAttribute('data-visao');
      titulo(alvo, 'c'); 
      call_save(''); 
      telaSup('objeto', ident.split('trl')[0]); 
      //if(visao){ visao = alvo.parentNode.parentNode.getAttribute("data-visao"); } else { visao = alvo.parentNode.getAttribute("data-visao"); }
      telaSup('visao', visao); 
      carregaPainel('list_ofiltro', ident.split('trl')[0]+'|'+visao); 
      carrega('list_ofiltro?ws_par_sumary='+ident.split('trl')[0]+'&prm_visao='+visao); 
      curtain('enabled');
    }

    if(alvo.classList.contains('sigma')){
      closeSideBar('saveap');
      let ident = alvo.parentNode.id.replace('more', '');
      let visao = get('dados_'+ident).getAttribute('data-visao');
      carregaPainel('calculada', ident.split('trl')[0]); 
      document.getElementById('titulo').innerHTML = alvo.title; 
      call_save('');
      //visao = "";
      //if(alvo.parentNode.parentNode.getAttribute("data-visao")){ visao = alvo.parentNode.parentNode.getAttribute("data-visao"); } else { visao = alvo.parentNode.getAttribute("data-visao"); }
      
      carrega('list_calculada?prm_objeto='+ident.split('trl')[0]+'&prm_visao='+visao); 
      curtain('enabled');
    }

    if(alvo.classList.contains('star')){
      closeSideBar('saveap');
      let ident = alvo.parentNode.id.replace('more', '');
      let visao = get('dados_'+ident).getAttribute('data-visao');
      titulo(alvo, 'c'); 
      call_save(''); 
      //if(alvo.parentNode.parentNode.getAttribute("data-visao")){ visao = alvo.parentNode.parentNode.getAttribute("data-visao"); } else { visao = alvo.parentNode.getAttribute("data-visao"); }
      
      telaSup('visao', visao); 
      telaSup('objeto', ident.split('trl')[0]); 
      carregaPainel('blink', ident.split('trl')[0]+'|'+visao); 
      carrega('blink?prm_objeto='+ident.split('trl')[0]+'&prm_visao='+visao); 
      curtain('enabled');
    }

    if(alvo.classList.contains('conf')){

      loading(); 
      let obj = alvo.parentNode.parentNode.id;
      ajax('fly', 'favoritar', 'prm_objeto='+obj+'&prm_nome='+document.getElementById(obj+'_ds').innerHTML+'&prm_url=&prm_screen='+tela+'&prm_parametros='+encodeURIComponent(document.getElementById('par_'+obj).value)+'&prm_dimensao='+encodeURIComponent(document.getElementById('col_'+obj).value)+'&prm_medida='+encodeURIComponent(document.getElementById('agp_'+obj).value)+'&prm_pivot='+encodeURIComponent(document.getElementById('cup_'+obj).value)+'&prm_acao=incluir', false); 
      loading(); 
      // 15/06/2022 - Alterado para sempre mostrar o icone FAVORITOS (foi adicionada as telas favoritas nesse icone)
      //call('obj_screen_count', 'prm_screen='+tela+'&prm_tipo=FAVORITOS').then(function(resposta){ 
      //  if(parseInt(resposta) > 0){ 
      //    document.getElementById('favoritos').classList.remove('inv'); 
      //  } else { 
      //    document.getElementById('favoritos').classList.add('inv'); 
      //  } 
      //});
    }
    
    if(alvo.classList.contains('arrowturn')){
      loading(); 
      var obj_html = alvo.parentNode.parentNode.id;
      var objeto  = obj_html
          cd_goto = '';
      if (obj_html.split('trl').length > 1) {   // Pega a sequencia do objeto no cadastro de drills 
        objeto  = obj_html.split('trl')[0];
        cd_goto = obj_html.split('trl')[1];
      }   

      if(alvo.parentNode.parentNode.classList.contains('cross')){
        var cross = 'N';
      } else {
        var cross = 'S';
      }
      if(document.getElementById('par_'+alvo.parentNode.parentNode.id)){
        var param = document.getElementById('par_'+alvo.parentNode.parentNode.id).value;
      } else {
        var param = '';
      }
      if(PRINCP.className == 'mac' || PRINCP.className == 'mobile'){ 
        var tag = '-webkit-order';  
      } else { 
        var tag = 'order'; 
      } 

      var local = tela;
 
      
      if(alvo.parentNode.parentNode.parentNode.style.getPropertyValue(tag) && !alvo.parentNode.parentNode.parentNode.classList.contains('drill')){ 
        var posx = alvo.parentNode.parentNode.parentNode.style.getPropertyValue(tag); 
        var dashorder = '&prm_dashboard=true'; 
        dashlocation = alvo.parentNode.parentNode.parentNode.id; 
        local = dashlocation;
      } else {
        var posx = alvo.parentNode.parentNode.offsetLeft; 
        var posy = alvo.parentNode.parentNode.offsetTop; 
        var dashorder = '&prm_dashboard=false'; 
      } 

      //remover(ident); 
      document.getElementById('drill_obj').value = obj_html;   // tem que ser o objeto completo com trl? 
      if(document.getElementById(obj_html)){
        document.getElementById(obj_html).remove();
      }
      let drillY = 'N';
      if(alvo.parentNode.parentNode.classList.contains('drill')){
        drillY = 'Y';
      }

      appendar('prm_drill='+drillY+'&prm_objeto='+objeto+'&prm_parametros='+param+'&PRM_POSX='+posx+'&PRM_POSY='+posy+'&PRM_ZINDEX=2&prm_screen='+tela+'&prm_track='+objeto+'&prm_objeton=&prm_cross='+cross+dashorder+'&prm_cd_goto='+cd_goto, dashlocation, false); 
      
    }
    
    if(alvo.classList.contains('size')){
      closeSideBar('saveap');
      let fun = function(){

        var pai        = alvo.parentNode.parentNode.parentNode.id; 
        call('av_prop', 'ws_par_sumary='+alvo.parentNode.id.replace('more', '').split('trl')[0]+'&prm_screen='+tela).then(function(resultado){
          document.getElementById('attriblist').innerHTML = resultado;
        }).then(function(){
          alvo.parentNode.classList.remove('hover');
        });
      }
      attReopen(fun, 'attriblist');
    }

    if(alvo.classList.contains('aduser')){
      if(document.querySelector('.optionbox')){
        document.querySelector('.optionbox').remove();
      }
      let nome = alvo.title;
      let fun = function(){
        call('advancedUsers', 'prm_user='+nome).then(function(resposta){ 
          get('attriblist').innerHTML = resposta;
        });
      }
      attReopen(fun, 'attriblist');
    }

    if(alvo.classList.contains('grupo_screen')){  // Abre o painel de telas liberadas para o grupo de usuários 
      var cd_grupo = alvo.parentNode.parentNode.id; 
			call('grupo_screen', 'prm_grupo='+cd_grupo ).then(function(resposta){ 
				document.getElementById('content').innerHTML = resposta; 
			}); 
      carregaPainel('menu_grupo_screen', cd_grupo);      
    }

    if(alvo.id == 'custom'){
      lmenuLink(alvo);
    }

  });
  
  
  document.addEventListener(up, clickGlobal);

  /*document.addEventListener("orientationchange", function(){
      setTimeout(function(){
        var alldrags = document.querySelectorAll('.dragme');
        var sizer = alldrags.length;
        for(var ig = 0;ig<sizer;ig++){
          if(document.getElementById('dados_'+alldrags[ig].id)){
            renderChart(alldrags[ig].id);
          }
        }
      }, 500);
  });*/


  if(document.getElementById('call-menu')){
    var menu = document.getElementById('call-menu');

    call('obj_screen_count', 'prm_screen=DEFAULT&prm_tipo=CALL_LIST').then(function(resposta){
      if(parseInt(resposta) > 0){
        menu.classList.remove('invisible');
      } else {
        menu.classList.add('invisible');
      }
    }); 
  }
  
   
  if(document.getElementById('show_only_screen')){
    if(document.getElementById('float-filter')){
      var float = document.getElementById('float-filter');
      call('obj_screen_count', 'prm_screen=DEFAULT&prm_tipo=FLOAT').then(function(resposta){
        if(parseInt(resposta) > 0){
          float.classList.remove('invisible');
        } else {
          float.classList.add('invisible');
        }
      });
    }
  }

  document.getElementById('fechar_sup').addEventListener('click', fecharSup);
  document.getElementById('refresh_sup').addEventListener('click', refreshSup);
  document.getElementById('back_sup').addEventListener('click', backSup);
  
  // document.getElementById('fechar_custom').addEventListener('click', fecharCustom);
  
  if(document.getElementById('prefdrop')){
    
    var prefdrop = document.getElementById('prefdrop').querySelectorAll('ul > li'); 
    for(p=0;p<prefdrop.length;p++){
      if(prefdrop[p].className != 'noscript' && !prefdrop[p].classList.contains('aba') ){
        prefdrop[p].firstElementChild.addEventListener('mousedown', function(){
          if(document.getElementById('prefdrop').clientWidth > 60){ 
            lmenuLink(this); 
          }
        });

        prefdrop[p].firstElementChild.addEventListener('touchend', function(e){
          e.cancelBubble();
          e.preventDefault();
          if(document.getElementById('prefdrop').clientWidth > 60){ lmenuLink(this); }
        });
      }
    }
  }

  
  if(ADMIN == 'A'){
    document.addEventListener('keypress', function(e){

            var keyp = e.which;
            var valor = document.getElementById('debug-key');

        switch (keyp){

        case 100: case 68:
          startTimer = setTimeout(function(){ valor.value = 0; }, 10000);
          valor.value = e.which;
        break;

      case 101: case 69:
          if(valor.value == '100' || valor.value == '68'){ valor.value = e.which; } else { valor.value = 0; }
      break;

            case 98: case 66:
                if(valor.value == '101' || valor.value == '69'){ valor.value = e.which; } else { valor.value = 0; }
            break;

            case 117: case 85:
                if(valor.value == '98' || valor.value == '66'){ valor.value = e.which; } else { valor.value = 0; }
            break;

            case 103: case 71:
                if(valor.value == '117' || valor.value == '85'){
                    valor.value = 0;
                    if(document.getElementById('debug').className == ''){
                        document.getElementById('debug').setAttribute('class', 'active');
                        setTimeout(function(){ document.getElementById('debug').firstElementChild.focus(); }, 100);
                    } else {
                        document.getElementById('debug').setAttribute('class', '');
                    }
                } else {
                    valor.value = 0;
                }
            break;

            default:
                valor.value = 0;
            }
    });
        
    //atalhos
    document.addEventListener('keydown', function(e){


          //salvar browser
          if(e.ctrlKey && e.key == 'Enter'){
            e.preventDefault();
            if(document.getElementById('data_list_menu')){
              if(document.getElementById('data_list_menu').classList.contains('open')){
                document.getElementById('data-valor').focus();
                document.getElementById('data-valor').blur();
                document.querySelector('.link.ac1').click();
              }
            }
          }
    });
  }

  document.addEventListener("mousemove", function(e){ cursorx = e.pageX-12; cursory = e.pageY-12; });
  document.addEventListener("touchstart", function(e){ cursorx = e.touches[0].pageX-12; cursory = e.touches[0].pageY-12; });

  document.getElementById('princp').addEventListener('touchstart', function(event){  
      if(event.target.id == 'princp'){ 
        if(document.getElementById('attriblist').className == 'open'){ 
          document.getElementById('attriblist').className = ''; 
        } 
      }  
  });

  window.addEventListener('orientationchange', function(){  
      if(window.orientation == 0){ 
        PRINCP.classList.add('retrato'); 
        PRINCP.classList.remove('paisagem'); 
      } else { 
        PRINCP.classList.remove('retrato'); 
        PRINCP.classList.add('paisagem'); 
      }  
  });

  window.addEventListener('touchstart', function(event){
      var t = event.touches;
      if(t.length > 1){
      var donut = document.getElementById('donut');
        donut.style.left = t[1].clientX+15+'px';
        donut.style.top = t[1].clientY+45+'px';
        donut.classList.toggle('open');
        
      }
  });

  window.addEventListener('touchmove', function(event){
      clearTimeout(time);
  });

  window.addEventListener('touchend', function(){
      clearTimeout(time); 
  });

  apscreen(OWNER_BI + '.fcl.show_screen?prm_screen=DEFAULT', 'DEFAULT');
  var loadingbar = document.getElementById('loading-bar').children[0].children[0];
  var bar = '';
  setTimeout(function(){
      bar = setInterval(function(){ loadingbar.style.setProperty('width', (parseInt(loadingbar.style.getPropertyValue('width'))+1)+'%'); }, 40);
  }, 200);

  setTimeout(function(){ clearInterval(bar); loadingbar.style.setProperty('width', '60%'); }, 300);
  setTimeout(function(){ loadingbar.style.setProperty('width', '100%');  }, 1000);
  
  setTimeout(function(){
      remover('starting');
      mac();
      donutEvent();
      telasup    = document.getElementById("telasup");
      telacustom = document.getElementById("telacustom");
  }, 1300 );
  
  projecoes = document.querySelectorAll('.show_only');
  if(projecoes.length > 0){
    var p = 0; var m = 1;
    projecoes[0].id = 'active-show';
    setTimeout(function(){ shscr(projecoes[0].value); }, 3100);
  }
  
  if(document.getElementById("current_screen").value == "DEFAULT"){
    var repetir = 0;
    var alpha = setInterval(function(){
    if(document.getElementById('loading-bar') == null || repetir == 0){
        clearInterval(alpha);
        repetir = 1;
        var objetos = document.querySelectorAll('.dragme');
        var objetoslength = objetos.length;
        for(let i=0;i<objetoslength;i++){
          if(document.getElementById(objetos[i].id+'more')){
            var more =  document.getElementById(objetos[i].id+'more');
            more.addEventListener('touchend', function(){ this.classList.add('hover'); var w = this; setTimeout(function(w){ w.classList.remove('hover'); }, 5000); });
          }
        }
        
      }
    }, 2000);

  }


  fakeListCustom.tpGroup = 
  '{ "1": { "value": "", "text": "'+TR_TP_MT+'", "type": "group" }, "2": { "value": "ROLL", "text": "'+TR_TP_SI+'", "type": "opt" }, "3": { "value": "GROUP", "text": "'+TR_TP_NA+'", "type": "opt" } }';

  fakeListCustom.amostra = 
  '{ "1": { "value": "", "text": "'+TR_AM_LL+'", "type": "group" }, "2": { "value": "50", "text": "50", "type": "opt" }, "3": { "value": "100", "text": "100", "type": "opt" }, "4": { "value": "200", "text": "200", "type": "opt" } }';

  fakeListCustom.condicoesSimples = 
  '{ "1": { "value": "", "text": "'+TR_CS_CD+'", "type": "group" }, "2": { "value": "IGUAL", "text": "'+TR_CS_IA+'", "type": "opt" }, "3": { "value": "DIFERENTE", "text": "'+TR_CS_DD+'", "type": "opt" }, "4": { "value": "MAIOR", "text": "'+TR_CS_MA+'", "type": "opt" }, "5": { "value": "MENOR", "text": "'+TR_CS_ME+'", "type": "opt" }, "6": { "value": "MAIOROUIGUAL", "text": "'+TR_CS_AI+'", "type": "opt" }, "7": { "value": "MENOROUIGUAL", "text": "'+TR_CS_EI+'", "type": "opt" }, "8": { "value": "LIKE", "text": "'+TR_CS_SE+'", "type": "opt" }, "9": { "value": "NOTLIKE", "text": "'+TR_CS_NS+'", "type": "opt" } }';
  
  fakeListCustom.tpRegra = 
  '{ "1": { "value": "", "text": "Tipo de Regra", "type": "group" }, "2": { "value": "I", "text": "BLOQUEADO", "type": "opt" }, "3": { "value": "S", "text": "LIBERADO", "type": "opt" } }';
  fakeListCustom.agrupado = 
  '{ "1": { "value": "", "text": "Agrupado", "type": "group" }, "2": { "value": "S", "text": "Sim", "type": "opt" }, "3": { "value": "N", "text": "Não", "type": "opt" } }';

}

function openFilter(x){
  if(document.getElementById(x)){
    var filterlist = document.getElementById('filterlist');
    filterlist.className = 'filtro hidden';
    if(filterlist.getAttribute('data-desc') != x){
      setTimeout(function(){
        filterlist.innerHTML = document.getElementById(x).innerHTML;
        filterlist.className = 'filtro show';
        filterlist.setAttribute('data-desc', x);
      }, 400);
    }
    filterlist.setAttribute('data-desc', '');
  }
}

function openDestaque(x){
  if(document.getElementById(x)){
    var destaquelist = document.getElementById('destaquelist');
    destaquelist.className = 'filtro hidden';
    if(destaquelist.getAttribute('data-desc') != x){
      setTimeout(function(){
        destaquelist.innerHTML = document.getElementById(x).innerHTML;
        destaquelist.className = 'filtro show';
        destaquelist.setAttribute('data-desc', x);
      }, 400);
    }
    destaquelist.setAttribute('data-desc', '');
  }
}

function blurView(dis, visao){
  if(dis.value != dis.getAttribute('data-default')){ 
    call('save_view', 'prm_view='+visao+'&prm_valor='+encodeURIComponent(dis.value)+'&prm_tipo=desc').then(function(resposta){ 
      if(resposta.indexOf('#alert') == -1){
        dis.setAttribute('data-default', dis.value); 
        alerta('msg', TR_AL); 
      }
    });
  }
}

function viewDetalhes(visao){
  document.getElementById('content').innerHTML = ''; 
  carregaPainel('list_crocks', visao);
  call('load_crocks', 'prm_visao='+visao).then(function(resposta){ 
    document.getElementById('painel-colunas').innerHTML = resposta; 
  }); 
  telaSup('visao', visao);
}

function saveView(dis, visao, tipo){
  var valor;
  if(dis.nextElementSibling){
    valor = dis.nextElementSibling.title;
  } else {
    valor = dis.value;
  }
  call('save_view', 'prm_view='+visao+'&prm_valor='+valor+'&prm_tipo='+tipo).then(function(resposta){ 
    if(resposta.indexOf('FAIL') == -1){ 
      alerta('feed-fixo', TR_AL); 
    } else { 
      alerta('feed-fixo', TR_ER); 
    } 
  });
}

function telaSup(x, y, z){

  if(typeof z !== "undefined"){
      return telasup.getAttribute("data-"+x);
  } else {
    telasup.setAttribute("data-"+x, y);
  }
}

var ie=document.all;
var nn6=document.getElementById&&!document.all;
var isdrag=false;
var xdrag,ydrag;
var dobj;

function movemouse(e){
  if (isdrag){
    if(e){
      var movimento = e.type;
    } else {
      var movimento = 'nomove';
    }
    if (movimento == "touchmove"){

    var targetEvent = nn6 ? e.touches.item(0) : event.touches.item(0);

    var calcx = parseInt(tx + targetEvent.clientX - xdrag);
      if(calcx%5 != 0){
        var a = Math.round(calcx/10)*10;
      } else {
        var a = calcx;
      }
    var calcy = parseInt(ty + targetEvent.clientY - ydrag);
      if(calcy%5 != 0){
        var b = Math.round(calcy/10)*10;
      } else {
        var b = calcy;
      }
      dobj.style.setProperty("left", a+"px");
      dobj.style.setProperty("top", b+"px");
    //dobj.style.setProperty("transform", "translate("+a+"px, "+b+"px)");
      return false;
    } else {
      var calcx = parseInt(tx + e.clientX - xdrag);
    if(calcx%5 != 0){
        var a = Math.round(calcx/10)*10;
      } else {
        var a = calcx;
      }
    var calcy = parseInt(ty + e.clientY - ydrag);
      if(calcy%5 != 0){
        var b = Math.round(calcy/10)*10;
      } else {
        var b = calcy;
      }
      dobj.style.setProperty("left", a+"px");
      dobj.style.setProperty("top", b+"px");
    //dobj.style.setProperty("transform", "translate("+a+"px, "+b+"px)");

      return false;
    }
  }
}

function selectmouse(e){

  var fobj       = nn6 ? e.target : event.srcElement;
  var topelement = nn6 ? "HTML" : "BODY";

  if (fobj.classList.contains("wd_move")){
    while (fobj.tagName != topelement && fobj.className != "dragme" && fobj.className != "dragme front top" && fobj.className != "dragme front" && fobj.className != "dragme front cross" && fobj.className != "dragme dados" && fobj.className != "dragme medidor" && fobj.className != "dragme medidor drill" && fobj.className != "dragme grafico" && fobj.className != "dragme float-par" && fobj.className != "dragme file" && fobj.className != "dragme file drill" && fobj.className != "dragme texto" && fobj.className != "dragme grid" && fobj.className != "dragme img" && fobj.className != "dragme icone" && fobj.className != "dragme ponteiro drill" && fobj.className != "dragme grafico drill" && fobj.className != "dragme front drill" && fobj.className != "dragme front drill cross" && fobj.className != "dragme marquee" && fobj.className != "dragme relatorio" && fobj.className != "dragme heatmap" && fobj.className != "dragme grafico mapa" && fobj.className != "dragme grafico drill mapa" && fobj.className != "dragme generico" && fobj.className != "dragme mapageoloc drill"){
        fobj = nn6 ? fobj.parentNode : fobj.parentElement;
    }
  }
  //if (fobj.className=="dragme" || fobj.className=="dragme front top" || fobj.className=="dragme front" || fobj.className=="dragme front cross" || fobj.className=="dragme float-par" || fobj.className=="dragme dados" || fobj.className=="dragme img" || fobj.className=="dragme medidor" || fobj.className=="dragme grafico" || fobj.className=="dragme file" || fobj.className=="dragme file drill" || fobj.className=="dragme texto" || fobj.className=="dragme grid" || fobj.className=="dragme icone" || fobj.className=="dragme ponteiro drill"  || fobj.className=="dragme grafico drill" || fobj.className=="dragme front drill" || fobj.className=="dragme front drill cross" || fobj.className=="dragme marquee" || fobj.className=="dragme relatorio" || fobj.className=="dragme heatmap" || fobj.className == "dragme grafico mapa" || fobj.className == "dragme medidor drill"|| fobj.className == "dragme generico"){
  if(fobj.classList.contains('dragme')){
    if(fobj.parentNode.parentNode.parentNode.id == 'main' || fobj.parentNode.parentNode.id == 'main' || fobj.parentNode.parentNode.parentNode.parentNode.id == 'main' || fobj.parentNode.id == 'main'){
      if (document.getElementById('movimento').value=='yes') {
        e.preventDefault();
        isdrag = true;
        dobj = fobj;
        tx = parseInt(window.getComputedStyle(dobj).getPropertyValue('left'));
        ty = parseInt(window.getComputedStyle(dobj).getPropertyValue('top'));
        //tx = parseInt(dobj.style.getPropertyValue("left"));
        //ty = parseInt(dobj.style.getPropertyValue("top"));
        if(e){
          var movimento = e.type;
        } else {
          var movimento = 'nomove';
        }
        if  (movimento=="touchstart") {
          var targetEvent = nn6 ? e.touches.item(0) : event.touches.item(0);
          xdrag = targetEvent.clientX;
          ydrag = targetEvent.clientY;
        } else {
          xdrag = nn6 ? e.clientX : event.clientX;
          ydrag = nn6 ? e.clientY : event.clientY;
        }
        return false;
      }
    }
  }
}

function syncForm(x, y, z){
  //x local texto, y filename, z 'text/html'
  var blob = new Blob([document.getElementById(x).innerHTML], {type: z});
  var formData = new FormData();
  formData.set('arquivo', blob, y);
    ajax('fly', 'upload', formData, false, '', '', '', 'upload');
}

var dataid = '';   


// Abre a tela de seleção da DRILL - novo jumpdrill
function drillfix(evento, objeto, parametros){

  var obj = get(objeto);

  var track = get('dados_'+objeto).getAttribute('data-track');

  var tipo = 'consulta';
  var grafico = '';

  if(obj.classList.contains('grafico')){
    tipo = 'grafico';
    grafico = get('dados_'+objeto).getAttribute('data-tipo');
  }

  if(obj.classList.contains('medidor') || obj.classList.contains('dados')){
    tipo = 'valor';
  }

  if(obj.classList.contains('mapageoloc')) {
    tipo = 'mapageoloc';
  }

  if(tipo != 'consulta' && parseInt(get('dados_'+objeto).getAttribute('data-drill')) == 0){
    return false;
  }

  if(get('anotacao_show')){
    get('anotacao_show').remove();
  }

  if(get('jumpdrill')){
    get('jumpdrill').remove();
  }

  //calculo da distancia
  //rever necessidade de por no scroll da consulta
  var largura = 320;

  // if(PRINCP.className == 'mobile'){  
  if (mobile_portrait_layout() == true) { 
    largura = 180/2;
  }
  
  var visao    = get('dados_'+objeto).getAttribute('data-visao'),
      cd_goto  = '';
  if (get('dados_'+objeto).getAttribute('data-cd_goto')) { 
    cd_goto  = get('dados_'+objeto).getAttribute('data-cd_goto'); 
  }

  var grupo    = '';
  var reverse  = 'normal';
  var formato  = 'complete';
  var vlinha;
  var colunas;
  var left;
  var vert;

  if((tipo == 'grafico') || (tipo == 'mapageoloc')) {
    largura = 200;
    vlinha  = parametros;
    colunas = vlinha.split('|').filter((v, i) => (i%2) ).join('|');
    left = cursorx-(largura/2)+5;
    vert = 'top: '+(cursory-get('html').scrollTop+40)+'px';
    formato = 'short';

  } else if(tipo == 'consulta'){
    
    //especifico da consulta
    var coluna  = get('selecteddata'); 
    var linha   = get('selectedline');
    vlinha  = linha.children[0].getAttribute('data-valor');
    //pega só os impars
    //colunas = vlinha.split('|').filter((v, i) => !(i%2) ).join('|');
    colunas = get('col_'+objeto).value;
    var rect    = coluna.getBoundingClientRect();
    vert    = 'top: '+(rect.top+(coluna.clientHeight+4))+'px;';
    left    = rect.left+(coluna.clientWidth/2)-(largura/2);
    var colSpan = 0;

    //if(left+largura > MAIN.clientWidth){ // Esta sendo tratado mais abaixo
    //  left = MAIN.clientWidth-largura;
    //}
    
    if(rect.top+(coluna.clientHeight+8)+(largura/2) > PRINCP.clientHeight){
      vert    = 'bottom: '+((PRINCP.getBoundingClientRect().height-get('selecteddata').getBoundingClientRect().top)+4)+'px;';
      reverse = 'reverse';
    }

    if(get(objeto+'c').children[0].children.length > 1){
      // colSpan = get(objeto+'c').children[0].children[0].querySelectorAll('.fix').length;
      colSpan = get(objeto+'c').children[0].children[0].querySelectorAll('.colagr').length;    // alterado para resolver problema quando a prop. COLUNAS FIXAS é alterada
    }

    var pos = coluna.cellIndex-colSpan;
    var valor, ordem_valor = '';
    if ( get(objeto+'c').children[0].lastElementChild.querySelectorAll('th')[pos])  {     // Somente colunas de valores (não considera colunas agrupadoras)
      // valor = get(objeto+'c').children[0].lastElementChild.querySelectorAll('th')[pos].getAttribute('data-valor'); 
      var th_valor = get(objeto+'c').children[0].lastElementChild.querySelectorAll('th')[pos];       
      valor = th_valor.getAttribute('data-valor');       
      if (th_valor.classList.contains('ASC')) {
        ordem_valor = 'ASC';
      } else if (th_valor.classList.contains('DESC')) {
        ordem_valor = 'DESC';
      }  
    }   
    // Desabilitado - tratamento está sendo feito no backend  
    // if(get(objeto+'c').children[0].lastElementChild.querySelectorAll('th:not(.inv)')[pos]){
    //   valor = get(objeto+'c').children[0].lastElementChild.querySelectorAll('th:not(.inv)')[pos].getAttribute('data-valor');
    // }


  } else {
    largura = 200;


    if(get('gxml_'+objeto)){
      colunas = get('gxml_'+objeto).getAttribute('data-parametros');
    }

    if(get('valores_'+objeto)){
      colunas = get('valores_'+objeto).getAttribute('data-colunareal');
    }
    
    var pos; 
    
    if(get('valor_'+objeto)){
      pos = get('valor_'+objeto).getBoundingClientRect();
    } else {
      pos = get(objeto+'_vl').getBoundingClientRect();
    }

    left = pos.x+(pos.width/2)-(largura/2);
    vert = 'top: '+(pos.y+pos.height+10)+'px';
    
    formato = 'short';
  }

 
  // Pega os parametros que deve ser repassados para o objeto/anotacao que será criado
  let arr = [];
  arr.push(get('par_'+objeto).value);
  arr.push(get('drill_go').value);
  
  let uniq = [...new Set(arr.sort())];
  let letCondicao = uniq.filter(e => e).join('|');
  letCondicao = letCondicao.replace('||', '|');

  let letColuna = ''; 
  if(typeof valor != "undefined" && valor != "undefined" && valor != null) { 
    letColuna = valor; 
  }

  call('jumpdrill', 'prm_objeto='+objeto+'&prm_screen='+tela+'&prm_colunas='+colunas+'&prm_visao='+visao+'&prm_objeto_ant='+track+'&prm_coluna='+letColuna+'&prm_condicao='+encodeURIComponent(letCondicao)+'&prm_cd_goto='+cd_goto).then(function(resposta){
    let temp = document.createElement('div');
    temp.innerHTML = resposta;

    let leftBefore = 0;

    // Se for consulta, refaz a posição da tela de drill conforme as opções de drill e dispositivo móvel 
    if(tipo == 'consulta') { 

      // Ajusta posição vertical da tela 
      let altura = 148;  
      if (temp.querySelector('#id_atalho_anotar')) { altura = 248; }; 
      
      // if(PRINCP.classList.contains('mobile') && !PRINCP.classList.contains('paisagem')){   
      if (mobile_portrait_layout() == true) { 
        altura = 230;
        if (temp.querySelector('#id_atalho_anotar')) { altura = 320; }; 
      }

      // Ajusta posição horizontal da tela, para mobile ou e tiver o icone de anotações  
      let largura2  = 0,
          larg_seta = 6; 
      // if(PRINCP.classList.contains('mobile') && !PRINCP.classList.contains('paisagem')){   
      if (mobile_portrait_layout() == true) { 
        largura2 = 150;
      } else if (temp.querySelector('#id_atalho_anotar')) { 
        largura2 = 355;
      }   
      if (largura2 != 0 ) { 
        largura = largura2; 
        left    = rect.left+(coluna.clientWidth/2) - (largura/2);
      }; 

      if(left+largura > MAIN.clientWidth){
        left       = (MAIN.clientWidth-5) - largura;
      }   
      leftBefore = largura - 5 - ( (coluna.clientWidth/2) - larg_seta) - (MAIN.clientWidth - rect.right); 
      if (leftBefore < ((largura/2)-larg_seta)) {  // Se a posição for menor que o meio da tela, Zera para não alterar na posição atual que é o meio da tela 
        leftBefore = 0 ;
      }  
      if (leftBefore >= largura-35) {  // Se a posição da seta for maior que a largura da tela, então diminui 35px da posição
          leftBefore = largura-35;
      }

      if(left <= 0) { 
        left = 2;
        leftBefore = rect.left+(coluna.clientWidth/2) - larg_seta ;
      }

      if(rect.top+(coluna.clientHeight+8)+altura > PRINCP.clientHeight){
        vert    = 'bottom: '+((PRINCP.getBoundingClientRect().height-get('selecteddata').getBoundingClientRect().top)+4)+'px;';
        reverse = 'reverse';
      } 
    }
    
    if(left < 0){ left = 2; }

    temp.children[0].setAttribute('style', 'left: '+left+'px; '+vert);

    if (leftBefore > 0 ) { 
      temp.children[0].style.setProperty('--left', leftBefore.toString()+'px');       
    } 
    
    //let arr = [];
    //arr.push(get('par_'+objeto).value);
    //arr.push(get('drill_go').value);
    //let uniq = [...new Set(arr.sort())];
    //temp.children[0].title = uniq.filter(e => e).join('|');
    //temp.children[0].title = temp.children[0].title.replace('||', '|');
    temp.children[0].title = letCondicao; 
    MAIN.appendChild(temp.children[0]);
  }).then(function(){

    var jumpdrill = get('jumpdrill');
    jumpdrill.classList.add(reverse);
    jumpdrill.classList.add(formato);
    jumpdrill.classList.add(objeto+'_jump');

    setTimeout(function(){
     
      jumpdrill.querySelector('.fechartab').addEventListener('click', function(){
        this.parentNode.remove();
        if(get('selecteddata')){ get('selecteddata').id = ''; }
      });

      jumpdrill.classList.add('open');
      let icons = jumpdrill.querySelectorAll('.icons');
      for(let i=0;i<icons.length;i++){
        icons[i].addEventListener('click', function(){
          quickPa(this);
        });
      }

      if(get(objeto+'dv2')){
        get(objeto+'dv2').removeEventListener('scroll', noScroll);
        get(objeto+'dv2').addEventListener('scroll', noScroll);
      }

    }, 10);

    //click do +
    let confirmTag = get('confirm-tag');

    confirmTag.addEventListener('click', function(){
        
        let ch = jumpdrill.querySelector('.ch');
        let tipo = ch.getAttribute('data-tipo');

        var col;

        if(typeof valor != 'string'){
          alerta('feed-fixo', TR_VL_NL);
          return;
        }

        if((tipo != 'VALOR' &&  get('quick-coluna').value.length > 1) || tipo == 'VALOR'){

          if(ADMIN == 'A'){
            
            col = valor;

            col = col+'@'+jumpdrill.title;
            col = col.replace('|||', '|').replace('||', '|');
            
          } else {

            if(document.getElementById(USUARIO.replace('.', '_')+'_temp')){ remover(USUARIO.replace('.', '_')+'_temp', 'excluir'); }
              
            ajax('fly', 'ex_obj', 'prm_objeto='+USUARIO.replace('.', '_')+'_temp', false);

            col = valor;

            col = col+'@'+jumpdrill.title;
            col = col.replace('|||', '|').replace('||', '|');

          }

          var obj = '';

          let quick = get('quick-obj');
          let quickInput = quick.children[0].value;
          let quickSelect = quick.children[1].value;

          if(quickInput.trim().length > 1){

            if(ADMIN != 'A'){
              quickInput = quickInput+'_temp';
            }

            var resp;

            call('quick_create', 'prm_nome='+encodeURIComponent(quickInput)+'&prm_tipo='+tipo+'&prm_parametros='+col+'&prm_visao='+jumpdrill.getAttribute('data-visao')+'&prm_coluna='+quickSelect+'&prm_grupo='+grupo+'&prm_obj_ant='+objeto+'&prm_filtro='+encodeURIComponent(jumpdrill.getAttribute('data-filtro'))+'&prm_screen='+tela+'&prm_ordem_vlr='+ordem_valor).then(function(resposta){
            // call('quick_create', 'prm_nome='+encodeURIComponent(quickInput)+'&prm_tipo='+tipo+'&prm_parametros='+col+'&prm_visao='+jumpdrill.getAttribute('data-visao')+'&prm_coluna='+quickSelect+'&prm_grupo='+grupo+'&prm_obj_ant='+objeto+'&prm_filtro='+encodeURIComponent(jumpdrill.getAttribute('data-filtro')+'&prm_screen='+tela)).then(function(resposta){              
              obj = resposta;
              if(obj.indexOf('duplicado') == -1){
                if(ADMIN == 'A'){
                  ajax('fly', 'inserir_objeto', 'prm_objeto='+obj+'&prm_screen='+tela, false);
                }
                appendar('prm_objeto='+obj+'&PRM_ZINDEX=2&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_screen='+tela, false,'');/*'false'*/
              } else {
                alerta('feed-fixo', 'Objeto duplicado!');
              }
            }).then(function(){
              if(obj.indexOf('duplicado') == -1){
                if(get('dados_'+obj)){
                  renderChart(obj);
                } else {
                  ajustar(obj);
                }

                centerDrill(obj); 
                get('selecteddata').id = ''; 
                loading();
              }
            });
          } else {
            alerta('feed-fixo', TR_NM_LE);
          }
        } else { 
          alerta('feed-fixo', TR_CO_SL); 
        } 

    });

    let confirmTagAnotAdd = get('confirm-tag-anot-add'),
        confirmTagAnotDel = get('confirm-tag-anot-del');  

    confirmTagAnotAdd.addEventListener('click', function(){
      let quick       = get('quick-anotacao'),
          letUsuario  = encodeURIComponent(quick.querySelector('#nm_usuario').value),
          letTexto    = encodeURIComponent(quick.querySelector('#quick-anotacao-texto').value),
          letUsuPerm  = encodeURIComponent(quick.querySelector('#fake-usuario-permissao').title),          
          letColuna   = valor, 
          letCondicao = jumpdrill.title.replace('|||', '|').replace('||', '|'); 

      if (letTexto.replace('%0A','').length == 0) { 
        alerta('feed-fixo', 'Texto da anota&ccedil;&atilde;o &eacute; obrigat&oacute;rio, para limpar o texto, exclua a anota&ccedil;&atilde;o'); 
        return;
      } 

      call('anotacao_grava', 'prm_objeto='+objeto+'&prm_screen='+tela+'&prm_usuario='+letUsuario+'&prm_coluna='+letColuna+'&prm_condicao='+letCondicao+'&prm_usuario_permissao='+letUsuPerm+'&prm_anotacao='+letTexto).then(function(resposta){
        alerta('feed-fixo', resposta.split('|')[1]); 
        if (resposta.split('|')[0] == 'OK') { 
          if(get('selecteddata')){ 
            get('selecteddata').classList.add('anotacao'); 

            if (!(get('selecteddata').querySelector('svg'))) { 
              // let txtsvg = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="15" height="20" viewBox="0 0 28 28" preserveAspectRatio="xMidYMid meet"> <g><path d="m1.45645,13.457466l0,-11.000003l13.000004,11.000003l-13.000004,0z" fill="#bf0000" id="svg_1" stroke="#bf0000" stroke-width="5" transform="rotate(90 7.95645 7.95746)"/> </g></svg>'; 
              // let txtsvg = '<span><svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="0 0 12 12" style="enable-background:new 0 0 12 10; fill:#BF0000;" xml:space="preserve"> <polygon points="10,1.9 10,5 12.1,7 12,-0.1 4.6,-0.1 6.7,1.9 "/> </svg></span>';
              let txtsvg = '<span><svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="4 0 8 8" style="enable-background:new 0 0 10 10; fill:#BF0000;" xml:space="preserve"> <polygon points="10,1.9 10,5 12.1,7 12,-0.1 4.6,-0.1 6.7,1.9 "/> </svg></span>';
              get('selecteddata').innerHTML = txtsvg + get('selecteddata').innerHTML; 
            }
          }        
        }  
      }); 
    });  

    confirmTagAnotDel.addEventListener('click', function(){
      let quick       = get('quick-anotacao'),
          letUsuario  = encodeURIComponent(quick.children[0].value),
          letColuna   = valor, 
          letCondicao = jumpdrill.title.replace('|||', '|').replace('||', '|'); 

      call('anotacao_exclui', 'prm_objeto='+objeto+'&prm_screen='+tela+'&prm_usuario='+letUsuario+'&prm_coluna='+letColuna+'&prm_condicao='+letCondicao).then(function(resposta){
        alerta('feed-fixo', resposta.split('|')[1]); 
        if (resposta.split('|')[0] == 'OK') { 

          quick.querySelector('#quick-anotacao-texto').value = ''; 
          quick.querySelector('#fake-usuario-permissao').title = ''; 
          quick.querySelector('#fake-usuario-permissao').children[0].innerHTML = 'TODOS'; 

          if(get('selecteddata')){ 
            get('selecteddata').title = resposta.split('|')[2]; 
            if (resposta.split('|')[2].length == 0)  {           // Se não sobrou anotação remove marcação da anotação da célula de dados 
              get('selecteddata').classList.remove('anotacao'); 
              if (get('selecteddata').querySelector('svg')) {             
                get('selecteddata').querySelector('svg').remove(); 
              }  
            }  
          }        
        }  
      }); 
    });  

  });

}

function noScroll(){
  if(get('jumpdrill'))      { get('jumpdrill').remove(); }
  if(get('jumpmed'))        { get('jumpmed').remove(); }
  if(get('anotacao_show'))  { get('anotacao_show').remove(); }
}


function cleardrill() {
  var drills = document.querySelectorAll('.drill');
  for(let i=0;i<drills.length;i++){ drills[i].remove(); }
}


function maxCall(){
  var all = document.getElementById('space').children;
  var saida = 0;
  for(let i=0;i<all.length;i++){
    if(all[i].clientWidth > saida){ saida = all[i].clientWidth+25; }
  }
  if(saida == 0){
    alerta('feed-fixo', TR_OB_NO);
  } else {
    return(saida+'px');
  }
}

function ctnrs(){
  var allEls=document.getElementsByTagName('*');
  var l=allEls.length,i;
  var saida=0;
  for(let i=0;i<l;i++){
    if(allEls[i]){
      if(allEls[i].id.substring(0,4) == 'ctnr'){ saida=allEls[i].id; }
    }
  }
  return(saida);
}

function quickPa(/*visao, grupo, tipo, coluna, rotulo,*/ self){

  if(document.querySelector('.ch')){
    document.querySelector('.ch').classList.remove('ch');
  }
  self.classList.add('ch');
  var tipo         = self.getAttribute('data-tipo'),
      quickobj     = get('quick-obj'),
      quickanot    = get('quick-anotacao'),
      quickatalhos = get('quick-atalhos');

  if (mobile_portrait_layout() == true) { 
    quickatalhos.style.setProperty('display', 'none'); 
  }  

  if(tipo == 'ANOTACAO'){ 
    quickobj.classList.remove('open');
    quickanot.classList.add('open');
  } else {   
    if(tipo != 'VALOR'){ 
      document.getElementById('quick-coluna').disabled = false; 
    } else {
      document.getElementById('quick-coluna').disabled = 'true';
    }
    quickanot.classList.remove('open');
    quickobj.classList.add('open');    
  }  
    
  
}

function quickerPa(user, obj, visao, grupo, tipo, coluna){
  loading();
  if(document.getElementById(user+'_temp')){ remover(user+'_temp', 'excluir'); }
  ajax('fly', 'ex_obj', 'prm_objeto='+user+'_temp', false);
  if(document.getElementById('drill_go').value.replace('|', '').length > 0){
    var drillgo = document.getElementById('drill_go').value;
  } else {
    var drillgo = '';
  }
  
  setTimeout(function(){ ajax('fly', 'quick_create', 'prm_nome='+user+'_temp&prm_tipo='+tipo+'&prm_parametros='+document.getElementById('jumpdrill').className+'@'+drillgo+'&prm_visao='+visao+'&prm_coluna='+coluna+'&prm_grupo='+grupo+'&prm_obj_ant='+obj+'&prm_filtro=&prm_screen='+tela, false); noerror('', TR_CR, 'feed-fixo');
    appendar('prm_objeto='+user+'_temp&PRM_ZINDEX=&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_screen='+tela, 'false');
    carrega('ajobjeto?prm_objeto='+user+'_temp');
    centerDrill(user+'_temp');
  }, 1000);
}

// Abre um novo objeto como DRILL 
function drillChange(drillValue, fakeoption, track, parobjn){
  var parametros;
  var go = get('drill_go').value; // drill_go contém os parametros de devem ser repassados para a Drill, os parametros são montados na check_tag  
  var paramArr = [];
  var dataParam = fakeoption.getAttribute('data-parametros');
  dataParam = dataParam.substring(0, dataParam.length-1);
  paramArr.push(dataParam);
  paramArr.push(fakeoption.title);
  if(go.slice(-1).indexOf('|') == 0){ go = go.substring(0, go.length-1); }
  go = encodeURIComponent(go);
  //até aqui n muda nada

  var arr = drillValue.split('###');

  var y = document.getElementById('drill_x').value;
  var x = document.getElementById('drill_y').value;
  if(get('selecteddata')){ get('selecteddata').id = ''; }

  //tipo
  var objeto   = '',
      objeton  = '',
      cd_goto  = '';

  if((drillValue.indexOf('SCR') != -1) || (drillValue.indexOf('SRC') != -1)){
   
    if (arr[0].indexOf('-')!= -1){
      shscr(arr[0].split('-')[0], tela, go);
    }else{
      shscr(arr[0], tela, go);
    }
    
  } else {
    if (drillValue.split('-').length > 1) {   // Pega a sequencia do objeto no cadastro de drills 
      objeto   = drillValue.split('-')[0];
      cd_goto = drillValue.split('-')[1];
    } else {
      objeto  = drillValue;
    } 

    remover(objeto+'trl'+cd_goto, false);    // adicionando a sequencia da drill 
    loading('x');

    var par = '';
    par = paramArr.filter(e => e).join('|'); 

    if(go.trim().length > 0){
      let arrGopar = [];
      arrGopar.push(go);
      arrGopar.push(encodeURIComponent(par));
      let uniq = [...new Set(arrGopar.sort())]; 

      // // Foi colocado este if para solucionar o problema no card: 916s
      // if (uniq[0].endsWith("%7C") === false) {
      //   uniq[0] += "|";
      // }
    
      parametros = uniq.filter(e => e).join('##'); 

    } else {
      parametros = encodeURIComponent(par.replace('||', '|'));
    }
    ajax('append', 'show_objeto', 'prm_drill=Y&prm_objeto='+objeto+'&prm_posx='+cursorx+'px&prm_zindex='+zindex_abs+'&prm_posy='+cursory+'px&prm_parametros='+parametros+'&prm_screen='+tela+'&prm_cd_goto='+cd_goto+'&prm_track='+track+'|'+objeto+'&prm_objeton='+parobjn+'  >  ', true, 'main', '', objeto+'trl'+cd_goto, 'obj');

    //mata o objeto script
    setTimeout(function(){ remover('script-load'); }, 10000);
  }
}

function centerDrill(obj){

  // if(document.getElementById('donut').children[1].className == 'circle select'){    -- Desabilitado para sempre centralizar - Icone CENTRO foi retirado do BI - 05/07/2022 
    var repete = '';
    var objeto;
    repete = setInterval(function(){

      if(document.getElementById(obj) || document.getElementById(obj+'trl')){ 
        if(document.getElementById(obj+'trl')){ objeto = document.getElementById(obj+'trl'); } else { objeto = document.getElementById(obj); }
        var larguratela = window.innerWidth/2;
        var alturatela  = window.innerHeight/2;
        var larguraobj  = objeto.clientWidth/2;
        var alturaobj   = objeto.clientHeight/2;
        if(parseInt(alturaobj) > parseInt(alturatela)){ alturaobj = parseInt(alturatela)/2; } 
        if(typeof window.scrollX !== 'undefined'){
          var x = (window.scrollX+(larguratela)-larguraobj)+'px';
          var y = (window.scrollY+(alturatela)-alturaobj)+'px';
        } else {
          var x = (larguratela)-larguraobj+'px';
          var y = (alturatela)-alturaobj+'px';
        }
        objeto.style.setProperty('left', x);
        if(parseInt(y) < 10){
          y = '40px';
        }
        objeto.style.setProperty('top', y);
        clearInterval(repete);
      }
    }, 100);
  // }  
}

function fitScreen(obj){
  if(document.getElementById(obj+'fixed')){
    document.getElementById(obj+'fixed').innerHTML = '';
    document.getElementById(obj+'fixed').style.setProperty('width', '0');
    document.getElementById(obj+'fixed').style.setProperty('max-height', 'auto');
  }
  toggleClass(obj, 'front', 'front expand', 'r');
  setTimeout(function(){ fixCol(obj); smartScroll(obj); },500);
}

function lmenuLink(ele){

  closeSideBar('prefdrop');
  clicked = ele;
  clearInterval(refresh_timer);
  
  if(ele.getAttribute('data-menu')!="no-menu"){
    curtain('enabled');
  }
  
  if(ele.getAttribute('data-carrega').length > 0){

    titulo(ele, 'c'); 
     
    /*carrega(ele.getAttribute('data-carrega'));*/ 
    // Carrega tela do conteudo/lista 

    loader("content"); 
    var pkg = ""; 
    if(ele.getAttribute("data-package")){ 
      pkg = ele.getAttribute("data-package"); 
    } 

    if(ele.getAttribute('data-carrega') != "_"){
      call(ele.getAttribute('data-carrega'), ele.getAttribute('data-url'), pkg).then(function(resposta){ 
        document.getElementById("content").innerHTML = resposta;   
      }).then(function(){
        if(ele.getAttribute('data-ace')){
            if(ele.getAttribute('data-ace').length > 1){ 
                var obj = ele.getAttribute('data-ace');
                ace_editor = ace.edit(obj);
                ace_editor.session.setMode("ace/mode/sql");
            }
        }
        telasup_ant = [];
        document.getElementById("back_sup").style.display='none';
      });
    } else {
      document.getElementById("content").innerHTML = ''; 
    }
  }
  
  if(ele.getAttribute('data-attrib').length > 1){ 
    document.getElementById('attriblist').classList.toggle('open'); 
    //loader('attriblist'); 
    ajax('list', ele.getAttribute('data-attrib'), '', false, 'attriblist'); 
  }
  
  call_save('');

  if(ele.getAttribute('data-menu')!="no-menu"){

    if(ele.getAttribute('data-menu').length > 1){ 
        document.getElementById("painel").innerHTML = ""; 
        call("menu", "prm_menu="+ele.getAttribute('data-menu')+"&prm_default=", "", "GET").then(function(resposta){ 
        document.getElementById("painel").innerHTML = resposta; 
        var prm_usu_origem = document.getElementById('prm_usuario_origem');
        if (prm_usu_origem) {
          prm_usu_origem.style.setProperty('display', 'none');
        }  
      }); 
    } else { 
        carregaPainel('');
    }
  }
   
  //refresh de tela
  refreshSupBtn('O');  // Oculta botão 
  if(clicked.getAttribute('data-refresh').length > 1){ 

    refreshSupBtn('V');  // botão Visivel 
    refresh_param[0] = clicked.getAttribute('data-refresh'); 
    refresh_param[1] = '';
    refresh_param[2] = '';
    if (clicked.getAttribute('data-refresh-pkg')) { 
      refresh_param[2] = clicked.getAttribute('data-refresh-pkg'); 
    }

    if ((clicked.getAttribute('data-refresh-ativo')) && (clicked.getAttribute('data-refresh-ativo') == 'S')) {  
      refreshSupStart(); 
    }

    // refresh_timer = setInterval( intervalFunc, 5000, true); 
  }
 
  if(document.getElementById('prefdrop')){
    document.getElementById('prefdrop').classList.remove('hover');
  }
  document.getElementById('popupmenu').innerHTML = '';
}

// function intervalFunc(){  
//   let proc = clicked.getAttribute('data-refresh'),
//       pkg  = '';
//   if (clicked.getAttribute('data-refresh-pkg')) { 
//     pkg = clicked.getAttribute('data-refresh-pkg'); 
//   }
//   ajax('list', proc, '', true, 'content','','',pkg);  
// }

function mostrak(x) {
  
  document.getElementById('sandbox').contentWindow.document.getElementById('parsecheck').setAttribute('value', x);

  if(document.getElementById('view_list').value == 'NOVAVIEW'){
    document.getElementById('sandbox').contentWindow.document.getElementById('nome').setAttribute('value', document.getElementById('new_query').value);
  }

  if(document.getElementById('view_list').value == 'NOVAVIEW' && document.getElementById('new_query').value.length < 1){
    alerta('', TR_TC);
  } else {
    loading('x');
    setTimeout(function(){ 
      //var conteudo = document.getElementById('texto').value;
      var conteudo = ace_editor.getValue();
      if(conteudo.trim().length == 0){
        alerta('', TR_QN);
        loading('x');
      } else {
        var total = Math.ceil(conteudo.length/30000);
        var url = '';
        for(let i=0;i<total;i++){
          var picado = document.createElement('input');
          picado.setAttribute('type', 'hidden');
          picado.setAttribute('name', 'PICADO');
          picado.setAttribute('value', conteudo.substr(([i]*30000),30000));
          document.getElementById('sandbox').contentWindow.document.forms[0].appendChild(picado);
        }
        document.getElementById('sandbox').contentWindow.document.zebra.submit();
        setTimeout(function(){
          var resposta = document.getElementById('sandbox').contentWindow.document.body.innerHTML; 
          if(resposta.indexOf('#alert') == -1){ 
            if(document.getElementById('view_list').value == 'NOVAVIEW'){ 
              alerta('msg', TR_CR); 
              //carrega('edit_dado'); 
              document.getElementById('new_query').value = '';
            } else { 
              alerta('msg', TR_AL); 
            } 
          } else {
            alerta('msg', resposta);
            /*if(resposta.indexOf('invalid table name') != -1){
              alerta('msg', 'Nome de tabela inválido ou não declarado!');
            }
            if(resposta.indexOf('FROM keyword not found') != -1){
              alerta('msg', 'FROM não encontrado na query!');
            }
            if(resposta.indexOf('missing SELECT keyword') != -1){
              alerta('msg', 'SELECT não encontrado na query!');
            }
            if(resposta.indexOf('success with compilation error') != -1){
              alerta('msg', 'Compilado, mas a view contém erro(s)!');
            }
            if(resposta.indexOf('invalid identifier') != -1){
              alerta('msg', 'Identificador '+resposta.split('ORA-00904:')[1].replace(': invalid identifier', '')+' inválido!'); 
            } else {
              if(resposta.indexOf('table or view does not exist') != -1){
                alerta('msg', 'Tabela ou view não existem!');
              } else {
                if(resposta.indexOf('OBJETO J') != -1){
                  alerta('msg', 'Nome de objeto já esta sendo usado!');  
                } else {
                  alerta('msg', 'Erro ao alterar view!');
                }
              }
            }*/
          } 
          loading('x'); 
          sandbox();
          edit_view(); 
        }, 1500);
      }
      
    }, 100);
  }
  
}

function sandbox(){
  var nome = document.getElementById('view_list').title;
  document.getElementById('sandbox').contentWindow.document.body.innerHTML = ('<form id="zebra" name="zebra" method="post" action="' + OWNER_BI + '.fcl.passagem_test"><input id="nome" type="hidden" name="nome" value="'+nome+'" /><input id="parsecheck" name="parseonly" type="hidden" value="N"/></form>');
}

function reload(x){
  if(x){
    document.getElementById('fechar_sup').setAttribute('data-reloado', x);
  } else {
    document.getElementById('fechar_sup').setAttribute('data-reloads', 'true');
  }
}

function execute_sql(Y,Z){
  /*document.getElementById('result').innerHTML = '';
  document.getElementById('result2').innerHTML = '';*/
  document.getElementById('sqloutput').children[0].innerHTML = '';
  document.getElementById('sqloutput').children[1].innerHTML = '';
  document.getElementById('sqloutput').children[2].innerHTML = '';

  loader('queryresult');

  setTimeout(function(){
    var conteudo = ace_editor.getValue();
    if(conteudo.trim().length > 1){
      var valor;
      if(ace_editor.getSelectedText().length > 1){
        valor = ace_editor.getSelectedText();
        //document.getElementById('selecionado').value = '';
      } else {
        valor = conteudo;
      }
      if(Y == 'S'){
        if(Z == '11'){
          ajax('list', 'exec_query', 'p_query='+encodeURIComponent(valor)+'&p_parse='+Y, true, 'queryresult');
        } else {
          ajax('list', 'exec_query', 'p_query='+encodeURIComponent(valor)+'&p_parse='+Y+'&p_linhas='+Z, true, 'queryresult');
        }
      } else {
        if(Z == '11'){
          ajax('double', 'exec_query', 'p_query='+encodeURIComponent(valor)+'&p_parse='+Y, true, 'queryresult');
        } else {
          ajax('double', 'exec_query', 'p_query='+encodeURIComponent(valor)+'&p_parse='+Y+'&p_linhas='+Z, true, 'queryresult');
        }
      }
    }
  }, 20);
}


function arrow(x, y, z){
  //var limit = parseInt((document.getElementById('content').clientWidth-document.getElementById('ajax').clientWidth)/400);
  var limit = 1;
  if(z != 'click'){
    var valor = x.value.trim();
    var defaultn = x.getAttribute('data-default').trim();
    if(valor != defaultn){
      if(document.getElementById('user-language').value == document.getElementById('sys-language').value){
        document.getElementById(y+'_rotulo').setAttribute('title', valor.toUpperCase());
      }
      ajax('fly','save_column', 'prm_visao='+document.getElementById('telasup').getAttribute('data-visao')+'&prm_name='+y+'&prm_campo='+z+'&prm_valor='+encodeURIComponent(valor), false);
      noerror('', TR_AL, 'msg');
      x.setAttribute('data-default', valor);
      if(z == 'NM_ROTULO'){
        document.getElementById(y+'id').children[1].innerHTML = valor.toUpperCase();
      }
    }
  } else {
    ajax('list','load_column', 'prm_visao='+document.getElementById('telasup').getAttribute('data-visao')+'&prm_name='+y+'&prm_screen='+tela, false, 'content'); 
  }
}

function userEvent(x, y, z, titulo){
  switch (z){
    case 'blur':
      if(x.getAttribute('data-default') != x.value){
        ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+encodeURIComponent(x.value.replace(/<[/a-zA-Z0-9 ="-]+>/g, ''))+'&prm_tipo=nome');
        noerror('', TR_AL, 'msg');
        x.setAttribute('data-default', x.value);
      }
      break;
    case 'email':
      if(x.getAttribute('data-default') != x.value){
        ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.value.replace(/<[/a-zA-Z0-9 ="-]+>/g, '')+'&prm_tipo=email');
        noerror('', TR_AL, 'msg');
        x.setAttribute('data-default', x.value);
      }
      break;
    case 'grupo':
        ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=grupo');
        noerror('', TR_AL, 'msg');
      break;
    case 'status':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=status');
      if (error == 'true') {  // Se der erro desfaz a alteração no checkbox 
        if(x.classList.contains("checked")){
          x.classList.remove("checked");
          x.title = x.getAttribute('data-negative');		
        } else {
          x.classList.add("checked");
          x.title = x.getAttribute('data-positive');	
        }
      } else {
        ajax('list', 'list_users', '', false, 'content');
      }  
      noerror('', TR_AL, 'msg');      
      break;
    case 'id_expira_senha':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=id_expira_senha');
      noerror('', TR_AL, 'msg');
      break;
    case 'expirar_senha':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=expirar_senha');
      noerror('', TR_AL, 'msg');
      if (document.getElementById('usuarios_dt_validacao_senha')) { 
        document.getElementById('usuarios_dt_validacao_senha').value = ""; 
      }  
      break;
    case 'cd_tela_inicial':
        ajax('return', 'alter_user', 'prm_nome='+y+'&prm_valor='+x+'&prm_tipo=cd_tela_inicial');
        if (respostaAjax.split('|')[0] == 'ERRO') { 
          alerta('msg', respostaAjax.split('|')[1]);
        } else {
          if (document.getElementById('cd_tela_inicial_usuario')) { 
            document.getElementById('cd_tela_inicial_usuario').title                 = respostaAjax.split('|')[2];
            document.getElementById('cd_tela_inicial_usuario').children[0].innerHTML = respostaAjax.split('|')[3]; 
          }  
          alerta('msg', respostaAjax.split('|')[1]);
        }   
        break;
    case 'dba':
      if(x.className == 'dot'){
        ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor=unlock&prm_tipo=dba');
        x.className = 'dot active';
      } else {
        ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor=lock&prm_tipo=dba');
        x.className = 'dot';
      }
      noerror('', TR_AL, 'msg');
      break;
    case 'upload':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=upload');
      noerror('', TR_AL, 'msg');
      break;
    case 'excel':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=excel_out');
      noerror('', TR_AL, 'msg');
      break;
    case 'app':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.title+'&prm_tipo=app');
      noerror('', TR_AL, 'msg');
      break;
    case 'permissao':
      get('attriblist').querySelector('.closer').click();
      if(x.value != 'n/a'){
        if(x.value == 'custom'){
          call('menu', 'prm_menu=add_custom&prm_default='+y).then(function(resposta){ document.getElementById("painel").innerHTML = resposta; });
          call('listaCustomizado', 'prm_usuario='+y).then(function(resposta){ document.getElementById("content").innerHTML = resposta; });
        } else if(x.value == 'permissao'){
            call('menu', 'prm_menu=user_permissao_list&prm_default='+y).then(function(resposta){ document.getElementById("painel").innerHTML = resposta; });
            call('user_permissao_list', 'prm_usuario='+y).then(function(resposta){ document.getElementById("content").innerHTML = resposta; });
        } else {
          document.getElementById('titulo').innerHTML = x.options[x.selectedIndex].innerHTML;
          document.getElementById("painel").innerHTML = "";
          call('menu_'+x.value+'_access', 'prm_usuario='+y).then(function(resposta){ document.getElementById("painel").innerHTML = resposta; });
          loader('content');
          call(x.value+"_access", "prm_usuario="+y+"&prm_conteudo=FULL").then(function(resposta){ document.getElementById("content").innerHTML = resposta; }); 
        }
      }
      break;
    case 'permissao-fake':
      document.getElementById("ajax").innerHTML = "";
      call("screen_access", "prm_usuario="+y+"&prm_conteudo=N&prm_grupo="+x.title).then(function(resposta){ 
        document.getElementById("ajax").innerHTML = resposta; 
      }); 
      break;
    case 'remove':
      if(confirm(TR_US_EX)){
        var row = document.getElementById(y+"linha"); 
        row.classList.add('removing'); 
        call('delete_user', 'usu_nome_d='+y).then(function(resposta){
          if(resposta.indexOf("ERRO") == -1){
            if(resposta.indexOf("#alert") == -1){
                row.remove(); 
                alerta('feed-fixo', TR_EX);
            } else {
                row.classList.remove('removing'); 
                alerta('feed-fixo', TR_ER);
            }
          } else {
            row.classList.remove('removing'); 
            alerta('feed-fixo', TR_ER_EX);
          }
        });
       }
      break;
    case 'show':
      carregaPainel('add_show&prm_default='+y);
      carrega('show_only?prm_usuario='+y);
      document.getElementById('titulo').innerHTML = titulo;
      break;
    case 'tp_ordem_coluna':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.value+'&prm_tipo=tp_ordem_coluna');
      noerror('', TR_AL, 'msg');
      break;
    case 'id_aviso_mostrar':
      ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.value+'&prm_tipo=id_aviso_mostrar');
      noerror('', TR_AL, 'msg');
      break;
    default:
      if(x.getAttribute('data-default') != x.value){
        ajax('fly', 'alter_user', 'prm_nome='+y+'&prm_valor='+x.value+'&prm_tipo='+z);
        if (error == 'false') {
          x.setAttribute('data-default',x.value);
        } else {
          x.value = x.getAttribute('data-default');
        }
        noerror('', TR_AL, 'msg');      
      }
      break;
  }
}

function newLine(x){
  var linha = document.getElementById(x);
  if(linha.nextElementSibling.className != 'new'){
    var tr = document.createElement('tr');
    tr.className = 'new';
    for(let i=0;i<linha.children.length;i++){
      var td = document.createElement('td');
      tr.appendChild(td);
    }
    linha.parentNode.insertBefore(tr, linha.nextElementSibling);
  }
}

function objAction(x,y,z, tipo){
  
  if(tipo == 'inserir'){
    loading();
    if(document.getElementById(x)){
      alerta('msg', TR_OB_DP);
    } else {
      ajax('fly', 'inserir_objeto', 'prm_objeto='+x+'&prm_screen='+tela+'&prm_screen_ant='+z);
      if(document.getElementById('lisobj').value != 'CALL_LIST'){ 
        appendar('prm_objeto='+x+'&PRM_ZINDEX=&prm_posx='+150+'px&prm_posy='+150+'px&prm_screen='+tela);
      } else {
        shscr(tela);
      }
      curtain();
      if(document.getElementById(x+'dv2')){
        ajustar(x);
      } else {
        carrega('ajobjeto?prm_objeto='+x);
      }
    }
  } else {
    if(confirm(TR_OB_EX)){
      ajax('fly', 'dl_object', 'prm_object='+x, false);
      noerror(y, TR_EX, 'msg');
      if(document.getElementById(x)){
        document.getElementById(x).style.display='none';
      }
    }
  }
}

function checkFix(tipo, self, a, b, c, d, e){
  if(tipo == 'check'){
    if(self.checked == true){ var fixa = 'S'; } else { var fixa = 'N'; }
    ajax('fly', 'linguagem_padrao', 'prm_update=S&prm_tabela='+a+'&prm_coluna='+b+'&prm_linguagem='+c+'&prm_default='+d+'&prm_fixa='+fixa, false);
  } else {
    if(self.previousElementSibling.value.trim().length > 0){
      ajax('fly', 'update_language', 'prm_valor='+self.previousElementSibling.value+'&prm_tabela='+a+'&prm_coluna='+b+'&prm_linguagem='+c+'&prm_default='+d+'&prm_tipo='+e, false); noerror('', TR_AL, 'msg');
      noerror('', TR_AL, 'msg');
    } else {
      alerta('msg', TR_BL);
    }
  }
}

function auto(obj, evento, visao){
//x = this, y = event, z = visao, 36 = $, 91 = [

  //function refeita
  var digitado = obj.selectionEnd-1;
  var anterior = obj.selectionEnd-2;
  var letras = obj.value.split("");
  var auto = document.getElementById("auto-complete-formula");
  var chaves = 0;

//adicionado

    if(evento.which == "8" && digitado < obj.getAttribute("data-lastkey")){
      auto.classList.add("off");
      obj.setAttribute("data-search", "N");
    }
    
    if(letras[digitado] == "[" && (letras[anterior] == "$")){
      auto.classList.remove("off");
      obj.setAttribute("data-search", "S");
      obj.setAttribute("data-lastkey", digitado+1);
      //redundante ajax('list', 'auto_complete', 'prm_visao='+visao+'&prm_letters=', true, 'auto-complete-formula');
    }
    
    if(letras[digitado] == "]"){
      auto.classList.add("off");
      obj.setAttribute("data-search", "N");
    }
    
    if(obj.getAttribute("data-search") == "S"){
      ajax('list', 'auto_complete', 'prm_visao='+visao+'&prm_letters='+(letras.slice(obj.getAttribute("data-lastkey")).join("")), true, 'auto-complete-formula');
    }
  
}

function autoClick(dis){
  dis.parentNode.classList.add('off'); 
  var alvo = document.getElementById('formula-coluna'); 
  var ih = dis.innerHTML; 
  //alvo.setAttribute('data-default', alvo.value.split('').slice(0, alvo.getAttribute('data-lastkey')).join('')+ih+']');
  alvo.value = alvo.value.split('').slice(0, alvo.getAttribute('data-lastkey')).join('')+ih+']'; 
  alvo.setAttribute('data-search', 'N'); 
  alvo.setAttribute('data-lastkey', ''); 
  //alvo.focus(); 
  
  var microVisao = document.getElementById('micro-visao').title;
  var coluna     = document.getElementById('ajax-lista').querySelector('.selected').title;
  var valor      = encodeURIComponent(alvo.value); 

  //alvo.setAttribute('data-default', valor);
  
  call('save_column', 'prm_visao='+microVisao+'&prm_name='+coluna+'&prm_campo=FORMULA&prm_valor='+valor+'&prm_screen='+tela).then(function(resposta){ 

    alerta('feed-fixo', resposta.split('|')[1]); 
    if (resposta.split('|')[1] != 'ERRO') {
      alvo.setAttribute('data-default', alvo.value);  
    }
    if (resposta.split('|')[2].length > 0) {  // Se tem erro na fórmula, altera a cor da fonte para vermelho
      alvo.style.setProperty('color', 'var(--vermelho-secundario)');
      document.getElementById('erro_coluna_formula').innerHTML = resposta.split('|')[2]+'.';
    } else {  
      alvo.style.setProperty('color', 'initial');
      document.getElementById('erro_coluna_formula').innerHTML = '';
    }  

    //if(resposta.indexOf('#alert') == -1){
    //  alerta('feed-fixo', resposta); 
    //  alvo.setAttribute('data-default', alvo.value);
    //} else {
    //  alerta('feed-fixo', TR_ER);
    // }
    alvo.focus();
  });
}

function swapColumn(x){

  var y = x.parentNode.getAttribute('data-tipo');

  if (x.lastElementChild.classList.contains('edit-prop-col')) { 
    eEdit = x.lastElementChild; 
    eEdit.removeEventListener('click', editColumn);
    eEdit.addEventListener('click', editColumn);
    eDelete = eEdit.previousElementSibling;
  } else { 
    eDelete = x.lastElementChild;
  }
  eDelete.removeEventListener('click', removeColumn);
  eDelete.addEventListener('click', removeColumn);

  if(x.id == 'selected'+y){
      if(x.classList.contains('template')){
        if((document.getElementById("prm_objeto")) != null){ 
          fakeOption(x.title, document.getElementById('prm_objeto').value, 'template', document.getElementById('prm_visao').value);
        }
      }
      x.id = '';
  } else {
    if(document.getElementById('selected'+y)){
      var selected = document.getElementById('selected'+y).outerHTML;
      var clicked = x.outerHTML;
      document.getElementById('selected'+y).outerHTML = clicked;
      x.outerHTML = selected;
      document.getElementById('selected'+y).id = '';
      save('consulta');
    } else {
      x.id = 'selected'+y;
    }
  }
}

function removeColumn(e, ele){
  e.stopPropagation();
  if(ele){ var linha = ele.parentNode; } else { var linha = this.parentNode; }
  //if(((linha.parentNode.id == 'colunac' || linha.parentNode.id == 'coluna') && linha.parentNode.children.length > 2) || linha.parentNode.id == 'colunas'){

    var nextsquare = linha.nextElementSibling;
    nextsquare.parentNode.removeChild(nextsquare);
    linha.parentNode.removeChild(linha);
    save('consulta');
  //} else {
  //  alerta('feed-fixo', 'Impossível excluir');
  //}
  
}

function editColumn(e){
  e.stopPropagation();
  var microVisao = '',
      codObjeto  = '',
      nomeColuna = ''; 

  if (document.getElementById('prm_visao'))  { microVisao = document.getElementById('prm_visao').value; }
  if (document.getElementById('prm_objeto')) { codObjeto  = document.getElementById('prm_objeto').value;}
  nomeColuna = this.parentNode.title; 

  if (microVisao != '' && codObjeto !== '' && nomeColuna !== '' ) { 
    curtain('enabled');
    carregaPainel('list_crocks', codObjeto, nomeColuna  );
    telaSup('visao', microVisao);
  }  		
}



function swapSquare(x){
  var y = x.parentNode.getAttribute('data-tipo');
  if(document.getElementById('selected'+y)){
    var selected = document.getElementById('selected'+y);
    var nextsquare = selected.nextElementSibling;
    if(x.previousElementSibling.id != 'selected'+y && x.nextElementSibling.id != 'selected'+y){
      nextsquare.parentNode.removeChild(nextsquare);
      selected.id = '';
      x.outerHTML = '<li onclick="swapSquare(this);" class="square"></li>'+selected.outerHTML+'<li onclick="swapSquare(this);" class="square"></li>';
      selected.parentNode.removeChild(selected);
    }
    save('consulta');
  }
}

function saveTpt(obj, visao, nome){
  var valores = obj.querySelectorAll('.linha'); 
  var valor = ''; 
  for(let i=0;i<valores.length;i++){ 
    if(valores[i].title.length > 0){ 
      if(i==0){ 
        valor = valores[i].title; 
      } else { 
        valor = valor+'|'+valores[i].title; 
      }
    }
  } 
  if(valor != obj.getAttribute('data-default')){ 
    ajax('fly', 'save_column', 'prm_visao='+visao+'&prm_name='+nome+'&prm_campo=FORMULA&prm_valor='+valor); 
    obj.setAttribute('data-default', valor);
  }
}

function fastInclude(obj, tipo){
  if(document.getElementById(obj)){
    alerta('feed-fixo', TR_OB_DP);
  } else {

    if(document.querySelector('.movingarticle')){
      var selecionado = document.querySelector('.movingarticle');
      var selecionadoid = selecionado.id;
    }
    
    if(selecionado){
      if(tipo != 'CALL_LIST' && tipo != 'FLOAT_PAR' && tipo != 'FLOAT_FILTER' && tipo != 'BROWSER'){
        ajax('fly', 'inserir_objeto', 'prm_objeto='+obj+'&prm_screen='+selecionadoid);
      } else {
        ajax('fly', 'inserir_objeto', 'prm_objeto='+obj+'&prm_screen='+tela);
        
      }
    }	else {
      call('inserir_objeto', 'prm_objeto='+obj+'&prm_screen='+tela).then(function(){
        if(tipo == 'FLOAT_PAR' || tipo != 'FLOAT_FILTER'){
          document.getElementById('float-filter').className = 'visible';
        }
        if(tipo == 'CALL_LIST'){
          document.getElementById('call-menu').className = 'visible';
        }
      });
    }
    
    if(tipo != 'CALL_LIST' && tipo != 'FLOAT_PAR' && tipo != 'FLOAT_FILTER' && tipo != 'BROWSER'){
      loading();
      var pro = new Promise(function(resolve, reject){
        if(selecionado){
          resolve(ajax('append', 'show_objeto', 'prm_objeto='+obj+'&PRM_ZINDEX=99&prm_posx=300px&prm_posy='+(selecionado.children.length+1)+'px&prm_screen='+tela+'&prm_dashboard=true', true, selecionadoid, '', obj, 'obj'));
          //document.getElementById('fakelist').classList.remove('visible');
          //selecionado.classList.remove('movingarticle');
        } else {
          resolve(ajax('append', 'show_objeto', 'prm_objeto='+obj+'&PRM_ZINDEX=&prm_posx=300px&prm_posy=200px&prm_screen='+tela, true, 'main', '', obj, 'obj'));
        }
      });

    } else {
      if(tipo == 'CALL_LIST' || tipo == 'BROWSER'){
        shscr(tela);
      } else {
        if(tipo == 'FLOAT_PAR' || tipo == 'FLOAT_FILTER'){
          alerta('feed-fixo', TR_AD);
          /*if(document.getElementById('float-icon').classList.contains('invisible')){
            document.getElementById('float-icon').className = 'visible';
          }*/
        }

        if(LAYER.classList.contains('ativo')){
          loading();
        }
      }
    }
  }  
}

function getlist(x) {
    var erros = document.getElementById('painel').querySelectorAll('.error').length;
    if(erros == 0){
        var visao = document.getElementById('consulta_visao').title;
        var nome = encodeURIComponent(document.getElementById('consulta_nome').value.replace(/\./g, '_').replace(/\#/g, ''));
        var desc = encodeURIComponent(document.getElementById('consulta_desc').value);
        var grupo = document.getElementById('consulta_grupo').title;
        var opcao = document.getElementById('consulta_prm').value;
        if(visao.trim().length > 0){
            if(nome.trim().length > 1){
                if(desc.trim().length > 1){
                    if(grupo.trim().length != 0){
                        if(error == 'false'){
                            carrega('consulta?prm_obj='+nome+'&prm_visao='+visao+'&prm_nome='+desc+'&prm_grupo='+grupo+'&prm_agrupamento='+opcao);
                            call_save('consulta');
                        }
                    } else { alerta('msg', TR_ES_GR); }
                } else { alerta('msg', TR_DS_LE); }
            } else { alerta('msg', TR_NM_LE); }
        } else { alerta('msg', TR_ES_VW); }
    } else { alerta('msg', TR_ID); }
}

function filter(obj, visao, counter, tipo, id){
    var coluna = document.getElementById('filtro-coluna-'+counter).getAttribute('data-default');
    var condicao = document.getElementById('filtro-condicao-'+counter).getAttribute('data-default');
    if(document.getElementById('filtro-conteudo-'+counter).className != 'fakeoption'){
      var conteudo = encodeURIComponent(document.getElementById('filtro-conteudo-'+counter).getAttribute('data-default'));
      var self = document.getElementById(id);
      var valor = encodeURIComponent(self.value);
    } else {
      var conteudo = encodeURIComponent(document.getElementById('filtro-conteudo-'+counter).children[0].title);
      var valor = conteudo;
    }
    var ligacao = document.getElementById('filtro-ligacao-'+counter).getAttribute('data-default');
    if(document.getElementById('filtro-agrupado-'+counter)){
        var agrupado = document.getElementById('filtro-agrupado-'+counter).getAttribute('data-default');
    } else {
        var agrupado = 'N';
    }
    
    if(document.getElementById('filtro-conteudo-'+counter).className != 'fakeoption'){
      
      
      self.setAttribute('data-default', self.value);
      if(self.tagName == 'SELECT'){
          for(let i=0;i<self.children.length;i++){
              if(self.children[i].value == self.value){
                  self.children[i].setAttribute('selected', 'selected');
              } else {
                  self.children[i].removeAttribute('selected');
              }
          }
      }
    }
    ajax('fly', 'edit_filtro','prm_objeto='+obj+'&prm_visao='+visao+'&prm_coluna='+coluna+'&prm_condicao='+condicao+'&prm_conteudo='+conteudo+'&prm_valor='+valor+'&prm_tipo='+tipo+'&prm_agrupado='+agrupado+'&prm_ligacao='+ligacao, true);

    noerror('', TR_AL, 'msg');
    reload(obj);
}

function list_obj(){
    var tipo = document.getElementById('obj_serch_tp').value;
    var view = document.getElementById('obj_serch_vw').value;
    var grupo = document.getElementById('obj_serch_gp').value;
    var desc = document.getElementById('obj_serch_in').value;
    if(desc.length < 1){ desc = 'N/A'; }
    document.getElementById('ajax_obj').innerHTML = '';
    loader('ajax_obj');
    ajax('list', 'list_obj', 'prm_tipo='+tipo+'&prm_view='+view+'&prm_grupo='+grupo+'&prm_desc='+desc, true, 'ajax_obj');
}

function order(x, ajax){
    var dir = document.getElementById(ajax).getAttribute('data-dir');

    if(x == 'notsame'){
        document.getElementById(ajax).innerHTML = '';
        loader(ajax);
        if(dir == '1'){
            document.getElementById(ajax).setAttribute('data-dir', '2');
        } else {
            document.getElementById(ajax).setAttribute('data-dir', '1');
        }
    } else {
        document.getElementById('content').innerHTML = '';
        loader('content');
    }
  return dir;
}

function checkError(){
    var erros = document.getElementById('painel').querySelectorAll('.error').length;
    if(erros != 0){
        alerta('feed-fixo', TR_II);
        throw new Error(TR_II);
    }
}

function dashSpace(x){
    document.getElementById('id_DASH_MARGIN'+x).value = (document.getElementById('DASH_MARGIN'+x+'_input1').value.replace('px', '')+'px')+' '+(document.getElementById('DASH_MARGIN'+x+'_input2').value.replace('px', '')+'px')+' '+(document.getElementById('DASH_MARGIN'+x+'_input3').value.replace('px', '')+'px')+' '+(document.getElementById('DASH_MARGIN'+x+'_input4').value.replace('px', '')+'px');
}

function checkPar(x, y){
    var valor = document.getElementById(x).value;
    if(valor.match(/\$\[[a-zA-Z0-9_]*\]/g)){
        var parametros = valor.match(/\$\[[a-zA-Z0-9_]*\]/g).join('|');
        ajax('input', 'checkpar', 'prm_variavel='+parametros+'&prm_visao='+y, true, x);
    }
}

var perline = 18; var divSet = false; var tmpf; var curId; var curTp; var curMd; var colorLevels = Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'); var colorArray = Array(); var ie = false; var nocolor = 'none';

if (document.all) { ie = true; nocolor = ''; }

function getObj(id){
    if(ie) {
        return document.all[id];
    } else {
        return document.getElementById(id);
    }
}

function addColor(r, g, b) {
var red = colorLevels[r]; var green = colorLevels[g]; var blue = colorLevels[b];
addColorValue(red, green, blue);
}

function addColorValue(r, g, b) { colorArray[colorArray.length] = '#' + r + r + g + g + b + b; }

function setColor(color) {
    var link = getObj(curId); var field = getObj(curId + 'field'); var picker = getObj('colorpicker'); var modelo = getObj(curMd);

    field.value = color;
    if( curMd == 'nomode' ) {
        field.value = color;
    } else {
        if(curTp == 'color') {
          if(parent.document.getElementById(curMd)){ parent.document.getElementById(curMd).style.color = color; }
        } else {
            if(parent.document.getElementById(curMd)){ parent.document.getElementById(curMd).style.backgroundColor  = color; }
        }
    }
    if (color == '') {
      link.style.background = nocolor;
      link.style.color = nocolor;
      color = nocolor;
        tmpf.value = '#000000';
    } else {
      link.style.background = color;
      link.style.color = color;
        tmpf.value = color;
  }
    picker.style.display = 'none';

  eval(getObj(curId + 'field').title);

  if(curId == 'cor_fundo'){ PRINCP.style.backgroundColor = color; }
    //set color da subquery
    var total = '';
    if(curId.indexOf('field') != -1){
        var valores = document.getElementById('fakelist').getElementsByTagName('input');
        for(let i=0;i<valores.length;i++){
            if(valores[i].value != '#065182'){
                total = total+valores[i].parentNode.title+valores[i].value+'|';
            }
        }
        ajax('fly', 'alter_attrib', 'prm_objeto='+document.getElementById(curId).getAttribute('data-visao')+'&prm_prop=SUBQUERY-COR&prm_value='+total, false);
    }

    if(link.previousElementSibling){
        var inputblink = link.previousElementSibling;
        if(inputblink.id){
            if(inputblink.id.indexOf('destaque-') != -1){
              destaque(inputblink.getAttribute('data-counter'), inputblink.getAttribute('data-tipo'), inputblink.id);
            }
        }
    }
}

function setDiv() {
if(!document.createElement) { return; }
  var elemDiv = document.createElement('div');
  if (typeof(elemDiv.innerHTML) != 'string') { return; }
  genColors();
  elemDiv.id = 'colorpicker';
  elemDiv.style.display = 'none';
  elemDiv.innerHTML = '<span style="font-family:Verdana; font-size:11px;"> '
  + getColorTable()
  + '</span>';

  if(document.getElementById('attriblist').className == 'open'){
    document.getElementById('fakelist').appendChild(elemDiv);
    document.getElementById('fakelist').className = 'visible';
    document.getElementById('fakelist').style.setProperty('left', '300px');
  } else {
    document.body.appendChild(elemDiv);
  }
  divSet = true;
}

function pickColor(id, modelo, tipo, tmpfield, e) {
  if(!divSet) { setDiv(); }
  var picker = getObj('colorpicker');
    if (id == curId && picker.style.display == 'block') {
      picker.style.display = 'none';
      return;
    }
  tmpf  = getObj(tmpfield);
  curId = id;
  curTp = tipo;
  curMd = modelo;
  var thelink = getObj(id);
  //picker.style.top = e.clientY+20+'px';
  //picker.style.left = e.clientX-220+'px';
  picker.style.top = cursory+'px';
  picker.style.left = cursorx+'px';
  picker.style.setProperty('opacity', '0');
  picker.style.setProperty('transition', 'all 0.1s linear');
  picker.style.setProperty('-webkit-transition', 'all 0.2s linear');
  setTimeout(function(){ picker.style.setProperty('opacity', '1'); }, 100);
  picker.setAttribute('class', 'font');
  picker.style.display = 'block';

}

function genColors() {
    addColorValue('0','0','0');
    addColorValue('3','3','3');
    addColorValue('6','6','6');
    addColorValue('9','9','9');
    addColorValue('C','C','C');
    addColorValue('F','F','F');

  for (let a = 1; a < colorLevels.length; a++)
    addColor(0,0,a);
  for (let a = 1; a < colorLevels.length - 1; a++)
    addColor(a,a,5);

  for (let a = 1; a < colorLevels.length; a++)
    addColor(0,a,0);
  for (let a = 1; a < colorLevels.length - 1; a++)
    addColor(a,5,a);

  for (let a = 1; a < colorLevels.length; a++)
    addColor(a,0,0);
  for (let a = 1; a < colorLevels.length - 1; a++)
    addColor(5,a,a);


  for (let a = 1; a < colorLevels.length; a++)
    addColor(a,a,0);
  for (let a = 1; a < colorLevels.length - 1; a++)
    addColor(5,5,a);

  for (let a = 1; a < colorLevels.length; a++)
    addColor(0,a,a);
  for (let a = 1; a < colorLevels.length - 1; a++)
    addColor(a,5,5);

  for (let a = 1; a < colorLevels.length; a++)
    addColor(a,0,a);
  for (let a = 1; a < colorLevels.length - 1; a++)
    addColor(5,a,5);

  return colorArray;
}

function getColorTable() {
    colorArray[colorArray.length] = '#8DB6CD';
    colorArray[colorArray.length] = '#B0E2FF';
    colorArray[colorArray.length] = '#6495ED';
    var colors = colorArray;
    var tableCode = '';
    tableCode += '<table border="0" cellspacing="1" cellpadding="1">';
    for(let i = 0; i < colors.length; i++){
      if(i % perline == 0) { tableCode += '<tr>'; }
      tableCode += '<td bgcolor="#000000"><a style="outline: 1px solid #000000; color: '
      + colors[i] + '; background: ' + colors[i] + ';font-size: 10px;" title="'
      + colors[i] + '" href="javascript:setColor(\'' + colors[i] + '\');">&nbsp;&nbsp;&nbsp;</a></td>';
      if (i % perline == perline - 1) { tableCode += '</tr>'; }
  }
    /*if(i == colors.length-2) {*/ tableCode += '<td bgcolor="#000"><a href="javascript:setColor(\'transparent\');" title="" style="padding: 0 2px; text-decoration: none; font-weight: bold; outline: 1px solid #000000; color: #CC0000; background: #FFF; font-size: 10px;">X</a></td>'; /*}*/
    if(i % perline != 0) { tableCode += '</tr>'; }

  tableCode += '</table>';
    return tableCode;
}

function relateColor(id, color) {
  var link = getObj(id);
  if (color == '') {
    link.style.background = nocolor;
    link.style.color = nocolor;
    color = nocolor;
  } else {
    link.style.background = color;
    link.style.color = color;
  }
  eval(getObj(id + 'field').title);
}

function getAbsoluteOffsetTop(obj){
  var top = obj.offsetTop;
  var parent = obj.offsetParent;
  while (parent != document.body) {
    top += parent.offsetTop;
    parent = parent.offsetParent;
  }
  return top;
}

function getAbsoluteOffsetLeft(obj) {
  var left = obj.offsetLeft;
  var parent = obj.offsetParent;
  while (parent != document.body) {
    left += parent.offsetLeft;
    parent = parent.offsetParent;
  }
  return left;
}


var checkscreen = '';
var loopscreen = '';

function fullscreen(){
    
    var obj = document.querySelector('.full').id;
    
    clearInterval(checkscreen);
    clearInterval(loopscreen);
    var valorcycle = document.getElementById('dados_'+obj).getAttribute('data-full');

    if(parseInt(valorcycle) > 0){
      
    if(document.getElementById(obj+'c')){
      
      var objm = document.getElementById(obj+'m').getElementsByTagName('tbody')[0];
      var maxscroll = objm.scrollHeight;
      var margintop = 0;
      var objmheight = document.getElementById(obj+'m').clientHeight;
      var childheight = document.getElementById(obj+'m').clientHeight/12;
    
      if(!document.getElementById(obj+'-estilo-full')){
        var estilos = '';
        //calcula altura dos tr
        
        estilos = ' height: '+childheight+'px;'; 
        
        estilos = 'div#'+obj+' tbody tr { '+estilos+' }';
        
        //efeito do scroll
        var active = document.getElementById('active-show').getAttribute('data-time');
        estilos = 'div#'+obj+' div#'+obj+'m tbody { transition: transform '+active+'s linear; } '+estilos;
  
        var estilo = document.createElement('style');
        estilo.id = obj+'-estilo-full';
        estilo.innerHTML = estilos;
        document.head.appendChild(estilo);
      }
      objm.style.setProperty('transform', 'translateY(-'+(maxscroll-(document.getElementById(obj+'dv2').clientHeight-(childheight*2)))+'px)');

      var teste = (maxscroll-(document.getElementById(obj+'dv2').clientHeight-(childheight*2)))/parseInt(active);

      if(objmheight < maxscroll){
        
        //escape de memória
        checkscreen = setInterval(function(){
          if(document.getElementById('layer').className != 'ativo' && document.getElementById(obj+'m')){
            clearInterval(checkscreen);
            loopscreen = setInterval(function(){
              if(margintop+objmheight < maxscroll+40){
                margintop = margintop+parseInt(teste);
                //objm.style.setProperty('margin-top', '-'+margintop+'px');
              } else {
                //objm.style.setProperty('margin-top', '-'+maxscroll+'px');
                clearInterval(loopscreen);
                var nextp = document.getElementById('active-show').nextElementSibling;
                if(nextp.className == 'show_only'){
                  setTimeout(function(){
                    document.getElementById('active-show').id = '';
                    nextp.id = 'active-show';
                    removeTrash();
                    shscr(nextp.value);
                  }, 5000 );
                } else {
                  setTimeout(function(){
                    document.getElementById('active-show').id = '';
                    document.querySelector('.show_only').id = 'active-show';
                    removeTrash();
                    shscr(document.querySelector('.show_only').value);
                  }, 5000 );
                }
              }
            }, 1000);
          }
        }, 10);
        
      } else {
        setTimeout(function(){
          clearInterval(loopscreen);
          var nextp = document.getElementById('active-show').nextElementSibling;
          if(nextp.className == 'show_only'){
            setTimeout(function(){
              document.getElementById('active-show').id = '';
              nextp.id = 'active-show';
              removeTrash();
              shscr(nextp.value);
            }, 1000 );
          } else {
            setTimeout(function(){
              document.getElementById('active-show').id = '';
              document.querySelector('.show_only').id = 'active-show';
              removeTrash();
              shscr(document.querySelector('.show_only').value);
            }, 1000 );
          }
        }, 4000);
      }
    }
  }
}


if(navigator.geolocation){ navigator.geolocation.getCurrentPosition(sucesso,erro); }

function sucesso(position){
  var lat = position.coords.latitude;
  var long = position.coords.longitude;
  var posicao = (lat+' '+long);
  ajax('fly', 'gps', 'prm_posicao='+posicao+'|'+mobilecheck());
}

function erro(){ return false; }

function mobilecheck() {
    var check = false;
    var tipo = 'desktop';
    (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))check = true})(navigator.userAgent||navigator.vendor||window.opera);
  check?tipo='mobile':tipo='desktop';
    return tipo;
}

var dbltouch = 0, dbltouchX = 0, dbltouchY = 0;

function dblTouch(obj){
    var ele = document.getElementById(obj+'_ds');
    if(ele.getAttribute('data-touch') == '1'){
        ele.setAttribute('data-touch', '0');
        if(touch){ clearTimeout(touch); }
        curtain('');
        scale(obj);
    } else {
        ele.setAttribute('data-touch', '1');
        touch = setTimeout(function(){ ele.setAttribute('data-touch', '0'); }, 1000);
    }
}

function swipeStart(obj, e){
    if(document.getElementById(obj).className.indexOf('scaled') != -1){
        document.getElementById(obj).setAttribute('data-swipe', e.touches[0].pageX);
        e.stopPropagation();
    }
}

function swipe(obj, e){
    var el = document.getElementById(obj);
    if(el.className.indexOf('scaled') != -1){
        if(parseInt(el.getAttribute('data-swipe')) > e.touches[0].pageX+50){
            cycle(obj, 'next');
        } else {
            if(parseInt(el.getAttribute('data-swipe')) < e.touches[0].pageX-50){
                cycle(obj, 'prev');
            }
        }
        e.stopPropagation();
    }
}

function smoothScroll2(pai, ele){
  var sup = document.getElementById(pai);
  var alvo = document.getElementById(ele);
  //sup.scrollTo(0, alvo.offsetTop-sup.offsetTop);
  var calc = (alvo.offsetTop-sup.offsetTop)-188;
  var i = 0;
  var smoothy = setInterval(function(){
        if(i > calc){
          clearInterval(smoothy);
      }
      i = i+47;
      sup.scrollTo(0, i);
    }, 5);
}


function smoothScroll(x){
  var x = x || window.innerHeight;
  var i = window.scrollY;
  var smoothy = setInterval(function(){
    if(i > x){
      clearInterval(smoothy);
    }
    i = i+20;
    window.scrollTo(0, i)
  }, 10);
}

function donutEvent(){
  var donut = document.getElementById('donut');
  donut.addEventListener("mouseleave", function(){ this.classList.remove('open'); });
  donut.addEventListener("click", function(e){ 
    this.classList.remove('open'); 
    // if(PRINCP.className != 'mobile' && e.target.innerHTML.indexOf('CENTRO') == -1){ 
    //  this.classList.remove('open'); 
    //} 
  });
  //donut.addEventListener("touchend", function(){ if(PRINCP.className == 'mobile'){ this.classList.remove('open'); }});
}

function over_evento(e){
  var objeto = this.id;
  var coluna = e.target;

  if(coluna.tagName != 'TABLE' && coluna.tagName != 'TBODY' && coluna.tagName != 'TR' && coluna.tagName != 'SVG' && coluna.tagName != 'TH'){
      
    if(coluna.classList){
      if(coluna.classList.contains('imgurl')){
        if(document.getElementById("img_content")){
          if(!document.getElementById("img_content").classList.contains('scaled')){
            document.getElementById("img_content").remove();
          }
        }
        var img_content = document.createElement('div');
        img_content.id = "img_content";
        var imagem = document.createElement('img');
        imagem.src = coluna.getAttribute('data-url');
        var erro = document.createElement('img');

        erro.src = OWNER_BI + '.fcl.download?arquivo=img_error.jpg';
        erro.className = 'img_error';
        var esquerda = coluna.getBoundingClientRect().left+36;

        var cima = coluna.getBoundingClientRect().top;
        imagem.addEventListener('error', function(){ 
          imagem.style.setProperty('display', 'none'); 
          img_content.appendChild(erro); 
        });
        
        img_content.appendChild(imagem);
        
        img_content.style.setProperty('left', esquerda+'px');
        img_content.style.setProperty('top', cima+'px');
        document.getElementById("main").appendChild(img_content);
      }
    }	  
  }
}

function out_evento(e){
  if(document.getElementById("img_content")){
    if(!document.getElementById("img_content").classList.contains('scaled')){
      document.getElementById("img_content").remove();
    }
  }
}

function click_evento(e){

  var objeto = this.id;
  var coluna = e.target;
  var classe = document.getElementById(objeto).parentNode.parentNode.parentNode.className;
  var screen = document.getElementById('current_screen').value;

  // Selecionado o marcador de anotações, quando existe anotação na célula 
  if (coluna.tagName == 'path' || coluna.tagName == 'circle' || coluna.tagName == 'polygon' || coluna.tagName == 'svg') { 
    if (coluna.tagName == 'svg') { 
      coluna = e.target.parentNode.parentNode;
    } else if (coluna.tagName == 'circle' || coluna.tagName == 'polygon') {   
      coluna = e.target.parentNode.parentNode.parentNode;      
    } else if (coluna.tagName == 'path') {   
      coluna = e.target.parentNode.parentNode.parentNode.parentNode;
    }  
  }

  //pega só o td
  if(coluna.tagName != 'TABLE' && coluna.tagName != 'TBODY' && coluna.getAttribute('colspan') < 2 && !coluna.parentNode.classList.contains('lc')){
    
      objeto = objeto.substring(0, objeto.length-1);
      if(coluna.className.indexOf("seta") != -1){
        var index = 0;
      } else {
        var index = parseInt(coluna.cellIndex);
      }
      var tipo = 'td';

     
    //troca de th
    if(coluna.classList.contains('callmed')){
        var visao = get('dados_'+objeto).getAttribute('data-visao');
        medDrill(coluna, objeto, visao);
    } else {
      if(coluna.tagName == 'TH' && classe.indexOf('cross') == -1){
        var numeroid = coluna.cellIndex;
        var ths;
        var thSpan = 0;
        ths = coluna.parentNode.parentNode.querySelectorAll('th');

        var fixed = coluna.parentNode.querySelectorAll('.colagr').length;
        if(!coluna.parentNode.querySelector('.colagr')){
          thSpan = coluna.parentNode.parentNode.querySelectorAll('.colagr').length;    //colunas agrupadoras
        }

        var colunaReal = coluna;
        if(!coluna.className && coluna.parentNode.parentNode.children.length > 1){
          colunaReal = coluna.parentNode.parentNode.lastElementChild.children[numeroid-fixed];
        } 
      
        // Se não for a primeira coluna (seta)
        if (numeroid+thSpan > 0) { 
          
          // Abre tela da micro visão com a coluna selecionada (ctrl + mouse left)
          if (e.ctrlKey ) { //window.event preterido
            var microVisao = '',
                nomeColuna  = '';  
            if (document.getElementById('dados_' + objeto)) { microVisao = document.getElementById('dados_' + objeto).getAttribute('data-visao');  }
            if (colunaReal.getAttribute('data-agrupador'))  { nomeColuna = colunaReal.getAttribute('data-agrupador') } 
            if (colunaReal.getAttribute('data-valor'))      { nomeColuna = colunaReal.getAttribute('data-valor') } 

            if (microVisao != '' && nomeColuna !== '') { 
              curtain('enabled');
              carregaPainel('list_crocks', objeto.split('trl')[0], nomeColuna );
              telaSup('visao', microVisao);
            }  
          // -- Ordenação das colunas da consulta   
          } else if((coluna.parentNode.parentNode.children.length < 5) ) {   
            
            let data_reorder_msg = document.getElementById(objeto).getAttribute('data-reorder-msg');
            if (data_reorder_msg && data_reorder_msg.length > 0 ) { 
              alerta('feed-fixo', data_reorder_msg);
              return;  // Interrompe reordenação 
            }

            var qt_col_inv = 0
            if (coluna.getAttribute('data-inv-antes')) {
              qt_col_inv = parseInt(coluna.getAttribute('data-inv-antes'));
            }
            var ordemc;
            if(colunaReal.className.indexOf('DESC') == -1 && colunaReal.className.indexOf('ASC') == -1){
              ordemc = numeroid+qt_col_inv+thSpan+' ASC';
            } else {
              if(colunaReal.className.indexOf('ASC') != -1){
                ordemc = numeroid+qt_col_inv+thSpan+' DESC';
              } else {
                if(colunaReal.previousElementSibling){
                  ordemc = '';
                } else {
                  ordemc = '';
                }
              }
            }

            colunaReal.className = ordemc;

            var ordem = [];
            if ((document.getElementById('usu-tp_ordem_coluna')) && (document.getElementById('usu-tp_ordem_coluna').value == 'U')) {  // Ordena somente uma coluna por vez (parametro definido no cadastro do usuário)
              ordem[0] = ordemc;
            } else {   
              for(let i=1;i<ths.length;i++){
                if(ths[i]){
                  ordem[i-1] = ths[i].className.replace(' fix', '').replace(' inv', '').replace('cen', '').replace('dir', '').replace('bld', '').replace('callmed', '').replace('colagr', '').trim();
                }
              }
            }    

            var parametro = encodeURIComponent(document.getElementById('par_'+objeto).value);
            var parente   = document.getElementById(objeto).parentNode.id;

            //remover('sdrill_'+objeto); 
            //remover('sdrill_'+objeto+'trl'); 
            //remover(objeto); 
            //remover(objeto+'trl');
            
            var vtop  = document.getElementById(objeto).offsetTop+'px';
            var vleft = document.getElementById(objeto).offsetLeft+'px';
            var drill =  'N', cd_objeto = objeto, cd_goto = '';
            var vdashorder = ''; 
            var vordem     = window.getComputedStyle(document.getElementById(objeto)).getPropertyValue('order');
             
            if(parente == 'main') { 
              vdashorder = '&prm_dashboard=false'; 
            } else { 
              vdashorder = '&prm_dashboard=true'; 
            }

            var track = '';
            if(document.getElementById(objeto).classList.contains('drill')){
              drill  = 'Y';
              if (objeto.split('trl').length > 1) {   // Pega a sequencia do objeto no cadastro de drills 
                cd_objeto = objeto.split('trl')[0];
                cd_goto   = objeto.split('trl')[1];
              }   
              track  = '&prm_track='+document.getElementById('dados_'+objeto).getAttribute('data-track')
            } else { 
              vleft = vordem;   // Se não for drill passa a ordem do objeto no dashboard 
            }

            // call('alterorder', 'prm_objeto='+cd_objeto+'&prm_screen='+screen+'&prm_valor='+ordem.filter(n => n).join(',')).then(function(resposta){
            let msg_erro = '';
            call('alterorder', 'prm_objeto='+objeto+'&prm_screen='+screen+'&prm_valor='+ordem.filter(n => n).join(',')).then(function(resposta){
              if (resposta.indexOf('#alert') != -1){
                msg_erro = resposta.split('#alert')[1];
              } 
              if (msg_erro.length > 0 ) { 
                alerta('feed-fixo', msg_erro);
              } else {
                  if(document.getElementById(objeto)){
                    document.getElementById(objeto).remove();       
                    loading();             
                  }
              }
            }).then(function(){
              if (msg_erro.length == 0 ) {
                if(document.getElementById(objeto+'sync')){
                  document.getElementById(objeto+'sync').click();
                } else {
                  appendar('prm_drill='+drill+'&prm_objeto='+cd_objeto+'&prm_posx='+vleft+'&prm_zindex=5&prm_posy='+vtop+'&prm_parametros='+parametro+'&prm_screen='+ tela + vdashorder + track+ '&prm_cd_goto='+cd_goto, false, parente);
                }						
              }  
            }).then(function(){
              // centerDrill(objeto+'trl');    // comentado pois não estava funcionando, pois o objeto já está com o trl no nome 
            });

          } else {
            var visao = get('dados_'+objeto).getAttribute('data-visao');
            medDrill(coluna, objeto, visao); 
            coluna.classList.toggle('tdselected');
          }
        }     
      }
      
    }


    if(index != 0){
      if(coluna.classList.contains('imgurl')){
        if(document.getElementById("img_content")){
          document.getElementById("img_content").remove();
        }
        var img_content = document.createElement('div');
        img_content.id = "img_content";
        img_content.className = "scaled";
        var imagem = document.createElement('img');
        imagem.addEventListener('click', removeImage);
        document.getElementById('layer2').addEventListener('click', removeImage);
        imagem.style.setProperty('opacity', '0');
        
        imagem.src = coluna.getAttribute("data-url");
        imagem.addEventListener('error', function(){ imagem.style.setProperty('display', 'none'); });
        img_content.appendChild(imagem);
        document.getElementById("main").appendChild(img_content);
        setTimeout(function(){
        
          img_content.style.setProperty('left', 'calc(50% - '+(imagem.clientWidth/2)+'px)');
          img_content.style.setProperty('top', '60px');
          img_content.style.setProperty('z-index', '900');
          
        }, 10);
        
        setTimeout(function(){
          imagem.style.setProperty('opacity', '1');
          curtain('only');
        }, 50);
        
      } else {

        if(coluna.tagName != 'TH'){
            if(document.getElementById('selecteddata')){ document.getElementById('selecteddata').id = ''; }
            coluna.id = 'selecteddata';
          
            if(document.getElementById('selectedline')){ document.getElementById('selectedline').id = ''; }
            coluna.parentNode.id = 'selectedline';
            document.getElementById('drill_obj').value = objeto.split('trl')[0];
            var datavalor = coluna.parentNode.firstElementChild.getAttribute('data-valor');
            var indexadd = objeto+index+'h';

            var indexth   = coluna.parentNode.parentNode.firstElementChild.children[coluna.cellIndex];
            var agrupSpan = 0;


            if((coluna.parentNode.parentNode.parentNode.firstElementChild.children.length > 1) && (!coluna.classList.contains('colagr'))) {
              agrupSpan = coluna.parentNode.parentNode.parentNode.firstElementChild.firstElementChild.querySelectorAll('.colagr').length;
            }
            var thead     = coluna.parentNode.parentNode.parentNode.firstElementChild.lastElementChild.children[coluna.cellIndex-agrupSpan];

            if(!!indexth){
              let col, linha, pivot;
              
              if(!coluna.classList.contains('colagr')){  
                pivot = get(objeto+'c').children[0].lastElementChild.children[coluna.cellIndex-agrupSpan].getAttribute('data-pivot');
              }
              if(typeof indexth.getAttribute('data-p') === "string"){
                //check_tag(e, objeto, thead.getAttribute('data-valor'), datavalor, indexth.getAttribute('data-p'), coluna);
                col = thead.getAttribute('data-valor');
                linha = datavalor;
                
              } else {
                if(coluna.parentNode.firstElementChild.getAttribute('data-valor')){
                  if(thead){
                      if(thead.getAttribute('data-valor')){

                        //check_tag(e, objeto, thead.getAttribute('data-valor'), datavalor, '', coluna);
                        col = thead.getAttribute('data-valor');
                        linha = datavalor;
                      } else {
                        //check_tag(e, objeto, '', datavalor, '', coluna);
                        linha = datavalor;
                      }
                  } else {
                      if(document.getElementById(objeto).className.indexOf('cross') != '-1'){
                        //check_tag(e, objeto, '', datavalor+'|'+indexth.innerHTML.trim(), '', coluna);
                        linha = datavalor+'|'+indexth.innerHTML.trim();
                      } else {
                        //check_tag(e, objeto, '', datavalor, '', coluna);
                        linha = datavalor;
                      }
                  }
                } 
              }

              //chamar o check uma só vez   check_tag(event, obj, coluna, linha, pivot, actual)
              check_tag(e, objeto, col, linha, pivot, coluna);
            }
        }
      }
    } else {
      if(coluna.className.indexOf('seta') != -1){ changearrow(coluna); }
    }
  }
}

function removeImage(){
  document.getElementById("img_content").remove();
  curtain('');
  document.getElementById('layer2').removeEventListener('click', removeImage);
}

function dbl_click_evento(e){
  var objeto = this.id;

  objeto = objeto.substring(0, objeto.length-1);
  var coluna = e.target;

  if(coluna.tagName == 'td' && coluna.className.indexOf('flag') != -1){
    var texttalk = document.getElementById('text-talk');
    texttalk.classList.remove('open');
    texttalk.classList.add('open');
    ajax('list', 'text_post', 'prm_objeto='+objeto.split('trl')[0]+'&prm_line='+coluna.getAttribute('data-valor'), false, 'campo');
  }
}

function changearrow(coluna){

  var objeto = coluna.parentNode.parentNode.parentNode.id;
  if(objeto.indexOf('trlc') != -1){
    objeto = objeto.replace('trlc', 'trl');
  } else {
    objeto = objeto.slice(0, -1);
  }
  
  var ele = coluna;
  var self = ele;

  if(self.parentNode.nextElementSibling != null){
    if(self.parentNode.nextElementSibling){
      var tag = self.parentNode.nextElementSibling.tagName;
    } else {
      var tag = 'LAST';
    }
    //recolher
    if(tag == 'STYLE'){
      var niveln = self.parentNode.className.replace(/[a-zA-Z ]/g, '');
      if(niveln.length == 0) { niveln = 0; } else { niveln = parseInt(niveln); }
      
        try{
          while((self.parentNode.nextElementSibling.className.indexOf('nivel') != -1 && parseInt(self.parentNode.nextElementSibling.className.replace(/[a-zA-Z ]/g, '')) > niveln) || self.parentNode.nextElementSibling.tagName == 'STYLE'){
            var excluir = self.parentNode.nextElementSibling;
            if(excluir.className){
              var cloneclass = excluir.className;
            }
            excluir.remove();
          }
        } catch (err){
          console.log('ultima linha');
        }
      
      if(document.getElementById('selectedline')){ document.getElementById('selectedline').id = ''; }
      topDistance(objeto);
      setTimeout(function(){
        fixCol(objeto);             
      }, 200);
            
    } else {

      if(self.className.indexOf('down') == -1 && self.className.indexOf('checked') == -1){
        //if(tag != 'STYLE'){
        if(self.getAttribute('data-subquery').length > 0){
          document.getElementById(objeto+'dv2').scrollLeft = 0;
          var v_self = [];
          if(document.getElementById('par_'+objeto).value.length > 0){
            v_self.push(encodeURIComponent(document.getElementById('par_'+objeto).value));
          }
          
          v_self.push(encodeURIComponent(self.getAttribute('data-valor')));
          var prm_self = '';
          if(self.getAttribute('data-self')){
            prm_self = self.getAttribute('data-self');
          }
           
          loading();
          if(document.getElementById('selectedline')){ document.getElementById('selectedline').id = ''; }
          self.parentNode.id = 'selectedline';
          setTimeout(function(){
            var ws_cd_goto = '';
            if (objeto.split('trl')[1]){
              ws_cd_goto = '&prm_cd_goto='+objeto.split('trl')[1];
            }
            var ws_popup_drill = '';
            if (objeto.includes('trl')){
              if (objeto.split('trl')[1] === '13062309' || (document.getElementById('par_'+objeto).value.length === 0 && objeto.split('trl')[1] === '')) {
                ws_popup_drill = '&prm_popup_drill=false';
              } else if (document.getElementById('par_'+objeto).value.length > 0){
                ws_popup_drill = '&prm_popup_drill='+document.getElementById('par_'+objeto).value;
              } else {
                ws_popup_drill = '&prm_popup_drill='+objeto.includes('trl');
              }
            }

            //inside é onde manda pra subquery
            ajax('inject', 'show_objeto','prm_objeto='+objeto.split('trl')[0]+ws_cd_goto+'&prm_posx=&prm_posy=&prm_parametros='+v_self.join("|")+'&prm_drill='+self.getAttribute('data-subquery')+'&prm_out=&prm_zindex=&prm_screen='+tela+'&prm_forcet='+self.nextElementSibling.innerHTML.trim()+'&prm_track=INSIDE&prm_objeton='+self.getAttribute('data-ordem')+'&prm_alt_med=&prm_cross=&prm_self='+prm_self+ws_popup_drill, false, 'selectedline', objeto, objeto, 'obj');
            var objetoc = document.getElementById(objeto+'c');
            //remove duplicados
            if(self.parentNode.className.indexOf('nivel') == -1){
              objetoc.removeEventListener('click', click_evento);
              objetoc.addEventListener('click', click_evento);
              objetoc.removeEventListener('dblclick', dbl_click_evento);
              objetoc.addEventListener('dblclick', dbl_click_evento);
            } else {
              var parente = 'nivel'+(parseInt(self.parentNode.className.replace('es nivel', '').replace('cl nivel', ''))+1);
              objetoc.removeEventListener('click', click_evento);
              objetoc.addEventListener('click', click_evento);
              objetoc.removeEventListener('dblclick', dbl_click_evento);
              objetoc.addEventListener('dblclick', dbl_click_evento);
            }
            
            topDistance(objeto);
            setTimeout(function(){
              fixCol(objeto);
            }, 200);
          }, 100);
        }

      } else {
        ele.classList.toggle('checked');
      }
    }
  } else {
    //last arrow
    if(self.className.indexOf('down') == -1 && self.className.indexOf('checked') == -1){
      //if(tag != 'STYLE'){
      if(self.getAttribute('data-subquery').length > 0){
        document.getElementById(objeto+'dv2').scrollLeft = 0;
        loading();
        if(document.getElementById('selectedline')){ document.getElementById('selectedline').id = ''; }
        self.parentNode.id = 'selectedline';
        
        var v_self = [];
          if(document.getElementById('par_'+objeto).value.length > 0){
            v_self.push(encodeURIComponent(document.getElementById('par_'+objeto).value));
          }
          
          v_self.push(encodeURIComponent(self.getAttribute('data-valor')));

        setTimeout(function(){
          ajax('inject', 'show_objeto','prm_objeto='+objeto.split('trl')[0]+'&prm_posx=&prm_posy=&prm_parametros='+v_self.join("|")+'&prm_drill='+self.getAttribute('data-subquery')+'&prm_out=&prm_zindex=&prm_screen='+tela+'&prm_forcet='+self.nextElementSibling.innerHTML.trim()+'&prm_track=INSIDE&prm_objeton='+self.getAttribute('data-ordem')+'&prm_alt_med=&prm_cross=&prm_self='+prm_self, false, 'selectedline', objeto, objeto, 'obj');

          var objetoc = document.getElementById(objeto+'c');
            //remove duplicados
            if(self.parentNode.className.indexOf('nivel') == -1){
              objetoc.removeEventListener('click', click_evento);
              objetoc.addEventListener('click', click_evento);
              objetoc.removeEventListener('dblclick', dbl_click_evento);
              objetoc.addEventListener('dblclick', dbl_click_evento);
            } else {
              var parente = 'nivel'+(parseInt(self.parentNode.className.replace('es nivel', '').replace('cl nivel', ''))+1);
              objetoc.removeEventListener('click', click_evento);
              objetoc.addEventListener('click', click_evento);
              objetoc.removeEventListener('dblclick', dbl_click_evento);
              objetoc.addEventListener('dblclick', dbl_click_evento);
            } 

            topDistance(objeto);
            setTimeout(function(){
              fixCol(objeto);
            }, 200);

        }, 100);
      }
    } else {
      if(document.getElementById(objeto).getElementsByClassName('checked').length < 17){
        ele.classList.toggle('checked');
      } else {
        coluna.className = 'setadown';
      }
    }
  }
}

var mapa = {};  

var geoarray = new Array();

// Monta os mapas de Geo localização (mapas do Google) 
function mapaGeoLoc(obj, geoarray) {

  var atributos = document.getElementById('atributos_'+obj), 
      dados     = document.getElementById('dados_'+obj), 
      gxml      = document.getElementById('gxml_'+obj), 
      div_erro  = document.getElementById(obj+'_ERR'); 

  var vmarker_hide  = '|' + atributos.getAttribute('data-marker_hide') + '|',
      vmarker_anime = atributos.getAttribute('data-marker_anime'),
      vdrill = dados.getAttribute('data-drill');     
      

  // Verifica se houve erro na montagem do objeto 
  if ((div_erro != null) && (atributos.getAttribute('data-show_nomarker') == 'N')) { 
    document.getElementById('ctnr_' + obj).innerHTML = div_erro.innerHTML; 
    return;
  }

  //----------------------------------------------------------------------- 
  // Define opções do mapa  
  //-----------------------------------------------------------------------
  var mapOptions = {
    center: {
      lat: (parseFloat(atributos.getAttribute('data-center_lat')) || 0),
      lng: (parseFloat(atributos.getAttribute('data-center_lng')) || 0)
    },
    zoom:    (parseFloat(atributos.getAttribute('data-zoom')) || 8),
    minZoom: (parseFloat(atributos.getAttribute('data-minzoom')) || 3),
    maxZoom: (parseFloat(atributos.getAttribute('data-maxzoom')) || 3),

    zoomControl:       (atributos.getAttribute('data-zoomcontrol')       == 'S' ? true : false),
    mapTypeControl:    (atributos.getAttribute('data-mapTypecontrol')    == 'S' ? true : false),
    streetViewControl: (atributos.getAttribute('data-streetviewcontrol') == 'S' ? true : false),
    fullscreenControl: (atributos.getAttribute('data-fullscreenControl') == 'S' ? true : false),
    scaleControl: true,
    disableDefaultUI: false,
    mapTypeControlOptions: {
      mapTypeIds: ["roadmap","satellite","hybrid","terrain"],
    }    
  };

  //----------------------------------------------------------------------- 
  // Define Estilo do Mapa
  //----------------------------------------------------------------------- 
  var styledMapType = new google.maps.StyledMapType(
    [ {
        featureType: "administrative",
        elementType: "geometry.fill"
      }
    ],
    { name: "myCustomMap" }
  );

  //----------------------------------------------------------------------- 
  // Cria mapa com as opções e com o estilo 
  //----------------------------------------------------------------------- 
  mapa = new google.maps.Map(document.getElementById('ctnr_' + obj), mapOptions); 
  mapa.mapTypes.set('myCustomMap', styledMapType);
  mapa.setMapTypeId(atributos.getAttribute('data-maptypeid') );  // Define o estilo padrão (inicial) para o mapa



  //----------------------------------------------------------------------- 
  // MOnta os marcadores no mapa (e houver marcador)
  //----------------------------------------------------------------------- 
  if (div_erro == null) { 
    
    try {
      var jsonParsed = JSON.parse("{"+  gxml.children[0].innerHTML.replace(/(\r\n|\n|\r)/g, " ") +"}");
    } catch (err){
      alerta('feed-fixo', 'Erro interpretando os dados dos marcadores do mapa');
      return;
    }

    var vcont  = 0,
        vlabel = {},
        vicon  = {}; 

    for(let linha in jsonParsed){
      vcont++ ;    

      vlabel      = { text:       jsonParsed[linha].label_text,
                      fontFamily: jsonParsed[linha].label_fontFamily,
                      fontWeight: jsonParsed[linha].label_fontWeight,
                      color:      jsonParsed[linha].label_color,
                      fontSize:   jsonParsed[linha].label_fontSize,
                      className:  jsonParsed[linha].cod
                    };
                    
      vlabelNone  = { text:' ',
                      className:  jsonParsed[linha].cod 
                    };
      vicon = '' ; 
      if (jsonParsed[linha].icon_url != null) { 
        vicon = {url:    jsonParsed[linha].icon_url }        
        if (Number(jsonParsed[linha].icon_height) != 0 && Number(jsonParsed[linha].icon_width) != 0)   { 
          vicon.size       = new google.maps.Size(Number(jsonParsed[linha].icon_height), Number(jsonParsed[linha].icon_width));  
          vicon.scaledSize = new google.maps.Size(Number(jsonParsed[linha].icon_height), Number(jsonParsed[linha].icon_width));  
        }
      } else if (jsonParsed[linha].icon_path != "") {
        vicon = {path:          jsonParsed[linha].icon_path,  
                 fillColor:     jsonParsed[linha].icon_fillColor,
                 strokeColor:   jsonParsed[linha].icon_fillColor,
                 fillOpacity:   parseFloat(jsonParsed[linha].icon_fillOpacity),
                 strokeOpacity: parseFloat(jsonParsed[linha].icon_strokeOpacity),
                 rotation:      parseFloat(jsonParsed[linha].icon_rotation),
                 scale:         parseFloat(jsonParsed[linha].icon_scale)
        }; 
      }  
      // vicon.url = 'https://img2.gratispng.com/20180209/vje/kisspng-hat-bonnet-christmas-icon-christmas-hats-5a7dcbf3133e85.9860966015181936510788.jpg';  

      var marker = new google.maps.Marker({
        map      : mapa,
        draggable: false,    // Não permite movimentar o marcador 
        position : { lat: parseFloat(jsonParsed[linha].lat), lng: parseFloat(jsonParsed[linha].lng) },
        icon     : vicon
      });

      if (vmarker_hide.indexOf('|NOME|')      == -1)  { marker.setLabel(vlabel); } else{marker.setLabel(vlabelNone);} 
      if (vmarker_hide.indexOf('|DESCRICAO|') == -1)  { marker.setTitle(jsonParsed[linha].title.trim());  }  
      if (vmarker_anime == 'S')                       { marker.setAnimation(google.maps.Animation.DROP); }  

      // *******  Mostrar caixa de texto sobre o marcador com a descrição do Hint 
      //if (jsonParsed[linha].title.trim() != '') { 
      //  var infoWindow = new google.maps.InfoWindow; 
      //  marker.addListener("dblclick", function(){ 
      //        infoWindow.close();
      //        infoWindow.setContent(jsonParsed[linha].title.trim());
      //        infoWindow.open(this.getMap(), this);
      //  }); 
      //}

      marker.addListener("click", function(){ 
        if(vdrill > 0){
          var vparametros = dados.getAttribute('data-colunareal').split('|')[0] + '|' + this.getLabel().className + '|';          
          get('drill_go').value = vparametros;
          drillfix(this, obj, vparametros);           
        } else if (vmarker_anime == 'S') { 
          if (this.getAnimation() !== null) {
            this.setAnimation(null);
          } else {
            this.setAnimation(google.maps.Animation.BOUNCE);
          }
        }  
      });
       
    }
  } 
}

function callHints(){
  var markers = document.getElementsByClassName('gmnoprint');
  for(let i=0;i<markers.length;i++){
    if(markers[i].children[1]){
      if(markers[i].children[1].children[0]){
        markers[i].setAttribute('data-text', markers[i].children[1].children[0].title.replace(/<BR>/g, ', \n '));
        markers[i].style.setProperty('opacity', '1');
      }

      var texto = document.createElement('span');
      texto.className = 'texto';
      texto.innerHTML = markers[i].children[1].children[0].title;
      markers[i].appendChild(texto);
    }
  }
}


function lock(x, y){
  if(y=='lockin'){
    if(x.className=='locked'){ throw "stop execution"; }
    x.setAttribute('class', 'locked');
  } else {
    x.setAttribute('class', '');
  }
}

function call_save(x){
  document.getElementById('salvar').setAttribute('onclick','');
  if(x.length > 1){
    document.getElementById('salvar').setAttribute('class','');
    document.getElementById('salvar').setAttribute('onclick','save("'+x+'")');
  } else {
    document.getElementById('salvar').setAttribute('class','disabled');
  }
}

function save(x) {
  switch(x){
    case 'pontoav': document.getElementById('savepa').submit();
    break;

  case 'browseredit':
    
    var linhas = document.getElementById('browseredit').children; 
    var linhasl = linhas.length;
    var nome = '';
    var valor = '';
    var padrao = '';
    var tipo = '';
    var campo = [];
    var ident = [];
    var temPipe = false;
    for(let i=0;i<linhasl;i++){ 
      if(linhas[i].getAttribute('data-chave') == '0'){ 
        if((!linhas[i].getAttribute('data-obrigatorio')) || (linhas[i].getAttribute('data-obrigatorio') && linhas[i].getAttribute('data-v').length > 0)){ 
          if((linhas[i].getAttribute('data-tipo') == 'data' && (linhas[i].getAttribute('data-v').length < 10 && linhas[i].getAttribute('data-v').length != 0)) || (linhas[i].getAttribute('data-tipo') == 'datatime' && (linhas[i].getAttribute('data-v').length < 16 && linhas[i].getAttribute('data-v').length != 0))){
            document.getElementById('data_list_menu').classList.add('shake');
            linhas[i].classList.add('error'); 
            alerta('feed-fixo', TR_TD_IN, TR_FL_DC); 
            setTimeout(function(){ document.getElementById('data_list_menu').classList.remove('shake'); }, 300); 
            return; 
          } else {
            valor = valor+'&prm_conteudo='+encodeURIComponent(linhas[i].getAttribute('data-v').trim()); 
            nome = nome+'&prm_nome='+linhas[i].getAttribute('data-c'); 
            padrao = padrao+'&prm_ant='+encodeURIComponent(linhas[i].getAttribute('data-d')); 
            tipo = tipo+'&prm_tipo='+linhas[i].getAttribute('data-tipo');
          } 
        } else { 
          document.getElementById('data_list_menu').classList.add('shake'); 
          linhas[i].classList.add('error'); 
          alerta('feed-fixo', TR_AO); 
          setTimeout(function(){ document.getElementById('data_list_menu').classList.remove('shake'); }, 300); 
          return; 
        } 
      } else {
        if(linhas[i].getAttribute('data-tipo') == 'data'){ 
          campo.push("to_char("+linhas[i].getAttribute("data-c")+", 'DD/MM/YYYY')");
        } else {
          campo.push(linhas[i].getAttribute('data-c'));
        }
        ident.push(linhas[i].getAttribute('data-v'));
        if (encodeURIComponent(linhas[i].getAttribute('data-v')).includes('%7C')) {
          temPipe = true;
        }
      } 
    }
    //var nome = ''; for(c=0;c<linhasl;c++){ nome = nome+'&prm_nome='+encodeURIComponent(linhas[c].getAttribute('data-c'));  }
    //var valor = ''; for(let i=0;i<linhasl;i++){ valor = valor+'&prm_conteudo='+encodeURIComponent(linhas[i].getAttribute('data-v'));  }
    //var padrao = ''; for(d=0;d<linhasl;d++){ padrao = padrao+'&prm_ant='+encodeURIComponent(linhas[d].getAttribute('data-d'));  }
    curtain();
    loading();
    var mdata = document.getElementById('browser-tabela').value;
    var mchave = linhas[0].getAttribute('data-c');
    var mvalor = linhas[0].getAttribute('data-v');

    if (temPipe) {
      ident = ident.join('*|*');
      
      if (!ident.includes('*|*')) {
        ident = ident.replace(/\|/g, '******');
      }
    
    } else {
      ident = ident.join('|');
    }

    ajax('fly', 'browserEditLine', 'prm_tabela='+document.getElementById('data_list').getAttribute('data-tabela')+'&prm_chave='+encodeURIComponent(ident)+'&prm_campo='+encodeURIComponent(campo.join('|'))+nome+valor+padrao+tipo+'&prm_obj='+document.getElementById('data_list').className, false, '', '', '', 'bro');
    
    if(error == 'false'){
      document.getElementById('data_list_menu').classList.remove('open');
      alerta('feed-fixo', TR_AL);
      //ajax('double', 'dt_pagination', 'prm_micro_data='+mdata+'&prm_coluna='+document.getElementById('browser-coluna').value+'&prm_objid='+mdata+'&prm_chave='+mchave+'&prm_screen='+tela+'&prm_limite='+document.getElementById('linhas').value+'&prm_origem=50&prm_direcao=BUSCA&prm_busca=&prm_condicao=semelhante', false, 'ajax', '', '', 'bro');
      browserSearch('save');
    } else {
      document.getElementById('data_list_menu').classList.remove('open');
      loading();
    }

  break;

  case 'browsereditclob':
  
  var param,
      conteudo; 
  if (document.getElementById('modal-output1').tagName.toLowerCase() == 'textarea') {
    conteudo = document.getElementById('modal-output1').value; 
  } else {
    conteudo = document.getElementById('modal-output1').innerHTML; 
  }

  param =           'prm_obj='         + document.getElementById('data_list').getAttribute('data-objeto');
  param = param + '&prm_screen='     + tela;    
  param = param + '&prm_tabela='     + document.getElementById('data_list').getAttribute('data-tabela');
  param = param + '&prm_campo_chave='+ document.getElementById('browser-edit-campo').value; 
  param = param + '&prm_chave='      + encodeURIComponent(document.getElementById('browser-edit-chave').value); 
  param = param + '&prm_tipo='       + document.getElementById('browser-edit-tipo').value;
  param = param + '&prm_campo='      + document.getElementById('browser-edit-coluna').value;; 
  param = param + '&prm_conteudo='   + encodeURIComponent(conteudo);   

  curtain();
  loading();

  // dis.classList.toggle('loading');

  call('browserEditColumn', param, 'bro').then(function(resultado){
    document.getElementById('data_list_menu').classList.remove('open');
    alerta('',resultado.split('|')[1]); 

    if(resultado.split('|')[1] != 'ERRO'){
      browserSearch('save');
    } else {
      loading();
    }
  }); 

  break;


  case 'browseradd': 
  
  var linhas = document.getElementById('browseredit').children; 
  var linhasl = linhas.length;
  var nome = ''; 
  var tipo = '';
  var identarr = document.getElementById('browser-campos').value.split('|');
  var ident = [];
  var sequence = false;
  var vazio = false;
  var valor = '';
  var campo = [];
  for(let c=0;c<linhasl;c++){ 
    if(linhas[c].getAttribute('data-tipo') == 'sequence'){ sequence = true; } 
    /*if(identarr.indexOf(linhas[c].getAttribute('data-c')) != -1){ 
      
      if(linhas[c].getAttribute('data-v').trim().length == 0){ 
        document.getElementById('data_list_menu').classList.add('shake'); 
        linhas[c].classList.add('error'); 
        alerta('feed-fixo', 'Campos com * são obrigatórios'); 
        setTimeout(function(){ document.getElementById('data_list_menu').classList.remove('shake'); }, 300); 
        return; 
      } 

      ident[parseInt(linhas[c].style.getPropertyValue('order'))] = (linhas[c].getAttribute('data-v').trim());
      //ident.push(linhas[c].getAttribute('data-v').trim()); push para sequencia, direto no array para respeitar ordem do order
    }*/

    //usa mesma ident da linha, menos risco de ir coluna diferente de valor
    if(linhas[c].getAttribute('data-chave') == '1'){
      if(linhas[c].getAttribute('data-v').trim().length == 0){ 
        document.getElementById('data_list_menu').classList.add('shake'); 
        linhas[c].classList.add('error'); 
        alerta('feed-fixo', TR_AO); 
        setTimeout(function(){ document.getElementById('data_list_menu').classList.remove('shake'); }, 300); 
        return;
      } 
      ident.push(linhas[c].getAttribute('data-v'));
      
      if(linhas[c].getAttribute('data-tipo') == 'data'){ 
        campo.push(encodeURIComponent("to_char("+linhas[c].getAttribute("data-c")+", 'DD/MM/YYYY')"));
      } else {
        campo.push(linhas[c].getAttribute('data-c'));
      }
    }

    if((!linhas[c].getAttribute('data-obrigatorio')) || (linhas[c].getAttribute('data-obrigatorio') && linhas[c].getAttribute('data-v').length > 0)){
      nome = nome+'&prm_nome='+encodeURIComponent(linhas[c].getAttribute('data-c')); 
      tipo = tipo+'&prm_tipo='+linhas[c].getAttribute('data-tipo'); 
      valor = valor+'&prm_conteudo='+encodeURIComponent(linhas[c].getAttribute('data-v'));  
    } else { 
      document.getElementById('data_list_menu').classList.add('shake'); 
      linhas[c].classList.add('error'); 
      alerta('feed-fixo', TR_AO); 
      setTimeout(function(){ document.getElementById('data_list_menu').classList.remove('shake'); }, 300); 
      return; 
    } 	
    
  }
  
  loading();
  
  if(vazio != true){
    var mdata = document.getElementById('browser-tabela').value;
    
    call('browserNewLine', 'prm_tabela='+document.getElementById('data_list').getAttribute('data-tabela')+'&prm_chave='+document.getElementById('browser-chave-valores').value+'&prm_coluna='+campo.join('|')+nome+valor+tipo+'&prm_ident='+encodeURIComponent(ident.join('|'))+'&prm_sequence='+sequence+'&prm_obj='+document.getElementById('data_list').className, 'bro').then(function(resposta){
      if(resposta.indexOf('#alert') == -1){
        alerta('feed-fixo', TR_AD);
        browserSearch('BUSCA');
        browserMenu(document.getElementById('data_list_menu'), '');
        curtain();
      } else {
        loading();
        curtain();
        alerta('feed-fixo', resposta.replace('#alert ', '').replace('undefined', ''));
      }
    });
  }

  break;

    case 'coluna': document.getElementById('saveap').submit();
    break;

  case 'saveprop':

    var lis = document.getElementById('attriblist').getElementsByTagName('LI');
    var valorreal = '';
    var lista = '';
    var arr = [];
    var objeto = document.getElementById('obj').value;
    var count = 0;

    for(let l=0;l<lis.length;l++){
      if(lis[l].parentNode.classList.contains('form')){
        if(lis[l].children[1].children[0]){
          if(lis[l].children[1].children[0].tagName != 'A' && !lis[l].children[1].querySelector('.script') && !lis[l].children[2]){
              
            if(lis[l].children[2]){
              if(lis[l].children[2].className.indexOf('inc') != -1){
                lista = lis[l].children[1].children; for(let i=0;i<lista.length;i++){ if(lista[i].value.indexOf('ffffff') == -1 && lista[i].value.indexOf('FFFFFF') == -1 && lista[i].value.indexOf('000000') == -1){ arr.push(lista[i].value); } } 
                valorreal = encodeURIComponent(arr.join('|'));
              }
            } else {
              
              if(lis[l].children[1].children[0].classList.contains('checkbox')){
                valorreal = lis[l].children[1].children[0].title;
              } else {
                if(lis[l].getAttribute('data-prop') == 'ESPACAMENTO' || lis[l].getAttribute('data-prop') == 'DASH_MARGIN'){
                  valorreal = encodeURIComponent(lis[l].children[1].children[0].value+'|'+lis[l].children[1].children[1].value+'|'+lis[l].children[1].children[2].value+'|'+lis[l].children[1].children[3].value);
                } else {
                  if(lis[l].children[1].children[0].getAttribute('type') == 'color'){
                    valorreal = encodeURIComponent(lis[l].children[1].children[1].value);
                  } else {
                    valorreal = encodeURIComponent(lis[l].children[1].children[0].value);
                  }
                }
              }
            }
            
            if(valorreal == 'on'){
              valorreal = lis[l].children[1].children[0].checked;
              if(valorreal == false){
                valorreal = 'N';
              } else {
                valorreal = 'S';
              }
            }

            if(valorreal == 'off'){ valorreal = 'S' }
            if(valorreal != encodeURIComponent(lis[l].getAttribute('data-default'))){
              count = count+1;
              ajax('fly', 'save_prop', 'prm_prop='+lis[l].getAttribute('data-prop')+'&prm_valor='+valorreal+'&prm_objeto='+draft+objeto+'&prm_url_default=&prm_screen='+tela, 'true');
              lis[l].setAttribute('data-default', valorreal);
            }
            //}
          }
        }
      }
    }
    if(count > 0){ alerta('feed-fixo', TR_AL); }
  break;

    case 'saveprop_chart': 
      var transf = document.getElementsByClassName('array_transf'); 
      var nomes = document.getElementsByClassName('array_nomes'); 
      var x = ''; 
      for(let i=0;i<transf.length;i++){ 
        x = x+'x='+transf[i].value+'&' 
      } 
      var y = ''; 
      for(let i=0;i<nomes.length;i++){ 
        y = y+'y='+nomes[i].value+'&' 
      } 
      y = y.slice(0, -1); 
      x = x.slice(0, -1); 
      objeto = document.getElementById('obj').getAttribute('value'); 
      ajax('fly', 'save_prop', y+'&'+x+'&prm_objeto='+objeto+'&prm_url_default=&prm_screen='+tela, 'true'); 
      curtain(); 
      shscr(tela); 
      alerta('feed-fixo', TR_AL);
    break;

    case 'savepa': 
      if(!document.getElementById('fakelist').classList.contains('visible')){ 
        var y = new Array(); 
        var a = 0; 
        var noh = document.getElementById('savepa').elements; 
        for(let i=0;i<noh.length;i++){ 
          if(noh[i].getAttribute('class')){ 
            if(noh[i].value=='on'){ 
              if(noh[i].checked===false){ 
                noh[i].value='off'; 
              }
            } 
            if(noh[i].value=='off'){ 
              if(noh[i].checked=='true'){ 
                noh[i].value='off'; 
              }
            } 
            y[a] = noh[i]; 
            a++; 
          }
        } 
        for(let i=0;i<y.length;i++){
          if(i == 0){ 
            var url = y[i].getAttribute('class')+'='+y[i].value; 
          } else { 
            if(y[i].className == 'p_nm_ponto'){ 
              url = url+ '&'+y[i].getAttribute('class')+'='+encodeURIComponent(y[i].value); 
            } else { 
              url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; 
            } 
          }
        } 
        if(document.getElementsByClassName('p_cd_ponto')[0].value.length > 1){ 
          if(document.getElementsByClassName('p_nm_ponto')[0].value.length > 0){ 
            ajax('fly', 'savepa', url+'&fakeoption='+document.getElementById('fake_grupo').title, false); 
            if(error == 'false'){ 
              objeto = document.getElementsByClassName('p_cd_ponto')[0].getAttribute('value'); 
              if(document.getElementById('titulo').innerHTML=='Ponto de avaliação'){ 
                alerta('feed-fixo', TR_CR); 
              } else { 
                alerta('feed-fixo', TR_AL); 
              } 
            } 
          } else { 
            alerta('msg', TR_DS_IN); 
          }
        } else { 
          alerta('msg', TR_NM_LE); 
        }
}
    break;

    case 'saveap':
     
      var y = new Array; 
      var w = 0; 
      var noh = document.getElementById('saveap').elements; 
      for(let i=0;i<noh.length;i++){ 
        if(noh[i].getAttribute('class')){ 
          if(noh[i].value=='on'){ 
            if(noh[i].checked===false){ noh[i].value='off'; }
          } 
          if(noh[i].value=='off'){ 
            if(noh[i].checked=='true'){ noh[i].value='off'; }
          } 
          y[w] = noh[i]; 
          w++; 
        }
      } 
      for(let i=0;i<y.length;i++){
        if(i == 0){ 
          url = y[i].getAttribute('class')+'='+y[i].value; 
        } else { 
          if(y[i].className == 'p_nm_objeto' || y[i].className == 'p_atributos' || y[i].className == 'p_sub_objeto'){ 
            url = url+ '&'+y[i].getAttribute('class')+'='+encodeURIComponent(y[i].value); 
          } else { 
            url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; 
          }
        }
      } 
      var objeto = document.getElementsByClassName('p_cd_objeto')[0].value; 
      var nome = document.getElementsByClassName('p_nm_objeto')[0].value; 
      if(document.getElementById(objeto)){ 
        obj = document.getElementById(objeto); 
        topo = obj.offsetTop; 
        left = obj.offsetLeft; 
      } 
      if(objeto.trim().length > 1){ 
        if(nome.trim().length > 1){ 
          if(document.getElementById('fake_atributo')){ 
            ajax('fly', 'savegd', url+'&p_atributos='+document.getElementById('fake_atributo').title+'&fakeoption='+document.getElementById('fake_grupo').title, 'true'); 
          } else { 
            ajax('fly', 'savegd', url+'&fakeoption='+document.getElementById('fake_grupo').title, 'true'); 
          }; 
          alerta('feed-fixo',TR_AL); 
        } else { 
          alerta('msg', TR_NM_LE); 
        } 
      } else { 
        alerta('msg', TR_NM_LE); 
      };
    
    
    break;

    case 'savecd': var y = new Array(); var a = 0; var noh = document.getElementById('savemvi').elements; for(let i=0;i<noh.length;i++){ if(noh[i].getAttribute('class')){ y[a] = noh[i]; a++; }} for(let i=0;i<y.length;i++){if(i == 0){ url = y[i].getAttribute('class')+'='+y[i].value; } else { url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; }} if((y[1].value).trim().length < 4){ alerta('msg', TR_NM_LE); } else { ajax('fly', 'savecd', url); alerta('msg', TR_AD); };
    break;

    case 'savecall': document.getElementById('fechar_sup').setAttribute('data-reloado', 'false'); var y = new Array; var w = 0; var noh = document.getElementById('saveap').elements; for(let i=0;i<noh.length;i++){ if(noh[i].getAttribute('class')){ if(noh[i].value=='on'){ if(noh[i].checked===false){ noh[i].value='off'; }} if(noh[i].value=='off'){ if(noh[i].checked=='true'){ noh[i].value='off'; }} y[w] = noh[i]; w++; }} for(let i=0;i<y.length;i++){if(i == 0){ url = y[i].getAttribute('class')+'='+y[i].value; } else { if(y[i].className == 'p_nm_objeto'){ url = url+ '&'+y[i].getAttribute('class')+'='+encodeURIComponent(y[i].value); } else { url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; } }} objeto = document.getElementsByClassName('p_cd_objeto')[0].value; nome = document.getElementsByClassName('p_nm_objeto')[0].value; if(objeto.trim().length > 1){ if(nome.trim().length > 1){ if(document.getElementById('fake_grupo')){ ajax('fly', 'savecallist', url+'&fakeoption='+document.getElementById('fake_grupo').title); alerta('feed-fixo', TR_AL); } } else { alerta('msg', TR_NM_LE); } } else { alerta('msg', TR_NM_LE); }
    break;

    case 'savesin': if(document.getElementById('savemvi')){ var y = new Array(); var a = 0; var noh = document.getElementById('savemvi').elements; for(let i=0;i<noh.length;i++){ if(noh[i].getAttribute('class')){ y[a] = noh[i]; a++; }} for(let i=0;i<y.length;i++){if(i == 0){ url = y[i].getAttribute('class')+'='+y[i].value; } else { url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; }} if((y[1].value).trim().length < 4){ alerta('msg', TR_NM_LE); } else { if((y[2].value).trim().length < 4){ alerta('msg', TR_DS_LE); } else { ajax('fly', 'savesign', url); if(error == 'false'){ alerta('msg', TR_AL); } }}} else { alerta('msg', TR_ES); };
    break;

    case 'savevp': if(document.getElementById('savevp')){ var y = new Array(); var a = 0; var noh = document.getElementById('savevp').elements; for(let i=0;i<noh.length;i++){ if(noh[i].getAttribute('class')){ y[a] = noh[i]; a++; }} for(let i=0;i<y.length;i++){if(i == 0){ url = y[i].getAttribute('class')+'='+y[i].value; } else { url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; }} if((y[1].value).trim().length < 4){ alerta('msg', TR_NM_LE); } else { ajax('fly', 'savevp', url); alerta('msg', TR_AD); }} else { alerta('msg', TR_ES); };
    break;

    case 'savescr': var y = new Array(); var a = 0; var noh = document.getElementById('saveap').elements;
    
    for(let i=0;i<noh.length;i++){
      if(noh[i].getAttribute('class')){
        y[a] = noh[i]; a++;
      }
    }
    
    for(let i=0;i<y.length;i++){
      if(i == 0){
        url = y[i].getAttribute('class')+'='+y[i].value;
      } else {
        if(!y[i].classList.contains('REPEAT') && !y[i].classList.contains('IMG_POS') && !y[i].classList.contains('IMG_SIZE')){
          url = url+ '&'+y[i].className+'='+encodeURIComponent(y[i].value);
        } else {
          ajax('fly', 'alter_attrib', 'prm_objeto='+tela+'&prm_prop='+y[i].getAttribute('class')+'&prm_value='+encodeURIComponent(y[i].value), true);
        }
      }
    }
    PRINCP.parentNode.style.setProperty('background-color', y[6].value);
    PRINCP.style.setProperty('background-image', 'url('+y[7].value+')');
    PRINCP.style.setProperty('background-position', y[8].value);
    PRINCP.style.setProperty('background-size', y[9].value);
    PRINCP.style.setProperty('background-repeat', y[10].value);

    if((y[1].value).trim().length < 4){
      alerta('msg', TR_NM_LE);
    } else {
      if((y[3].value).trim().length < 4){
        alerta('msg', TR_DS_LE);
      } else {
        if((document.getElementById('fake_grupo').title).trim().length < 1){
          alerta('msg', TR_ES_gr);
        } else {
          ajax('fly', 'savescr', url+'&p_grupof='+document.getElementById('fake_grupo').title);
          if(error == 'false'){ 
            curtain(); 
            alerta('feed-fixo', TR_AL); 
            ajax('list', 'screen_list', '', true, 'floatops'); 
            document.getElementById('floatops').selectedIndex = -1; 
          }
        }
      }
    };
    break;

    case 'savepar': 
      var transf = document.getElementsByClassName('array_transf'); 
      var nomes = document.getElementsByClassName('array_nomes'); 
      var x = ''; 
      
      for(let i=0;i<transf.length;i++){ 
        x = x+'x='+encodeURIComponent(transf[i].value)+'&' 
      } 

      var y = ''; 
      
      for(let i=0;i<nomes.length;i++){ 
        y = y+'y='+nomes[i].value+'&'; 
      } 

      y = y.slice(0, -1); 
      x = x.slice(0, -1); 
      ajax('fly', 'save_par', y+'&'+x, '', 'false'); 
      curtain(); 
      carrega('ajscreen?prm_screen='+tela); 
      alerta('feed-fixo', TR_AL);
    break;

    case 'consulta': 
      var erros = document.getElementById('painel').querySelectorAll('.error').length;
      if(erros == 0){ 
        var visao = document.getElementById('prm_visao').value; 
        var nome = document.getElementById('prm_objeto').value; 
        
        if(document.getElementById('nome_consulta')){ 
          var desc = document.getElementById('nome_consulta').value; 
        } else { 
          var desc = ''; 
        } 
        
        if(document.getElementById('agrupamento_consulta')){ 
          var rp = document.getElementById('agrupamento_consulta').value; 
        } else { 
          var rp = ''; 
        }

        if(document.getElementById('grupo_consulta')){ 
          var grupo = document.getElementById('grupo_consulta').value; 
        } else { 
          var grupo = ''; 
        }

        var coluna = ''; 
        colunas = document.getElementById('coluna').querySelectorAll('.linha'); 
        //if(colunas.length > 0){ 
          for(let i=colunas.length-1;i>-1;i--){ 
            coluna = colunas[i].title+'|'+coluna; 
          } 
          var colup = ''; 
          var colups = document.getElementById('colunas').querySelectorAll('.linha'); 
          for(let i=colups.length-1;i>-1;i--){ 
            colup = colups[i].title+'|'+colup; 
          } 
          var agrupador = ''; 
          var agrupadores = document.getElementById('colunac').querySelectorAll('.linha'); 
          //if(agrupadores.length > 0){ 
            for(let i=agrupadores.length-1;i>-1;i--){ 
              agrupador = agrupadores[i].title+'|'+agrupador; 
            } 
            coluna = coluna.substr(0, coluna.length -1); 
            colup = colup.substr(0, colup.length -1); 
            agrupador = agrupador.substr(0, agrupador.length -1); 
            ajax('fly', 'save_consulta', 'prm_visao='+visao+'&prm_nome='+encodeURIComponent(nome)+'&prm_desc='+encodeURIComponent(desc)+'&prm_coluna='+coluna+'&prm_colup='+colup+'&prm_agrupador='+agrupador+'&prm_grupo='+grupo+'&prm_rp='+rp, false); 
            ajax('fly', 'alter_ordem_geral', 'prm_valor=1&prm_objeto='+nome); 
            if(document.getElementById('fake_grupo')){ 
              noerror('', TR_CR, 'msg'); 
            } else { 
              noerror('', TR_AL, 'msg'); 
            }  
            if(document.getElementById(nome+'trl')){   
              remover(nome+'trl'); 
              reload(nome+'trl'); 
            } else { 
              reload(nome); 
            } 

      } else { 
        alerta('msg', TR_ID); 
      };
    break;

    case 'browser': 
      var y = new Array(); 
      var a = 0; 
      var noh = document.getElementById('browseredit').children; 
      
      for(let i=0;i<noh.length;i++){ 
        if(noh[i].getAttribute('class')){ y[a] = noh[i]; a++; }
      } 
      
      for(let i=0;i<y.length;i++){
        if(i == 0){ url = y[i].getAttribute('class')+'='+y[i].value; } else { url = url+ '&'+y[i].getAttribute('class')+'='+y[i].value; }
      } 
      
      if((y[1].value).trim().length < 3){ 
        alerta('msg', TR_NM_LE); 
      } else { 
        ajax('fly', 'browserEditLine', url); 
        alerta('msg', TR_AD); 
      }
    break;


default: document.getElementById('fakelist').setAttribute('class', '');
  }
}

function blocoConsulta(dis, bloco){
  dis.style.setProperty('display', 'none'); 
  var bloco = document.getElementById(bloco); 
  var li = document.createElement('li'); 
  var span = document.createElement('span'); 
  span.innerHTML = 'X'; 
  li.className = 'linha'; 
  li.title = dis.title; 
  li.innerHTML = dis.innerHTML; 
  li.appendChild(span); 
  li.setAttribute('onclick', 'swapColumn(this)'); 
  bloco.appendChild(li); 
  var square = document.createElement('li'); 
  square.className = 'square'; 
  square.setAttribute('onclick', 'swapSquare(this)'); 
  bloco.appendChild(square);
}
  
function resizeBrowser(self, obj){
  var parente = self.parentNode; 
  if(parente.clientHeight != parente.getAttribute('data-height')){ 
    ajax('fly', 'alter_attrib', 'prm_objeto='+obj+'&prm_prop=ALTURA&prm_value='+parente.clientHeight+'&prm_usuario='+USUARIO, true); 
  } 
  if(parente.clientWidth != parente.getAttribute('data-width')){ 
    ajax('fly', 'alter_attrib', 'prm_objeto='+obj+'&prm_prop=LARGURA&prm_value='+parente.clientWidth+'&prm_usuario='+USUARIO, true); 
  }
}

function showtag(temp, obj, cell, value, values, linha, pivot){

  if(document.getElementById(obj)){ 
    var delfit = document.getElementById(obj); 
    delfit.parentNode.removeChild(delfit); 
  }

  if(document.getElementById("jumpdrill")){
    var delfit = document.getElementById("jumpdrill");
    delfit.parentNode.removeChild(delfit);
  }
  
  var div = document.createElement('div');
  div.setAttribute("id", "jumpdrill");
  div.setAttribute("name", cell);
  div.setAttribute("class", value);
  div.setAttribute("data-multi", values);
  div.setAttribute("data-linha", linha);

  //verificar depois
  if(document.querySelector('.info').innerHTML.indexOf('DWU') != -1){
    div.setAttribute("title", document.getElementById('drill_go').value);
  }

  var datafiltro = '';

  if(document.getElementById('par_'+obj.replace('sdrill_', ''))){
    datafiltro = document.getElementById('par_'+obj.replace('sdrill_', '')).value;
  }
  div.setAttribute("data-pivot", pivot);
  div.setAttribute("data-filtro", datafiltro);
  MAIN.appendChild(div);
}

// Descontinuado - não identificado rotina que executa essa função 
function showview(valor){
      //var valor = document.getElementById(valor).getAttribute('data-valor');
    valor = valor.split('|');
    var param = '';

    for(let i=0;i<valor.length-6;i++){
        if(valor[i+6]){
            if(i==0){
                param = check_value(valor[i+6]);
            } else {
                param = param+check_value(valor[i+6]);
            }
        }
    }

    param = encodeURIComponent(param).replace(/\'/g, "%27");

    removeTrash();

    if(document.getElementById(valor[0]+'trl')){    
        if(document.getElementById(valor[3]).className != 'dragme grafico scaled' ){
            loading();
            LAYER.className = 'ativo';
            remover(valor[0]+'trl');
            document.getElementById('drill_obj').value=valor[0];
            appendar('prm_drill=Y&prm_objeto='+valor[0]+'&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_zindex=&prm_parametros='+check_value(valor[1])+check_value(valor[2])+check_value(valor[5])+param+'&prm_screen='+valor[4]+'&prm_track='+valor[0]+'&prm_objeton='+valor[0], 'in');
            setTimeout(function(){
          centerDrill(valor[0]);
        var ciclo = setInterval(function(){
            if(document.getElementById(valor[0])){
              carrega('ajobjeto?prm_objeto='+valor[0]);
            clearInterval(ciclo);
          }
          if(document.getElementById(valor[0]+'trl')){ clearInterval(ciclo); }
        }, 100);
      }, 500);
        }
    } else {
        if(document.getElementById(valor[3]).className != 'dragme grafico scaled' ){
            loading();
            document.getElementById('drill_obj').value=valor[0];
            appendar('prm_drill=Y&prm_objeto='+valor[0]+'&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_zindex=&prm_parametros='+valor[1]+check_value(valor[2])+check_value(valor[5])+param+'&prm_screen='+valor[4]+'&prm_track='+valor[0]+'&prm_objeton='+valor[0], 'in');
            setTimeout(function(){
          centerDrill(valor[0]);
        ciclo = setInterval(function(){
            if(document.getElementById(valor[0])){
              carrega('ajobjeto?prm_objeto='+valor[0]);
            clearInterval(ciclo);
          }
          if(document.getElementById(valor[0]+'trl')){ clearInterval(ciclo); }
        }, 100);
      }, 500);
        } else { return false; }
    }
}

// Descontinuado - não identificado rotina que executa essa função 
function showview2(objeto){
    var objeto = document.getElementById(objeto).getAttribute('data-valor');
    //tag +1 objeto
    var valor = objeto.split("|");
    var param = '';
    for(let i=0;i<valor.length-1;i++){
        if(valor[i+1]){
            if(i == 0){
                param = valor[i+1];
            } else {
                param = param+check_value(valor[i+1]);
            }
        }
    }

    param = encodeURIComponent(param).replace(/\'/g, "%27");

    if(param.charAt(0) === '|'){ param = param.substr(1); }
    if(document.getElementById(valor[0]).className != 'dragme grafico scaled' ){
        removeTrash()
        remover(valor[0]+'trl');
        if(document.getElementById("jumpdrill")) { var delfit=document.getElementById("jumpdrill"); delfit.parentNode.removeChild(delfit); }
        showtag('drill_show','sdrill_'+valor[0], '', param, param, param, '');
        ajax('list', 'load_drill', 'prm_objeto='+valor[0]+'trl&prm_parametros='+encodeURIComponent(param)+'&prm_track='+param+'&prm_objeton='+param, false, 'jumpdrill');
        jumpdrill.setAttribute('style', 'top:'+(cursory+3)+'px; left:'+(cursorx)+'px;');
        setTimeout(function(){ jumpdrill.style.setProperty('opacity', '1'); jumpdrill.style.setProperty('margin-top', '0'); }, 100);
    }
}

// Descontinuado - não identificado rotina que executa essa função 
function showview3(objeto){

    loading();
    var valor = objeto.split('||')[0].split('|');
    var param = objeto.split('||')[1];

    /*continuar aqui, rever intervalo do carregar e appendar */
    if(!valor[2]){
      if(!valor[3]){
        remover(valor[1]+'trl');   
        call('show_objeto', 'prm_drill=Y&prm_objeto='+valor[1]+'&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_zindex=&prm_parametros='+encodeURIComponent(param)+'&prm_screen='+tela+'&prm_track='+valor[0]+'&prm_objeton='+valor[0], 'obj').then(function(resposta){
          
          var div = document.createElement('div');
          div.innerHTML = resposta;
          div.children[0].style.setProperty('opacity', '0');
          MAIN.appendChild(div.children[0]);
          //div.children[0].style.setProperty('opacity', '0');
        }).then(function(){
          //setTimeout(function(){
            //ciclo = setInterval(function(){
              if(document.getElementById(valor[1])){
                carrega('ajobjeto?prm_objeto='+valor[1]);
                centerDrill(valor[1]);
                eventos(document.getElementById(valor[1]));
                ajustar(valor[1]);
                setTimeout(function(){
                  document.getElementById(valor[1]).style.setProperty('opacity', '1');
                  //loading();
                }, 100);
                //clearInterval(ciclo);
              }
              if(document.getElementById(valor[1]+'trl')){   
                carrega('ajobjeto?prm_objeto='+valor[1]+'trl');
                centerDrill(valor[1]+'trl');
                eventos(document.getElementById(valor[1]+'trl'));
                ajustar(valor[1]+'trl');
                setTimeout(function(){
                  document.getElementById(valor[1]+'trl').style.setProperty('opacity', '1');
                  //loading();
                }, 100);
                //clearInterval(ciclo);
              }
            //}, 100);
          //}, 500);
        });
      }
    } else {
      remover(valor[1]+'trl');
      call('show_objeto', 'prm_drill=Y&prm_objeto='+valor[1]+'&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_zindex=&prm_parametros='+encodeURIComponent(param)+'&prm_screen='+tela+'&prm_track='+valor[0]+'&prm_objeton='+valor[0], 'obj').then(function(resposta){
          var div = document.createElement('div');
          div.innerHTML = resposta;
          div.children[0].style.setProperty('opacity', '0');
          MAIN.appendChild(div.children[0]);
          
      }).then(function(){
        //setTimeout(function(){
          //ciclo = setInterval(function(){
            if(document.getElementById(valor[1])){
              carrega('ajobjeto?prm_objeto='+valor[1]);
              centerDrill(valor[1]);
              eventos(document.getElementById(valor[1]));
              ajustar(valor[1]);
              setTimeout(function(){
                document.getElementById(valor[1]).style.setProperty('opacity', '1');
                //loading();
              }, 100);
              //clearInterval(ciclo);
            }
            if(document.getElementById(valor[1]+'trl')){
              carrega('ajobjeto?prm_objeto='+valor[1]+'trl');
              centerDrill(valor[1]+'trl');
              eventos(document.getElementById(valor[1]+'trl'));
              ajustar(valor[1]+'trl');
              setTimeout(function(){
                document.getElementById(valor[1]+'trl').style.setProperty('opacity', '1');
                //loading();
              }, 100);
              //clearInterval(ciclo);
            }
          //}, 100);
        //}, 500);
      });
    }
    setTimeout(function(){
      loading();
    }, 100);
}

// Descontinuado - não identificado rotina que executa essa função 
function showview4(objeto){
 
  if(objeto.split("|").length > 2){
    if(objeto.indexOf('||') != -1){
      var param = objeto.split("||")[1];
      var valor = objeto.split("||")[0].split("|");
    } else {
      var param = '';
      var valor = objeto.split("|");
    }
    
    if(param.charAt(0) === '|'){ param = param.substr(1); }
    removeTrash();
    remover(valor[0]+'trl');     
    if(document.getElementById("jumpdrill")){ 
      var delfit = document.getElementById("jumpdrill"); 
      delfit.parentNode.removeChild(delfit); 
    }
    showtag('drill_show','sdrill_'+valor[0], '', param, param, param, '');
    ajax('list', 'load_drill', 'prm_objeto='+valor[0]+'trl&prm_parametros='+encodeURIComponent(param)+'&prm_track='+param+'&prm_objeton='+param, false, 'jumpdrill');
    jumpdrill.setAttribute('style', 'top:'+(cursory+3)+'px; left:'+(cursorx)+'px;');
    setTimeout(function(){ 
      jumpdrill.style.setProperty('opacity', '1'); 
      jumpdrill.style.setProperty('margin-top', '0'); 
    }, 100);
  }
}

// Descontinuado - não identificado rotina que executa essa função 
function showview_org(node){
  var no = node[0];
  if(no.getAttribute('data-goto').length > 1){
    loading();
    var valor = no.getAttribute('data-goto').split('|');
    removeTrash()
    remover(valor[0]+'trl');   
    remover(valor[0]);
    var param = '';
    for(let i=0;i<valor.length-1;i++){
      if(valor[i+1]){
        if(i == 0){
          param = valor[i+1];
        } else {
          param = param+'|'+valor[i+1];
        }
      }
    }
    appendar('prm_drill=Y&prm_objeto='+valor[0]+'&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_zindex=&prm_parametros=1|1|qb_depto|'+no.id+'|'+param+'&prm_screen='+tela+'&prm_track=qb_depto&prm_objeton=departamento', 'in');
    ajustaIframe(valor[0]+'trl');
    centerDrill(valor[0]);
    carrega('ajobjeto?prm_objeto='+valor[0]);
  }
}

// Monta parametros para a DRILL e abre a ela de DRILL 
function check_tag(event, obj, coluna, linha, pivot, actual){

  if(get(obj).className.indexOf('scaled') == -1){

    // Monta os parametros que serão repassados para a DRILL 
    var pivot = pivot || '';
    var pos;
    var colunas = '';
    var linhas  = linha;
    var objeto  = get(obj);
    var arr = [];
    var selecionados = objeto.querySelectorAll('.tdselected');
    var selecionadosl = selecionados.length;
    var marcados  = objeto.querySelectorAll('.checked');
    var marcadosl = marcados.length;
    
    if(actual.parentNode.className == 'fixed'){
      pos = actual.parentNode.getAttribute('data-i');
    } else {
      pos = actual.getAttribute('data-i');
    }

    for(let i=0;i<selecionadosl;i++){
      arr.push(selecionados[i].getAttribute('data-valor'));
    }
    colunas = arr.filter(e => e).join('|');
    
    arr = [];
    for(let t=0;t<marcadosl;t++){
      arr.push(marcados[t].getAttribute('data-valor'))
    }


    if(arr.length > 0){
      linhas = arr.filter(e => e).join('|');
    }

    let parArr = [];
    parArr.push(linhas);
    parArr.push(pivot);

    document.getElementById('drill_go').value = parArr.filter(e => e).join('|');   // Grava os parametros no elemento DRILL_GO que será utilizado na abertura da Drill 

    var drill = true;
    
    if(actual.parentNode.getAttribute('data-drill')){
      if(actual.parentNode.getAttribute('data-drill') != 'S'){
        drill = false;
      }
    } 

    if(actual.parentNode.classList.contains('duplicado')){
      drill = false;
    }


    var dados = document.getElementById('dados_'+obj);
    if (dados) { 
      let data_drill = dados.getAttribute('data-drill');
      if (data_drill) { 
        if (data_drill == 'C') { 
          drill = false;
        }
      }
    } 

    var elemento = event.target;
    if (elemento.tagName == 'path' || elemento.tagName == 'circle' || elemento.tagName == 'polygon' || elemento.tagName == 'svg') {        // Se o elemento clicado é o link para mostrar a anotação 
      anotacao_show(event, obj);
    } else {  
      if(drill){   // Abre tela para seleção de drills 
        drillfix(event, obj);
      }
    }  
  }
}

function check_value(x){
    if(typeof x !== "undefined"){
        if(x.trim.length == 0){
            return '';
        } else {
            return ('|'+x).replace('||', '|');
        }
    } else {
        return ('');
    }
}

var sobbar = '';
var checklayer = '';
var activeshow = '';

var conteudo = '';

function shscr(screen, anterior, parametros, origem){
  //window.status = '';

  var filtroAberto = document.querySelectorAll('.filtro.show');

  for(let f=0;f<filtroAberto.length;f++){
    filtroAberto[f].classList.remove('show');
    filtroAberto[f].classList.add('hidden');
    filtroAberto[f].setAttribute('data-desc', '');
  }



  if(document.getElementById('popupmenu')){
    var menu = document.getElementById('popupmenu');
    if(menu.classList.contains('visible')){
      menu.classList.remove('visible');
      menu.innerHTML = '';
    }
  }
  
  if(document.getElementById('search-mobile')){
    var pmobile = document.getElementById('search-mobile');
    if(screen != 'DEFAULT'){
      pmobile.classList.remove('invisible');
    } else {
      pmobile.classList.add('invisible');
    }
  }  

  //cor de fundo, background
  if( get('screen-props')){
    get('screen-props').innerHTML = '';
  }
  var estilo = document.createElement('style');

  /*MAIN.style.setProperty('background-color', ''); 
  MAIN.style.setProperty('background-image', ''); */

  if(parseInt(document.getElementById('layer3').style.getPropertyValue("height")) > 0){
    PRINCP.style.setProperty("overflow", "visible");
    PRINCP.style.removeProperty("height");
    document.getElementById('html').style.setProperty("overflow", "visible");
    document.getElementById('layer3').style.setProperty("height", "0");
    document.getElementById('prev').style.setProperty("display", "none");
    document.getElementById('next').style.setProperty("display", "none");
  }
  
  clearInterval(checklayer);
  loaded();

  if(!LAYER.classList.contains('ativo')){

    //try {
    var origemvar = origem || 'UPQUERY';
  
    if(document.getElementById('atu_view')){
      var menu = document.getElementById('atu_view');
      if(menu.classList.contains('invisible')){
        menu.classList.remove('invisible');
      }
    }
    

    if(origemvar != 'UPQUERY'){
      document.getElementById('menup').classList.add('invisible');
      MAIN.style.setProperty('padding-top', '0');
      LAYER.style.setProperty('top', '0');
      LAYER.style.setProperty('height', '100%');
    } else {
      if(document.getElementById('menup')){
        document.getElementById('menup').classList.remove('invisible');
        MAIN.style.setProperty('padding-top', '');
        LAYER.style.setProperty('top', '35');
        LAYER.style.setProperty('height', 'calc(100% - 35px)');
      }
    }
    //call('check_screen_access', 'prm_screen='+screen).then(function(resposta){ 
      //if((parseInt(resposta) > 0 || screen.indexOf('DEFAULT') != -1) && (resposta.indexOf('imposs') == -1)){
        document.getElementById('attriblist').classList.remove('open');
        document.getElementById('floatlist').classList.remove('open');
        document.getElementById('donut').classList.remove('open');
        curtain('x');
        clearInterval(refresh_timer);
        document.getElementById('fakelist').classList.remove('visible');
        zindex_abs = 5;
        clearInterval(textTalk);
        /*document.getElementById('menubutton').className = 'open';*/
        /*if(document.getElementById('menup')){ document.getElementById('menup').className = 'closed'; }*/

        if(document.getElementById('show_only_screen')){
          MAIN.style.setProperty('padding-top', '6px');
        }

        if(document.getElementById('call-menu')){
          var menu = document.getElementById('call-menu');
          menu.classList.add('invisible');
          call('obj_screen_count', 'prm_screen='+screen+'&prm_tipo=CALL_LIST').then(function(resposta){
            if(parseInt(resposta) > 0){
              menu.classList.remove('invisible');
            } else {
              menu.classList.add('invisible');
            }
          });  
        }

        if(document.getElementById('float-filter')){
          var float = document.getElementById('float-filter');
          float.classList.add('invisible');

          if(!document.getElementById('show_only_screen')){
            call('obj_screen_count', 'prm_screen='+screen+'&prm_tipo=FLOAT').then(function(resposta){
              if(parseInt(resposta) > 0){
                float.classList.remove('invisible');
              } else {
                float.classList.add('invisible');
              }
            });
          }
        }
        
        // Alterado para sempre mostrar o icone FAVORITOS (foi adicionada as telas favoritas nesse icone)
        //if(document.getElementById('favoritos')){
        //  var favoritos = document.getElementById('favoritos');
        //  favoritos.classList.add('invisible');
        //  call('obj_screen_count', 'prm_screen='+screen+'&prm_tipo=FAVORITOS').then(function(resposta){
        //    if(parseInt(resposta) > 0){
        //      favoritos.classList.remove('invisible');
        //    } else {
        //      favoritos.classList.add('invisible');
        //    }
        //  });
        //}

        clearInterval(checkscreen);
        clearInterval(loopscreen);
        
        if(document.getElementById('show_only_bar')){
          clearInterval(sobbar);
          document.getElementById('show_only_bar').style.setProperty('width', 0);
        }

        document.getElementById('filterlist').className = 'filtro hidden';
        
        var ascreen = document.getElementById('current_screen');
        
        loading('x');

        document.getElementById('text-talk').className = '';
        
       

        var child0 = PRINCP.children[0];
        
        if(child0.className == 'calendar-box'){ 
          child0.style.setProperty('display', 'none'); 
        }
        
        if(document.getElementById('timer')){
          var tim = document.getElementById('timer');
          tim.parentNode.removeChild(tim);
        }
        
        //setTimeout(function(){
            removeTrash();
            document.getElementById('main-ext').innerHTML = '';
            while(MAIN.firstChild){
              MAIN.removeChild(MAIN.firstChild);
            }

            tela = screen.replace(' ', '_').trim();

            if(typeof anterior !== "undefined"){

              call('show_screen', 'prm_screen='+screen+'&prm_screen_ant='+anterior+'&prm_parametro='+parametros).then(function(resposta){
                if(resposta.indexOf('LOGOUT') != -1){
                  logout(); 
                  return;
                }
                
                MAIN.innerHTML = resposta;
                icarrega();
                if(MAIN.children[0]){
                  if(MAIN.children[0].id == 'data_list'){
                    ajustar(MAIN.children[0].className);
                  }
                }
              });
                
            } else {
                call('show_screen', 'prm_screen='+screen+'&prm_screen_ant=&prm_parametro=').then(function(resposta){
                  
                  if (resposta.indexOf('Usu&aacute;rio sem permiss&atilde;o de acesso a tela!')!= -1){
                    tela = 'DEFAULT';
                    call('alter_user','prm_nome='+USUARIO+'&prm_valor='+tela+'&prm_tipo=cd_tela_inicial').then(function(resposta2){
                      if (resposta2.split('|')[0] == 'OK'){                
                        setTimeout(function(){ 
                          window.location.reload(true);                        
                        }, 200);                       
                      }
                    })
                    
                  }
                  
                  main.innerHTML = resposta;
                  
                  icarrega();
                  if(main.children[0]){
                    if(main.children[0].id == 'data_list'){
                      ajustar(main.children[0].className);
                    }
                  }
							  });
                
            }

            ajaxExt(screen);

            ascreen.value = tela;
            clearInterval(timeout);
            if(ascreen.value != 'DEFAULT' && ascreen.value != 'SANDBOX'){
                //ajax('time', 'countdown', 'prm_screen='+ascreen.value, false);
                //if(countdown != 0){ var temporefresh = parseInt(countdown); timeout = setInterval(refreshTela, temporefresh); }
                var countdown;
                call('countdown', 'prm_screen='+ascreen.value).then(function(resposta){ 
                  countdown = resposta; 
                  if(countdown != 0){ 
                    var temporefresh = parseInt(countdown); timeout = setInterval(refreshTela, temporefresh); 
                  } 
                });
                
            }
            //if(document.getElementById('space-options')){ document.getElementById('space-options').nextElementSibling.className='border'; }
        //}, 1);

        var conta = 0;
         
    checklayer = setInterval(function(){
      if(layer.className != 'ativo'){ 
        clearInterval(checklayer); 
        loaded();
      }
      conta = conta+1;

      if(conta >= 500){
        clearInterval(checklayer);
      }
      
    }, 200);

    if(document.getElementById('tela-atual')){
      document.getElementById('tela-atual').innerHTML = '';
      //ajax('return', 'title_screen', 'prm_screen='+screen, false);
      //if(respostaAjax.trim().length > 0){ document.getElementById('tela-atual').innerHTML = respostaAjax.trim(); };
      call('title_screen', 'prm_screen='+screen).then(function(resposta){ 
        /*
        if(resposta.trim().length > 0){ 
          document.getElementById('tela-atual').innerHTML = resposta.split('</span>')[0].trim();
          //var asciiCharSeta = '\u2192';
          var asciiCharSeta = '>';
          var title = "UpQuery - " + resposta.split('</span>')[1].replace('|*|#02/2024#|*|', asciiCharSeta).split('<a title')[0];
          document.title = title;
        } 
        */
        call('title_screen', 'prm_screen='+screen).then(function(resposta){ 
          if(resposta.trim().length > 0){ 
            document.getElementById('tela-atual').innerHTML = resposta.split('<titulo_aba_navagedor>')[0].trim(); 
            var title = "UpQuery - " + resposta.split('<titulo_aba_navagedor>')[1].trim();
            document.title = title;
            } 
        });
               
      });
    }
        
    setTimeout(function(){
        if(MAIN.className.indexOf('usuario') != -1){
            ajax('input', 'check_data', 'prm_valor='+screen+'&prm_tabela=main&prm_true=usuario&prm_false=usuario row', true, 'main');
        } else {
            ajax('input', 'check_data', 'prm_valor='+screen+'&prm_tabela=main&prm_true=&prm_false=row', true, 'main');
        }
    }, 5);

    var back = document.getElementById('back');
        
    if(typeof anterior !== "undefined" && anterior.length > 0){
      back.className = 'visible';
      back.setAttribute('data-screen', anterior);
      ajax('list', 'screen_list', 'prm_objeto=', true, 'floatops');
      
    } else {
      back.className = 'invisible';
    }

  }
  
  
  if(ascreen){
    if(ascreen.value != 'DEFAULT'){
      call('background_attrib', 'prm_screen='+screen).then(function(resposta){
        let css = resposta;
        let cssRegular = css.split('|')[0];
        let cssBefore  = css.split('|')[1];
        estilo.innerHTML = 'div#main { '+cssRegular+' } div#main:before { '+cssBefore+' }';
        /*if(css.indexOf('EXT=') == -1){ 
          MAIN.setAttribute('style', css);
        } else { 
          MAIN.style.setProperty('background-image', 'none'); 
        } */
      });
    } else {
      setTimeout(function(){
        estilo.innerHTML = 'div#main:before { url(' + OWNER_BI + '.fcl.download?arquivo=bg.png); }';
      }, 1000);
    }
  }
  
  if( get('screen-props')){
    get('screen-props').appendChild(estilo);
  }

}

function refreshTela(){
  var drillaberto = document.querySelectorAll('.drill').length; 
  if(drillaberto == 0){ 
    shscr(tela); 
    curtain(); 
  }
}


//inutilizado?
function loaded(){
  clearTimeout(activeshow);
  var objetos = document.querySelectorAll('.dragme');
  var objetoslength = objetos.length;
  for(let i=0;i<objetoslength;i++){
    if(document.getElementById(objetos[i].id+'min')){
      var min = document.getElementById(objetos[i].id+'min');
      min.addEventListener('mouseup', function(){ 
        this.parentNode.querySelector('.espaco').classList.toggle('min'); 
      });
      min.addEventListener('touchend', function(){ 
        this.parentNode.querySelector('.espaco').classList.toggle('min'); 
      });
    }
            
    if(ADMIN == 'A'){
      var down, up;
      if(document.getElementById(objetos[i].id+'_ds') && document.getElementById(objetos[i].id).className.indexOf('float') == -1){
        var obj = objetos[i].id;
        var titulo = document.getElementById(obj+'_ds');
        if(PRINCP.className == 'mobile'){
          down = 'touchstart';
          up   = 'touchend'
        } else {
          down = 'mousedown';
          up   = 'mouseup';
        }
        titulo.addEventListener(down, function(){
          invisible_touch(this.parentNode.id, 'start');
        });
        titulo.addEventListener(up, function(){
          invisible_touch(this.parentNode.id, 'stop');
          if(up == 'touchend'){ 
            dblTouch(this.parentNode.id); 
          }
        });
        titulo.addEventListener('dblclick', function(){
          if(get('jumpdrill')){
            get('jumpdrill').remove();
          }
          curtain('');
          scale(this.id.replace('_ds', ''), 'direct');
        });
      }
    } else {
      if(document.getElementById(objetos[i].id+'_ds') && document.getElementById(objetos[i].id).className.indexOf('float') == -1){
        var obj = objetos[i].id;
        var titulo = document.getElementById(obj+'_ds');
        titulo.addEventListener('dblclick', function(){
          if(get('jumpdrill')){
            get('jumpdrill').remove();
          }
          curtain('');
          scale(this.id.replace('_ds', ''), 'direct');
        });
      }
    }
  }
        

  //show_only


  if((projecoes.length > 0) && (parseInt(document.getElementById('active-show').getAttribute('data-time'))>0)){

    var nextp = document.getElementById('active-show').nextElementSibling;

    if(nextp.className == 'show_only'){
      activeshow = setTimeout(function(){
        document.getElementById('active-show').id = '';
        nextp.id = 'active-show';
        removeTrash();
        shscr(nextp.value); 
      }, parseInt(document.getElementById('active-show').getAttribute('data-time')+'000')+1000 );
    } else {
      activeshow = setTimeout(function(){
        document.getElementById('active-show').id = '';
        projecoes[0].id = 'active-show';
        removeTrash();
        shscr(projecoes[0].value);
      }, parseInt(document.getElementById('active-show').getAttribute('data-time')+'000')+1000 );
    }

  }
}


function addLink(){
  if(document.getElementById('attriblist')){
    var calls = document.getElementById('attriblist').getElementsByTagName('LI');
    var callslength = calls.length;
    for(let c=0;c<callslength;c++){
      if(calls[c].className != 'SCRIPT'){
        calls[c].firstElementChild.removeEventListener('click', menuLink);
        calls[c].firstElementChild.addEventListener('click', menuLink);
      }
    }
  }
}

function changeScreen(){
  document.getElementById('floatops').blur();
  document.getElementById('donut').setAttribute('class','');
  var raiz = document.getElementById('html');
  var linha = document.getElementById('floatops').getElementsByTagName('option')[document.getElementById('floatops').selectedIndex];
  if(document.getElementById('prefdrop')){
      document.getElementById('prefdrop').className = 'hidden';
  }
  if(linha.value != 'X') {
    shscr(linha.value);
    if(linha.getAttribute('data-url').indexOf('EXT=') == -1){
      setTimeout(function(){
          raiz.style.setProperty('background-color', linha.getAttribute('data-bg'));
          MAIN.style.setProperty('background-repeat', linha.getAttribute('data-repeat'));
          MAIN.style.setProperty('background-position', linha.getAttribute('data-pos'));
          MAIN.style.setProperty('background-size', linha.getAttribute('data-size'));
          MAIN.style.setProperty('background-image','url('+linha.getAttribute('data-url')+')');
      }, 1000);
    } else {
      setTimeout(function(){
        raiz.style.setProperty('background-color', linha.getAttribute('data-bg'));
        MAIN.style.setProperty('background-repeat', linha.getAttribute('data-repeat'));
        MAIN.style.setProperty('background-position', linha.getAttribute('data-pos'));
        MAIN.style.setProperty('background-size', linha.getAttribute('data-size'));
        MAIN.style.setProperty('background-image','');
      }, 1000);
    }
  } else {
    document.getElementById('opcoes').className = 'closed';
  }
}

function fecharSup(){ 
  var ele = this;
  clearInterval(refresh_timer);
  document.getElementById("fakelist").setAttribute("data-campo", "");
  document.getElementById("fakelist").setAttribute("class", "");
  alerta("msg", "");
  curtain();

  setTimeout(function(){
    var recarregar = ele.getAttribute("data-reloado");
    if(recarregar != "false"){
      if(get(recarregar)){
        var obj = document.getElementById(recarregar);
        var esquerda = obj.offsetLeft+"px";
        var cima = obj.offsetTop;
        var pai = tela;
        if(window.getComputedStyle(obj).getPropertyValue('order')){
          dashorder = "&prm_dashboard=true";
          dashlocation = obj.parentNode.id;
          esquerda = window.getComputedStyle(obj).getPropertyValue('order');
          pai = obj.parentNode.id;
        }
        obj.remove();
        loading("");
        appendar('prm_objeto='+recarregar+'&PRM_ZINDEX=2&prm_posx='+esquerda+'&prm_posy='+cima+'px&prm_screen='+tela+dashorder, dashlocation, pai);
        setTimeout(function(){ carrega("ajobjeto?prm_objeto="+recarregar); }, 100);
      }
      ele.setAttribute("data-reloado", "false");
    }
    if(ele.getAttribute("data-reloads") != "false"){
      shscr(tela);
      ele.setAttribute("data-reloads", "false");
    }
  }, 200);
}

// -- Ação do botão de ativa e inativa o refresh 
function refreshSup(){ 
  if (refresh_param[3] == 'S') { 
    refreshSupStop();
  } else {  
    refreshSupStart();
  }
}

// -- Pausa o refresh da tela 
function refreshSupStop() { 
  refreshSupBtn('V');      // altera botão 
  clearInterval(refresh_timer);
}

// -- Inicia o refresh da tela 
function refreshSupStart() { 
  refreshSupBtn('A');       // altera botão 
  clearInterval(refresh_timer);
  ajax('list', refresh_param[0], refresh_param[1], true, 'content','','',refresh_param[2]);
  refresh_timer = setInterval( function () { {ajax('list', refresh_param[0], refresh_param[1], true, 'content','','',refresh_param[2]); }}, 5000);       
}

// -- Altera a situação do botão de refresh da tela superior, e altera a situação de ativo do refresh para S ou N 
function refreshSupBtn(situacao) {

  if (document.getElementById("refresh_sup")) { 

    document.getElementById("refresh_sup").style.display='none';  
    document.getElementById('refresh_sup').classList.remove('ativo'); 
    refresh_param[3] = 'N';       // refresh Intivo 

    if (situacao == 'V' || situacao == 'A') {  //Visivel ou Ativo 
      document.getElementById("refresh_sup").style.display='block';
      if (situacao == 'A') { //Ativo 
        document.getElementById('refresh_sup').classList.add('ativo'); 
        refresh_param[3] = 'S';   // refresh Ativo 
      }
    } 
  }
}


function backSup(){ 
  // Carrega a tela superior anterior
  if (telasup_ant.length != 0) { 
    let param = telasup_ant[telasup_ant.length-1].split('|')
    let cont_proc  = param[0], 
        cont_param = param[1], 
        cont_pkg   = param[2], 
        painel     = param[3];   
    telasup_ant.pop(); // Retira a tela do array das últimas 
    carregaTelasup(cont_proc, cont_param, cont_pkg, painel, '', '', '');  
  }
}


function fecharCustom(){ 
  //var ele = this;
  //clearInterval(refresh_timer);
  //document.getElementById("fakelist").setAttribute("data-campo", "");
  //document.getElementById("fakelist").setAttribute("class", "");
  alerta("msg", "");
  curtain_custom();
}


function activemap(objeto, altura, largura){
  try { var myMap = new FusionCharts ("Brazil", "mapid", largura, altura); } catch(err) { picx=0; };
  if(document.getElementById('gxml_'+objeto).children[0]){
    myMap.setXMLData(document.getElementById('gxml_'+objeto).innerHTML);
  } else {
    myMap.setXMLData(document.getElementById('gxml_'+objeto).value);
  }

  try { myMap.render('ctmr_'+objeto); } catch(err) { picx=0; }
  myMap.setChartAttribute( "stroke" , null );
}


function browserMenu(menu, ev){
  menu.classList.remove('open');
  document.getElementById('editb').innerHTML = '';
  var menuh = parseInt(window.getComputedStyle(document.getElementById('data_list_menu')).height);
  if(ev){
    setTimeout(function(){ menu.classList.add('open'); }, 100);
  }
}

function browserOrder(e){
  if(e.target.getAttribute('data-coluna')){ 
    if(e.target.classList.contains('selectedbheader')){ 
      if(e.target.classList.contains('desc')){ 
        e.target.classList.remove('desc'); 
        e.target.classList.remove('selectedbheader');
      } else { 
        e.target.classList.add('desc'); 
      } 
    } else { 
      e.target.classList.add('selectedbheader');
    }			
    browserSearch('BUSCA'); 
  }
}

var beta = {};

beta.browser = { acumulado: false };


function browserSearch(direcao, origem){
  if(document.querySelector('.selectedbheader')){
    var ordenadas = document.querySelectorAll('.selectedbheader');
    var ordemarr = [];
    var ordem;
    for(let i=0;i<ordenadas.length;i++){
      if(ordenadas[i].classList.contains('desc')){
        ordemarr.push(ordenadas[i].getAttribute('data-ordem')+' DESC'); 
      } else {
        ordemarr.push(ordenadas[i].getAttribute('data-ordem')); 
      }
    }
    ordem = ordemarr.join(',');
  } else {
    ordem = 1; 
  }

  var direcao = direcao || 'BUSCA';
  var origem  = origem  || '';
  
  if(!LAYER.classList.contains('ativo')){
    loading(); 
  }
    
  if(origem.length == 0){
    ajax('fly', 'alter_attrib', 'prm_objeto='+document.getElementById('data_list').className+'&prm_prop=DIRECTION&prm_value='+ordem+'&prm_usuario='+USUARIO, true);
  }
  
  if(!document.getElementById('browser-condicao').parentNode.classList.contains('ligacao') && 
     !document.getElementById('browser-condicao').parentNode.classList.contains('ligacaoc') && 
     !document.getElementById('browser-condicao').parentNode.classList.contains('listboxp') && 
     !document.getElementById('browser-condicao').parentNode.classList.contains('listboxt') &&
     !document.getElementById('browser-condicao').parentNode.classList.contains('listboxtd') &&
     !document.getElementById('browser-condicao').parentNode.classList.contains('listboxtcd')) {
    var valor = document.getElementById('data-valor').value;
  } else {
    var valor = document.getElementById('browser-condicao').nextElementSibling.title;
  }

  var micro_data = document.getElementById('data_list').getAttribute('data-tabela');
  var coluna     = document.getElementById('browser-coluna').value;
  var objeto     = document.getElementById('data_list').className;
  var chave      = document.getElementById('data-coluna').value;
  var condicao   = document.getElementById('browser-condicao').value;
  var limite     = document.getElementById('linhas').value;
  var buscatexto = document.getElementById('data-coluna').options[document.getElementById('data-coluna').selectedIndex].innerHTML;

  setTimeout(function(){
    
    //vpipe_par
    if(condicao == 'semelhante'){
      var pipecondicao = 'like';
    } else {
      var pipecondicao = condicao;
    }
    
    var acumulado   = '',
        foot_height = 0; 

    if(document.getElementById('multi-search')){
    
      var condicao_fun = '$['+pipecondicao.toUpperCase()+']';
      var titulo       = chave+'|'+condicao_fun+valor;
      var repetido     = false;
      var vazio        = false;
     
      
      if(!repetido){
        let filtro = document.createElement('span');
        if(condicao.indexOf('nulo') != -1){
          if(condicao.indexOf('nnulo') != -1){
            filtro.innerHTML = buscatexto+' não nulo';
          } else {
            filtro.innerHTML = buscatexto+' '+condicao.toLowerCase();
          }
        } else {
          
          if(valor.trim().length == 0){
            vazio = true;
          }

          /* voltado merge da 837d */ 
          if(condicao.indexOf('diferente') != -1){
            filtro.innerHTML = buscatexto+' '+condicao.toLowerCase()+' de '+valor;
          } else {
            if(condicao.indexOf('maior') != -1){
              filtro.innerHTML = buscatexto+' '+condicao.toLowerCase()+' que '+valor;
            } else {
              filtro.innerHTML = buscatexto+' '+condicao.toLowerCase()+' a '+valor;
            }   
          }    
          /****  voltado merge da 837d
          call('check_taux_bro', 'prm_objeto='+objeto+'&prm_tabela='+micro_data+'&prm_coluna='+chave+'&prm_valor='+valor,'bro').then(function(resposta){ 
           
            if (resposta.indexOf('erro') == -1){
    
              if(condicao.indexOf('diferente') != -1){
                filtro.innerHTML = buscatexto+' '+condicao.toLowerCase()+' de '+resposta;
              } else {
                if(condicao.indexOf('maior') != -1){
                  filtro.innerHTML = buscatexto+' '+condicao.toLowerCase()+' que '+resposta;
                } else {
                  filtro.innerHTML = buscatexto+' '+condicao.toLowerCase()+' a '+resposta;
                }
              }
            }
            
          });
          **************/ 

        }

        filtro.addEventListener('click', () => { 
          event.stopPropagation();
          if(confirm(TR_CE)){ 
            filtro.remove();
            setTimeout(function(){ 
              browserSearch('');
            }, 100);
          }
        });

        document.getElementById('data-valor').value = '';
        document.getElementById('data-valor').previousElementSibling.title = '';
        document.getElementById('data-valor').previousElementSibling.children[0].innerText = '';
        
        //cria a flag
        
        if(!vazio){
          filtro.title = titulo;
          filtro.classList.add('acumulado');
         
          document.getElementById('filtros-acumulados').appendChild(filtro);
        }
      }

      let acumularArr = [];

      document.querySelectorAll('.acumulado').forEach((valor) => { acumularArr.push(valor.title); });

      acumulado = acumularArr.join('|');
      
    }

    // Ajusta o tamanho da tela se tem filtro acumulado ou não 
    foot_height = 122;
    if (acumulado.length > 0) { 
      foot_height = foot_height + document.getElementById('filtros-acumulados').clientHeight + 12 ;   // 12 é margem top + margem bottom   
    }
    document.getElementById(objeto + 'dv2').style.setProperty('--foot-height', foot_height.toString()+'px');

    if(direcao == 'save'){
      direcao = '>';
      if(document.getElementById('ajax').firstElementChild){ 
        origem = parseInt(document.getElementById('ajax').firstElementChild.className)-1; 
      } else { 
        origem = 0; 
      }
    }
    
    ajax('list', 'dt_pagination', 'prm_micro_data='+micro_data+'&prm_coluna='+coluna+'&prm_objid='+objeto+'&prm_chave='+chave+'&prm_ordem='+ordem+'&prm_screen='+tela+'&prm_limite='+limite+'&prm_origem='+origem+'&prm_direcao='+direcao+'&prm_busca='+valor+'&prm_condicao='+condicao+'&prm_acumulado='+acumulado, false, 'ajax', '', '', 'bro'); 
    loading();
    
    document.getElementById('browser-page').innerHTML = '';
    call('get_total', 'prm_microdata='+micro_data+'&prm_objid='+objeto+'&prm_screen='+tela+'&prm_condicao='+condicao+'&prm_coluna='+coluna+'&prm_chave='+chave+'&prm_ordem='+ordem+'&prm_busca='+valor, 'bro').then(function(resposta){
      document.getElementById('browser-page').outerHTML = resposta;
    }).then(function(){
      var linhas = document.getElementById('linhas').value;
      if(document.getElementById('ajax').lastElementChild){
        var pagina = Math.ceil((parseInt(document.getElementById('ajax').lastElementChild.className)/linhas));
        var total  = Math.ceil((document.getElementById('browser-page').getAttribute('data-total')/linhas));
        document.getElementById('browser-page').setAttribute('data-pagina', pagina);
        document.getElementById('browser-page').innerHTML = pagina+'/'+total;
      }
    });
  }, 10);
}

function browserPage(){
  var bpage  = document.getElementById('browser-page');
  var linhas = document.getElementById('linhas').value;

  var pagina = Math.ceil((parseInt(document.getElementById('ajax').lastElementChild.className)/linhas));
  var total  = Math.ceil((bpage.getAttribute('data-total')/linhas));
  if(pagina < 1){ pagina = 1; }
  if(total < 1){ total = 1; }
  bpage.innerHTML = pagina+'/'+total;
  bpage.setAttribute('data-pagina', pagina);
  bpage.className = total;

}

function toggleAba(ele){
  if (document.querySelector('.abas').querySelector('.green') ) { 
    document.querySelector('.abas').querySelector('.green').classList.remove('green');
  }  
  ele.classList.add('green');
  var listas = ele.parentNode.parentNode.querySelectorAll('.form, .form-config');

  for(let i=0;i<listas.length;i++){
    if(listas[i].id == ele.getAttribute('data-for')){
      listas[i].classList.remove('closed');
    } else {
      listas[i].classList.add('closed');
    }
  }
}

function saveFloats(){
  var item = document.querySelector('.itens');
  var uls = item.getElementsByTagName('ul');
  for(let i=0;i<uls.length;i++){
    var filhos = uls[i].children; 
    for(let li=0;li<filhos.length;li++){ 
      if(filhos[li].children[2].className.indexOf('float') != -1){ 
        var multi = filhos[li].children[2].children[0].children; 
        var multivar = ''; 
        for(let b=0;b<multi.length;b++){ 
          if(multi[b].selected == true){ 
            multivar = multivar+'|'+multi[b].value; 
          }
        } 
        ajax('fly', 'save_float', 'ws_conteudo='+encodeURIComponent(multivar)+'&ws_padrao='+filhos[li].children[1].title);
      } else { 
        if(filhos[li].children[2]){ 
          ajax('fly', 'save_float', 'ws_conteudo='+encodeURIComponent(filhos[li].children[2].value)+'&ws_padrao='+filhos[li].children[1].title);
        } 
      } 
    }
  }
}

function sos(idObj){
  //script or screen
  var obj = document.getElementById(idObj);
  if(obj.getAttribute('data-script').length > 0){
    if(confirm(TR_CM)){
      call('programa_execucao', 'prm_objeto='+idObj+'&prm_parametros='+encodeURIComponent(obj.getAttribute('data-parametros'))+'&prm_screen='+tela).then(function(resposta){ 
        if(resposta.indexOf('WS_EXECUTANDO') != -1){
          alerta('feed-fixo', TR_PR);
        } else { 
          if(resposta.indexOf('WS_NOEXEC') != -1){
            alerta('feed-fixo', TR_XC);
          } else { 
            if(resposta.indexOf('OTHERS') != -1){
              alerta('feed-fixo', TR_XC);
            } else {
              alerta('feed-fixo', resposta.trim());
            }
          }
        }

      });
        
    }
  }

  var chamada = obj.getAttribute('data-chamada');
  if(chamada.length > 0){
    if(chamada.indexOf('SRC_') != -1){ 
      shscr(chamada); 
    } else { 
      cleardrill(); 
      //loading(); 
      document.getElementById('drill_obj').value = chamada+'trl';
      appendar('prm_drill=Y&prm_objeto='+chamada+'&prm_zindex=2&prm_posx='+(cursorx-20)+'px&prm_posy='+(cursory-20)+'px&prm_screen='+tela, '', ''); 
      carrega('ajobjeto?prm_objeto='+chamada+'trl'); 
      centerDrill(chamada);
    } 
  }
}

var v_button_column_running = 'N'; 


function browserEvent(event, x, y, Z){


  // Se não for edit de campo calendário, fecha a tela de calendário se estiver aberta 
  if (y != 'edit' || (y == 'edit' && event.target.getAttribute('data-t') != 'calendario' ) ) {
    let div_calendar = document.getElementsByClassName('calendar-box');
    if (div_calendar.length > 0 ) { 
      if (div_calendar[0].id.startsWith('calender_div') ) {
        div_calendar[0].remove();
      }
    }
  }  

  var menu = document.getElementById('data_list_menu');

  if(y == 'button-column' && Z.length > 0) {
    if (v_button_column_running == 'N') {     

      var ele  = event.target; 
      var chaves = []; 
      var allChaves = ele.parentNode.parentNode.querySelectorAll('.chave'); 
      for(let i=0;i<allChaves.length;i++){ 
        chaves.push(encodeURIComponent(allChaves[i].getAttribute('data-d'))); 
      } 
      var v_param = 'prm_objeto='      +x+
                    '&prm_tabela='     +document.getElementById('data_list').getAttribute('data-tabela')+
                    '&prm_campo_chave='+document.getElementById('browser-chave').value+ 
                    '&prm_chave='      +chaves.join('|')+ 
                    '&prm_campo='      +ele.getAttribute('data-c')+ 
                    '&prm_acao='       +Z; 
      
      v_button_column_running = 'S';
      ele.classList.toggle('loading');

      call('exec_button_column', v_param, 'bro').then(function(resultado){
        alerta('',resultado.split('|')[1]); 
        if (resultado.split('|')[2].length > 0 )  { 
          if (resultado.split('|')[2] == 'RECARREGAR_BROWSER') { 
              browserSearch('');
          } else {
            ele.innerHTML = resultado.split('|')[2]; 
            if (resultado.split('|')[3].length == 0) { 
              ele.style.backgroundColor = ""; 
              ele.style.color           = ""; 
            } else {  
              var vestilo = resultado.split('|')[3].toLowerCase().split(';'); 
              ele.style.backgroundColor = vestilo[0].replace('background-color:', '').replace('!important','').trim(); 
              ele.style.color           = vestilo[1].replace('color:', '').replace('!important','').trim(); 
            }  
          }  
        }      
        v_button_column_running = 'N';
        ele.classList.toggle('loading');
      });
    }   

  }   
    
  if(y == 'edit'){
    
    var parente = event.target.parentNode;
    
    if(document.querySelector('.selectedbline')){
      document.querySelector('.selectedbline').classList.remove('selectedbline');
    }
    
    if(selectedb == parente.id && !parente.classList.contains('attach')){ 
      parente.classList.remove('selectedbline'); 
      menu.classList.remove('open'); 
      selectedb = ''; 
    } else  { 
      selectedb = parente.id; 
      parente.classList.add('selectedbline');

      var chaves   = [], 
         allChaves = []; 

      if(event.target.classList.contains('attach-div')){
        var vTR = parente.parentNode; 
      } else {
        var vTR = parente; 
      }
      
      if (vTR.tagName == 'TR') { 
        var allChaves = vTR.querySelectorAll('.chave');       
        var temPipe = false;
        var pipeString = '|';
        
        for(let i=0;i<allChaves.length;i++){ 
          if (encodeURIComponent(allChaves[i].getAttribute('data-d')).includes('%7C')) {
            temPipe = true;
          }
          chaves.push(encodeURIComponent(allChaves[i].getAttribute('data-d'))); 
        } 
        if (temPipe) {

          if (chaves.length == 1 && chaves[0].includes('%7C')) {
            chaves[0] = chaves[0].replace(/%7C/g, '******');;
          }

          chaves = chaves.join('*|*');
          pipeString = '*|*';
          
        } else {
          chaves = chaves.join('|');
        }
      }  
      
      
      if(parente.classList.contains('attach')){ 
        curtain('only');
        browserMenu(menu, event); 
        ajax('list', 'anexo', 'prm_chave='+x+pipeString+chaves, false, 'editb', '', '', 'bro'); 
        ajax('list', 'browserButtons', 'prm_tipo=&prm_visao=&prm_chave=', false, 'browserbuttons', '', '', 'bro'); 
      } else { 
        if (chaves.length > 0 ) { 
          curtain('only');           
          ajax('list', 'browserButtons', 'prm_tipo=update&prm_visao='+x+'&prm_chave=', false, 'browserbuttons', '', '', 'bro');           
          call('browserEdit', 'prm_obj='+x+'&prm_chave='+chaves+'&prm_campo='+document.getElementById('browser-chave').value+'&prm_tabela='+document.getElementById('data_list').getAttribute('data-tabela'), 'bro').then(function(resultado){
            browserMenu(menu, event); 
            document.getElementById('editb').innerHTML = resultado;
          }).then(function(){
            
            browserHint();

            var browseredit = document.getElementById('browseredit').querySelectorAll('[data-evento]');
            var browsereditl = browseredit.length;
          
            for(let b=0;b<browsereditl;b++){
              browseredit[b].getAttribute('data-evento').split('|').forEach(function(evento){
                browseredit[b].addEventListener(evento, browser_tipo_valor);
              });
            }
          });
        }  
      } 
    }
  }

  if(y == 'new'){
    if(document.querySelector('.selectedbline')){
      document.querySelector('.selectedbline').classList.remove('selectedbline');
    }
    curtain('only'); 
    ajax('list', 'browserButtons', 'prm_tipo=insert&prm_visao='+x+'&prm_chave='+document.getElementById('browser-chave').value, false, 'browserbuttons', '', '', 'bro'); 
    
    call('browserEdit', 'prm_obj='+x+'&prm_chave=&prm_campo='+document.getElementById('browser-chave').value+'&prm_tabela='+document.getElementById('data_list').getAttribute('data-tabela'), 'bro').then(function(resultado){
      browserMenu(menu, event);
      document.getElementById('editb').innerHTML = resultado;
    }).then(function(){

      browserHint();

      var browseredit = document.getElementById('browseredit').querySelectorAll('[data-evento]');
        var browsereditl = browseredit.length;
      
        for(let b=0;b<browsereditl;b++){
          browseredit[b].getAttribute('data-evento').split('|').forEach(function(evento){
            browseredit[b].addEventListener(evento, browser_tipo_valor);
          });
        }
    });
  }

  if(y == 'colunas'){
    selectedb = ''; 
    browserMenu(menu, '');
    if(document.querySelector('.selectedbline')){
      document.querySelector('.selectedbline').classList.remove('selectedbline');
    }
    document.getElementById('titulo').innerHTML = y; 
    call_save('');
    curtain('enabled');
    
    call('browserConfig', 'prm_microdata='+x, 'BRO').then(function(resposta){
      document.getElementById('content').innerHTML = resposta;
      var visao = document.getElementById('data_list').getAttribute('data-tabela');
      carregaPainel('browser', x+'|'+visao);
    });
  }
  if(y == 'filtros'){
    selectedb = ''; 
    browserMenu(menu, '');
    if(document.querySelector('.selectedbline')){
      document.querySelector('.selectedbline').classList.remove('selectedbline');
    }
    document.getElementById('titulo').innerHTML = y; 
    call_save(''); 
    curtain('enabled');
   
    call('list_ofiltro', 'ws_par_sumary='+x+'&prm_visao='+Z).then(function(resposta){
      document.getElementById('content').innerHTML = resposta;
      carregaPainel('browserfiltro', x);
    }); 
    
  }
  if(y == 'destaques'){
    selectedb = ''; 
    browserMenu(menu, '');
    if(document.querySelector('.selectedbline')){
      document.querySelector('.selectedbline').classList.remove('selectedbline');
    }
    document.getElementById('titulo').innerHTML = y; 
    call_save(''); 
    curtain('enabled');
    call('blink', 'prm_objeto='+x+'&prm_visao='+Z).then(function(resposta){
      document.getElementById('content').innerHTML = resposta;
      carregaPainel('blinkbrowser', x);
    }); 
  }

  if(y == 'edit_txtclob' || y == 'edit_htmlclob'){ 

    var ele       = event.target;
    let cd_coluna = ele.getAttribute('data-coluna'), 
        parente   = ele.parentNode;
    
    if(document.querySelector('.selectedbline')){
      document.querySelector('.selectedbline').classList.remove('selectedbline');
    }
    parente.classList.add('selectedbline');

    var chaves   = [], 
       allChaves = []; 

    if(event.target.classList.contains('attach-div')){
      var vTR = parente.parentNode; 
    } else {
      var vTR = parente; 
    }
      
    if (vTR.tagName == 'TR') { 
      var allChaves = vTR.querySelectorAll('.chave');       
      for(let i=0;i<allChaves.length;i++){ 
        chaves.push(encodeURIComponent(allChaves[i].getAttribute('data-d'))); 
      } 
    }  
    
    if (chaves.length > 0 ) { 
      curtain('only');           
      ajax('list', 'browserButtons', 'prm_tipo=update&prm_visao='+x+'&prm_chave=&prm_coluna='+cd_coluna, false, 'browserbuttons', '', '', 'bro');

      call('browserEditCLOB', 'prm_obj='+x+'&prm_chave='+chaves.join('|')+'&prm_campo='+document.getElementById('browser-chave').value+'&prm_coluna='+cd_coluna, 'bro').then(function(resultado){
        browserMenu(menu, event);
        document.getElementById('editb').innerHTML = resultado;

        if (document.getElementById('editb').querySelectorAll('.pell-bar').length > 0) {
          pellLaunch('1','browser'); 
        }  
      });
      event.stopPropagation(); 
    } 
  }
}

function browserHint() {

  // hint dimensionamento browser.

  var parentDiv = document.getElementById('editb').parentNode;

  var hint = document.createElement('div');
  hint.textContent = '"CTRL + ALT + D" para voltar a tela ao tamanho default.';
  hint.style.position = 'fixed'; 
  hint.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
  hint.style.color = '#fff';
  hint.style.padding = '5px';
  hint.style.borderRadius = '5px';
  hint.style.zIndex = '9999'; 

  hint.style.left = (cursorx + 10) + 'px';
  hint.style.top = (cursory + 10) + 'px';

  function showLabel(event) {
    var rect = parentDiv.getBoundingClientRect();
    var mouseX = event.clientX - rect.left;
    var mouseY = event.clientY - rect.top;

    if (mouseX > rect.width - 30 && mouseY > rect.height - 30) {
      document.body.appendChild(hint);
      hint.style.display = 'block';
      hint.style.left = (event.pageX - hint.offsetWidth - 10) + 'px';
      hint.style.top = (event.pageY + 10) + 'px';
    } else {
      hint.style.display = 'none';
    }
  }

  function mouseOut() {
    hint.style.display = 'none';
  }

  function keydownHandler(event) {
    if (!parentDiv.classList.contains("open")) {
      document.body.removeEventListener('keydown', keydownHandler);
    }
  
    if (event.ctrlKey && event.altKey && event.key === 'd') {
      
      call('update_prop', 'prm_id='+document.getElementById('browser-tabela').value+'&prm_prop=TAMANHO_DEFAULT_BRO').then(function(resposta){ 
        
        var arr = JSON.parse(resposta);

        parentDiv.style.width = arr[0] + 'px';
        parentDiv.style.height = arr[1] + 'px';

      });
    }
  }

  parentDiv.addEventListener('mousemove', showLabel);

  parentDiv.addEventListener('mouseout', mouseOut);

  document.body.addEventListener('keydown', keydownHandler);

  // end hint
}

function browser_salva_alteracao(config, parametros){
  var linha = config.parentNode.parentNode;
  var microdata = parametros.split('&')[0].split('=')[1];
  ajax('return', 'browserConfig_alter', parametros||'&prm_acao=update', false, '', '', '', 'bro');
  var resultado = respostaAjax.split('|');
  if(resultado[0] == 'OK'){
    call('menu', 'prm_objeto='+microdata,'bro').then(function(resposta){
      document.getElementById('bro-menu').innerHTML = resposta; 
    }); 
    alerta('msg', resultado[1]);
  }
  else {
    alerta('msg', resultado[1]);
  }
}

function browser_tipo_valor(){
  if(this.parentNode.getAttribute('data-tipo').indexOf('number') == -1){ 
    this.parentNode.setAttribute('data-v', this.value.replace(/\>/g, '').replace(/\</g, '')); 
  } else { 
    var valor = this.value; 
    valor = valor.split('.'); 
    valor[valor.length-1] = valor[valor.length-1].replace(',', '.'); 
    valor = valor.join(','); 
    this.parentNode.setAttribute('data-v', valor); 
  }
}




function callDrill(x, y){
  var valor = x.value; 
  document.getElementById('drill_obj').setAttribute('value', valor+'trl'); 
  
  remover('jumpdrill'); 
  remover(valor+'trl'); 

  appendar('prm_drill=Y&prm_objeto='+valor+'&prm_posx='+cursorx+'px&prm_posy='+cursory+'px&prm_zindex=2&prm_parametros='+encodeURIComponent(y)+'&prm_screen='+tela); 
  setTimeout(function(){ 
    ajustar(valor+'trl'); 
    carrega('ajobjeto?prm_objeto='+valor+'trl'); 
    centerDrill(valor); 
  }, 10);
}

function colunasCalculo(x, y){
  var total = []; 
  var linhas = document.getElementById('fakelist').querySelectorAll('.calculos_n'); 
  for(let a=0;a<linhas.length;a++){ total.push(encodeURIComponent(linhas[a].value)); }  
  ajax('fly', 'alter_attrib', 'prm_objeto='+x+'&prm_prop=CALCULADA_N&prm_value='+total.join('|')+'&prm_usuario='+y, false);

  var total = []; 
  var linhas = document.getElementById('fakelist').querySelectorAll('.calculos'); 
  for(let b=0;b<linhas.length;b++){ total.push(encodeURIComponent(linhas[b].value)); }  
  ajax('fly', 'alter_attrib', 'prm_objeto='+x+'&prm_prop=CALCULADA&prm_value='+total.join('|')+'&prm_usuario='+y, false);

  var total = []; 
  var linhas = document.getElementById('fakelist').querySelectorAll('.calculos_m'); 
  for(let c=0;c<linhas.length;c++){ total.push(encodeURIComponent(linhas[c].value)); }  
  ajax('fly', 'alter_attrib', 'prm_objeto='+x+'&prm_prop=CALCULADA_M&prm_value='+total.join('|')+'&prm_usuario='+y, false);
  alerta('feed-fixo', TR_AL);
}


function colunasPropriedades(p_objeto, p_campo, p_usuario){

    var total_n  = [];    
    var total    = [];  
    var linhas_n = document.getElementById('fakelist').querySelectorAll('.prop_col_n'); 
    var linhas   = document.getElementById('fakelist').querySelectorAll('.prop_col');   
    
    for(let a=0;a<linhas_n.length;a++){ 
      if (encodeURIComponent(linhas_n[a].value) != '' && encodeURIComponent(linhas_n[a].value) != '.') { 
        if (!(total_n.find(element => element == encodeURIComponent(linhas_n[a].value)))) {
          if (encodeURIComponent(linhas[a].value) != '') {
            total_n.push(encodeURIComponent(linhas_n[a].value)); 
            total.push(encodeURIComponent(linhas[a].value)); 
          }  
        }   
      }  
    }  

    ajax('fly', 'alter_attrib', 'prm_objeto='+p_objeto+'&prm_prop='+p_campo+'_N&prm_value='+total_n.join('|')+'&prm_usuario='+p_usuario, false);
    ajax('fly', 'alter_attrib', 'prm_objeto='+p_objeto+'&prm_prop='+p_campo+'&prm_value='+total.join('|')+'&prm_usuario='+p_usuario, false);
  
}


function savePrefixo(dis, x){
  if(x == 'add'){
    var linha = document.getElementById('painel'); 
    var prefixo = linha.children[0]; 
    var lov = linha.children[1]; 
    var lovp = linha.children[2]; 
    var agrupador = linha.children[3]; 
    var mascara = linha.children[4]; 
    var alinhamento = linha.children[5]; 
  } else {
    var linha = dis.parentNode.parentNode; 
    var prefixo = linha.children[0].children[0]; 
    var lov = linha.children[1].children[0]; 
    var lovp = linha.children[2].children[0]; 
    var agrupador = linha.children[3].children[0]; 
    var mascara = linha.children[4].children[0]; 
    var alinhamento = linha.children[5].children[0];  
  }

  call('prefixo_alter', 'prm_prefixo='+prefixo.value+'&prm_lov='+lov.value+'&prm_lovp='+lovp.value+'&prm_agrupador='+agrupador.value+'&prm_mascara='+mascara.value+'&prm_alinhamento='+alinhamento.value+'&prm_prefixo_ant='+prefixo.getAttribute('data-ant')+'&prm_lov_ant='+lov.getAttribute('data-ant')+'&prm_lovp_ant='+lovp.getAttribute('data-ant')+'&prm_agrupador_ant='+agrupador.getAttribute('data-ant')+'&prm_mascara_ant='+mascara.getAttribute('data-ant')+'&prm_alinhamento_ant='+alinhamento.getAttribute('data-ant')+'&prm_evento='+x).then(function(resposta){
    if(resposta.indexOf('ok') != -1){
      prefixo.setAttribute('data-ant', prefixo.value);
      lov.setAttribute('data-ant', lov.value);
      lovp.setAttribute('data-ant', lovp.value);
      agrupador.setAttribute('data-ant', agrupador.value);
      mascara.setAttribute('data-ant', mascara.value);
      alinhamento.setAttribute('data-ant', alinhamento.value);
    }
  }).then(function(){
    if(x == 'add'){
      carrega('prefixo_lista');
      alerta('feed-fixo', TR_AD);
    }
    if(x == 'remove'){
      alerta('feed-fixo', TR_EX);
    }
    if(x == 'edit'){
      alerta('feed-fixo', TR_AL);
    }
      
  });
}

function medDrill(dis, obj, visao){
  remover('sdrill_'+obj); 
  remover('jumpmed');
  

  setTimeout(() => {
  
    let ilocalx = cursorx;
    let ilocaly = cursory; 

    let med = document.createElement('div'); 
    med.id = 'jumpmed'; 
    var rect = dis.getBoundingClientRect();
    med.style.setProperty('left', (rect.left-104+(rect.width/2))+'px'); 
    med.style.setProperty('top', rect.top+(rect.height)+'px');
          
    let spanInv = document.createElement('span');
    spanInv.classList.add('inv');
          
    let col = document.createElement('p');
    col.innerHTML = dis.innerText;

    let aScript = document.createElement('a');
    aScript.classList.add('script');
    aScript.addEventListener('click', () => {
      agrupadorChange(obj, dis.getAttribute('data-valor'), aScript.nextElementSibling.title);
    });

    var selectInv = document.createElement('span');
    call('jumpmed', 'prm_coluna='+dis.getAttribute('data-valor')+'&prm_visao='+visao+'&prm_objeto='+obj.split('trl')[0]).then(function(res){
      selectInv.outerHTML = res;
    });

    let aInv = document.createElement('a');
    aInv.innerHTML = 'x';
    aInv.addEventListener('click', function(){
      remover('jumpmed');
    });

    med.appendChild(aScript);
    med.appendChild(selectInv);
    med.appendChild(aInv);

    MAIN.appendChild(med);

    setTimeout(function(){ 
      med.classList.add('open');
    }, 100); 
  }, 100);

}

function converteDecimal(x){
  var valor = x;
  var arr = valor.split();
  for(let i=0;i<arr.length;i++){
    if(arr[i] == "."){
      arr[i] = ",";
    } else {
      if(arr[i] == ","){
        arr[i] = "."; 
      }
    }  
  }
  valor = arr.join();
  return valor;  
}

function stripTags(valor){
  //ver uso no browser
  return valor.split(/\<[a-zA-Z0-9/]+\>/g).join(""); 
}

function update_prop(x, y, z){
  
  var valor = z;
  
  if(y == 'nome' || y == 'subtitulo' || y == 'descritivo'|| y == 'tamanho_tela'|| y == 'descritivo_tela'){ valor = encodeURIComponent(valor); }
 
  call('update_prop', 'prm_id='+x+'&prm_prop='+y+'&prm_valor='+valor+'&prm_screen='+tela).then(function(resposta){ 
    
    if(resposta.indexOf('fail') == -1){ 

      alerta('feed-fixo', TR_AL);

      switch (y){

        case 'nome':
          if(document.getElementById(x+'_ds')){
            if(!document.getElementById(x+'_ds').parentNode.classList.contains('texto')){
              document.getElementById(x+'_ds').innerHTML = resposta;
            }
          }
          if (x.startsWith('COBJ_')) { 
            if (document.getElementById('lista-custom-fav') ) { 
              document.getElementById('lista-custom-fav').children[0].innerHTML = resposta;
            }  
          }
        break;
        
        case 'ID':
            var iddefault = document.getElementById('ident').getAttribute('data-default');
            if(document.getElementById(iddefault).parentNode.parentNode.id == 'main'){ 
              var dash = '&prm_dashboard=false'; 
              var ordem = ''; 
            } else { 
              dashlocation = document.getElementById(iddefault).parentNode.parentNode.id; 
              var dash = '&prm_dashboard=true'; 
              var ordem = document.getElementById(iddefault).parentNode.style.getPropertyValue('order'); 
            }
            document.getElementById(iddefault).remove();
            appendar('prm_objeto='+z+'&PRM_ZINDEX=&prm_posx='+ordem+'&prm_posy=&prm_screen='+tela+dash, false);
        break;
        
        case 'subtitulo':
          if(document.getElementById(x+'_sub')){
            document.getElementById(x+'_sub').innerHTML = resposta;
          }
          
        case 'descritivo_tela':
          if(x == tela){
            document.getElementById('tela-atual').innerHTML = resposta;
          }
        break;
        
        case 'cor_tela':
          if(x == tela){
            MAIN.style.setProperty('background-color', resposta);
          }
        break;
      }
    } else {
      alerta('feed-fixo', TR_ER);
    }		
  });  
}

function updatePermissao(dis, evt){
  if(!document.querySelector('.fakelistbox.open').parentNode.classList.contains('searchbar')){
    var classe = dis.className;
    var titulo = dis.title;
    if(evt == 'over'){
      if(mousedown == true){
        if(classe.indexOf('selected') == -1){ 
          update_prop(tela, 'usuarios-tela-add', titulo); 
        } else { 
          update_prop(tela, 'usuarios-tela-del', titulo); 
        }
      }
    } else {
      if(classe.indexOf('selected') == -1){ 
        update_prop(tela, 'usuarios-tela-add', titulo); 
      } else { 
        update_prop(tela, 'usuarios-tela-del', titulo); 
      }
    }
  }
}

function limpaTimer(){
  clearInterval(timer_rel);  
}

function gerar_relatorio(obj, screen, cod){

  if (obj.includes('trl')) {
    obj = obj.replace('trl', '');
  }

  if(!document.getElementById(obj+'_button').classList.contains('loading')){
    
    if(document.getElementById(obj+'_lista').children[0]){
      document.getElementById(obj+'_lista').children[0].classList.add('LOCKED');
    }
    call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=false', 'up_rel').then(function(resposta){ 
      if(resposta.indexOf('SEM CONSULTA') != -1){
        alerta('feed-fixo', resposta);
      } else {
        if(resposta.indexOf('gerado') != -1){ 
          alerta('feed-fixo', resposta);
          call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=check', 'up_rel').then(function(resposta2){ 
            document.getElementById(obj+'_button').innerHTML = resposta2; 
            if(resposta2.indexOf('EXEC') == -1){ 
              clearInterval(timer_rel); 
            }
          }).then(function(){
            timer_rel = setInterval(function(){ 
              call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=check', 'up_rel').then(function(resposta2){ 
                document.getElementById(obj+'_button').innerHTML = resposta2; 
                if(resposta2.indexOf('EXEC') == -1){ 
                  clearInterval(timer_rel);
                  document.getElementById(obj+'_button').classList.remove('loading');
                  alerta('feed-fixo', 'RELAT&Oacute;RIO GERADO');
                  document.getElementById(obj+'_lista').children[0].classList.remove('LOCKED');
                  call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=file', 'up_rel').then(function(resposta3){ 
                    document.getElementById(obj+'_lista').innerHTML = resposta3; 
                  }); 
                } 
              });  
            }, 5000); 
            
          });
          
        } else { 
          if(resposta.length > 10){
            if(resposta.indexOf('existe') != -1){
              alerta('feed-fixo', TR_RG); 
            } else {
              document.getElementById(obj+'_lista').innerHTML = ''; 
              document.getElementById(obj+'_lista').innerHTML = resposta; 
            }
          } else {
            call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=check', 'up_rel');
            alerta('feed-fixo', TR_GR); 
            document.getElementById(obj+'_button').classList.add('loading');
            document.getElementById(obj+'_button').children[0].innerHTML = 'EXECUTANDO';
            timer_rel = setInterval(function(){ 
              call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=check', 'up_rel').then(function(resposta2){ 
                document.getElementById(obj+'_button').innerHTML = resposta2; 
                if(resposta2.indexOf('EXEC') == -1){ 
                  clearInterval(timer_rel);
                  setTimeout(function(){ 
                    document.getElementById(obj+'_button').classList.remove('loading');

                    alerta('feed-fixo', 'RELAT&Oacute;RIO GERADO COM SUCESSO');
                    if(resposta2.indexOf('EXCEDEU') == -1){ 
                      call('lista_rel', 'prm_objeto='+obj+'&prm_screen='+screen+'&prm_cod='+cod+'&prm_lista=file', 'up_rel').then(function(resposta3){ 
                        document.getElementById(obj+'_lista').innerHTML = resposta3; 
                      });
                    }
                  }, 1000); 
                }  
              });  
            }, 5000); 
          } 
        } 
      }
    });
      
  }
}

function createView(){
  var regex = new RegExp('^[a-zA-Z0-9_]+$'); 
  //checkError(); 
  var visao_nome = document.getElementById('visao_nome').value; 
  var tabela = document.getElementById('visao_tabela').title; 
  var desc = document.getElementById('visao_desc').value; 
  var grupo = document.getElementById('fake_grupo').title; 
  if(visao_nome.length > 1){ 
    if(tabela.length > 1){ 
      if(desc.length > 1){ 
        if(grupo.length > 1){ 
          if(regex.test(visao_nome)){ 
            call('new_view', 'prm_nome='+visao_nome+'&prm_tabela='+tabela+'&prm_desc='+encodeURIComponent(desc)+'&prm_grupo='+grupo).then(function(resposta){ 
              if(resposta.indexOf('FAIL') != - 1){ 
                alerta('feed-fixo', resposta.replace('FAIL','') );
              } else { 
                alerta('feed-fixo', 'View criada com sucesso!'); 
                call('load_tables', '').then(function(resposta2){ 
                  document.getElementById('content').innerHTML = resposta2; 
                  carregaPainel('visoes');
                }); 
              } 
            }); 
          } else { 
            alerta('msg', TR_VI); 
          } 
        } else { 
          alerta('msg', TR_ES_gr); 
        } 
      } else { 
        alerta('msg', TR_DS_LE); 
      } 
    } else { 
      alerta('msg', TR_ES_TB); 
    } 
  } else { 
    alerta('msg', TR_NM_LE); 
  }

}

//header:html e td:html fixos usando pouco js e sticky:css
function topDistance(x){


  if(document.getElementById(x)){
    if(document.getElementById(x+'dv2') ){    

      var obj = document.getElementById(x);
      if(obj.getElementsByTagName('thead')[0]){

        var cabecalho = obj.getElementsByTagName('thead')[0];
        
        var row = cabecalho.getElementsByTagName('tr');
        var rowl = row.length;

        // Define o TOP da segunda/terceira/.. linha do cabeçalho - se for pivot - necessário para manter a segunda linha fixa quando for usado a barra de rolagem 
        //------------------------------------------------------------------------------------
        if(rowl > 1){
          for(let r=1;r<rowl;r++){
            //retirando reflow de linhas desnecessarias
            var rowtop = row[r].offsetTop;
            if(rowtop > 0){
              var celulastop = row[r].getElementsByTagName('th');
          
              var celulastopl = celulastop.length;
          
              for(let i=0;i<celulastopl;i++){
                celulastop[i].style.setProperty('top', rowtop+'px');
              }
            }			
            
          }
        }
        
        // fixo a esquerda, vai até o final da função 
        //testa se for slide, desnecessário nesse caso
        if(!document.getElementById('show_only_screen')){

          var celulas = obj.querySelectorAll('.fix');   
          var celulasl = celulas.length;
          var total = 0;
          var s     = 0;

          while(celulas[s]){
            
            total = total+celulas[s].clientWidth;

            //interrompe se ultima da linha, ou se não existirem colunas sem fix
            try{  
              if ( !celulas[s].nextElementSibling.classList.contains('fix') ) { 
                break;
              }
            } catch(e) {
              break;
            }

            s++
            
          }
          var estilo = [];

          //limpa estilo para não acumular
          if(document.getElementById(x).lastElementChild.tagName == 'STYLE'){
            document.getElementById(x).lastElementChild.remove();
          }

          var celulasV = [];

          for(let c=1;c<celulasl;c++){
            if(window.getComputedStyle(celulas[c], null).display != 'none'){
              celulasV.push(celulas[c]);
            }
          }

          //só fixa horizontal se fixado for menor que largura menos duas colunas
          //------------------------------------------------------------------------------------------
          if(total < obj.clientWidth-180){
            // alterado em 21/09/2022 para considerar também as colunas da subquery 
            //estilo.push('table#'+x+'c tr:not(.sub) td:nth-child(1), table#'+x+'c tr:not(.sub):nth-child(1) th:nth-child(1){ left: 1px; }');
            estilo.push('table#'+x+'c tr td:nth-child(1), table#'+x+'c tr:nth-child(1) th:nth-child(1){ left: 1px; }');  // Primeira coluna (seta) 
          
            let total = 0;
            for(let f=0;f<celulasV.length+1;f++){
            
              if(celulasV[f]){
                // alterado em 21/09/2022 para considerar também as colunas da subquery 
                // estilo.push('table#'+x+'c tr:not(.sub) td:nth-child('+(celulasV[f].cellIndex+1)+'), table#'+x+'c tr:not(.sub):nth-child(1) th:nth-child('+(celulasV[f].cellIndex+1)+'){ left: '+(celulasV[f].offsetLeft-6)+'px; }');
                 estilo.push('table#'+x+'c tr td:nth-child('+(celulasV[f].cellIndex+1)+'), table#'+x+'c tr:nth-child(1) th:nth-child('+(celulasV[f].cellIndex+1)+'){ left: '+(celulasV[f].offsetLeft-6)+'px; }');                                                
                
                if(celulasV[f].nextElementSibling){
                  if(!celulasV[f].nextElementSibling.classList.contains('fix')){
                    f = 9999999;
                  }
                }
              } else {
                f = 9999999;
              }             
            }
          }
          var estiloFixo = document.createElement('style');
          var estiloSemRepetir = [...new Set(estilo)];
          estiloFixo.innerHTML = estiloSemRepetir.join(' ');
          document.getElementById(x).appendChild(estiloFixo); 

          /** Desativado em 21/09/2022 - foi realizado correção na subquery deixand o a quantidade de colunas da sub igual a da query principal,     
          //Desativado, fixa colunas da subquery, não pode generalizar cada nivel do sub pode ser diferente
          if(document.getElementById(x+'c').querySelector('.sub')){
          
            var tdsLinha = document.getElementById(x+'c').getElementsByClassName('fixsub');
            
            for(let tds=0;tds<tdsLinha.length;tds++){
              tdsLinha[tds].style.setProperty('left', (tdsLinha[tds].offsetLeft-6)+'px');
            }               
          }
          *************/           
          
        }
      }
    }
  }
}

//document.addEventListener('mousemove', function(e){ if(e.clientX > window.innerWidth-20){ document.getElementById('prefdrop').classList.add('hover'); } if(e.clientX < window.innerWidth-90){ document.getElementById('prefdrop').classList.remove('hover'); } });

/*trocar table por linhas na consulta*/
function calcBasis(x){
  var objeto = document.getElementById(x);
  var linhas = objeto.children.length;
  var colunas = objeto.children[0].children.length;
  var basis = [];
  for(let b=0;b<colunas;b++){
    basis.push(0);
  }
  var acwidth = 0;

  for(let i=0;i<linhas;i++){ for(let l=0;l<colunas;l++){ acwidth = objeto.children[i].children[l].clientWidth; if(acwidth > basis[l]){ basis[l] = acwidth; } } }
  var estilo = document.createElement('style');
  var estiloin = '';
  for(let s=1;s<basis.length;s++){
    estiloin = estiloin+' div#'+x+' ul li:nth-child('+(parseInt(s)+1)+'){ flex-basis: '+basis[s]+'px; }'; 
  }
  estilo.innerHTML = estiloin;
  objeto.appendChild(estilo);
}

function carregaObjeto(){
  
  var allLoaders = document.querySelectorAll('.loader');
  var ll = allLoaders.length;
  for(let i=0;i<ll;i++){
    var target = allLoaders[i];
    call('carrega_objeto', 'prm_tipo='+target.getAttribute('data-tipo')+'&prm_posicao='+target.getAttribute('data-posicao')+'&prm_parametro='+target.getAttribute('data-parametro')+'&prm_visao='+target.getAttribute('data-visao')+'&prm_coluna='+target.getAttribute('data-coluna')+'&prm_agrupador='+target.getAttribute('data-agrupador')+'&prm_tip='+target.getAttribute('data-tip')+'&prm_obj='+target.getAttribute('data-objeto')+'&prm_screen='+target.getAttribute('data-screen')+'&prm_colup='+target.getAttribute('data-colup')).then(function(resposta){
      document.getElementById(target.parentNode.id).innerHTML = resposta;  
    });
    /*var htmlobj = document.createElement('div');
    htmlobj.outerHTML = respostaAjax;
    target.parentNode.appendChild(htmlobj);*/
  }
  
}

function carregaTela(obj, fundo, url){
  shscr(obj); 
  setTimeout(function(){ 
    MAIN.style.setProperty('background-color', fundo); 
    if(url.indexOf('EXT=') == -1){ 
      if(url.indexOf('N/A') == -1){ 
        MAIN.style.setProperty('background-image', 'url('+url+')'); 
      } else { 
        MAIN.style.setProperty('background-image', 'none'); 
      } 
    } else { 
      MAIN.style.setProperty('background-image', 'none'); 
    } 
  }, 500);
}

function addLov(){
  checkError(); 
  var nome   = document.getElementById('nome_lov').value; 
  var tabela = document.getElementById('lista-tabelas').title; 
  var codigo = document.getElementById('lista-codigo').title; 
  var desc   = document.getElementById('lista-descricao').title; 
  var tipo   = document.getElementById('tipos').title; 

  if (tipo == 'LISTA') {
    tabela = document.getElementById('lista_lov').value;
  }

  if(nome.length < 2){ 
    alerta('msg', TR_TC); 
  } else { 
    if(tabela.length > 1 && codigo.length > 1 && desc.length > 1 || tipo == 'LISTA'){ 
      call('savecd', 'p_funcao=G&p_nds_tabela='+nome+'&p_nds_owner=DWU&p_nds_tfisica='+tabela+'&p_nds_cd_empresa=&p_nds_cd_codigo='+codigo+'&p_nds_cd_descricao='+desc+'&p_tipo='+tipo).then(function(resposta){ 
        if(resposta.indexOf('ok') != -1){ 
          alerta('feed-fixo', TR_CR); 
          ajax('list', 'list_cdesc', 'prm_order=1&prm_dir=', false, 'content'); 
          carregaPainel('lov'); 
        } else { 
          alerta('feed-fixo', resposta); 
        } 
      }); 
    } else {
      alerta('feed-fixo', TR_TC);
    }
  }
}

function addDestaque(){
  var d_usuario  = document.getElementById('destaque-usuario').title; 
  var objeto     = document.getElementById('destaque-objeto').title; 
  var coluna     = document.getElementById('destaque-coluna').title; 
  var condicao   = document.getElementById('destaque-condicao').title; 
  var conteudo   = document.getElementById('destaque-valores').title; 
  var fundo      = document.getElementById('destaque-corfundo').value; 
  var fonte      = document.getElementById('destaque-corfonte').value; 
  var tipo       = document.getElementById('destaque-tipo').value; 
  var prioridade = document.getElementById('destaque-prioridade').value; 
  
  if(d_usuario != '' && conteudo != '' && fundo != '' && fonte != '' && prioridade != '' && objeto != ''){ 
    call('setdestaque', 'prm_usuario='+d_usuario+'&prm_objeto='+objeto+'&prm_coluna='+coluna+'&prm_condicao='+condicao+'&prm_conteudo='+encodeURIComponent(conteudo)+'&prm_fundo='+fundo+'&prm_fonte='+fonte+'&prm_tipo='+tipo+'&prm_prioridade='+prioridade).then(function(resposta){ 
      if(resposta.indexOf('FAIL') == -1){ 
        alerta('feed-fixo', TR_AD); 
        if(document.getElementById('destaque-objeto').getAttribute('data-default')){
          ajax('list', 'list_mblink', 'prm_objeto=&prm_usuario='+d_usuario+'&prm_order=1&prm_dir=', true, 'ajax'); 
        } else {
          carrega('blink?prm_objeto='+objeto+'&prm_visao='+document.getElementById('destaque-visao').title+'&prm_order=1&prm_dir=');
        }
      } else { 
        alerta('feed-fixo', TR_ER); 
      } 
    }); 
  } else { 
    alerta('feed-fixo', TR_TC); 
  }
}

document.addEventListener("keyup", function(e){
  var alvo = e.target;

  if(alvo.parentNode.classList.contains('search')){
    var fake = alvo.parentNode.parentNode.parentNode;
    fakeboxevent(fake.id, fake.getAttribute('data-opcao'), fake.title, 'N', fake.getAttribute('data-visao'), fake.getAttribute('data-reverse'), fake, fake.children[0].getAttribute('data-fixed').length, alvo.value, '');
  }
  
  if(alvo.parentNode.classList.contains('custom')){
    if(e.which == 13){
    /*  let multi = document.querySelector('.fakeoption.open').classList.contains('multi');
      if(multi == true){
        let valor = alvo.value;
        let linha = document.createElement('li');
        linha.title = valor;
        linha.innerHTML = valor;
        linha.classList.add('opt');
        linha.classList.add('selected');
        
        alvo.parentNode.parentNode.insertBefore(linha, alvo.parentNode.parentNode.children[1]);
        alvo.value = '';
      } else {*/
        alvo.nextElementSibling.click();
      //}
      
    }
  }

  if(alvo.classList.contains('errorinput')){
    if(alvo.getAttribute('data-min')){
      if(alvo.value.length >= parseFloat(alvo.getAttribute('data-min'))){
        alvo.classList.remove('errorinput');
      }
    } else {
      alvo.classList.remove('errorinput');
    }
  }

});

/*evento precarregado, usar em conjunto com css fake checkbox*/
function clickStart(e){
  var alvo = e.target;

  call('refresh_session', '');    // Para cada iteração do usuário atualiza a data de atividade da sessão no BI 
  

  /*** call('refresh_session', '').then(function(resposta){ 
    if( resposta.indexOf("0") != -1){
      ajax('fly', 'xlogout', '', true);
      alerta('x', TR_SE);
      setTimeout(function(){ 
        window.location.reload(true); 
      }, 1000);
      return false;
    }})
  *********/   
   
  if(alvo.id == 'sizeUp'){
    document.getElementById('sizeUp').remove();
    return;
  };

  
  if(alvo.id == 'call-menu'){
    document.getElementById('attriblist').innerHTML = '';
    let fun = function(){ 
      call('show_screen', 'prm_screen='+tela+'&prm_tipo=MENU').then(function(resposta){ 
        let container = document.createElement('div');
        container.classList.add('itens');
        container.innerHTML = resposta;
        document.getElementById('attriblist').appendChild(container); 
      }).then(function(){ 
        addLink();
        call('closer_menu').then(function(closer){
          let container = document.createElement('div');
          container.innerHTML = closer;
          document.getElementById('attriblist').appendChild(container.children[0]);
        });
      });
    }
    attReopen(fun, 'attriblist');
  }

    if(alvo.id == 'favoritos'){
     let fun = function(){
        ajax('list', 'favoritos', 'prm_screen='+tela, 'false', 'attriblist'); 
      }
      attReopen(fun, 'attriblist');
    }

  // Excluído o icone de favoritos somente de telas 
  //if(alvo.id == 'favoritos_telas'){
  //  let fun = function(){
  //   ajax('list', 'favoritos', 'prm_screen=FAVORITOS_TELAS', 'false', 'attriblist'); 
  //  }
  //  attReopen(fun, 'attriblist');
  //}

  if(alvo.id == 'atu_view'){
    let fun = function(){
      ajax('list', 'atu_view', 'prm_screen=', 'false', 'attriblist'); 
    }
    attReopen(fun, 'attriblist');
  }


  if(alvo.id == 'config'){
    let fun = function(){ 
      ajax('list', 'list_vconteudo', 'prm_usuario=', false, 'attriblist');
    }
    attReopen(fun, 'attriblist');
  }

  if(alvo.id == 'float-filter'){

      closeSideBar('get_float');

      if(PRINCP.className == 'mac' || PRINCP.className == 'mobile'){
        var local = 'floatlist';
      } else {
        var local = 'floatlist';
        if(document.getElementById(local).classList.contains('open')){
          document.getElementById(local).querySelector('.closer').click();
          return;
        }
      }
      
      let fun = function(){ 
        ajax('list', 'get_float', 'prm_screen='+tela, false, local);
      }
      
      attReopen(fun, local);

  }

  if(alvo.classList.contains('closer')){
    if(document.querySelector('.optionbox')){
      document.querySelector('.optionbox').remove();
    }
    if(document.querySelector('.destacada')){
      document.querySelector('.destacada').classList.remove('destacada');
    }
    var pai = alvo.parentNode; 
    /*if(alvo.previousElementSibling.id == 'get_float'){ 
      if(document.getElementById('get_float').getAttribute('data-alterado') == 'T'){ 
        shscr(tela); 
      } 
    } */
    if(pai.id == 'attriblist' && document.getElementById('fakelist').classList.contains('visible')){
      document.getElementById('fakelist').classList.remove('visible');
      setTimeout(function(){ document.getElementById('fakelist').innerHTML = ''; pai.classList.remove('open'); }, 400);
      setTimeout(function(){ pai.innerHTML = '';  }, 600);
    } else {
      pai.classList.remove('open');
      document.getElementById('fakelist').classList.remove('visible');
      setTimeout(function(){ 
        var closer = pai.querySelector('.closer').cloneNode(true);
        pai.innerHTML = '';
        pai.appendChild(closer); 
      }, 210);
      //setTimeout(function(){ pai.className = ''; }, 400);
    } 
    if(document.querySelector('.itens')){
      if(document.querySelector('.itens').getAttribute('data-alterado') == 'T'){ 
        if(document.querySelector('.itens').getAttribute('data-obj')){
          var obj = document.querySelector('.itens').getAttribute('data-obj');
          if(document.getElementById(obj)){
            if(document.getElementById(obj+'sync')){
              document.getElementById(obj+'sync').click();
            } else {
              shscr(tela);
            }
          }
        } else {
          shscr(tela); 
        }
      }
    }

  }

  if(alvo.classList.contains('reorder')){
    var obj = alvo.parentNode.parentNode.id.replace('sdrill_', '').split('trl')[0];
    
    /* clicka no novo reorder */
    var datai = document.getElementById('selecteddata').getAttribute('data-i');
    document.getElementById(obj+datai+'h').click();
   
  }

  if(alvo.classList.contains('f_addcoluna')){
    add_coluna(alvo.getAttribute('data-template'));
  }

  if(alvo.classList.contains('arrowline') && !alvo.classList.contains('firstline') && !alvo.parentNode.classList.contains('firstline')){
    if(document.querySelector('.arrowline.selected')){
      document.querySelector('.arrowline.selected').classList.remove('selected');
    }
    alvo.classList.add('selected');
  }

  if(alvo.parentNode.classList.contains('custom') && alvo.classList.contains('search') ){
    
    var fake  = alvo.parentNode.parentNode.parentNode;  
    var obj = alvo.parentNode.parentNode.parentNode;

    if (fake.previousElementSibling && fake.title != fake.getAttribute('data-default') ) {  // Alterado para executar somente se houve alteração 
      if(fake.previousElementSibling.classList.contains('script') && !alvo.classList.contains('noscript')){
        fake.previousElementSibling.click();
      }
    }

    if(obj.classList.contains('multi')){
      var multi = 'S';
    } else {
      var multi = 'N';
    }

    fakeboxevent(obj.id, obj.getAttribute('data-opcao'), obj.title, multi, alvo.parentNode.parentNode.parentNode.getAttribute('data-visao'), obj.getAttribute('data-adicional'), obj, obj.children[0].getAttribute('data-fixed').length, alvo.previousElementSibling.value, obj.getAttribute('data-reverse'));
  }

  //Add do fakelistbox - adiciona o data-fixed (item incluido manualmente)
  if(alvo.classList.contains('add')){
    fakeboxAdd(alvo); 
  }

  if(alvo.parentNode.classList.contains('custom')){
    if(alvo.previousElementSibling){
      var fake  = alvo.parentNode.parentNode.parentNode;
      // desativado - var valor = alvo.previousElementSibling.value;
      // desativado - deve ser alterado somente depois da gravação no banco de dados - fake.setAttribute('data-ant', valor);
      fake.click();
    }
  }

  if((alvo.classList.contains("fakeoption") || alvo.parentNode.classList.contains("fakeoption")) && !alvo.classList.contains("fakelistbox")){
    if(alvo.parentNode.classList.contains("fakeoption")){ alvo = e.target.parentNode; }
    var multi = "N";
    if(alvo.classList.contains("multi")){ multi = "S"; }
    /* click principal do fake */
    //fakeListBoxClick(alvo, alvo.getAttribute('data-adicional'), alvo.id, alvo.getAttribute('data-opcao'), multi, alvo.getAttribute('data-visao'), alvo.getAttribute('data-reverse'), e);
  
    if(!e.target.classList.contains('noprop')){
      if (alvo.children[0]) {  // Quando for fakelist do Browser, não tem esse objeto 
        alvo.children[0].setAttribute('data-custom', 'N'); 
        var adicional = alvo.getAttribute('data-adicional'); 
        if(adicional.length > 0){ 
          if(document.getElementById(adicional)){   
            if(!document.getElementById(adicional).classList.contains("dragme") && !document.getElementById(adicional).classList.contains("fakeoption")){
              var adicional = document.getElementById(adicional).title; 
            }
          }
        } 
        fakeListBox(alvo.id, alvo.getAttribute('data-opcao'), alvo.title, multi, alvo.getAttribute('data-visao'), adicional, alvo.getAttribute('data-reverse'), e, alvo.getAttribute('data-custom'));
      }  
    }
  }
  
  
  if(alvo.classList.contains("checkbox")){
    var objid = alvo.parentNode.parentNode.parentNode.parentNode.getAttribute('data-obj');
    
    if(!document.getElementById(objid)){
      if(document.getElementById(objid+'trl')){  
        objid = objid+'trl';
      }
    }

    //nevative e positive para sim/não customizado
    if(alvo.classList.contains("checked")){
      alvo.classList.remove("checked");
      alvo.title = alvo.getAttribute('data-negative');		
    } else {
      alvo.classList.add("checked");
      alvo.title = alvo.getAttribute('data-positive');	
    }
    
    if(alvo.previousElementSibling){
      if(alvo.previousElementSibling.classList.contains("script")){
        alvo.previousElementSibling.click();
      }
    }
  }

  
  if(alvo.classList.contains("sync")){
    var ident = alvo.parentNode.id;
    var pai   = alvo.parentNode.parentNode.id;
    var dash  = '',
        ordem = '',
        posy  = ''; 

    alerta('feed-fixo','Carregando Objeto');

    if(pai == 'main'){ 
      dash = '&prm_dashboard=false'; 
      ordem = ((alvo.parentNode.getBoundingClientRect().x)-28)+'px';   // essa redução de 28 é acrestada na show_objeto, se alterar lá tem que alterar aqui, e vise versa  
      posy  = alvo.parentNode.getBoundingClientRect().y+'px'; 
      if (ordem == 'null') {
        ordem = '';
      }
    } else { 
      dashlocation = pai; 
      ordem = window.getComputedStyle(alvo.parentNode).getPropertyValue('order'); 
      let rect = document.getElementById(dashlocation).getBoundingClientRect();
      dash = '&prm_dashboard=true&prm_dash_altura='+rect.height.toString()+'&prm_dash_largura='+rect.width.toString(); 

    } 

    // Verifica se a consulta está na tela de customização de consultas 
    var drill = 'N';
    if (pai.toLowerCase() == 'article_customizacao') {   
      drill = 'C';
      dash = '&prm_dashboard=true'; 
      ordem = '1';
    }
    
    alvo.parentNode.remove(); 
    appendar('prm_drill='+drill+'&prm_objeto='+ident+'&PRM_ZINDEX=&prm_posx='+ordem+'&prm_posy='+posy+'&prm_screen='+tela+dash, false, pai);
  }


  //call dinamico
  if(alvo.classList.contains("addpurple") && alvo.getAttribute('data-req')){
    
    var req          = alvo.getAttribute('data-req');               //require, chamada da requisição
    var par          = alvo.getAttribute('data-par').split('|');    //passagem de parametros
    var res          = alvo.getAttribute('data-res');               //ajax para chamar depois da resposta
    var res_par      = '';                                          //parametros do res
    var sup          = alvo.getAttribute('data-sup');               //menu para chamar
    var res_tar      = 'content';                                   //alvo do require
    var load         = alvo.getAttribute('data-load');              //loading
    var msg          = alvo.getAttribute('data-msg') || TR_AD;      //msg na tela
    var pkg          = alvo.getAttribute('data-pkg') || 'FCL';      //Package
    var par_agrupa   = alvo.getAttribute('data-par-agrupa') || 'N'; //Agrupa parametros e conteudos 
    var par_menu     = '';                                          //Paramentro da chamada menu (menu tela superior)
    

    //variaveis de calculo interno
    var url          = [];
    var res_url      = [];
    var err          = 0;
    var valor_aux    = ''; 
    var par_agrupado = 'prm_parametros=';
    var val_agrupado = 'prm_conteudos='; 

    //para cada parametro passado monta a url
    for(let i=0;i<par.length;i++){

      let tag = document.getElementById(par[i]);
      let valor = '';

      //para o caso de ser fake usa o title
      if(tag.tagName == 'SPAN'){
        valor = tag.title;
      } else {
        valor = tag.value;
      }

      //testa o tamanho do campo
      if(tag.getAttribute('data-min')){
        if(valor.length < parseFloat(tag.getAttribute('data-min')) ){
          tag.classList.add('errorinput');
          err = err+1;
        }
      }

      //testa necessidade de encode
      valor_aux = valor; 
      if(tag.getAttribute('data-encode') == 'S'){
        valor_aux = encodeURIComponent(valor);
      }
      if (par_agrupa == 'S') {
        par_agrupado = par_agrupado+par[i].replace('prm_','')+'|';
        val_agrupado = val_agrupado+valor_aux+'|';
      } else { 
        url.push(par[i]+'='+valor_aux);
      }  

      if (par[i] == 'prm_report') { 
        par_menu = 'prm_default=ID|' + valor; 
      }
    }

    if (par_agrupa == 'S') { 
      url = [];    // limpa o array 
      url.push(par_agrupado); 
      url.push(val_agrupado); 
    }

    //testa se existe parametros no segundo require, faz mesma operação do primeiro
    if(alvo.getAttribute('data-res-par')){
      res_par = alvo.getAttribute('data-res-par').split('|');

      for(let r=0;r<res_par.length;r++){
        
        let tag = document.getElementById(res_par[r]);
        let valor = '';

        if(tag.tagName == 'SPAN'){
          valor = tag.title.split('|')[0];
        } else {
          valor = tag.value.split('|')[0];
        }

        res_url.push(res_par[r]+'='+valor);
        
      }

    }

    //verifica alvo, se não cai no default "content"
    if(alvo.getAttribute('data-res-tar')){
      res_tar = alvo.getAttribute('data-res-tar');
    }

    if(alvo.getAttribute('data-save')){
      if(window[alvo.getAttribute('data-save')].indexOf(url.join('&')) == -1){
        window[alvo.getAttribute('data-save')].push(url.join('&'));
      }
    }

    //se não tem nenhum erro procede 
    if(err == 0){

      if(load){
        document.getElementById(load).classList.add('loading');
      }

      call(req, url.join('&'), pkg).then(function(resposta){
        if(resposta.indexOf('FAIL') == -1 && resposta.indexOf('ERRO|') == -1){ 
          alerta('feed-fixo', msg);
          if(res){
            //se tem um callback de resposta
            ajax('list', res, res_url.join('&'), false, res_tar, '', '', pkg);
          } else {
            document.getElementById(res_tar).innerHTML = resposta;    
          }
          
          if(alvo.getAttribute('data-children')){
            var filhos = alvo.getAttribute('data-children');
            if(filhos.length > 0){ 
              fakeReset(filhos.split('|')); 
            }
          }

          if(sup){

              if (sup == 'filtror') { 
                par_menu = 'prm_menu='+sup+'&'+par_menu; 
              } else { 
                par_menu = 'prm_menu='+sup; 
              }
  
              call('menu', par_menu).then(function(resp){ 
                document.getElementById('painel').innerHTML = resp; 
                var prm_usu_origem = document.getElementById('prm_usuario_origem');
                if (prm_usu_origem) {
                  prm_usu_origem.style.setProperty('display', 'none');
                }  
              });
          }
        } else { 

            if(resposta.indexOf('FAIL DUPLICADO') != -1){
              alerta('feed-fixo', resposta.replace('FAIL DUPLICADO', ''));
            }else if(resposta.indexOf('FAIL FLOAT') != -1){  
              alerta('feed-fixo', resposta.replace('FAIL FLOAT', ''));
            }else if (resposta.indexOf('FAIL FILTRO') != -1){
              alerta('feed-fixo', resposta.replace('FAIL FILTRO', ''));
            }else {
              if (resposta.indexOf('ERRO|') >= 0 && resposta.split('|')[1].length > 0)  { 
                alerta('', resposta.split('|')[1], '', 'ERRO');   
              } else { 
                alerta('feed-fixo', TR_ER, resposta.replace('FAIL', ''));
              }  

            } 

        }

        if(load){
          document.getElementById(load).classList.remove('loading');
        }
      });
    } else {
      alerta('feed-fixo', TR_TC);
    }
  }

  // ivanor - testar se é necessário 
  //se reload recarrega objeto
  if(alvo.getAttribute('data-reload')){
    reload(alvo.getAttribute('data-reload'));
  }

  
  // Abre tela Modal para input dos comandos do processo de ETL   
  if (alvo.classList.contains("etl_modal_comando") || alvo.classList.contains("etl_modal_comando_limpar") ){

    let parente = alvo.parentNode.id,
        campo   = '',
        erro    = 'N';
    if (alvo.classList.contains("etl_modal_comando_limpar")) { 
      campo = 'COMANDO_LIMPAR';
    } else { 
      campo = 'COMANDO'; 
    }     
    call('etl_step_comando', 'prm_step_id='+parente+'&prm_coluna='+campo, 'etl').then(function(resposta){ 
      document.getElementById('modal-box').innerHTML = resposta; 
      if (resposta.split('|')[0] == 'ERRO') { 
        alerta('',resposta.split('|')[1]); 
        erro = 'S';
      }  
    }).then(function(){ 
      if (erro == 'N') { 
        setTimeout(function(){ 
          document.getElementById('modal'+parente).classList.add('expanded'); 
        }, 200); 

        let obj = 'modal-input-text'; 
        ace_editor = ace.edit(obj);
        ace_editor.session.setMode("ace/mode/sql");
      }  
    });
  }


};



document.addEventListener("change", function(e){
  var alvo = e.target;

  if(alvo.parentNode.classList.contains('columnline') && alvo.classList.contains('listener')){
    if(alvo.value != alvo.getAttribute('data-default')){

      var microVisao = document.getElementById('micro-visao').title;
      var coluna     = document.getElementById('ajax-lista').querySelector('.selected').title;
      var pai        = alvo.parentNode;
      var valor      = encodeURIComponent(alvo.value); 

      if(alvo.getAttribute('data-search') != 'S'){
        
        let campo = pai.getAttribute('data-campo'); 
        
        call('save_column', 'prm_visao='+microVisao+'&prm_name='+coluna+'&prm_campo='+campo+'&prm_valor='+valor+'&prm_screen='+tela).then(function(resposta){ 
          
          if (campo == 'FORMULA') { 
            alerta('feed-fixo', resposta.split('|')[1]); 
            if (resposta.split('|')[1] != 'ERRO') {
              alvo.setAttribute('data-default', alvo.value);  
            }
            if (resposta.split('|')[2].length > 0) {  // Se tem erro na fórmula, altera a cor da fonte para vermelho 
              alvo.style.setProperty('color', 'var(--vermelho-secundario)');
              document.getElementById('erro_coluna_formula').innerHTML = resposta.split('|')[2]+'.';
            } else {  
              alvo.style.setProperty('color', 'initial');
              document.getElementById('erro_coluna_formula').innerHTML = '';
            }  
          } else if (resposta.indexOf('#alert') == -1){
            alerta('feed-fixo', resposta); 
            alvo.setAttribute('data-default', alvo.value);
          } else {
            alerta('feed-fixo', TR_ER);
          } 
        });
      }
    }
  }

  if(alvo.classList.contains('user-password')){
    var linha = alvo.parentNode.parentNode.id.replace('linha', '');
    if(alvo.value.trim().length > 3){ 
      if(confirm(TR_CM)){ 
        ajax('fly', 'save_pwd', 'prm_senha='+encodeURIComponent(alvo.value)+'&prm_senha2='+encodeURIComponent(alvo.value)+'&prm_email=&prm_number=&prm_user='+linha+'&prm_nome='); 
        alvo.value = ''; 
      }
    } else { 
      alerta('msg', TR_SE_LE); 
    }
  }

  /* input de variavel de sistema */
  if(alvo.classList.contains('vsis-input')){
    
    var linha = alvo.parentNode.parentNode;
    var linhaDefault = linha.getAttribute('data-default');
    var linhaUsuario = linha.getAttribute('data-usuario');

    if(alvo.value != linhaDefault){
      call('edit_vconteudo', 'prm_variavel='+encodeURIComponent(linha.title)+'&prm_conteudo='+encodeURIComponent(alvo.value)+'&prm_usuario='+linhaUsuario).then(function(resposta){ 
        if(resposta.indexOf('#alert') == -1){
          alerta('', 'Valor alterado com sucesso!'); 
          linha.setAttribute('data-default', alvo.value);
        } else {
          alerta('', resposta.replace('#alert ', ''));
        } 
      });
    }
  }

  // Alteração da ordem da consulta/gráfico 
  //------------------------------------------------------------------------
  if(alvo.classList.contains('ordem') && alvo.parentNode.classList.contains('grafico')){
    let grafico = alvo.parentNode.id;
    let dados   = document.getElementById('dados_'+grafico);
    let troca   = document.getElementById(grafico).querySelector('.agrupador_troca');

    if (troca && troca.value != 'null' && troca.value != 'N/A') {  // Se foi definido agrupador de troca então não atualiza o atributo de ORDEM do objeto/gráfico 
      renderChartDirect(grafico); 
    } else { 
      //call('alter_attrib', 'prm_objeto='+grafico.split('trl')[0]+'&prm_prop=ORDEM&prm_value='+alvo.value+'&prm_usuario='+USUARIO+'&prm_screen='+tela.trim() ).then(function(res){ 
      call('alter_attrib', 'prm_objeto='+grafico+'&prm_prop=ORDEM&prm_value='+alvo.value+'&prm_usuario='+USUARIO+'&prm_screen='+tela.trim() ).then(function(res){         
        if(res.indexOf('alert') == -1){ 
          renderChartDirect(grafico); 
        } 
      });
    }   
  }


  // Adicionando agrupadores para troca de coluna no gráfico - 31/01/2022 
  //------------------------------------------------------------------------------------
  if(alvo.classList.contains('agrupador_troca') && alvo.parentNode.classList.contains('grafico')) {

    let grafico    = alvo.parentNode.id;
    let dados      = document.getElementById('dados_'+grafico);
    let agrup_real = dados.getAttribute('data-agrupadoresreal'); 
    let ordem      = document.getElementById(grafico).querySelector('.ordem'); 

    // Remove da lista de ordens os campos agrupadores atuais
    for (let i=0; i<ordem.length; i++) {
      let col_real = ordem.options[i].value.substring(2, 200);   // retira o r_ do inicio da string
      if (col_real.indexOf(' ') != ' ') { 
        col_real = col_real.substring(0,col_real.indexOf(' ') ); // Pega o nome do campo somente até o primeiro espaço em branco, para retirar o ASC ou DESC 
      }
      if (agrup_real.indexOf(col_real) != -1 && ordem.options[i].value != 'N/A' ) {      
        ordem.remove(i);
        i = i - 1;    
      }
    } 

    // Adiciona na lista de ordens o campo selecionando para troca 
    var opt = document.createElement('option');
    opt.value = 'r_' + alvo.value + ' ASC';
    opt.innerHTML = alvo.options[alvo.selectedIndex].text + ' crescente'; 
    ordem.appendChild(opt);
    opt = document.createElement('option');
    opt.value = 'r_' + alvo.value + ' DESC';
    opt.innerHTML = alvo.options[alvo.selectedIndex].text + ' decrescente'; 
    ordem.appendChild(opt);

    // Altera os dados do gráfico para seguir o campo de troca escolhido  
    dados.setAttribute('data-agrupador_troca', alvo.value ) ; 
    dados.setAttribute('data-agrupadoresreal', alvo.value ) ;  
    dados.setAttribute('data-agrupadores', alvo.options[alvo.selectedIndex].text ) ;  

    renderChartDirect(grafico); 
  }


});

function add_coluna(tpt){
  var coluna = document.getElementById('add_coluna').value; 

  var regex = new RegExp('^[a-zA-Z0-9_]+$'); 

  if(regex.test(coluna)){ 
    if(coluna.trim().length > 1){ 
      var visao = document.getElementById('micro-visao').title; 
      if(visao.trim().length != 0){ 
        call('savecolumn', 'p_cd_coluna='+coluna+'&p_visao='+visao+'&prm_template='+tpt).then(function(res){
          if(res.indexOf('existe') == -1 && res.indexOf('Erro') == -1){
            alerta('feed-fixo', TR_AD); 
            document.getElementById('content').value = '';
            let colunas = get('painel-colunas').getAttribute('data-colunas');
            setTimeout(function(){
              call('load_crocks', 'prm_visao='+document.getElementById('telasup').getAttribute('data-visao')+'&prm_valores='+colunas).then(function(resposta){
                document.getElementById('painel-colunas').innerHTML = resposta;
              }).then(function(){
                smoothScroll2('container-colunas', coluna.toUpperCase()+'id');
                document.getElementById(coluna.toUpperCase()+'id').click();
                document.getElementById('add_coluna').value = '';
              });
            },500);
          } else {
            alerta('feed-fixo', res); 
          }
        });
      } else { 
        alerta('msg', TR_ES_VW); 
      }
    } else { 
      alerta('msg', TR_NM_LE); 
    }
  } else { 
    alerta('msg',TR_VI); 
  } 
}

function edit_view(){

  ace_editor.setValue('');

  var arr = document.getElementById('painel').querySelector('.fakelistbox').querySelectorAll('.opt');
  var psh = [];
  
  for(let r=0;r<arr.length;r++){
    psh.push(arr[r].title);
  }

  var nome = document.getElementById('view_list').title;

  var novo;
  if(psh.indexOf(nome) != -1){ 
    novo = false;
  } else { 
    novo = true;
  }

  document.getElementById('sandbox').contentWindow.document.body.innerHTML = ('<form id="zebra" name="zebra" method="post" action="'+OWNER_BI+'.fcl.passagem_test"><input id="nome" type="hidden" name="nome" value="'+nome+'" /><input id="parsecheck" name="parseonly" type="hidden" value="N"/></form>');

  if(!novo){ 
    //ace_editor.setValue(''); 
    document.getElementById('sandbox').contentWindow.document.getElementById('nome').value = document.getElementById('view_list').title; 
    //var valor = new Array(); 
    for(let i=0;i<21;i++){ 
      ajax('slice', 'load_dado', 'prm_nome='+nome+'&prm_tipo=view&prm_time='+i, 'false', 'slice', i);  
    }  
  } 
  
}

function openText(){
  document.getElementById('text-talk').setAttribute('data-objeto', ''); 
  document.getElementById('text-talk').setAttribute('data-line', ''); 
  if(document.getElementById('text-talk').className == 'open'){ 
    clearInterval(textTalk); 
  } 
  //ajax('list', 'text_post', 'prm_objeto=&prm_line=&prm_group='+this.document.getElementById('usuario-msg').title, true, 'campo');
  document.getElementById('text-talk').classList.toggle('open'); 
  get('campo').innerHTML = '';
  call('listContainer', '').then(function(res){
    document.querySelector('.list_container').innerHTML = res;
  });
}

function closeSideBar(obj){
  
  if(document.getElementById('text-talk')){
    if(obj != 'text-talk'){
      document.getElementById('text-talk').classList.remove('open');
    }
  }

  if(document.getElementById('get_float')){
    if(obj != 'get_float'){
      document.getElementById('get_float').classList.remove('open');
    }
  }

  if(document.getElementById('obs-field')){
    if(obj != 'obs-field'){
      document.getElementById('obs-field').classList.remove('open');
    }
  }

  if(document.getElementById('perfil')){
    if(obj != 'perfil'){
      document.getElementById('perfil').classList.remove('open');
    }
  }

  if(document.getElementById('popupmenu')){
    if(obj != 'popupmenu'){
      document.getElementById('popupmenu').classList.remove('visible');
      document.getElementById('popupmenu').innerHTML = '';
    }
  }

  if(document.getElementById('prefdrop')){
    if(obj != 'prefdrop'){
      document.getElementById('prefdrop').classList.remove('hover');
    }
  }

  if(document.getElementById('attriblist')){
    if(obj != 'attriblist'){
      document.getElementById('attriblist').classList.remove('open');
      document.getElementById('attriblist').innerHTML = '';
    }
  }

  if(document.getElementById('floatlist')){
    if(obj != 'floatlist'){
      document.getElementById('floatlist').classList.remove('open');
      document.getElementById('floatlist').innerHTML = '';
    }
  }
}

document.addEventListener('change', function(e){
  if(e.target.id == 'data-coluna'){
    let tplig = e.target.options[e.target.selectedIndex].getAttribute('data-tipo'); 
    if( tplig == 'ligacao' || tplig == 'ligacaoc' || tplig == 'listboxp' || tplig == 'listboxt' || tplig == 'listboxtd' || tplig == 'listboxtcd'){ 
      document.getElementById('data_list').children[1].classList.add('ligacao');
      document.getElementById('browser-condicao').nextElementSibling.id =  e.target.value;
      document.getElementById('browser-condicao').nextElementSibling.title =  '';  
      document.getElementById('browser-condicao').nextElementSibling.children[0].innerHTML =  '';  
    } else { 
      if(document.getElementById('browser-condicao').value != 'nulo' && document.getElementById('browser-condicao').value != 'nnulo'){
        document.getElementById('data_list').children[1].classList.add('ligacao');
      }
      document.getElementById('data_list').children[1].classList.remove('ligacao'); 
    }
  }
});

function excluirModelo(){
  var varmodelo = document.getElementById("import-tabela-ut").value;

  call('excluir_modelo','prm_modelo='+varmodelo, 'imp').then(function(resposta){
    //Esse Index testa se o FAIL existe no htp.p do backend, o ==-1 serve para analisar a condição do FAIL não estar localizado no htp.p...Mandando uma msg de TR_EX(Excluido com sucesso)...
    if(resposta.indexOf('FAIL')==-1){
        alerta('mensagem', TR_EX); 
        call('main', 'prm_modelo=', 'imp').then(function(resposta){ document.getElementById('content').innerHTML = resposta; });
    } else {
        alerta('mensagem', resposta.replace('FAIL', ''));
    }
  });
}

function addVarconteudo(){
  var valor = document.getElementById('valor').value; 
  var vusuario = document.getElementById('filtro-usuario').title; 
  if(valor.trim().length < 1){ 
    alerta('msg', TR_NM_LE1); 
  } else { 
    if(vusuario.length < 3){ 
      alerta('msg', TR_EU); 
    } else { 
      call('add_vconteudo', 'prm_variavel='+valor+'&prm_usuario='+vusuario+'&prm_lock='+document.getElementById('locked').value).then(function(resposta){ 
        if(resposta.indexOf('OK') != -1){ 
          alerta('feed-fixo', TR_AD); 
          document.getElementById('valor').value = ''; 
          call('list_vconteudo', 'prm_usuario='+vusuario+'&prm_todo=N').then(function(inside){ 
            document.getElementById('conf_ajax').innerHTML = inside; 
          });  
        } else { 
          alerta('feed-fixo', TR_ER); 
        } 
      });
    }
  }
}

function addObjeto(){
  checkError(); 
  var nome = document.getElementById('nome').value.trim(); 
  if(nome.length < 4){ 
    alerta('msg', TR_NM_LE); 
  } else { 
    if(document.getElementById('fake_grupo').title != ''){ 
      var tipo = document.getElementById('tipo').title; 
      if(tipo.length > 0){ 
        var tabela = ''; 
        if(tipo == 'BROWSER' || tipo == 'CONSULTA'){ 
          tabela = document.getElementById('lista-tabelas').title; 
        } 
        if((tipo == 'BROWSER' && tabela.length > 0) || tipo != 'BROWSER'){ 
          call('save_obj', 'prm_nome='+encodeURIComponent(nome)+'&prm_atributo='+OWNER_BI+'.fcl.download?arquivo='+document.getElementById('fake_img_new').title+'&prm_grupo='+document.getElementById('fake_grupo').title+'&prm_tipo='+tipo+'&prm_visao='+tabela).then(function(resposta){ 
            if(resposta.indexOf('FAIL') != -1){ 
              alerta('feed-fixo', TR_ER); 
            } else { 
              if(resposta.indexOf('ERROCOLUNA') != -1){ 
                alerta('feed-fixo', TR_ER); 
              } else { 
                alerta('feed-fixo', TR_AD); 
              } 
            } 
            ajax('list', 'list_objetos', 'prm_tipo='+tipo+'&prm_screen='+tela, false, 'ajax'); 
            document.getElementById('tipo-objeto').value = tipo; 
            carregaPainel('objetos'); 
          }); 
        } 
        if(tipo == 'SCREEN'){ 
          ajax('list', 'screen_list', '', true, 'floatops'); 
        } 
      } 
    } else { 
      alerta('msg', TR_ES_GR); 
    } 
  }
}

function enviodecampos(clickconcluir){

    var nome             = encodeURIComponent(document.getElementById('boxnome').value.trim());
    var email            = document.getElementById('boxemail').value.trim();
    var celular          = document.getElementById('boxcelular').value.trim();
    var senha            = encodeURIComponent(document.getElementById('boxsenha').value.trim());
    var notificacao      = [];

    notificacao.push('celular');
    notificacao.push('email');

    notificacao = notificacao.join('|');

    if (clickconcluir == 'enviar'){
       
            if (nome.length == 0 || email.length == 0 || celular.length == 0 || senha.length == 0){
                alerta('feed-fixo', TR_TC);
                return;                
            }
 
            if (nome.length <= 3 && nome.length != 0) {
                alerta('feed-fixo', TR_NM_LE);
                return;                
            }
  
            if (email.length <= 5 && email.length != 0) {
                alerta('feed-fixo', TR_EI); 
                return;                 
            }
  
            if (senha.length < 6 || !senha.match((/[0-9]+/g)) || !senha.match((/[a-zA-Z]+/g))) {
              alerta('feed-fixo', TR_SE_LE);
                return;                
            }

            if (celular.length < 8 && celular.length != 0) {
                alerta('feed-fixo', 'Número de celular deve conter 8 ou mais caracteres.');
                return;                 
            }

            call('userinfo','prm_nome='+nome+'&prm_email='+email+'&prm_cell='+celular+'&prm_notificacao='+notificacao+'&prm_senha='+senha).then(function(resposta){          
             
              if (resposta.split('|')[0] !== 'OK') { 
                alerta('feed-fixo', resposta.split('|')[1]);
                return; 
              } else {
                  if(resposta.indexOf('#alert') == -1){ 
                    curtain(); 
                    alerta('feed-fixo', TR_CA); 
                    setTimeout(function(){ 
                      window.location.reload(true); 
                    }, 500);
                  } else {
                    alerta('feed-fixo', resposta.replace('#alert ', ''));
                  }                   
              } 

          });
        

    }
}


document.addEventListener('keypress', function(e){
  var tecla = e.which;
  var alvo = e.target;

  if(alvo.id=='boxemail'){  

    if('abcdefghijklmnopqrstuvwxyzçABCDEFGHIJKLMNOPQRSTUVWXYZÇ@._1234567890'.indexOf(String.fromCharCode(tecla)) != -1){ return true; } else { e.preventDefault(); return false; }

  }

  if(alvo.id=='boxcelular'){ 
    VMasker(document.getElementById("boxcelular")).maskPattern("(99) 999999999999");

    if(alvo.value.length > 17){ e.preventDefault(); return false; }
    
    if('1234567890'.indexOf(String.fromCharCode(tecla)) != -1){ return true; } else { e.preventDefault(); return false; }

  }

 });

function setMicroAgrupador(){
  if(document.getElementById('micro-agrupador')){ 
    document.getElementById('micro-agrupador').title = ''; 
    document.getElementById('micro-agrupador').children[0].innerHTML = document.getElementById('micro-agrupador').children[0].getAttribute('data-placeholder'); 
  } 
}

function ver_logs(){
  var log = document.getElementById('logs_recentes');
  var valor = 'select dt_log as DATA, vl_query as QUERY, ds_log as STATUS from BI_LOG_QUERY';

  call('exec_query', 'p_query='+encodeURIComponent(valor)+'&p_parse=N&p_linhas=9999999').then(function(resposta){
    document.getElementById('queryresult').innerHTML = resposta;
    document.getElementById('queryresult2').innerHTML = resposta;
  });
  
}

//LIXOS unificados do sistema:

document.addEventListener('click', function(e){

  //Alvo pressionado
  var alvo = e.target;

  // Se não existe 2 parents no alvo, intenrrope a execução do click, não faz parte dos objetos LIXO  
  if (!alvo.parentNode || !alvo.parentNode.parentNode) { 
    return; 
  }

  var linha = alvo.parentNode.parentNode;
  var vlprms = '';

  if(alvo.classList.contains('remove') && linha){

    var req       = alvo.getAttribute('data-require');        //Nome da procedure 
    var parm      = alvo.getAttribute('data-param');          //Parametros passados
    var vlobjetos = alvo.getAttribute('data-valor');          //Valores a serem passados nos parametros(sequencial)
    var vldecode  = alvo.getAttribute('data-decode');         //Numero da coluna para fazer o decode
    var objeto    = alvo.getAttribute('data-objeto');         // ID do objeto da tela 
    var pkg       = alvo.getAttribute('data-pkg') || 'FCL';   // Package 

    // Se não foi informado a procedure, cancela exclusão 
    if (!req)  {  
      return false; 
    }

    if(get('attriblist').classList.contains('open')){
      get('attriblist').classList.remove('open');
    }

    if(document.getElementById(objeto)){
      if(document.getElementById(objeto).parentNode.tagName == 'ARTICLE'){ 
        var superior = document.getElementById(objeto).parentNode.id;
      } else { 
        var superior = tela;
      }  
      vlprms = 'prm_cod='+objeto+'&prm_tela='+superior;
    } else {

      if (req === 'remove_image' && vlobjetos.includes('|') && vlobjetos.indexOf('|') !== vlobjetos.lastIndexOf('|')) {

        var parts = vlobjetos.split('|');

        if (parts.length > 1) {
          var firstPart = parts.shift();
          
          if (firstPart.endsWith('*')) {
            firstPart = firstPart.slice(0, -1);
          }
    
          var remainingPart = parts.join('|');

          if (remainingPart.startsWith('*')) {
              remainingPart = remainingPart.slice(1);
          }
          var valor = [firstPart, remainingPart]; 
        }

    } else {
        if (vlobjetos.includes('*|*')) {
          var valor = vlobjetos.split("*|*")
        } else {
          var valor = vlobjetos.split("|");
        }
    }

      var parm2 = parm.split("|");
      // var valor = vlobjetos.split("|");
      var url = [];

      for(let i=0;i<parm2.length;i++){
        if(vldecode == i){
          url.push(parm2[i]+'='+encodeURIComponent(valor[i]));
        } else {
          url.push(parm2[i]+'='+valor[i])
        }
        vlprms = url.join("&");
      }
    }

    if(confirm(TR_CE)) {

      linha.classList.add("removing"); 
      call(req, vlprms, pkg).then(function(resposta){ 
        
        if(resposta.indexOf("FAIL") == -1 && resposta.indexOf("ERRO|") ){
          alerta('feed-fixo', TR_EX);
          if (req.toLowerCase() == 'favoritar') { 
            document.getElementById('id_atualizar_menu').value = 'S';  
          }

          if(alvo.parentNode.tagName == 'LI'){
            alvo.parentNode.remove();
          } else if(alvo.parentNode.tagName == 'DIV' && alvo.parentNode.id == "content"){
              var visao = document.getElementById('micro-visao').title;
              document.getElementById('content').innerHTML = '';
            ajax('list', 'load_crocks', 'prm_visao='+visao+'&prm_completo=N', 'true', 'ajax-lista');
          } else if(document.getElementById('custom-conteudo')){
              let lista = document.getElementById('lista-custom-fav');
              lista.title = '';
              lista.children[0].innerHTML = 'CONSULTA ATUAL';
              var objCustom = lista.previousElementSibling ; 

              restoreCustom(lista.previousElementSibling);
          } else {

            linha.remove();
            if(document.getElementById(objeto)){
              document.getElementById(objeto).remove();
            }
          }                     
        } else {
          linha.classList.remove("removing");
          if(document.getElementById(objeto)){
            document.getElementById(objeto).classList.remove("removing");
          }
          if (resposta.indexOf("ERRO|") != -1) { 
            alerta('',resposta.split('|')[1],'','ERRO');
          } else {
            alerta('', TR_ER, '', 'ERRO');  
          }

        }
      });
    }
  }
});

function save_usuario(){
  var senha1       = encodeURIComponent(document.getElementById('senha1').value); 
  var email        = document.getElementById('email').value;
  var numero       = document.getElementById('number').value;
  var nome         = encodeURIComponent(document.getElementById('completo').value);
  var tela_ini_usu = document.getElementById('cd_tela_inicial_usuario').title.trim();

    call('save_pwd', 'prm_user='+USUARIO+'&prm_senha='+senha1+'&prm_email='+email+'&prm_number='+numero+'&prm_nome='+nome+'&prm_tela_inicial='+tela_ini_usu).then(function(resposta){ 
      if(resposta.indexOf('#alert') == -1){ 
        curtain(); 
        alerta('feed-fixo', TR_AL); 
        setTimeout(function(){ 
          window.location.reload(true); 
        }, 1500);
      } else {
        alerta('feed-fixo', resposta.replace('#alert ', ''));
      } 
    });
}

function attReopen(fun, classe){
  let attrib = document.getElementById(classe);
  if(attrib.classList.contains('open')){
    attrib.classList.remove('open');
    setTimeout(function(){
      //attrib.classList.remove('vertical');
      //attrib.classList.remove('horizontal');
      closeSideBar(classe); 
      //setTimeout(function(){ 
        attrib.innerHTML = ""; 
        //setTimeout(function(){
          //attrib.classList.add(classe);
          loader(classe); 
          setTimeout(function(){
            attrib.classList.add('open');
          }, 100);
          setTimeout(fun, 50);
        //}, 200);
        
      //}, 200);
    }, 100);
    
  } else {
    //attrib.classList.remove('vertical');
    //attrib.classList.remove('horizontal');
    //attrib.classList.add(classe);
    loader(classe); 
    setTimeout(fun, 50);
    setTimeout(function(){
      attrib.classList.add('open');
    }, 100);
    
  }
  
}

function templateMarcado(dis, objeto, view){
  if(dis.className == 'green'){ 
    dis.className = ''; 
  } else { 
    dis.className = 'green'; 
  } 
  var lista = dis.parentNode.querySelectorAll('.green'); 
  var tpt = ''; 
  for(let i=0; i<lista.length; i++){ 
    tpt = tpt+'|'+lista[i].title; 
  } 
  ajax('fly', 'template', 'prm_objeto='+objeto+'&prm_valor='+tpt+'&prm_view='+view, false);
}

function movingArticle(event){
  event.stopPropagation(); 
  if(document.querySelector('.movingarticle')){ 
    document.querySelector('.movingarticle').classList.remove('movingarticle'); 
  } 
  if(document.querySelector('.hoverchangearticle')){ 
    document.querySelector('.hoverchangearticle').classList.remove('hoverchangearticle'); 
  }
}

function getvalue(ele){
  if(ele.classList.contains('fakeoption')){
    return ele.title;
  } else {
    return ele.value;
  }
}

function getFileName(dis){
  
  dis.innerHTML = 'CARREGANDO ARQUIVO';
  var botao = document.getElementById('painel').querySelector('iframe').contentWindow.document.body.children[0].children[0];
  botao.setAttribute('data-arquivo', '');
  botao.click(); 
  uploadFile = setInterval(function(){ 
    if(botao.getAttribute('data-arquivo').length > 0){
      dis.classList.add('loading'); 
      let botaoSplit = botao.getAttribute('data-arquivo').split('|');
      dis.innerHTML = botaoSplit[botaoSplit.length-1].toUpperCase();
      botao.setAttribute('data-arquivo', '');
      dis.classList.remove('loading'); 
      clearInterval(uploadFile);
    } 
  }, 100);

}

function passChange(dis, usu){
  //ver 1.5.5
  if(!dis.getAttribute('data-changed')){
    if(dis.value.trim().length > 6 && dis.value.match((/[0-9]+/g)) && dis.value.match((/[a-zA-Z]+/g))/*&& dis.value.match(/[A-Z]+/g)*/){
      if(confirm(TR_CM)){
        call('save_pwd', 'prm_senha='+encodeURIComponent(dis.value)+'&prm_email=&prm_number=&prm_user='+usu+'&prm_nome=').then(function(res){
          dis.value = '';
          if(res.indexOf('#alert' == -1)){
            alerta('msg', TR_SA);
          } else {
            alerta('msg', TR_ER_SE);
          }
        });
      }
    } else {
      alerta('msg', TR_SE_LE);
    }
  }
  if(dis.getAttribute('data-changed') == 'S'){
    if(dis.value.trim().length > 6 && dis.value.match((/[0-9]+/g)) && dis.value.match((/[a-zA-Z]+/g))/*&& dis.value.match(/[A-Z]+/g)*/){
      if(confirm(TR_CM)){
        call('save_pwd', 'prm_senha='+encodeURIComponent(dis.value)+'&prm_email=&prm_number=&prm_user='+usu+'&prm_nome=').then(function(res){
          dis.value = '';
          dis.setAttribute('data-changed', 'N');
          if(res.indexOf('#alert' == -1)){
            alerta('msg', TR_SA);
          } else {
            alerta('msg', TR_ER_SE);
          }
        });
      }
    } else {
      alerta('msg', TR_SE_LE);
    }
  }
}

function montaCustom(){
  var arr = []; 
  var filtroPipe = document.getElementById('filtropipe'); 
  var coluna = document.getElementById('filtroc-coluna').title; 
  var condicao = document.getElementById('filtroc-condicao').title; 
  var valores = document.getElementById('filtroc-valores').title; 
  if(valores.length > 0 && coluna.length > 0 && condicao.length > 0){ 
    arr.push(filtroPipe.title); 
    arr.push(coluna+'|$['+condicao+']'+valores); 
    var resultado = arr.filter(n => n).join('||'); 
    if(filtroPipe.title.indexOf(coluna+'|'+'$['+condicao+']'+valores) == -1){ 
      filtroPipe.title = resultado; 
      fakeReset(['filtroc-valores']); 
      document.getElementById('gerar-custom').click(); 
    } else { 
      alerta('fix', 'Filtro ja existe!'); 
    } 
  }
}

function removeCustomFiltro(dis){
  if(confirm(TR_CE)){ 
    var pipe = document.getElementById('filtropipe');

    pipe.title = pipe.title.split('||').filter(function(a){
      if(a != dis.title){
        return a;
      }
    }).join('||')
    
    document.getElementById('gerar-custom').click(); 
  }
}

function requestDefault(req, par, dis, val, obj, pkg, onFail){

  // Valida valor passado por parametro 
  if(dis.hasAttribute('data-default')){
    if(val == dis.getAttribute('data-default')){
      return false;
    }
  }
  if(dis.previousElementSibling){
    if(dis.previousElementSibling.classList.contains('default')){
      if(dis.previousElementSibling.innerHTML == val){
        return false;
      }
    }
  }
  if(dis.getAttribute('data-min')){
    if(val.length < parseFloat(dis.getAttribute('data-min')) ){
      alerta('', 'Campo deve ser preenchido','','ERRO');
      return false;
    }
  }

  call(req, par, pkg||'COM').then(function(resposta){ 
    if(resposta.split('|')[0] == 'OK'){ 
      if (resposta.split('|')[1]) { 
        alerta('', resposta.split('|')[1]); 
      } else {
        alerta('', TR_AL); 
      }  
      
      // Atualiza atributos referente ao valor 
      if(dis.hasAttribute('data-default')){
        dis.setAttribute('data-default', val);
        if(obj){
          obj.innerHTML = val;
        }
      }
      if(dis.previousElementSibling){
        if(dis.previousElementSibling.classList.contains('default')){
          dis.previousElementSibling.innerHTML = val;
          if(obj){
            obj.innerHTML = val;
          }
        }
      }
      if(dis.nextElementSibling){
        var adic = dis.nextElementSibling.getAttribute('data-adicional');
        if ( resposta.split('|')[2]  &&  adic && dis.nextElementSibling.id.indexOf('prm_objeto') != -1 ) { 
          var obj = document.getElementById('prm_ds_tp_objeto_' + adic); 
          if (obj) {
            obj.value = resposta.split('|')[2]; 
          }
        }
      }  
    } else { 
      if (resposta.split('|')[1].length > 0) { 
        alerta('', resposta.split('|')[1],'','ERRO'); 
      } else {   
        alerta('', TR_ER,'','ERRO'); 
      }  
      if (typeof onFail === "function"){
        onFail();
      }
    } 
  });
}

function pellLaunch(num, barra){
  action = [
              {
                name: 'bold',
                icon: '<b>N</b>',
                title: 'Negrito (Bold)',
              },
              {
                name: 'italic',
                title: 'Itálico',
                result: () => pell.exec('italic')
              },
              {
                name: 'underline',
                icon: '<u>S</u>',
                title: 'Sublinhado',
              },
              {
                name: 'center',
                icon: 'centeralign',
                title: 'Centralizar',
                result: () => pell.exec('justifyCenter')
              },
              {
                name: 'left',
                icon: 'leftalign',
                title: 'Alinhar à Esquerda',
                result: () => pell.exec('justifyLeft')
              },
              {
                name: 'right',
                icon: 'rightalign',
                title: 'Alinhar à Direira',
                result: () => pell.exec('justifyRight')
              },
              {
                name: 'full',
                icon: 'fullalign',
                title: 'Justificar',
                result: () => pell.exec('justifyFull')
              },
              {
                name: 'size',
                icon: 'fontsize',
                title: 'Tamanho Texto/Título',
                result: () => {
                  const SIZE = window.prompt('Digite o tamanho do texto entre 1 e 7');
                  if(SIZE){ pell.exec('fontSize', SIZE); }
                }
              },
              {
                name: 'link',
                title: 'Adicionar um link ao texto',
                result: () => {
                  const URL = window.prompt('Informe a URL do link')
                  if (URL) pell.exec('createLink', URL)
                }
              },
              {
                name: 'image',
                title: 'Adicionar um imagem',                
                result: () => {
                  const LINK = window.prompt('Informe a URL da imagem')
                  if (LINK) pell.exec('insertImage', LINK)
                }
              },
              /*** Adiciona as tags ao texto mas não mostra 
              {
                name: 'olist',
                icon: '&#35;',
                title: 'Lista ordenada',
                result: () =>  document.execCommand('insertOrderedList', false)
              },
              {
                name: 'ulist',
                title: 'Lista',
                result: () =>  document.execCommand('insertUnorderedList', false) 
              },
              ****************/ 
              {
                name: 'line',
                title: 'Linha Horizontal',
              }
             ] ; 

  if(!document.getElementById('pell-editor'+num).children[0]){
    pell.init({
      element: document.getElementById('pell-editor'+num),
      onChange: html => {
        document.getElementById('modal-output'+num).textContent = html
      },
      styleWithCSS: true,
      actions: action,
      classes: {
        size: 'size'
      }
    })
  }
}

function autoUpdateTodos (tipo_atualizacao){

  var tbody = document.getElementById('tbody_lista_autoupdate'); 
  var qt_upd = 0;
    
  // Cria função do tipo assincrona para chamada das baixas/atualizações 
  const executaPendentes = async () => {
    for (etr of tbody.querySelectorAll("tr") ) { 
      for (etd of etr.querySelectorAll("td") ) {       
        if ( ( (tipo_atualizacao == 'BAIXA' && etd.classList.contains('td-baixa')) || ( tipo_atualizacao == 'ATUALIZA' && etd.classList.contains('td-atualiza')) ) &&  
              etd.querySelector('a').classList.contains('upd') && !etd.querySelector('a').classList.contains('blocked') ) { 
          qt_upd = qt_upd + 1;         
          const retorno = await autoUpdate(etd.querySelector('a'), tipo_atualizacao, 'TODOS');
          if (retorno != 'ok') { 
            alerta('feed-fixo', retorno ) ; 
            return false;  // Cancelar/parar a execução 
          }
        }  
      }  
    }
    if (qt_upd == 0) { 
      alerta('feed-fixo', 'Nenhum objeto pendente') ; 
    }  
    else {   
      if (tipo_atualizacao == 'BAIXA') {
        alerta('feed-fixo', qt_upd + ' objetos baixados com sucesso') ; 
      } else { 
        alerta('feed-fixo', qt_upd + ' objetos atualizados com sucesso') ; 
      }  
    }
  };

  executaPendentes();
 
}
 

function autoUpdate(ele, tipo_atualizacao, tipo_execucao){  
    var eleTR = ele.parentNode.parentNode; 
    
    var req, param, pkg, v_children; 
    var sistema = eleTR.getAttribute('data-sistema'),
        versao  = eleTR.getAttribute('data-versao'), 
        usuario = eleTR.getAttribute('data-usuario'),
        tipo    = eleTR.getAttribute('data-tipo'), 
        nome    = eleTR.getAttribute('data-nome');    
    
    ele.classList.toggle('loading');   
    if (tipo_atualizacao == 'BAIXA') { 
      ele.innerText = 'Baixando ...';
      pkg        = 'upd';
      req        = 'AutoUpdate_baixa_conteudo';
      param      = 'prm_sistema='+sistema+'&prm_versao='+versao+'&prm_usuario='+usuario+'&prm_tipo='+tipo+'&prm_nome='+nome+'&prm_chamada=NAVEGADOR';
      v_children = 6; 
  
    } else { 
      ele.innerText = 'Atualizando ...';
      if (nome == 'UPD') { 
        pkg        = 'sch';
        req        = 'autoUpdate_atu_PACKAGE';
        param      = 'prm_usuario='+usuario+'&prm_tipo='+tipo+'&prm_nome='+nome+'&prm_chamada=NAVEGADOR';
      } else if (tipo == 'ESTADOS' || tipo == 'CIDADES') {
        pkg        = 'upd';
        req        = 'autoUpdate_CIDADES_ESTADOS';
        param      = 'prm_usuario='+usuario+'&prm_tipo='+tipo+'&prm_chamada=NAVEGADOR';
      } else {   
        pkg        = 'upd';
        req        = 'AutoUpdate_atu_sistema';
        param      = 'prm_usuario='+usuario+'&prm_tipo='+tipo+'&prm_nome='+nome+'&prm_chamada=NAVEGADOR';
      }   
      v_children = 7;   
    }  
    
    // Só retorna depois de terminar a execução 
    return new Promise((resolve ,reject)=>{ 
      call(req, param, pkg).then(function(res){ 
        
        ele.classList.toggle('loading');
        
        if(res.indexOf('OK|') >= 0){
          ele.className = 'green ok';
          ele.setAttribute('onclick', '');
          ele.parentNode.parentNode.children[v_children].innerHTML = res.split('|')[1];
          ele.innerText = res.split('|')[2];
          if (tipo_execucao != 'TODOS') { 
            alerta('feed-fixo', res.split('|')[3]) ; 
          }
          // Se fez a baixa libera o botão da Atualização também 
          if (tipo_atualizacao == 'BAIXA') {  
            
            let ele2 = ele.parentNode.nextElementSibling.querySelector('a');

            if (tipo == 'AVISO') {
              ele2.innerHTML = 'Atualizado'; 
              ele2.className = 'green ok';
              ele2.setAttribute('onclick', "") ; 
            } else {
              ele2.innerHTML = 'Atualiza&ccedil;&atilde;o dispon&iacute;vel'; 
              ele2.className = 'upd';
              ele2.setAttribute('onclick', "autoUpdate(this, 'ATUALIZA');") ; 
            }  
          }   
          resolve('ok');  // Retorna           
        } else {
          ele.className = 'upd error';
          ele.innerText = res.split('|')[2];
          if (tipo_execucao != 'TODOS') { 
            alerta('feed-fixo', res.split('|')[3]) ; 
          }   
          resolve(res.split('|')[3]);  // Retorna           
        }
      });  
   } );  
}
 

//floats

function saveFloat(valor, padrao){
  document.getElementById('get_float').setAttribute('data-alterado', 'T'); 
  call('save_float', 'prm_conteudo='+encodeURIComponent(valor)+'&prm_padrao='+padrao+'&prm_screen='+tela).then(function(resposta){ 
    if(resposta.indexOf('FAIL') == -1){ 
      alerta('feed-fixo', TR_AL); 
    } else { 
      // alerta('feed-fixo', TR_EX); 
      alerta('feed-fixo', resposta.split('|')[1] );       
    }
  });
}

/* BOTÃO DO LOGIN */
function login(dis){
  var menu     = document.getElementById('login-menu');
  var login    = menu.querySelectorAll('.login-session')[0];
  var pass     = menu.querySelectorAll('.login-session')[1];
  var IPext    = '';  

  menu.className = 'loading'; 

  // Cria função do tipo assincrona para aguarda a chamada de verificacao do IP
  const executaAguarda = async () => {
    IPext = await callExt('https://api.ipify.org/');
    if (IPext.split('')[0] == '#ERRO') { 
      menu.className = 'shake'; 
      alerta('x', 'Erro na chamada de requisicao externa');
      setTimeout(function(){ 
        menu.className = ''; 
      }, 300);  
    } else {
      loginExec(IPext); 
    }  
  }  
  if (document.getElementById('sis-netwall-externo') && document.getElementById('sis-netwall-externo').value == 'S')  { 
    if(login.value.trim().length == 0 || pass.value.trim().length == 0){ 
      menu.className = 'shake'; 
      alerta('x', TR_TC);
      pass.value = ''; 
      setTimeout(function(){ 
        menu.className = ''; 
      }, 300); 
    } else { 
      executaAguarda();  // Executa o login, aguardando a busca do IP do usuário
    }  
  } else { 
    loginExec();  // Executa o login (não precisa validar o IP do usuário)
  }  
}


/* Chama o login do backend  */
function loginExec(IPext){
  var menu     = document.getElementById('login-menu');
  var login    = menu.querySelectorAll('.login-session')[0];
  var pass     = menu.querySelectorAll('.login-session')[1];
  
  menu.className = 'loading'; 

  var caminho   = window.document.location.pathname.split('/');
  var endpoint  = caminho.slice(0, caminho.length - 1).join("/") + "/"; 
  var url_local = window.location.protocol + '//'+(window.document.location.host+'/'+endpoint).replace('//', '/');
  var ws_email, ws_cod, ws_msg;  

  call('login', 'prm_user='+encodeURIComponent(login.value)+'&prm_password='+encodeURIComponent(pass.value)+'&prm_session=&prm_prazo=0.5'+'&prm_url='+url_local+'&prm_ip='+IPext).then(function(resposta){

    if (resposta.split('|')[0] == 'ERRO' || resposta.split('|')[0] == 'LOGINVALIDA' || resposta.split('|')[0] == 'LOGINEXPIRA') {        
        //shake
        menu.className = 'shake'; 
        pass.value = '';
        setTimeout(function(){ 
          menu.className = ''; 
        }, 300);
          
        if (resposta.split('|')[0] == 'LOGINEXPIRA') {
          ws_cod   = resposta.split('|')[1]; 
          ws_email = resposta.split('|')[2];
          ws_msg   = resposta.split('|')[3];
          if (ws_cod == 'OK') {
            ws_msg = TR_LO_ES.replace(':001',ws_email);     // mensagem de expiração da senha
            alerta('alert', ws_msg );
          } else {
            alerta('x', ws_msg);
          }  
        } else if (resposta.split('|')[0] == 'LOGINVALIDA') {
          ws_cod   = resposta.split('|')[1]; 
          ws_email = resposta.split('|')[2];
          ws_msg   = resposta.split('|')[3];
          if (ws_cod == 'OK') {
            ws_msg = TR_LO_VA.replace(':001',ws_email);     // mensagem de validação da identificação 
            alerta('alert', ws_msg );
          } else {
            alerta('x', ws_msg);
          }  
        } else {
          alerta('x', resposta.split('|')[2]);
        }
    } else {
        if (resposta.indexOf('LOGINSENHANOVA') !== -1 ) { 
          alerta('alert', TR_LO_ET ); 
        } else { 
          alerta('x', TR_LE);
        }   
        menu.className = 'logged'; 
        setTimeout(function(){                      //tempo para ler msg, criar cookie e então recarregar tela já devidamente logado
          window.location.reload(true);
        }, 500);  // 500
    }
  });

}



function recoverPassword(dis){
  var menu     = document.getElementById('login-menu');
  var login    = menu.querySelectorAll('.login-session')[0];
  var password = menu.querySelectorAll('.login-session')[1];

  var caminho   = window.document.location.pathname.split('/');
  var endpoint  = caminho.slice(0, caminho.length - 1).join("/") + "/"; 
  var url_local = window.location.protocol + '//'+(window.document.location.host+'/'+endpoint).replace('//', '/');

  if(login.value.length > 0){
    call('newPassword', 'prm_usuario='+login.value+'&prm_url='+url_local).then(function(resposta){
      if(resposta.indexOf('ACL') != -1){
        alerta('x', 'Problema no envio do email(ACL), favor contactar o administrador!');
      } else {
        alerta('x', resposta);
      }
    });
  } else {
    alerta('x', TR_IU);
  }
}


function restoreCustom(dis){

  // document.getElementById('custom-conteudo').innerHTML = '';
  if(dis.nextElementSibling.title.length > 0){
    document.getElementById('SECTION_CUSTOMIZACAO').classList.add('loading');       // Alterado para utilizar telacustom  
    let objcustom = dis.nextElementSibling.title.split('||')[0];
    appendar('prm_drill=C&prm_objeto='+objcustom+'&prm_zindex=1&prm_posx=&prm_posy=&prm_screen='+ tela + '&prm_dashboard=true' , '', '');
  }
}

function eraseCustom(){
  var conteudo = get('custom-conteudo');
  conteudo.innerHTML = '';
}

function deleteCustom(){
  var arr = get('lista-custom-fav', 'custom');
  var custom = arr[0].split('||')[0];
  call('deleteCustom', 'prm_custom='+custom).then(function(resposta){
    if(resposta.indexOf('EXCLUIDO') != -1){
      alerta('feed', 'TR_EX');
      arr[1].click();
    } else {
      alerta('feed', 'TR_ER');
    }
  });
}

function copyListBtn(usu){
  if(document.querySelector('.optionbox')){
    document.querySelector('.optionbox').remove();
  } else {
    call('copiarPermissaoBox', 'prm_usuario='+usu).then(function(resposta){
      let box = document.createElement('div');
      box.classList.add('optionbox');
      box.classList.add('reverse');
      box.innerHTML = resposta;
      box.style.setProperty('left', cursorx+20+'px');
      box.style.setProperty('top', cursory+10+'px');
      MAIN.appendChild(box);
      setTimeout(function(){
        box.classList.add('open');
      }, 100);
    });
  }
}

function copyUserBtn(usu){
  //var rules = get('regras').value;
  var rules = document.getElementById('regras').value;


  if((get('fake-copiar-permissao').title.length > 0) && ((rules == 'manter') || (rules == 'deletar'))){

    if (rules == 'manter'){
    var msg = TR_CA_US;
    }
    if(rules == 'deletar'){
      msg = TR_LR_US;
    }
    if(confirm(msg)){
      call('copiarPermissao', 'prm_usuario='+usu+'&prm_usuario_cop='+get('fake-copiar-permissao').title+'&prm_status='+rules).then(function(res){
        if(res.indexOf('ok') == -1){
          alerta('feed-fixo', TR_ER);
        } else {
          alerta('feed-fixo', TR_AL);
        }
        document.querySelector('.optionbox').remove();
      });
    }
  } else {
    alerta('feed-fixo', TR_TC);
  }
}

function blockOptions(dis){
  update_prop(get('ident').value, 'tipo', dis.value); 
  get('attriblist').children[0].setAttribute('data-alterado', 'T'); 

  get('coluna-sec').parentNode.parentNode.classList.remove('invisible');
  get('micro-coluna').parentNode.parentNode.classList.remove('invisible'); 

  if(dis.value == 'PIZZA' || dis.value == 'MAPA' || dis.value == 'MAPAGEOLOC'){ 
    get('coluna-sec').parentNode.parentNode.classList.add('invisible'); 
  } else if(dis.value == 'PONTEIRO') { 
    get('micro-coluna').parentNode.parentNode.classList.add('invisible');
    get('coluna-sec').parentNode.parentNode.classList.add('invisible');
  }

  get('micro-coluna').classList.add('multi');    
  if(dis.value == 'PIZZA' || dis.value == 'MAPA' || dis.value == 'PONTEIRO'){   
    get('micro-coluna').classList.remove('multi');    
  } 


}

function attribList(obj){

  var attriblist = get('attriblist');
  if(((event.offsetX < 367 && event.offsetX > 339) || (window.innerWidth < 500 && window.matchMedia('(orientation: portrait)').matches && event.offsetX < 221 && event.offsetX > 193)) && document.getElementById('fakelist').className != 'visible'){ 
    if(parseInt(get('fakelist').style.getPropertyValue('left')) > 0){
      get('fakelist').style.setProperty('left', '0');
      document.querySelector('.itens').innerHTML = '';
    }
    if(attriblist.children[0].children[0]){
      if(attriblist.children[0].getAttribute('data-alterado') == 'T'){
        attriblist.classList.remove('open');
        if(get(obj)){
          if(get(obj+'sync')){
            get(obj+'sync').click();
          } else {
            shscr(tela);
          }  
        } else { 
          shscr(tela);
        }
        attriblist.children[0].setAttribute('data-alterado', 'F'); 
      }  
    } 
    attriblist.className = ''; 
    setTimeout(function(){ 
      attriblist.innerHTML = ''; 
    }, 500); 
  }
}

function createUser(){
  var nome      = encodeURIComponent(get('nome').value); 
  var login     = get('login').value; 
  var senha     = encodeURIComponent(get('senha').value); 
  var email     = get('email').value;
  var email_usu = get('email_usuario').value;
  var grupo     = get('usuario-grupo').title;
  var permissao = get('fake-permissao').title; 
  if(nome.length < 1){ 
    alerta('msg', TR_NM_LE1); 
  } else { 
    if(login.trim().length < 3){ 
      alerta('msg', TR_LO_LE); 
    } else { 
      if(senha.trim().length < 6 || !senha.match((/[0-9]+/g)) || !senha.match((/[a-zA-Z]+/g))){ 
        alerta('msg', TR_SE_LE); 
      } else { 
        get('scroll').classList.add('saving') 
        var regex = new RegExp('^[a-zA-Z0-9.]+$'); 
        if(regex.test(login)){ 
          if(email.length > 0){ 
            call('save_user', 'prm_nome='+login+'&prm_completo='+nome+'&prm_status=&prm_email='+email_usu+'&prm_senha='+senha+'&prm_permissao='+permissao+'&prm_grupo='+grupo).then(function(resposta){ 
              if(resposta.indexOf('FAIL') == -1){ 
                alerta('feed-fixo', TR_CR); 
                get('scroll').classList.remove('saving');
                ajax('list', 'list_users', '', false, 'content'); 
                carregaPainel('usuarios'); 
              } else { 
                get('scroll').classList.remove('saving')
                alerta('feed-fixo', resposta.replace('FAIL ', '')); 
              } 
            }); 
          } else { 
            noerror('', TR_EI, 'msg'); 
          } 
        } else { 
          alerta('msg', TR_LO_LI); 
        } 
      }
    }
  } 
}

function screenObs(){
  document.getElementById('obs-field').innerHTML = get('tela-atual').children[1].getAttribute('data-obs');
  document.getElementById('obs-field').classList.toggle('open');
}

function objObs(txt){

  if(document.querySelector('.optionbox')){
    document.querySelector('.optionbox').remove();
  } else {
    //call('copiarPermissaoBox', 'prm_usuario='+usu).then(function(resposta){
      let box = document.createElement('div');
      box.classList.add('optionbox');
      box.classList.add('obsbox');
      //box.classList.add('reverse');
      
      box.innerHTML = txt;

      var esquerda = cursorx+16;


      if(esquerda+360 > document.body.clientWidth){
        esquerda = document.body.clientWidth-242;
      }

      var cima = parseInt(event.clientY);
      //var cima = MAIN.getBoundingClientRect().top;

      box.style.setProperty('left', esquerda+'px');
      box.style.setProperty('top', (12+cima)+'px');
      MAIN.appendChild(box);
      setTimeout(function(){
        box.classList.add('open');
        box.addEventListener('mouseleave', function(){ 
          document.querySelector('.optionbox.obsbox.open').classList.remove('open');
          setTimeout(function(){ document.querySelector('.optionbox.obsbox').remove(); }, 200);
        });
      }, 100);
    //});
  }
}

function importEditColumn(dis, modelo){

  if( (dis.value != dis.getAttribute('data-default')) || (dis.tagName == 'INPUT' && dis.type == 'checkbox') ) { 
    
    var linha     = dis.parentNode.parentNode.querySelectorAll('input, select');
    var nome      = linha[1].value;
    var ordem     = linha[2].value;
    var tipo      = linha[3].value;
    var transform = linha[4].value;
    var entrada   = linha[5].value;
    var saida     = linha[6].value;
    var mascara   = linha[7].value;
    var operacao  = 'UPDATE';

    if (dis.tagName == 'INPUT' && dis.type == 'checkbox' && dis.checked == false) { 
      operacao  = 'DELETE';
    } 
    dis.setAttribute('data-default', dis.value); 
    call('import_change', 'prm_modelo='+modelo+'&prm_numero='+ordem+'&prm_nome='+nome+'&prm_destino=&prm_tipo='+tipo+'&prm_trfs='+transform+'&prm_replacein='+entrada+'&prm_replaceout='+saida+'&prm_mascara='+mascara+'&prm_op='+operacao, 'imp').then(function(res){ 
      if(res.indexOf('FAIL') == -1){ 
        alerta('feed-fixo', TR_AL); 
        call('main', 'prm_modelo='+modelo, 'imp').then(function(resposta){ 
          document.getElementById('content').innerHTML = resposta;
        });
      } 
    }); 
  }
}

function importGenerateData(dis){
  dis.classList.add('loading'); 
  dis.innerHTML = 'IMPORTANDO DADOS'; 
  call('import_test', 'prm_arquivo='+document.getElementById('import-arquivo-ut').title.replace(OWNER_BI+'.fcl.download?arquivo=', '').replace('.xlsx', '')+'&prm_tabela='+document.getElementById('import-tabela-ut').value+'&prm_cabecalho='+document.getElementById('import-cabecalho-ut').value+'&prm_acao='+document.getElementById('import-acao-ut').value, 'imp').then(function(resposta){ 
    dis.classList.remove('loading'); 
    dis.innerHTML = 'IMPORTAR DADOS'; 

    if(resposta.indexOf('FAIL') == -1){
      alerta('feed-fixo', resposta); 
    } else {  
      alerta('feed-fixo', resposta.replace('FAIL', 'IMP')); 
    } 
    
  });
}

function importAddModel(){
  call('import_cabecalho', 'prm_modelo='+get('import-modelo').value+'&prm_arquivo='+get('import-arquivo').title.replace(OWNER_BI + '.fcl.download?arquivo=', '').replace('.xlsx', '')+'&prm_tabela='+get('visao_tabela').title+'&prm_cabecalho=0&prm_acao='+get('import-acao').value+'&prm_rotina='+get('import-pos-rotina').title, 'imp').then(function(resposta){ 
    if(resposta.indexOf('FAIL') == -1){ 
      alerta('feed-fixo', TR_AD); 
      document.getElementById('import-tabela-ut').value = get('import-modelo').value; 

      call('main', 'prm_modelo='+get('import-modelo').value, 'imp').then(function(resposta){ 
        get('content').innerHTML = resposta; 
        carregaPainel('import&prm_default='); 
      }); 
    } else { 
      alerta('feed-fixo', TR_ER); 
    } 
  });
}

//com
document.addEventListener('click', function(e){ 
	
  // Se o elemento clicado não parent com ID finaliza, não deve fazer parte dos objetos da tela de relatório 
  var alvo = e.target; 
  if (!alvo.parentNode || !alvo.parentNode.id ) { 
    return; 
  }

  var parente = alvo.parentNode.id; 

  if(alvo.classList.contains('com_modal')){
    call('modal', 'prm_id='+parente, 'com').then(function(resposta){ 
      document.getElementById('modal-box').innerHTML = resposta; 
    }).then(function(){ 
      setTimeout(function(){ 
        document.getElementById('modal'+parente).classList.add('expanded'); 
      }, 200); 
      pellLaunch(parente); 
    });
  }

  if(alvo.classList.contains('com_enviar')){

    if(alvo.title.toUpperCase() == 'ENVIAR'){
			var seta = alvo.children[0]; seta.classList.add('readonly'); 
			//call('sendReport', 'prm_report='+parente+'&prm_email='+get('prm_email_'+parente).title+'&prm_cc=&prm_assunto='+get('prm_assunto_'+parente).value+'&prm_url='+get('prm_tela_'+parente).title+'&prm_mimic='+get('prm_usuario_'+parente).title, 'COM').then(function(res){ 
      call('sendReport', 'prm_chamada=BI&prm_id_report='+parente, 'COM').then(function(res){ 
        alerta('feed-fixo', res.split('|')[1]); 
				seta.classList.remove('readonly');
        var tr = alvo.parentNode;  
        tr.querySelector('#td_report_status').querySelector('#span_report_status').className = 'com_status com_status_aguardando'; 
			}); 
		}

		if(alvo.title.toUpperCase() == 'FILTROS'){
      carregaTelasup('reportFilter', 'prm_report='+parente, 'COM', 'filtror', 'ID|'+parente, '', '');  
		}

		if(alvo.title.toUpperCase() == 'AGENDAMENTO'){
      carregaTelasup('reportSchedule', 'prm_id='+parente, 'COM', 'report_schedule', '', '', '');  
		}

    if(alvo.title.toUpperCase() == 'LOG'){
      carregaTelasup('reportLog', 'prm_id='+parente, 'COM', '', '', '', '');  
		}

	}

});

function snackObject(dis, obj, tipo, tipoGraf){
  loadAttrib('ed_gadg', 'ws_par_sumary='+obj+'&prm_tipo='+tipo+'&prm_tipo_graf='+tipoGraf); 
  var lis = dis.parentNode.children;
  for(let i=0; i<lis.length; i++){
    if(lis[i] != dis){
      lis[i].classList.add('removed');
    }
  }

  if (tipo == 'grafico') {
    setTimeout(function() {
    document.getElementById(obj+'sync').click();
    }, 100);
  } 
  else {
    dis.classList.add('single');
  }
} 

function ClickIconGrap(selecionado) {

  seleIcon = selecionado.querySelector('svg');
  grupo    = selecionado.closest('.queryadd-graph-group');
  arIcones = grupo.querySelectorAll('.icones-graficos');
  
  for (icone of arIcones) {
    // var label = icone.parentNode.querySelector('span');
    if (icone == seleIcon) {
      icone.classList.add('selecionado');
    } else {
      icone.classList.remove('selecionado');
    }
  }
}

//experimental

function get(...objs){ 
  var arr = []; 
  
  for(let obj in objs){ 
    arr.push(document.getElementById(objs[obj])); 
  } 
  arr = arr.filter(e => e); 
  if(arr.length == 0){
    return false;
  } else if(arr.length > 1){
    return arr; 
  } else {
    return arr[0];
  }
}

function getAttributes(rule, attr, concat){
  var arr = document.querySelectorAll(rule);
  var ret = [];
  for(let i=0; i<arr.length; i++){
    if(arr[i].getAttribute(attr)){
      ret.push(arr[i].getAttribute(attr));
    }
  }
  if(concat){
    return ret.join(concat);
  } else {
    return ret;
  }
}

function resizeObj(dis, obj, tipo){

/*-----resize em tempo real-----*/

  if(tipo == 'height'){
    var extra = 20;
  } else {
    var extra = 0;
  }

  var valor = parseInt(dis.value.replace('px', ''))+extra; 
  
  var ident = document.getElementById('ctnr_'+obj) || document.getElementById(obj+'dv2') || document.getElementById(obj+'_gr'); 
   
  if(tipo == 'height'){
    ident.parentNode.style.setProperty(tipo, valor+'px'); 
    ident.style.setProperty(tipo, valor+'px');
  }
  
  if(tipo == 'height'){ 
    ident.style.setProperty('max-height', valor+'px');
  }
  
  if(tipo == 'width'){ 
    ident.style.setProperty(tipo, valor+'px');
  }

  //redraw
  renderChart(obj);

}
function copyToClipBoard(e) {
  var content = e.previousElementSibling.firstElementChild;
  content.select();
  document.execCommand('copy'); 
  alerta('feed-fixo','Token copiado');
}

function browserQuickEdit(dis, linha, tabela, coluna, tipo){
  //var dis = this; 
  if(dis.value != dis.getAttribute('data-d')){ 
    dis.nextElementSibling.classList.add('loading'); 
    dis.classList.add('readonly'); 
    var obj = document.getElementById('data_list').className; 
    var valor    = dis.value;
    var valorAnt = dis.getAttribute('data-d');
    
    switch(tipo){
      case 'number':
        var valor    = valor.replace(/\./g, '').replace(',', '.');
        var valorAnt = valorAnt.replace(/./g, '').replace(',', '.');
      break;
    }
   
    call('browserEditLine', 'prm_tabela='+tabela+'&prm_chave='+getAttributes('#'+linha+' .chave', 'data-d', '|')+'&prm_campo='+getAttributes('#'+linha+' .chave', 'data-n', '|')+'&prm_nome='+coluna+'&prm_conteudo='+valor+'&prm_ant='+valorAnt+'&prm_tipo='+tipo+'&prm_obj='+obj, 'bro').then(function(res){ 
      dis.nextElementSibling.classList.remove('loading'); 
      dis.nextElementSibling.classList.add('ok'); 
      alerta('feed-fixo', TR_AL); 
      dis.setAttribute('data-default', dis.value); 
      setTimeout(function(){ dis.classList.remove('readonly'); 
      dis.nextElementSibling.classList.remove('ok'); }, 2000); 
    }); 
  }
}

function browserEditColumn(dis){

  var eTD   = dis.parentNode,
      eTR   = dis.parentNode.parentNode; 

  var recarrega = document.getElementById('B'+dis.getAttribute('data-c')).getAttribute('data-recarrega');

  if (dis.classList.contains('fakeoption')) { 
    var valor = dis.parentNode.getAttribute('data-v').trim(); 
  } else {
    if (dis.hasAttribute('data-t') && dis.getAttribute('data-t') == 'checkbox') {
      dis.value = (dis.checked ? dis.getAttribute('data-valor1') : dis.getAttribute('data-valor2')); 
    }  
    var valor = dis.value.trim(); 
  }

  var temPipe = false;
  
  if (valor !== dis.getAttribute('data-a').trim() ) {

    var chaves = []; 
    var allChaves = dis.parentNode.parentNode.querySelectorAll('.chave'); 
    for(let i=0;i<allChaves.length;i++){ 
      chaves.push(encodeURIComponent(allChaves[i].getAttribute('data-d'))); 

      if (encodeURIComponent(allChaves[i].getAttribute('data-d')).includes('%7C')) {
        temPipe = true;
      }
    } 
    
    if (temPipe) {
      chaves = chaves.join('*|*');
      
      if (!chaves.includes('*|*')) {
        chaves = chaves.replace(/\|/g, '******');
        chaves = chaves.replace(/\%7C/g, '******');
      }
      
    } else {
      chaves = chaves.join('|');
    }

    v_param =           'prm_obj='         + document.getElementById('data_list').getAttribute('data-objeto');
    v_param = v_param + '&prm_screen='     + tela;    
    v_param = v_param + '&prm_tabela='     + document.getElementById('data_list').getAttribute('data-tabela');
    v_param = v_param + '&prm_campo_chave='+ document.getElementById('browser-chave').value; 
    v_param = v_param + '&prm_chave='+chaves; 
    v_param = v_param + '&prm_tipo=' +dis.getAttribute('data-t') ;     
    v_param = v_param + '&prm_campo='+dis.getAttribute('data-c') ; 
    v_param = v_param + '&prm_conteudo='+encodeURIComponent(valor); 

    dis.classList.toggle('loading');
    call('browserEditColumn', v_param, 'bro').then(function(resultado){

      alerta('',resultado.split('|')[1]); 
      if (resultado.split('|')[0] == 'ERRO') { 
        if (dis.classList.contains('fakeoption')) { 
          dis.setAttribute('data-v', dis.getAttribute('data-a'));
          dis.innerHTML = dis.getAttribute('data-a');
        } else { 
          dis.value = dis.getAttribute('data-a');
        }  
      } else {   

        dis.setAttribute('data-a', valor); 
        eTD.setAttribute('data-d', valor); 

        // Destaque de celula - Remove e aplica 
        if (resultado.split('|')[2] != 'CAMPO SEM DESTAQUE') { 
          if (resultado.split('|')[2].length > 0 ) { 
            eTD.style.cssText = resultado.split('|')[2];    // Adiciona o destaque na celula
          } else {
            eTD.style.backgroundColor = null;               // Retira o destaque da celula 
            eTD.style.color = null;
          }
          dis.style.cssText = eTD.style.cssText;   // Aplica o mesmo estilo da TD no elemento 
        }    

        // Destaque de linha e estrela - Remove os destaques existentes (se houver)
        if (resultado.split('|')[3] != 'CAMPO SEM DESTAQUE') { 
          var arStyles    = eTR.querySelectorAll('style');
          for (ele of arStyles) {
            if (ele.innerText.toLowerCase().indexOf('td input') != -1 || ele.innerText.toLowerCase().indexOf('destaqueicon') != -1)  {  // Se for destaque de linha
              eTR.removeChild(ele);
            }
          }

          // Destaque de linha e estrela - Adiciona os destaques (se houver)  
          var txSyleLinha = resultado.split('|')[3].replace(/#@ID@#/g, eTR.id) ; 
          if (txSyleLinha.length > 0 ) { 
            for (txt of txSyleLinha.split('<style>')) {  // loop porque no estilo retornado pelo backend pode ter mais de um style (linha e estrela)
              if (txt.trim().length > 0) { 
                var ele = document.createElement('style');  
                ele.innerText = txt.replace('</style>','');
                eTR.appendChild (ele); 
              }  
            }
          }
        }  
        //atualiza o browser após preencher um campo
        if (recarrega === 'S') {
          browserSearch('BUSCA', document.getElementById('ajax').lastElementChild.className || '');
        }
      }
      dis.classList.toggle('loading');      
    }); 
  }  
}

function browserInputMask(dis, tipo, mask){

  var cursorPosition = dis.selectionStart;

  if (tipo == 'data' || tipo == 'datatime') {
    var mask2 = mask.toUpperCase().replace('DD','99').replace('MM','99').replace('YYYY','9999').replace('YY','99').replace('HH24','99').replace('HH','99').replace('MI','99').replace('SS','99');

    dis.value = VMasker.toPattern(dis.value, mask2);  
    
    if (dis.value[cursorPosition-1] == '/' || dis.value[cursorPosition-1] == ':') {
      cursorPosition = cursorPosition + 1 ;
    }
    dis.setSelectionRange(cursorPosition, cursorPosition); 

  } 
  if (tipo == 'number') {
    var precisao = mask.toUpperCase().replace('G', '.').replace('D', ','); 
    
    if(precisao.split(',')[1]){ 
      precisao = precisao.split(',')[1].length 
    } else { 
      precisao = 0; 
    } 
    
    VMasker(dis).maskMoney({ precision: parseInt(precisao), separator: ',', delimiter: '.', showSignal: true });
     
    dis.addEventListener('keydown', function(event) {
      
      if (event.key === 'Backspace') {
    
        var cursorPosition = dis.selectionStart;
 
        dis.value = '';
        dis.setSelectionRange(cursorPosition - 1, cursorPosition - 1); // Move o cursor uma posição para trás
      }
      
    });
  }
}  


var fakescrollm = 0;
barheight = "";

function proxCampo(e,esse){
  if (e.code == 'Enter'){
  esse.parentNode.nextElementSibling.children[0].focus();
  }

}; 

function createFakescroll(ele){
    var fakescroll;
    if(!ele.querySelector('.fakescroll')){
      fakescroll = document.createElement('span');
      fakescroll.className = 'fakescroll';
      ele.appendChild(fakescroll);
    } else {
      fakescroll = ele.querySelector('.fakescroll');
    }

    //calculo de diferença de espaço
    //barheight = ele.scrollHeight/ele.clientHeight;

    var barheight      = (ele.clientHeight*100)/ele.scrollHeight;
    var limit          = ele.parentNode.clientHeight-ele.clientHeight;
    var espaco         = ele.clientHeight-ele.parentNode.clientHeight;
    var desloc         = 108; /*espaco/(100-barheight);*/
    var porcentoscroll = 108*barheight/100;
    var limitscroll    = espaco*barheight/100;
    var scrollstyle    = ele.parentNode.querySelector('.fakescroll').style;
    var elestyle       = ele.children[0].style; 

    //if(parseFloat(barheight) < 90){ barheight = 90; }

    //altura da fakescroll é igual a altura do objeto dividida pelo (scroll real dividida pela altura), -10 para ajuste de arrows
    fakescroll.style.setProperty('height', 'calc('+barheight+'% - 5px)');

    //dispara evento ao dar scroll no objeto superior que calcula os pixels de deslocamento
    ele.addEventListener("scroll", function(){
      var pulse = (ele.clientHeight/ele.scrollHeight)+1;
      var slowDown = ele.clientHeight/document.body.clientHeight;
      //considerar no calculo se o objeto é relativo a posição da tela ou fixado/absolute
      document.querySelector('.fakescroll').style.setProperty('margin-top', (this.scrollTop*pulse)/slowDown+'px');
    });

    /*ele.addEventListener("wheel", function(e){
      e.preventDefault();
      var reverse = "";
      //chrome firefox reverse
      if(e.wheelDeltaY){ 
        var direction = e.wheelDeltaY.toString().replace(/\w/g, "");
        if(direction == "-"){ direction = "-"; reverse = ""; } else { direction = ""; reverse = "-"; }
      } else {
        var direction = e.deltaY.toString().replace(/\w/g, "");
        if(direction == "-"){ direction = ""; reverse = "-"; } else { direction = "-"; reverse = ""; }
      }

      var fakeTop = parseInt(scrollstyle.getPropertyValue("margin-top"));
      var eleTop = parseInt(elestyle.getPropertyValue("margin-top"));

      //limits bar
      if(eleTop+parseInt((direction+desloc)) > 0){ 
        eleTop = 0; 
      } else {
        if(eleTop+parseInt((direction+desloc)) <= limit+6){
          eleTop = limit+6;
        } else {
          eleTop = eleTop+parseInt((direction+desloc));
        } 
      }

      //limits scroll limitscroll
      if(fakeTop+parseInt(reverse+porcentoscroll) < 0){
        fakeTop = 0;
      } else {
        if(fakeTop+parseInt(reverse+porcentoscroll) > limitscroll){
          fakeTop = limitscroll-4;
        } else {
          fakeTop = fakeTop+parseInt(reverse+porcentoscroll);
        }
      }

     //if(fakeTop > 0){ fakeTop = 0; }

      elestyle.setProperty("margin-top", eleTop+"px");
      scrollstyle.setProperty("margin-top", fakeTop+"px");
    });*/

    //evento para mover com o mouse
    fakescroll.addEventListener("touchstart", function(e){
      e.stopPropagation();
      fakescrollm = 1;
    });

    fakescroll.addEventListener("mousedown", function(e){
      e.stopPropagation();
      fakescrollm = 1;
    });

    fakescroll.addEventListener("mouseup", function(e){
      e.stopPropagation();
      fakescrollm = 0;
    });

    fakescroll.addEventListener("mouseleave", function(e){
      e.stopPropagation();
      fakescrollm = 0;
    });

    fakescroll.addEventListener("mousemove", function(e){
      if(fakescrollm == 1){
        if(e.clientY <= (ele.scrollHeight-ele.parentNode.offsetHeight)+20){
          e.style.setProperty("margin-top", '-'+(e.layerY*2)+"px");
          fakescroll.style.setProperty("margin-top", (e.layerY*2)+"px");
        }
      }
    });

  //}
}

var fakeListCustom = {};
var menu = {}

menu.usuarios = function(){
  let painel = document.getElementById('painel');
  
  let h4 = document.createElement('h4');
  h4.innerHTML = 'USUÁRIOS';

  let inputLogin = document.createElement('input');
  inputLogin.id = 'login';
  inputLogin.setAttribute('maxlength', '40');
  inputLogin.setAttribute('placeholder', 'login');
  inputLogin.style.setProperty('text-transform', 'uppercase');
  inputLogin.setAttribute('onkeypress', "return input(event, 'login')");

  let inputNome = document.createElement('input');
  inputNome.id = 'nome';
  inputNome.setAttribute('maxlength', '60');
  inputNome.setAttribute('placeholder', 'NOME');

  let inputMail = document.createElement('input');
  inputMail.id = 'email_usuario';
  inputMail.type = 'email';
  inputMail.setAttribute('maxlength', '60');
  inputMail.setAttribute('placeholder', 'E-MAIL');
  inputMail.setAttribute('onkeypress', "return input(event, 'email')");

  let inputPass = document.createElement('input');
  inputPass.id = 'senha';
  inputPass.type = 'password';
  inputPass.setAttribute('placeholder', 'PASSWORD');

  let addPurple = document.createElement('a');
  addPurple.classList.add('addpurple');
  addPurple.title = 'Novo usuário';
  addPurple.innerHTML = TR_AU;
  addPurple.setAttribute('onclick', "var nome = document.getElementById('nome').value; var login = document.getElementById('login').value; var senha = document.getElementById('senha').value; var permissao = document.getElementById('fake-permissao').title; if(nome.length < 1){ alerta('msg', 'Campo nome de usuário em branco!'); } else { if(login.trim().length < 3){ alerta('msg', 'Campo login precisa ter mais de 3 caracteres!'); } else { if(senha.trim().length < 3){ alerta('msg', 'Campo senha precisa ter mais de 3 caracteres!'); } else { var regex = new RegExp('^[a-zA-Z0-9.]+$'); if(regex.test(login)){ if(document.getElementById('email_usuario').value.length > 0){ call('save_user', 'prm_nome='+login+'&prm_completo='+nome+'&prm_status=&prm_email='+document.getElementById('email_usuario').value+'&prm_senha='+senha+'&prm_permissao='+permissao).then(function(resposta){ if(resposta.indexOf('FAIL') == -1){ alerta('feed-fixo', TR_CR); ajax('list', 'list_users', '', false, 'content'); carregaPainel('usuarios'); } else { alerta('feed-fixo', resposta.replace('FAIL ', '')); } }); } else { noerror('', TR_EI, 'msg'); } } else { alerta('msg', TR_LO_LI); } }}} ");
  
  painel.appendChild(h4);
  painel.appendChild(inputLogin);
  painel.appendChild(inputNome);
  painel.appendChild(inputMail);
  painel.appendChild(inputPass);
  painel.appendChild(addPurple);

}


function marcadorEvent(evento, ele, p_cd_marcador){
  
  switch (evento){
    case 'onblur':
      if (ele.classList.contains('script') && (ele.nextElementSibling.classList.contains('fakeoption')) ) {
        ele = ele.nextElementSibling; 
      }

      if (ele.classList.contains('fakeoption')) { 
        var valor = ele.title, 
            ante  = '',
            campo = ele.getAttribute('data-adicional') ; 
      } else { 
        var valor = ele.value, 
            ante  = ele.getAttribute('data-ant'),
            campo = ele.getAttribute('data-coluna') ;  
      }
      if (ele.tagName == 'INPUT' && ele.type == 'checkbox') { 
        if (ele.checked == true) { 
          valor = 'bold';
        } else {
          valor = '';
        }
      }  
      if(ante != valor){
        var v_param =  'prm_chave='    + encodeURIComponent(p_cd_marcador) + 
                      '&prm_campo='    + campo + 
                      '&prm_conteudo=' + encodeURIComponent(valor) ;   

        call('update_mapa_marcador', v_param, 'fcl').then(function(resultado){
          alerta('',resultado.split('|')[1]); 
          if (resultado.split('|')[0] != 'ERRO') { 
            ele.setAttribute('data-ant', valor); 

            // Atualiza outros campos da tela 
            var imagem = ele.parentNode.parentNode.children[7].children[0];                
            if (ele.tagName == 'INPUT') { 
              if (ele.type == 'color') { 
                ele.nextElementSibling.value = valor; 
                ele.nextElementSibling.setAttribute('data-ant', valor); 
                imagem.style.setProperty('fill',  valor); 
              } else if (ele.previousElementSibling && ele.previousElementSibling.type == 'color') { 
                ele.previousElementSibling.value = valor; 
                ele.previousElementSibling.setAttribute('data-ant', valor); 
                imagem.style.setProperty('fill',  valor);
              } 
               
              if (campo.toLowerCase() == "svg_fillopacity") { 
                imagem.style.setProperty('fill-opacity', valor.replace(',','.'));
              } 

              if (campo.toLowerCase() == "svg_path") {   // Atualiza a path da imagem svg 
                imagem.children[0].setAttribute('d',valor);
              } 
 
            }   

            if (campo.toLowerCase() == "img_url") {     // Atualiza o arquivo da imagem IMG (scr)
              var imagem = ele.parentNode.parentNode.children[7].children[0];              
              var url = imagem.getAttribute('src').toLowerCase();
              if (url.indexOf('fcl.download') != -1) { 
                url = url.substring(0,(url.indexOf('=')+1))+valor;   
              } else { 
                url = valor; 
              }  
              imagem.setAttribute('src',url);              
            } 
          }
        }); 
      }
      break;
    case 'remove':
      if(confirm("Confirma a exclus\u00e3o do marcador?")){
        var row = ele.parentNode.parentNode; 
        row.classList.add('removing'); 
        call('delete_mapa_marcador', 'prm_chave=' + encodeURIComponent(p_cd_marcador) ).then(function(resultado){
          alerta('',resultado.split('|')[1]);           
          if (resultado.split('|')[0] != 'ERRO') { 
              row.remove(); 
          } else {
              row.classList.remove('removing'); 
          }
        });
       }
      break;
  }
}

function notice_popup_open (p_id_aviso, p_tipo ){

  if ((p_tipo == 'INICIO') || (p_tipo == 'MENU')) { 

    call('notice_popup_mount', 'prm_tipo='+p_tipo).then(function(resposta){
      if (resposta.split('|')[0] == 'ERRO') {
        alerta('feed-fixo', resposta.split('|')[1]);
      } else { 
        var extra = document.getElementById('extra'), 
            etemp = document.createElement('div'); 
        etemp.innerHTML = resposta;
        
        if (extra.querySelector('#blockpage') ) { 
          extra.querySelector('#blockpage').remove(); 
        }
        extra.appendChild(etemp.children[0]) ; 
      }  
    } );  
  } else { 
    call('notice_popup_mount', 'prm_aviso='+p_id_aviso+'&prm_tipo=' + p_tipo).then(function(resposta) { 
      if (resposta.split('|')[0] == 'ERRO') {
        alerta('feed-fixo', resposta.split('|')[1]);
      } else {
        document.getElementById('blockpage').innerHTML = resposta;
      }
    });
  }
}

function notice_refresh_count(){

  if (document.getElementById('notice-menup-count')) { 
    call('notice_ret_count').then(function(resposta){
      if (resposta.split('|')[0] == 'ERRO') {
        alerta('feed-fixo', resposta.split('|')[1]);
      } else { 
        document.getElementById('notice-menup-count').innerHTML = resposta; 
        if (resposta == '0') { 
          document.getElementById('notice-menup-circle').style.visibility = 'hidden';
          document.getElementById('notice-menup-count').style.visibility = 'hidden';
        } else { 
          
          if ((document.getElementById('princp').className == 'slide-A')||(document.querySelector('a[title="Configurações"]'))){
            document.getElementById('notice-menup-circle').style.visibility = 'visible';
            document.getElementById('notice-menup-count').style.visibility = 'visible';
          }else{
            document.getElementById('notice-menup-circle').style.visibility = 'visible';
            document.getElementById('notice-menup-count').style.visibility = 'visible';
            document.getElementById('notice-menup-circle').style.setProperty('right','37px');
            document.getElementById('notice-menup-count').style.setProperty('right','41px');

          }
        }
      }
    });
  }
}  


function ampliar_img(obj,vlr){
  if(document.getElementById('sizeUp')){
      document.getElementById('sizeUp').remove();
  }else{
    zoomImg = document.createElement('img');
    zoomImg.id='sizeUp'
    zoomImg.src=vlr;

    if(zoomImg.naturalWidth <  window.outerWidth || zoomImg.naturalHeight <  window.outerHeight){ 
      var larguratela = window.innerWidth/2;
      var alturatela  = window.innerHeight/2;
      var larguraobj  = zoomImg.naturalWidth/2;
      var alturaobj   = zoomImg.naturalHeight/2;

      var x = (larguratela)-larguraobj+'px';
      var y = (alturatela)-alturaobj+'px';

      zoomImg.style.setProperty('left', x);
      zoomImg.style.setProperty('top', y);
    }else{
      zoomImg.style.setProperty('inset','50px');

      zoomImg.style.setProperty('width','calc(100% - 100px)');
      zoomImg.style.setProperty('height','calc(100% - 100px)');
    }

    
    document.body.appendChild(zoomImg);
  }  

}

document.onkeydown = function(evt) {
  evt = evt || window.event;
  var isEscape = false;
  if (document.getElementById('sizeUp')){
    if ("key" in evt) {
        isEscape = (evt.key === "Escape" || evt.key === "Esc");
    } else {
        isEscape = (evt.keyCode === 27);
    }
    if (isEscape) {
      document.getElementById('sizeUp').remove();
    }
  }
};

document.addEventListener('mouseup', function(e) {
  var container = document.getElementById('sizeUp');
  if (container) {
    if (!container.contains(e.target)) {
      document.getElementById('sizeUp').remove();
    }
  }
});

function limpar_filter(filtro,screen,usuario){
  
  var idFiltro = document.getElementById('padrao_'+filtro),
      tipo     = '';
  if (idFiltro) {
    tipo = 'padrao';
  } else { 
    idFiltro = document.getElementById('data_id_'+filtro);
    if (idFiltro) { 
      tipo = 'input';
    }
  }       

  if (tipo == '') { 
    return ; 
  }

  if(tipo == 'padrao' && idFiltro.className == 'fakeoption multi open'){
    idFiltro.click();
  }    

  setTimeout(() => {
    call('limpar_float_filter','prm_filtro='+filtro+'&prm_usuario='+usuario+'&prm_screen='+screen).then(function(resposta){

    if(resposta.indexOf('Erro') == -1){ 
      alerta('feed-fixo', 'Alterado com sucesso');
      document.getElementById('get_float').setAttribute('data-alterado','T');

      if (tipo == 'padrao') { 
        idFiltro.setAttribute('data-default','');
        idFiltro.setAttribute('title','');
        idFiltro.firstElementChild.innerHTML='  -';
        idFiltro.classList.remove('reverse');
      } else {
        idFiltro.value = ''; 
      }  
    } else {
      alerta('feed-fixo', 'Sem opções selecionadas');
      return;
    }

    });
  }, 300);
};


// Abre a tela de anotações da célula da consulta 
function anotacao_show (evento, objeto){

  if(get('jumpdrill')){
    get('jumpdrill').remove();
  }    

  // Se já estiver aberto, só fecha 
  if(get('anotacao_show')){
    get('anotacao_show').remove();
    if(get('selecteddata')) { get('selecteddata').id = ''; }
    return;
  }

  //calculo da distancia
  var largura = 320,
      altura  = 111, 
      reverse = 'normal', 
      left, 
      vert ;

  var coluna  = get('selecteddata'); 
  var rect    = coluna.getBoundingClientRect();

  // Define a posicao horizontal da tela 
  left    = rect.left+5+(coluna.clientWidth/2)-(largura/2);
  if(left+largura > MAIN.clientWidth){
    left = MAIN.clientWidth-largura-5;
  }

  // Ajusta posição vertical da tela 
  vert    = 'top: '+(rect.top+(coluna.clientHeight+4))+'px;';  
  if(rect.top+(coluna.clientHeight+12)+(altura) > PRINCP.clientHeight){
    vert    = 'bottom: '+((PRINCP.getBoundingClientRect().height-get('selecteddata').getBoundingClientRect().top)+4)+'px;';
    reverse = 'reverse';
  }

  // Define a célula da anotação
  let colSpan = 0; 
  if(get(objeto+'c').children[0].children.length > 1){
    colSpan = get(objeto+'c').children[0].children[0].querySelectorAll('.colagr').length;    // alterado para resolver problema quando a prop. COLUNAS FIXAS é alterada
  }
  var pos = coluna.cellIndex-colSpan;
  var valor = '';
  if ( get(objeto+'c').children[0].lastElementChild.querySelectorAll('th')[pos])  {     // Somente colunas de valores (não considera colunas agrupadoras)
    var th_valor = get(objeto+'c').children[0].lastElementChild.querySelectorAll('th')[pos];       
    valor = th_valor.getAttribute('data-valor');       
  }   

  // Define a posição da seta da tela de anotação 
  let larg_seta  = 6; 
  let leftBefore = largura - 5 - ( (coluna.clientWidth/2) - larg_seta) - (MAIN.clientWidth - rect.right); 
  if (leftBefore < ((largura/2)-larg_seta)) {  // Se a posição for menor que o meio da tela, Zera para não alterar na posição atual que é o meio da tela 
    leftBefore = 0 ;
  }  
  if (leftBefore >= largura-35) {  // Se a posição da seta for maior que a largura da tela, então diminui 35px da posição
    leftBefore = largura-35;
  }
  if(left <= 0) { 
    left       = 2; 
    leftBefore = rect.left+(coluna.clientWidth/2) - larg_seta ;
  }

  // Pega os parametros que deve ser repassados para o objeto/anotacao que será criado
  let arr = [];
  arr.push(get('par_'+objeto).value);
  arr.push(get('drill_go').value);
  let uniq = [...new Set(arr.sort())];
  let letCondicao = uniq.filter(e => e).join('|');
  letCondicao = letCondicao.replace('||', '|');
  let letColuna = ''; 
  if(typeof valor != "undefined" && valor != "undefined") { 
    letColuna = valor; 
  }

  call('anotacao_show', 'prm_objeto='+objeto+'&prm_screen='+tela+'&prm_coluna='+letColuna+'&prm_condicao='+letCondicao).then(function(resposta){
    let temp = document.createElement('div');
    temp.innerHTML = resposta;
    temp.children[0].setAttribute('style', 'left: '+left+'px; '+vert);
    
    if (leftBefore > 0 ) { 
      temp.children[0].style.setProperty('--left', leftBefore.toString()+'px');       
    } 

    MAIN.appendChild(temp.children[0]);
  }).then(function(){

    var aShow = get('anotacao_show');
    aShow.classList.add(reverse);

    setTimeout(function(){
      aShow.querySelector('.fechartab').addEventListener('click', function(){
        this.parentNode.remove();
        if(get('selecteddata')) { get('selecteddata').id = ''; }
      });
      
      if(get('selecteddata')) { get('selecteddata').id = ''; }
      aShow.classList.add('open');
    }, 10);
  });   

}

function valida_formula(filtro,screen,usuario){

  var visao   = document.getElementById('micro-visao').title,
      coluna  = document.getElementById('ajax-lista').querySelector('.selected').title, 
      alvo    = document.getElementById('formula-coluna'), 
      formula = encodeURIComponent(alvo.value);

  call('valida_formula_navegador','prm_tipo=COLUNA&prm_formula='+formula+'&prm_screen='+tela+'&prm_visao='+visao+'&prm_coluna='+coluna).then(function(resposta){
    if (resposta.split('|')[0] == 'ERRO') { // Se tem erro na fórmula, altera a cor da fonte para vermelho 
      alvo.style.setProperty('color', 'var(--vermelho-secundario)');
      document.getElementById('erro_coluna_formula').innerHTML = resposta.split('|')[1]+'.';
      alerta('feed-fixo', 'F&oacute;rmula com erro');       
    } else { 
      alvo.style.setProperty('color', 'initial');
      document.getElementById('erro_coluna_formula').innerHTML = '';
      alerta('feed-fixo', 'F&oacute;rmula OK');       
    }
  });

};

function mobile_portrait_layout () {
  if (window.innerWidth <= 500 && window.matchMedia('(orientation: portrait)').matches ) { 
    return true;
  } else { 
    return false; 
  }
}


document.addEventListener("click", function(event) {

  if (event.target.id == "search-mobile") {
    // Criar o elemento div com a classe "panel panel-default"
    var panel = document.getElementById("panel-default"); 
    var totalResults = 0;
    
    if (panel.classList.contains("mostrar")){ 
      panel.classList.remove("mostrar");

      var elements = document.getElementsByTagName("mark"); 
      // Percorre cada elemento e remove a tag
      for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        // Obtém o texto dentro da tag
        var text = element.textContent || element.innerText;
        // Substitui a tag por uma string vazia
        element.outerHTML = text;
      }

    }else{

      panel.classList.add("mostrar");
      var input=document.querySelector(".form-control.input-sm")
      input.value= '';
      setTimeout(function() {
        input.focus();
        }, 200); //move o cursor para dentro do input
      
      var keywordInput = document.querySelector("input[name='keyword']");
      var optionInputs = document.querySelectorAll("input[name='opt[]']");

      
      performMark();       
    
      keywordInput.addEventListener("input", performMark);
      for (var i = 0; i < optionInputs.length; i++) {
      optionInputs[i].addEventListener("change", performMark);
      }
    }

    function performMark() {

      var keyword = keywordInput.value.trim();
      var instance = new Mark(document.getElementById("main"));

      instance.unmark({
        done: function(){
          instance.mark(keyword, {
            separateWordSearch: false, 
            done: function(){
              // Define o índice atual
              var currentIndex = 0;
              var markedElements = getVisibleElements(document.querySelectorAll("#main mark"));
              totalResults = markedElements.length;

              function updateSearchCount() {
                var countElement = document.getElementById("searchCount");
                if (keyword) {
                  //Verifica se o resultado exite, se não aplica 0/0
                  if(totalResults != 0){
                    countElement.textContent = (currentIndex+1) + "/" + totalResults;
                  }else{
                    
                    countElement.textContent = "0/0";
                  }

                } else {
                  countElement.textContent = "";
                }
              }
    
              updateSearchCount();

              function getVisibleElements(elements) {
                return Array.from(elements).filter(function (element) {
                  return element.offsetParent !== null;
                });
              }
              function jumpTo() {
                var visibleElements = getVisibleElements(document.querySelectorAll("#main mark"));
                if (visibleElements.length) {
                  markedElements.forEach(function (element) {
                    element.classList.remove("current");
                  });

                  currentIndex++;
                  if (currentIndex > visibleElements.length - 1) {
                    currentIndex = 0;
                  }
                  updateSearchCount();
    
                  visibleElements[currentIndex].classList.add("current");

                  visibleElements[currentIndex].scrollIntoView({ block: "center" });
                }
              }

              function jumpBack() {
                var visibleElements = getVisibleElements(document.querySelectorAll("#main mark"));
                if (visibleElements.length) {
                  markedElements.forEach(function (element) {
                    element.classList.remove("current");
                  });

                  currentIndex--;
                  if (currentIndex < 0) {
                    currentIndex = visibleElements.length - 1;
                  }
                  updateSearchCount();

                  visibleElements[currentIndex].classList.add("current");

                  visibleElements[currentIndex].scrollIntoView({ block: "center" });
                }
              }

              function closeSearch(){
                  panel.classList.remove("mostrar"); 

                  //For para pegar o texto dentro da tag mark,remover a tag e devolver o texto na div
                  var elements = document.getElementsByTagName("mark"); 
                  // Percorre cada elemento e remove a tag
                  for (var i = 0; i < elements.length; i++) {
                    var element = elements[i];
                    var text = element.textContent || element.innerText;
                    element.outerHTML = text;
                  }
                  
              }

              jumpTo();

              // Adiciona um evento de clique em um botão para chamar a função de pular novamente
              document.querySelector("#nextSearch").addEventListener("click", jumpTo);
              
              keywordInput.addEventListener("keydown", function(event) {

                if ((event.key === "Enter" || event.keyCode === 13) && event.target === keywordInput) {
                  jumpTo();
                }

              });

              // Adiciona um evento de clique em outro botão para chamar a função de voltar
              document.querySelector("#backSearch").addEventListener("click", jumpBack);

              document.querySelector("#closeSearch").addEventListener("click", closeSearch);
              //document.querySelector("#closeSearchP").addEventListener("click", closeSearch);
              
              document.addEventListener("keydown", function(event) {
                if (event.key === "Escape" || event.keyCode === 27) {
                  closeSearch();
                }
              });

            }
          });
        }
      });

    };

  }
});

function clone_object (obj) {
  if(confirm(TR_CL_OB)){
    var cd_obj = obj.split('trl')[0];
    call('clone_object_navegador','prm_objeto='+cd_obj).then(function(resposta){
      alerta('feed-fixo', resposta.split('|')[1] );
  
      if (resposta.split('|')[0] == 'OK') { 
        let new_obj = resposta.split('|')[2],
            new_tip = resposta.split('|')[3]; 
        fastInclude(new_obj, new_tip); 
      }
    });
  }
} 


function clone_screen (tela_atual) {
  if(confirm(TR_CL_SC)){
    call('clone_screen','prm_screen='+tela_atual).then(function(resposta){
      alerta('feed-fixo', resposta.split('|')[1] );
  
      if (resposta.split('|')[0] == 'OK') { 
        if(confirm(TR_CL_SC2)){
          let nova_tela = resposta.split('|')[2]; 
          shscr(nova_tela); 
        }   
      }
    });
  }
}


function copfilter(option) {

    //Pegando os Elementos do fakelistoptions para poder esconder caso seja selecionado 'COPIAR USUARIO'
    var prm_visao = document.getElementById('prm_visao');
    var prm_conteudo = document.getElementById('prm_conteudo');
    var prm_condicao = document.getElementById('prm_condicao');
    var prm_coluna = document.getElementById('prm_coluna');
    var prm_usu_origem = document.getElementById('prm_usuario_origem');

    var botao = document.getElementById('filtrou');


    if (option == 'CopiarUsuario') { 

        //Substitui a chamada de procedure de setfiltro para copfiltro
        botao.setAttribute('data-req', 'copfiltro');
        botao.setAttribute('data-par', 'prm_usuario|prm_usuario_origem');
        botao.textContent = 'COPIAR FILTRO';
        botao.title = 'Copiar filtro'

        prm_visao.style.setProperty('display', 'none'); 
        prm_conteudo.style.setProperty('display', 'none'); 
        prm_condicao.style.setProperty('display', 'none'); 
        prm_coluna.style.setProperty('display', 'none'); 
        prm_usu_origem.style.setProperty('display', 'block');
    }
    else {
        prm_visao.style.setProperty('display', 'block'); 
        prm_conteudo.style.setProperty('display', 'block'); 
        prm_condicao.style.setProperty('display', 'block');
        prm_coluna.style.setProperty('display', 'block');
        prm_usu_origem.style.setProperty('display', 'none');

        botao.setAttribute('data-req', 'setfiltro');
        botao.setAttribute('data-par', 'prm_usuario|prm_visao|prm_coluna|prm_condicao|prm_conteudo');
        botao.textContent = 'ADICIONAR FILTRO';
        botao.title = 'Adicionar'
      }
};


function obterHoraAtualizada() {
  var dataAtual = new Date();
  var horaLocal = dataAtual.getHours();
  var minutosLocais = dataAtual.getMinutes();
  var horaFormatada = horaLocal.toString().padStart(2, '0');
  var minutosFormatados = minutosLocais.toString().padStart(2, '0');
  var horaMinutos = horaFormatada + 'h' + minutosFormatados;

  return horaMinutos;
}
  
  
function hexToRgba (hex, alfa, perc) {
  var R = parseInt(hex.substring(1,3),16);
  var G = parseInt(hex.substring(3,5),16);
  var B = parseInt(hex.substring(5,7),16);
  if ( perc > 0 ) {
    R = parseInt(R * perc);
    G = parseInt(G * perc);
    B = parseInt(B * perc);
    R = Math.round((R>0)?R:0);  
    G = Math.round((G>0)?G:0);  
    B = Math.round((B>0)?B:0);  
    R = Math.round((R<255)?R:255);  
    G = Math.round((G<255)?G:255);  
    B = Math.round((B<255)?B:255);  
  }  

  return 'rgba('+R+','+G+','+B+','+alfa+')';
}

function uploadevoltarbotoes(opcao,dados) {

  switch (opcao) {
    case 'upload':
      var selectElement = document.getElementById("import-tabela-ut");
      var selectedValue = selectElement.value;
      document.getElementById('titulo').innerHTML = 'UPLOAD';
      call_save('');
      curtain('enabled');
      carregaPainel('upload','VOLTAR' + selectedValue);
      carrega('uploaded');  

    break;
    case 'voltar':
      var painel = document.getElementById('painel');
      call('main', 'prm_modelo='+dados, 'imp')
      .then(function(resposta){ 
        document.getElementById('content').innerHTML = resposta; 
      });
      call('menu','prm_menu=import').then(function(resposta){
        painel.innerHTML = resposta;
      });
    break;
    default:
      break;
  }
   
}

function obterHoraAtualizada() {
  var dataAtual = new Date();
  var horaLocal = dataAtual.getHours();
  var minutosLocais = dataAtual.getMinutes();
  var horaFormatada = horaLocal.toString().padStart(2, '0');
  var minutosFormatados = minutosLocais.toString().padStart(2, '0');
  var horaMinutos = horaFormatada + 'h' + minutosFormatados;

  return horaMinutos;
}

function modal_txt_sup (event, texto, posicao) {
  
  if (texto.length == 0) {
    return;
  }
  
  let erro = 'N';
  call('modal_txt_sup', 'prm_txt='+encodeURIComponent(texto), 'fun').then(function(resposta){ 
    document.getElementById('modal-txt').innerHTML = resposta; 
    if (resposta.split('|')[0] == 'ERRO') { 
      alerta('',resposta.split('|')[1]); 
      erro = 'S';
    }  
  }).then(function(){ 
    if (erro == 'N') { 
      setTimeout(function(){ 
        let telaModal = document.getElementById('modal-txt-content');
        let telaSup    = document.getElementById('telasup')

        if (!posicao) { posicao = 'mouse';  }

        if ((texto.length < 200) && (texto.length > 70)) { document.getElementById('modal-txt-input').style.width = '500px';}
        if ( telaModal.clientWidth > 1200 ) { telaModal.style.width = '1200px'; }
        if ( telaModal.clientWidth > telaSup.clientWidth - 100)   { telaModal.style.width = (telaSup.clientWidth - 100).toString() + 'px'; }  

        if ( telaModal.clientHeight > 500 ) { telaModal.style.height = '500px'; }
        if ( telaModal.clientHeight > telaSup.clientHeight - 100 ) { telaModal.style.height = (telaSup.clientHeight - 50).toString() + 'px'; }  

        posiciona_modal(telaModal, telaSup , event.clientX, event.clientY, posicao);
        telaModal.classList.add('expanded'); 
      }, 200); 
    }  
  });
}

function posiciona_modal (ele, telasup, xpos, ypos, posicao) {

  let altura  = ele.clientHeight,
      largura = ele.clientWidth,
      top     = 1,
      left    = 1,
      tela_largura = 0,
      tela_left    = 0;

  if (telasup && telasup != '') { 
    tela_largura = telasup.clientWidth; 
    tela_altura  = telasup.clientHeight;
    tela_left    = getComputedStyle(telasup).marginLeft.replace('px',''); 
  } else {
    tela_largura = PRINCP.clientWidth;
    tela_altura  = PRINCP.clientHeight;
    tela_left    = 0;
  }  

  if (posicao == 'mouse') {
    top = ypos - altura - 60;
    if(top <= 0) {
      top = 1;
    }
    
    left = xpos - tela_left - (largura/2);  
    if (left <= 0) { 
      left = 1;
    }  
    if (left + largura > tela_largura) {
      left = tela_largura - largura - 5;
    }  
  } else {
    top = (tela_altura - altura) / 2;
    if(top <= 0 || posicao == 'top-center') {
      top = 1;
    }
    left = (tela_largura - largura) / 2 ;      
  }  
  ele.style.setProperty('top',   top+'px');
  ele.style.setProperty('left',  left+'px');
}

function etl_conexoes_teste (ele, p_id_conexao) {
  ele.classList.add('executando');
  call('etl_conexoes_teste', 'prm_id_conexao='+encodeURIComponent(p_id_conexao), 'etl').then(function(resposta){ 
    ele.classList.remove('executando');
    alerta('',resposta.split('|')[1],'',resposta.split('|')[0]); 
  });


}

function obterHoraAtualizada() {
  var dataAtual = new Date();
  var horaLocal = dataAtual.getHours();
  var minutosLocais = dataAtual.getMinutes();
  var horaFormatada = horaLocal.toString().padStart(2, '0');
  var minutosFormatados = minutosLocais.toString().padStart(2, '0');
  var horaMinutos = horaFormatada + 'h' + minutosFormatados;

  return horaMinutos;
}

function modal_txt_sup (event, texto, posicao) {
  
  if (texto.length == 0) {
    return;
  }
  
  let erro = 'N';
  call('modal_txt_sup', 'prm_txt='+encodeURIComponent(texto), 'fun').then(function(resposta){ 
    document.getElementById('modal-txt').innerHTML = resposta; 
    if (resposta.split('|')[0] == 'ERRO') { 
      alerta('',resposta.split('|')[1]); 
      erro = 'S';
    }  
  }).then(function(){ 
    if (erro == 'N') { 
      setTimeout(function(){ 
        let telaModal = document.getElementById('modal-txt-content');
        let telaSup    = document.getElementById('telasup')

        if (!posicao) { posicao = 'mouse';  }

        if ((texto.length < 200) && (texto.length > 70)) { document.getElementById('modal-txt-input').style.width = '500px';}
        if ( telaModal.clientWidth > 1200 ) { telaModal.style.width = '1200px'; }
        if ( telaModal.clientWidth > telaSup.clientWidth - 100)   { telaModal.style.width = (telaSup.clientWidth - 100).toString() + 'px'; }  

        if ( telaModal.clientHeight > 500 ) { telaModal.style.height = '500px'; }
        if ( telaModal.clientHeight > telaSup.clientHeight - 100 ) { telaModal.style.height = (telaSup.clientHeight - 50).toString() + 'px'; }  

        posiciona_modal(telaModal, telaSup , event.clientX, event.clientY, posicao);
        telaModal.classList.add('expanded'); 
      }, 200); 
    }  
  });
}

function posiciona_modal (ele, telasup, xpos, ypos, posicao) {

  let altura  = ele.clientHeight,
      largura = ele.clientWidth,
      top     = 1,
      left    = 1,
      tela_largura = 0,
      tela_left    = 0;

  if (telasup && telasup != '') { 
    tela_largura = telasup.clientWidth; 
    tela_altura  = telasup.clientHeight;
    tela_left    = getComputedStyle(telasup).marginLeft.replace('px',''); 
  } else {
    tela_largura = PRINCP.clientWidth;
    tela_altura  = PRINCP.clientHeight;
    tela_left    = 0;
  }  

  if (posicao == 'mouse') {
    top = ypos - altura - 60;
    if(top <= 0) {
      top = 1;
    }
    
    left = xpos - tela_left - (largura/2);  
    if (left <= 0) { 
      left = 1;
    }  
    if (left + largura > tela_largura) {
      left = tela_largura - largura - 5;
    }  
  } else {
    top = (tela_altura - altura) / 2;
    if(top <= 0 || posicao == 'top-center') {
      top = 1;
    }
    left = (tela_largura - largura) / 2 ;      
  }  
  ele.style.setProperty('top',   top+'px');
  ele.style.setProperty('left',  left+'px');
}

function etl_conexoes_teste (ele, p_id_conexao) {
  ele.classList.add('executando');
  call('etl_conexoes_teste', 'prm_id_conexao='+encodeURIComponent(p_id_conexao), 'etl').then(function(resposta){ 
    ele.classList.remove('executando');
    alerta('',resposta.split('|')[1],'',resposta.split('|')[0]); 
  });


}

// função usada para exportar o que está na tela para PDF
function imprimir_pagina(id_elemento) {
    // aplica regra no iframe para gerar corretamente o canva
    var regra_iframe = muda_regra_iframe();
    var dashboards = move_dashboards_fixos();
    if (id_elemento == null && document.getElementById('main') && document.getElementById('main').children.length > 0){
        for(c in document.getElementById('main').children){
            if (document.getElementById('main').children[c].id) {
                if (document.getElementById('main').children[c].id.startsWith('SECTION')){
                  id_elemento = 'main';
                  break;
                } else if (document.getElementById('main').children[c].id.endsWith('data_list')){
                  id_elemento = document.getElementById('main').children[c].id;
                  break;
                }
            }
        }
        if (id_elemento == null){
            id_elemento = 'main';
        }
    }
    var el = document.getElementById(id_elemento);
    // coleta propriedades de tamanho da tela para gerar o pdf de acordo e
    // manter a proporção dos elementos na página
    var style = el.currentStyle || window.getComputedStyle(el);
    var el_width = el.offsetWidth+parseFloat(style.marginLeft)+parseFloat(style.marginRight)+2;//+1 da margem em cada lado
    var el_height = el.offsetHeight+parseFloat(style.marginTop)+parseFloat(style.marginBottom)+2;//+1 da margem em cada lado
    var nome_arquivo = (id_elemento === 'data_list') ? 'browser.pdf' : 'dashboard.pdf';
    var opt = {
        margin: 1,
        filename: nome_arquivo,
        image: {type: 'png'},
        enableLinks: false,
        pagebreak: {mode:['avoid-all']},
        html2canvas: {
            allowTaint:true, useCORS: true, scrollY: 0, scrollX: 0, 
            removeContainer: false, logging: true,
            // ignora elemento que configura tamanho da fonte do objeto browser pois ele 
            // saia sem o estilo de slider no pdf, desta forma ele não é exportado
            ignoreElements: (element)=>{
                if (element.classList.contains('font-size') && element.tagName == 'INPUT'){
                    return true;
                }
                if (element.classList.contains('frame') && element.tagName == 'IFRAME'){
                  return true;
                }
                return false;
            },
            // após o objeto ser clonado (pré geração do canva que será exportado)
            // essa função corrige um problema de visualização da biblioteca
            onclone : (doc, refele) => {
                if (doc.getElementById('main').querySelector('div:not([class],[id])')) {
                  let div = doc.getElementById('main').querySelector('div:not([class],[id])')
                  if (div.innerHTML === '' && div.parentNode.id === 'main'){
                    doc.getElementById('main').querySelector('div:not([class],[id])').remove();
                  }
                }
                if (id_elemento !== 'data_list'){onclone_arrumar_outline(doc);}
                // throw new Error("teste aqui")
            }
        },
        jsPDF: {orientation:'landscape', 
                unit:'px', 
                hotfixes: ["px_scaling"], 
                format:[el_width, el_height]}
    }
    alerta("msg", "Iniciando exporta&ccedil;&atilde;o");
    var w = html2pdf() 
    w = w.set(opt).then(loading()).from(el)
    //.then(loading())
    // retorna o worker que da biblioteca que gera o pdf
    // pode ser usado para interagir com a biblioteca de algumas formas
    // foi usado desta forma durante os testes e mantido assim para caso
    // haja necessidade de futuros testes
    return w.save()
        .then(
            ()=>{
                muda_regra_iframe(regra_iframe);
                move_dashboards_fixos(dashboards);
                loading();
                alerta("msg", "PDF gerado com sucesso!");
            },
            (errMsg)=>{
                muda_regra_iframe(regra_iframe); 
                move_dashboards_fixos(dashboards);
                loading();
                alerta("msg", "Erro gerando PDF!", '', 'ERRO');
                console.log(errMsg)
            });
}

function move_dashboards_fixos(dashboards){
  if (dashboards === undefined || dashboards === null){
    // let id, propName, prop;
    let dashes = [];
    let dashboards = document.getElementById('main').children;
    // dashboards = dashboards.filter((dash)=>{dash.style.contains('top')||dash.style.contains('bottom')})
    for(let dash of dashboards){
      if(dash.style.top){
        dashes.push({id:dash.id, propName:'top', prop:dash.style.top});
        dash.style.removeProperty('top');
      }
      if(dash.style.bottom){
        dashes.push({id:dash.id, propName:'bottom', prop:dash.style.bottom});
        dash.style.removeProperty('bottom');
      }
      if(dash.style.position){
        dashes.push({id:dash.id, propName:'position', prop:dash.style.position});
        dash.style.position = 'relative';
      }
    }
    return dashes;
  } else {
    for(let dt of dashboards){
      document.getElementById(dt.id).style.setProperty(dt.propName,dt.prop);
    }
  }
}

function onclone_arrumar_outline(doc){
    // essa função é necessária pois a biblioteca que gera o canvas não trabalha
    // com o outline (já que a ideia dele é marcar algo que o usuario está 
    // selecionando ou interagindo) então é necessário simular a aparencia do outline 
    // com outras propriedades de estilo
    let main = doc.getElementById('main');
    main.style.paddingTop = '0px';
    var border_style
    let tables = doc.getElementsByTagName('table');
    for(let table of tables){
      let trs = table.getElementsByTagName('tr');
      for(let tr of trs){
        let ths = tr.getElementsByTagName('th');
        let tds = tr.getElementsByTagName('td');
        let tr_bgColor = window.getComputedStyle(tr).backgroundColor;
        for(let th of ths){
          border_style = window.getComputedStyle(th).outlineColor
          th.style.outline = 'none';
          th.style.outlineOffset = 'none';
          th.style.borderColor = border_style;
          th.style.borderTopWidth = '1px'
          th.style.borderTopStyle = 'solid'
          th.style.top = '0px';
          th.style.backgroundColor = window.getComputedStyle(th).backgroundColor;
        }
        for(let td of tds){
          border_style = window.getComputedStyle(td).outlineColor
          td.style.outline = 'none';
          td.style.outlineOffset = 'none';
          if(td.style.backgroundColor === '' && !tr.classList.contains('total')){
            td.style.backgroundColor = tr_bgColor;
          } else {
            td.style.backgroundColor = window.getComputedStyle(td).backgroundColor;
          }
        }
        tr.style.setProperty('background-color', 'transparent')
      }
      table.setAttribute('border', '0');
      table.setAttribute('borderspacing', '1');
      table.setAttribute('cellpadding', '1');
      table.parentElement.style.backgroundColor = border_style;
    }
    return doc
}

function muda_regra_iframe(regra_iframe){
    // essa mudança no css é necessária pois a biblioteca usa iframes em algum 
    // momento do seu funcionamento para gerar o canva e como ela usa o CSS computado os
    // elementos precisam estar visiveis para que ela funcione
    if (regra_iframe === undefined || regra_iframe === null){
        regra_iframe = []
        for (let ss of document.styleSheets){
            try {
                for(let i=0; i < ss.cssRules.length; i++){
                    let rule = ss.cssRules[i]
                    if (!( rule instanceof CSSStyleRule)){
                        continue
                    } else {
                        if (rule.selectorText.indexOf('iframe') != -1 
                          && rule.style.display == 'none'){
                            regra_iframe.push(rule);
                            ss.cssRules[i].style.removeProperty('display');
                        }
                    }
                }
            } catch (DOMException) {
                continue
            }
        }
    } else {
        for(let ri of regra_iframe){
            ri.style.display = 'none'
        }
    }
    return regra_iframe;
}

function aviso_mostrar_novamente(botao) {
  var id = botao.getAttribute('data-valor')
  call('aviso_mostrar_novamente', 'prm_id_aviso='+id, 'cfg').then(function(resposta){
    alerta('',resposta.split('|')[1], '', resposta.split('|')[0]);
    if(resposta.indexOf('OK')!=-1){
      call('avisos', '', 'cfg').then((resposta)=>{
        document.getElementById("content").innerHTML = resposta;
      });
    }
  })
}

function atualizar_aviso(id_aviso, nome_param, obj) {
  var valor = obj.value || obj.title
  if (obj.tagName == 'A') {
    valor = document.getElementById(nome_param+'_'+id_aviso).title;
  }
  call('atualizar_aviso','prm_id_aviso='+id_aviso+'&prm_cd_coluna='+nome_param+'&prm_conteudo='+valor, 'cfg').then(function(resposta){
    alerta('',resposta.split('|')[1], '', resposta.split('|')[0]);
    if(resposta.split('|')[0] !== 'OK' || (resposta.split('|')[0] === 'OK' && nome_param.indexOf('prm_tp_conteudo')!==-1)){
      call('avisos', '', 'cfg').then((resposta)=>{
        document.getElementById("content").innerHTML = resposta;
      });
    }
  })
}

function notice_popup_go_to(prm_cd_tela) {
    call('ir_para_tela_aviso', 'prm_cd_tela='+prm_cd_tela, 'cfg').then(function(resposta){
        alerta('',resposta.split('|')[1], '', resposta.split('|')[0]);
        if (resposta.split('|')[0] === 'OK') {
            shscr(prm_cd_tela);
            document.getElementsByClassName('notice-close-popup')[0].click();
        }
    })
}

async function uploadArquivos(prm_alternativo, input_id) {
  var arquivosInput = document.getElementById(input_id||'arquivos');
  var arquivos = arquivosInput.files;
  var totalArquivos = arquivos.length;
  var arquivosEnviados = 0;
  var acao = OWNER_BI + '.upload.upload';
  
  if (document.getElementById('btnUploadArquivos')){
    var btn = document.getElementById('btnUploadArquivos');
    
    if (totalArquivos > 0) {
      btn.style.display = 'none';
    };
  }
  for (var i = 0; i < totalArquivos; i++) {
    var arquivo = arquivos[i];

    var arquivosRestantes = totalArquivos - arquivosEnviados;
    if (arquivosRestantes > 0) {
      alerta('msg', 'Enviando arquivo: ' + arquivo.name + ', ' + arquivosRestantes + '/'+ totalArquivos +' arquivos..');
    }

    if (prm_alternativo == null) {
      if (ADMIN == 'A') {
        prm_alternativo = 'DWU';
      } else {
        prm_alternativo = USUARIO;
      }
    }

    await enviarArquivo(arquivo, acao, prm_alternativo);
    arquivosEnviados++;
  }

}

function  mostrarArquivosSelecionados(btn_id, input_id) {

  var arquivosInput = document.getElementById(input_id || 'arquivos');
  var arquivos = arquivosInput.files;
  var totalArquivos = arquivos.length;
  
  var escolherArquivoButton = document.getElementById(btn_id || 'escolherArquivoButton');
  
  if (totalArquivos > 1) {
    
    var arquivosString = "";
    
    for (var i = 0; i < totalArquivos; i++) {
      arquivosString += arquivos[i].name + '\n';
    }

    escolherArquivoButton.title = arquivosString;
    escolherArquivoButton.innerHTML = totalArquivos + ' ARQUIVOS';
  } else {
    escolherArquivoButton.title = arquivos[0].name;
    escolherArquivoButton.innerHTML = arquivos[0].name;
  }

}

function enviarArquivo(arquivo, acao, prm_usuario) {
  return new Promise(function(resolve, reject) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', acao, true);
    xhr.onload = function () {
      var respostaDiv = document.createElement('script');
      respostaDiv.innerHTML = xhr.responseText;
      document.body.appendChild(respostaDiv);
      resolve();
    };
    xhr.onerror = function () {
      reject(xhr.statusText);
    };
    var formData = new FormData();
    formData.append('arquivo', arquivo);
    formData.append('prm_usuario', prm_usuario);
    xhr.send(formData);
  });
}


