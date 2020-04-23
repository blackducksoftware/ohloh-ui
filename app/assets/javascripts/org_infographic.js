OrganizationPictogram = {
  init: function() {
    SVGArrow.generate();
    OrganizationPictogram.block_ui();
    OrganizationPictogram.select_subview();
    OrganizationPictogram.default_selected("view");
    OrganizationPictogram.print_infographic();
    AppendHistory.init();
  },
  select_subview: function(){
    $(".select_sub_view").click(function() {
      var update = $(this).attr('update');
      $.ajax({
        url: $(this).attr('url'),
        success: function(response) {
          $('#org_infographic').replaceWith(response.pictogram_html);
          $(update).html(response.subview_html);
          OrganizationPictogram.init();
          Expander.init();
          $.unblockUI();
        }
      });
      return false;
    });
  },
  print_infographic: function(){
    $(".print_infographic").click(function(){
    if (!!window.chrome) {
      var print_window = window.open($(this).attr('url'), "print_win", '');
      print_window.focus();
      print_window.print();

    } else {
      var output = $("#org_infographic").clone().find("a.print_infographic").remove().end();
      output.find('a').removeAttr('href').addClass('infographic_links_in_print');
      var print_window = window.open($(this).attr('url'), "print_win", '');
      $(print_window).on('load', function(){
        $(print_window.document.body).find('#org_infographic').html(output);
        print_window.focus();
        print_window.print();
      });
    }
    });
  },
  /* Block the Page While loading the Data Tables */
  block_ui: function(){
    $(".block_ui").click(function(){
      $.blockUI({ message: $('.spinner').html() });
    });
  },
  default_selected: function(view){
    var match = location.search.match(new RegExp("[?&]"+view+"=([^&]+)(&|$)"));
    params_value = match && decodeURIComponent(match[1].replace(/\+/g, " "));
    if(params_value == null)
      params_value = $("#infographic_box").attr("default_view");
    $('.'+params_value).addClass('pictogram_link_active').attr("href", "javascript:void(0)").unbind("click");
  }
};

var AppendHistory = {
  init: function() {
    $(".append_history").click( function() {
      var url = $(this).attr('url');
      var title = $(this).attr('append_title');
      if(url != "")
        history.pushState('', title, url);
      return false;
    });
  }
};

