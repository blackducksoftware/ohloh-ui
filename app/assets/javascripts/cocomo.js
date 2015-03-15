var Cocomo = {
  init: function() {
    $('#cocomo_loc_dropdown').change(Cocomo.update_cocomo);
    $('#cocomo_salary').change(Cocomo.update_cocomo);
    $('#cocomo_salary').keyup(Cocomo.update_cocomo);
  },

  number_with_delimiter: function(n) {
    var d = ',';
    n = n.toString();

    if (n.length > 3) {
      var mod = n.length % 3;
      var output = (mod > 0 ? (n.substring(0,mod)) : '');
      for (i=0 ; i < Math.floor(n.length / 3); i++) {
        if ((mod == 0) && (i == 0))
          output += n.substring(mod+ 3 * i, mod + 3 * i + 3);
        else
          output+= d + n.substring(mod + 3 * i, mod + 3 * i + 3);
      }
      return output;
    }
    else {
      return n;
    }
  },

  loc_from_index: function(i) {
    var cocomo_loc = $("#cocomo_loc_dropdown")[0];
    return parseInt(cocomo_loc.options[i].value);
  },

  update_cocomo: function() {
    var cocomo_loc = $("#cocomo_loc_dropdown")[0];
    var man_years = 0;
    var loc_code = Cocomo.loc_from_index(1);
    var loc_markup = Cocomo.loc_from_index(2);
    var loc_build = Cocomo.loc_from_index(3);
    var loc = 0;
    switch(cocomo_loc.selectedIndex) {
      case 0:
        loc = loc_code + loc_markup + loc_build;
        man_years = project_analysis.logic_man_years + project_analysis.markup_man_years + project_analysis.build_man_years
        break;
      case 1:
        loc = loc_code;
        man_years = project_analysis.logic_man_years;
        break;
      case 2:
        loc = loc_markup;
        man_years = project_analysis.markup_man_years;
        break;
      case 3:
        loc = loc_build;
        man_years = project_analysis.build_man_years;
        break;
    }
    var salary = parseFloat($("#cocomo_salary")[0].value);
    final_cost = man_years * salary;
    if (isNaN(final_cost)) {
      final_cost = 0;
    }
    $("#cocomo_years").html(Cocomo.number_with_delimiter(Math.round(man_years)));
    $("#cocomo_loc").html(Cocomo.number_with_delimiter(Math.round(loc)));
    $("#cocomo_value").html(Cocomo.number_with_delimiter(Math.round(final_cost)));
  }
}
