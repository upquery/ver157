
calendar = {
  month_names: ["Janeiro","Fevereiro","Mar&ccedil;o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro",],
  weekdays: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"],
  month_days: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
  today: new Date(),
  opt: {},
  data: [],
  months_ingles: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
  months_portug: ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],

  wrt: function (txt) {
    this.data.push(txt);
  },

  getStyle: function (ele, property) {
    if (ele.currentStyle) {
      var alt_property_name = property.replace(/\-(\w)/g, function (m, c) {
        return c.toUpperCase();
      });
      var value =
        ele.currentStyle[property] || ele.currentStyle[alt_property_name];
    } else if (window.getComputedStyle) {
      property = property.replace(/([A-Z])/g, "-$1").toLowerCase(); //backgroundColor becomes background-color

      var value = document.defaultView
        .getComputedStyle(ele, null)
        .getPropertyValue(property);
    }

    //Some properties are special cases
    if (property == "opacity" && ele.filter)
      value = parseFloat(ele.filter.match(/opacity\=([^)]*)/)[1]) / 100;
    else if (property == "width" && isNaN(value))
      value = ele.clientWidth || ele.offsetWidth;
    else if (property == "height" && isNaN(value))
      value = ele.clientHeight || ele.offsetHeight;
    return value;
  },
  getPosition: function (ele) {
    var x = 0;
    var y = 0;
    while (ele) {
      x += ele.offsetLeft;
      y += ele.offsetTop;
      ele = ele.offsetParent;
    }
    if (
      navigator.userAgent.indexOf("Mac") != -1 &&
      typeof document.body.leftMargin != "undefined"
    ) {
      x += document.body.leftMargin;
      offsetTop += document.body.topMargin;
    }

    var xy = new Array(x, y);
    return xy;
  },
  selectDate: function (year, month, day) {
    
    var ths = _calendar_active_instance;
    var mes = ths.months_portug[month - 1];

    if (ths.opt["onDateSelect"]) {
      ths.opt["onDateSelect"].apply(ths, [year, mes, day]);
      if (ths.parentNode) {
        if (ths.parentNode.getAttribute("data-v")) {
          ths.parentNode.setAttribute("data-v", day + "-" + mes + "-" + year);
        }
      }
    } else {

      var inputElement = document.getElementById(ths.opt["input"]);
      if (!inputElement) {
        ths.hideCalendar();
        return;
      }

      //var isFloatPar = (inputElement.parentNode.parentNode.getAttribute("data-hint") != "FILTROS");

      var isFloatPar    = (inputElement.getAttribute("data-tipofloat") || '') == "PAR",
          isFloatFilter = (inputElement.getAttribute("data-tipofloat") || '') == "FILTER",
          isBrowser     = (inputElement.getAttribute("data-t") || '') == "calendario",
          isMulti       = (inputElement.getAttribute("data-multi") || 'N') == 'S',
          isVazio       = (inputElement.getAttribute("data-vazio") || 'S') == 'S'; 

      var inputVal     = inputElement.value.split("|"),
          inputValAnte = inputElement.value;
      var dateFormats = [
        day + "-" + mes + "-" + year,
        day + "-" + month + "-" + year,
        day + "/" + mes + "/" + year,
        day + "/" + month + "/" + year,
      ];

      var found = false;

      // Retira a data da seleção - Se a data já estava entre as selecionada
      for (var i = 0; i < dateFormats.length; i++) {
        if (inputVal.includes(dateFormats[i])) {
          inputVal = inputVal.filter((item) => item !== dateFormats[i]);
          inputElement.value = inputVal.join("|");
          found = true;
          break;
        }
      }
      
      // Adiciona a data como selecionada - Se a data não estava entre as selecionadas
      if (!found) {   
        let dateFormated = day + "-" + mes + "-" + year;
        if (isBrowser) {
          dateFormated = day + "/" + month + "/" + year;
        }  
        if (!isMulti) { 
          inputElement.value = dateFormated;  
        } else {
          let valueToAdd = inputElement.value == "" ? dateFormated : "|" + dateFormated;
          inputElement.value = inputElement.value + valueToAdd;
        }
      }

      if (!isVazio && inputElement.value.length == 0) {
        inputElement.value = inputValAnte; 
        alerta("feed-fixo", 'Filtro de preenchimento obrigat&oacute;rio n&atilde;o pode ficar vazio');
        return ;
      }

      if (ths.parentNode && ths.parentNode.getAttribute("data-v")) {
        ths.parentNode.setAttribute("data-v", inputElement.value);
      }

      if (inputElement.parentNode && inputElement.parentNode.hasAttribute("data-v") ) {
        inputElement.parentNode.setAttribute("data-v", inputElement.value);
      }
      inputElement.setAttribute('value', inputElement.value);  // Somente para atualizar o atributo value do input 

      var event = new Event('change');
      inputElement.dispatchEvent(event);

      if (isFloatPar) {
        if (
          document.getElementById(ths.opt["input"]).parentNode.parentNode.id == "form-parametro"
        ) {
          var float = document.getElementById(ths.opt["input"]).parentNode.parentNode;
          document.querySelector(".itens").setAttribute("data-alterado", "T");
          call("save_float","prm_conteudo=" +document.getElementById(ths.opt["input"]).value +"&prm_padrao=" + document.getElementById(ths.opt["input"]).parentNode.title +"&prm_screen=" +tela
          ).then(function (resposta) {
            if (resposta.indexOf("FAIL") == -1) {
              alerta("feed-fixo", TR_AL);
            } else {
              alerta("feed-fixo", resposta.split('FAIL')[1]);
            }
          });
          var filhos = float.children;
        }
      } else if (isFloatFilter) {
        document.querySelector(".itens").setAttribute("data-alterado", "T");
        call("save_float_filter", "prm_conteudo=" +document.getElementById(ths.opt["input"]).value +"&prm_coluna=" + document.getElementById(ths.opt["input"]).parentNode.title +"&prm_screen=" +tela
        ).then(function (resposta) {
          if (resposta.indexOf("FAIL") == -1) {
            alerta("feed-fixo", TR_AL);
          } else {
            alerta("feed-fixo", resposta.split('FAIL')[1]);
          }
        });
      }
    }

    ths.hideCalendar();
    if (isMulti) {    // !isFloatPar 
      ths.showCalendar(year, month);
    }
  },

  makeCalendar: function (year, month) {

    var ths = _calendar_active_instance;
    var currentDate = new Date();
    if (year == null) {
      year = currentDate.getFullYear();
    }
    if (month == null) {
      month = currentDate.getMonth();
    }
    year = parseInt(year);
    month= parseInt(month);
    month_idx = month - 1;
    
    //Cria array com as datas existentes no INPUT 
    var date_in_input = document.getElementById(this.opt["input"]).value;
    var dates_selected = []   
    if (date_in_input) {
      var dates_selected = date_in_input.split("|");
      dates_selected = dates_selected.map((dates) =>
        dates.includes("-") ? dates.split("-") : dates.split("/")
      );
      // Converte nome dos meses para númerico
      dates_selected.forEach((date) => {
        if (date[1].length == 3) {
          let idx = ths.months_portug.indexOf(date[1]);
          if (ths.months_portug.indexOf(date[1]) >= 0) {
            date[1] = ths.months_portug.indexOf(date[1]) + 1;
          } else { 
        	  date[1] = ths.months_ingles.indexOf(date[1]) + 1;
          }  
        }
        date[0] = parseInt(date[0]);
        date[1] = parseInt(date[1]);
        date[2] = parseInt(date[2]);
      })  
    }  

    var next_month = month + 1;
    var next_month_year = year;
    if (next_month > 12) {
      next_month = 1;
      next_month_year++;
    }

    var previous_month = month - 1;
    var previous_month_year = year;
    if (previous_month <= 0) {
      previous_month = 12;
      previous_month_year--;
    }

    this.wrt("<table>");
    this.wrt("<tr><th onclick='calendar.makeCalendar(" + previous_month_year +"," +previous_month +");'><</th>");
    this.wrt("<th colspan='5' class='calendar-title'><select name='calendar-month' class='calendar-month' onChange='calendar.makeCalendar(" + year +",this.value);'>");
    for (var i in this.month_names) {
      let idx = parseInt(i) + 1; 
      this.wrt("<option value='" + idx.toString() + "'");
      if (i == month_idx) this.wrt(" selected='selected'");
      this.wrt(">" + this.month_names[i] + "</option>");
    }
    this.wrt("</select>");
    this.wrt("<select name='calendar-year' class='calendar-year' onChange='calendar.makeCalendar(this.value, " + month +");'>");
    var current_year = this.today.getYear();
    if (current_year < 1900) current_year += 1900;

    for (var i = current_year - 50; i < current_year + 10; i++) {
      this.wrt("<option value='" + i + "'");
      if (i == year) this.wrt(" selected='selected'");
      this.wrt(">" + i + "</option>");
    }
    this.wrt("</select></th>");
    this.wrt("<th onclick='calendar.makeCalendar(" + next_month_year + "," + next_month + ");'>></th></tr>");
    this.wrt("<tr class='header'>");
    for (var weekday = 0; weekday < 7; weekday++)
      this.wrt("<td>" + this.weekdays[weekday] + "</td>");
    this.wrt("</tr>");

    var first_day = new Date(year,month-1,1);
    var start_day = first_day.getDay();

    var d = 1;
    var flag = 0;

    // Trata ano bisexto do mês de Fevereiro
    if (year % 4 == 0) this.month_days[1] = 29;
    else this.month_days[1] = 28;

    // Monta o calendário com as datas 
    var days_in_this_month = this.month_days[month_idx];    
    for (var i = 0; i <= 5; i++) {
      if (w >= days_in_this_month) break;
      this.wrt("<tr>");
      for (var j = 0; j < 7; j++) {
        if (d > days_in_this_month)       flag = 0;
        else if (j >= start_day && !flag) flag = 1;

        if (flag) {
          var w = d,
            mon = month;
          if (w < 10) w = "0" + w;
          if (mon < 10) mon = "0" + mon;

          var class_name = "";
          var yea = this.today.getYear();
          if (yea < 1900) yea += 1900;

          if ( yea == year && this.today.getMonth()+1 == month && this.today.getDate() == d ) {
            class_name = " today";
          }
            
          for (var x=0; x<dates_selected.length; x++) {
            if (dates_selected[x][0] == d && dates_selected[x][1] == month && dates_selected[x][2] == year) {
              class_name += " selected";
            }  
          }  

          class_name += " " + this.weekdays[j].toLowerCase();

          this.wrt("<td class='days" + class_name +"' onclick='calendar.selectDate(\"" + year + '","' + mon + '","' + w + "\");'>" + w + "</td>");
          d++;
        } else {
          this.wrt('<td style="border-color: transparent; box-shadow: none;" class="days">&nbsp;</td>');
        }
      }
      this.wrt("</tr>");
    }
    this.wrt("</table>");
    this.wrt(
      "<input type='button' value='Fechar' class='calendar-cancel' onclick='calendar.hideCalendar();' />"
    );

    document.getElementById(this.opt["calendar"]).innerHTML =
      this.data.join("");
    this.data = [];
  },

  showCalendar: function (year, month, tipo) {

    tipo = tipo || '';

    _calendar_active_instance = this;
    var ths = _calendar_active_instance ;

    if ( !this.opt["calendar"] || !document.getElementById(this.opt["calendar"])) {
      var div = document.createElement("div");
      if (!this.opt["calendar"])
        this.opt["calendar"] =
          "calender_div_" + Math.round(Math.random() * 100);

      div.setAttribute("id", this.opt["calendar"]);
      div.className = "calendar-box";

      if (tipo == 'calendarioBrowser') {
        document.getElementById("main").appendChild(div);
      } else {
        document.getElementById("get_float").appendChild(div);
      }

    }

    var input = document.getElementById(this.opt["input"]);
    var div   = document.getElementById(this.opt["calendar"]);

    if (this.opt["display_element"])
      var display_element = document.getElementById(
        this.opt["display_element"]
      );
    else var display_element = document.getElementById(this.opt["input"]);
    
    if (tipo != 'calendarioBrowser') {
      var xy = this.getPosition(display_element);
      if (xy[0] - 52 < 0) {
        xy[0] = 57;
      }
      div.style.left = xy[0] - 52 + "px"; // div.style.left=xy[0]-60+"px";  -- centralizado
      div.style.top = (xy[1] + 2) + "px";   // div.style.top=xy[1]+height+5+"px"; -- Alterado para subir um pouco mais o calendário
    } else {
      var inputFieldRect = input.getBoundingClientRect(), 
          calend_top     = inputFieldRect.top + 40, 
          calend_height  = 290;  // maior altura quando o mês tem mais de 5 (linhas)
      if (( calend_top + calend_height) > PRINCP.getBoundingClientRect().height) {
        calend_top = PRINCP.getBoundingClientRect().height - calend_height;
      }    
      div.style.position = 'fixed';
      div.style.top      = calend_top + 'px';
      div.style.left     = (inputFieldRect.left) + 'px';
    }

    if (year == null || month == null) { 
      var date_in_input = input.value;
      if (date_in_input) {

        // Pega o ano e mês da primeira data selecionada 
        var date_first = date_in_input.split("|")[0];
        var date_parts = date_first.includes("-") ? date_first.split("-") : date_first.split("/") ; 
        if (isNaN(date_parts[1])) {
          month = ths.months_portug.indexOf(date_parts[1])+1;
        } else {
          month = parseInt(date_parts[1]);  
        }  
        year = date_parts[2];
      } else {
        var currentDate = new Date();
        year  = currentDate.getFullYear();
        month = currentDate.getMonth()+1;
      }
    }  

    this.makeCalendar(year, month );
    document.getElementById(this.opt["calendar"]).style.setProperty("display", "block");
  },

  hideCalendar: function (instance) {
    var active_calendar_id = "";
    if (instance) active_calendar_id = instance.opt["calendar"];
    else active_calendar_id = _calendar_active_instance.opt["calendar"];

    if (active_calendar_id) {
      document
        .getElementById(active_calendar_id)
        .parentNode.removeChild(document.getElementById(active_calendar_id));
    }

    _calendar_active_instance = {};
  },

  set: function (input_id, opt, tipo) {
    
    var input = document.getElementById(input_id);
    if (!input) {
      return;
    }
    
    if (opt) this.opt = opt;

    if (!this.opt["calendar"]) {
      this.init(tipo);
    }  

    var ths = this;
    if (this.opt["onclick"]) input.onclick = this.opt["onclick"];
    else {
      input.onclick = function () {
        ths.opt["input"] = this.id;
        ths.showCalendar(null,null,tipo);
      };
    }
  },

  init: function (tipo) {
    if (!this.opt["calendar"] || !document.getElementById(this.opt["calendar"]) ) {
      var div = document.createElement("div");
      if (!this.opt["calendar"])
        this.opt["calendar"] = "calender_div_" + Math.round(Math.random() * 100);

      div.setAttribute("id", this.opt["calendar"]);
      div.className = "calendar-box";
      if (tipo == 'calendarioBrowser') {
        document.getElementById("main").appendChild(div);
      } else {  
        document.getElementById("get_float").appendChild(div);
      }
    }
  },
};
