StackVerb = {
  path: '/stacks/*/stack_entries',

  init: function() {
    $(".stack_verb, .stack_trigger").not($(".create_and_stack")).unbind().click(StackVerb.stackit);
    $("form.create_stack_entry input[type=checkbox]").unbind().click(StackVerb.checkbox);
    $(".create_and_stack").unbind().click(StackVerb.create_and_stack);
  },

  checkbox: function() {
    var project_id = $(this).attr('id').split("_")[1];
    var stack_id = $(this).attr('id').split("_")[2];
    var stackit = $(this).is(':checked');
    var status_span = $(this).parent().parent().find('span.status');
    status_span.val("&nbsp;");
    status_span.addClass('busy');
    $.ajax({
      url: '/stacks/' + stack_id + '/stack_entries' + ( (stackit) ? '' : '/*'+'.json'),
      data: {'stack_entry[project_id]':project_id},
      type: stackit ? "POST" : "DELETE",
      success: function(result, textStatus) {
        status_span.removeClass('busy');
        status_span.html( stackit ? "stacked" : "unstacked" );
      }
    });
  },

  create_and_stack: function() {
    var project_id = $(this).attr('id').split("_")[1];
    var data = {};
    if (project_id != "nil") {
      data = {'initial_project_id':project_id}
    }
    $.ajax({
      url: "/stacks.json",
      data: data,
      dataType: "json",
      type: "POST",
      success: function(json) {
        //tb_remove();
        window.location = json.stack_url;
      },
      error: function (xml_http_request, textStatus, errorThrown) {
        alert('Error: ' + xml_http_request.responseText);
      }
    });
    return true;
  },

  stackit: function() {
    var project_id = $(this).attr('id').slice("stackit_".length);
    var u ='/stack_entries/new?height=350&width=370&project_id='+project_id;
    if ($(this).hasClass('dontnav')) {
      u = u + "&dontnav=t";
    }
    tb_show('Add to Stacks', u, false);
    return false;
  }
}


StackShow = {
  init: function() {
    StackShow.recommendations_init();
    StackShow.hook();
    StackShow.add_project_init();
  },
  reinit: function() {
    StackShow.recommendations_init(true);
    StackShow.rehook();
    ProjectRating.init();
    Expander.init();
  },
  hook: function() {
    $(".stack_remove").bind("click", StackShow.remove);
    $("#show").click(StackShow.show_recommendations_panel);
    $("#hide").click(StackShow.hide_recommendations_panel);
  },
  rehook: function() {
    $(".stack_remove").unbind("click", StackShow.remove);
    $(".stack_remove").bind("click", StackShow.remove);
  },
  recommendations_init: function(reinit) {
    $("a.stack_add").click(StackShow.add);
    $(".recommendations a#skip_all").click(StackShow.skip_all);
    $(".recommendations a#more").click(StackShow.more);
    $("a.ignore").click(StackShow.skip);
    if(reinit != true) $(".clear_ignores").click(StackShow.clear_ignores);
  },

  add_project_init: function() {
    $('input#stack_entry_project_name').autocomplete({source:'/p/autocomplete'});
    $('input#new_stack_entry').click(StackShow.add_autocompleted_project);
    $('#add_project_form').submit(StackShow.add_autocompleted_project);
  },

  add_autocompleted_project: function() {
    var project_name = $("input#stack_entry_project_name").val();
    $.ajax({
      url: '/stacks/'+StackShow.stack_id()+'/stack_entries.json',
      data: {'stack_entry[project_name]':project_name},
      type: "POST",
      dataType: "json",
      success: function(json) {
        StackShow.add_stack_entry(json);
        StackShow.update_count(json);
        StackShow.reinit();
        StackShow.update_recommendations(null, $("a:visible").filter("#skip_all, #more"));
      },
      error: function (xml_http_request, textStatus, errorThrown) {
        alert('Error: ' + xml_http_request.responseText);
      }
    });
    return false;
  },

  enable_more_or_skip_link: function(which) {
    $(".clear_ignores").html("Show All Projects");
    switch (which) {
    case "more":
      $(".recommendations a#more").show();
      $(".recommendations a#skip_all").hide();
      break;
    case "skip":
      $(".recommendations a#more").hide();
      $(".recommendations a#skip_all").show();
      break;
    default:
      alert("unexpected");
    }
  },

  stack_id: function() {
    return $("table.stack_list") && $("table.stack_list").attr('id').slice("stack_list_".length);
  },

  add_stack_entry: function(json) {
    var stack_entry = json.stack_entry;
    if (stack_entry == null) {
      return;
    }
    var list = $(".stack_item_list > table")
    list.prepend(stack_entry);
    var new_entry = $(list.find('tr'));
    new_entry.slideDown(1000, function() {
      RestInPlace.init();
    }).ohloh_fade();
    $(".empty_stack_text").slideUp();
    StackShow.update_previews();
  },

  timeoutPreview: null,
  timeoutDelay: 3000, // 4 seconds
  update_previews: function() {
    if (StackShow.timeoutPreview != null) {
      clearTimeout(StackShow.timeoutPreview);
    }
    StackShow.timeoutPreview = setTimeout('StackShow.update_callback()', StackShow.timeoutDelay);
  },
  update_callback: function() {
    StackShow.update_widget_preview();
    StackShow.update_similar_stacks_preview();
    StackShow.timeoutPreview = null;
  },
  update_widget_preview: function() {
    $(".widget_preview").load("/stacks/"+StackShow.stack_id()+"/widgets/stack_normal.html?icon_height=16&icon_width=16&projects_shown=8&width=100");
  },
  update_similar_stacks_preview: function() {
    $("#similar_stacks").load("/stacks/"+StackShow.stack_id()+"/similar_accounts?preview=true");
  },

  execute: function(clicked_link, url, type, action) {
    clicked_link.html("&nbsp;").addClass('busy').blur().css('padding', '0px 8px').unbind();
    var project_id = clicked_link.attr('id') && clicked_link.attr('id').slice("stackit_".length);
    var project_node = clicked_link.parents(action == "remove" ? 'tr' : 'li');
    if (type != "DELETE") { // user has stacked or skipped something
      StackShow.enable_more_or_skip_link("more");
    }
    if (action == "skip") {
      data = {'stack_ignore[project_id]' : project_id}
    } else {
      data = {'stack_entry[project_id]': project_id}
    }
    $.ajax({
      url: url+'.json'+location.search,
      data: data,
      type: type,
      dataType: "json",
      success: function(json) {
        if (type == "DELETE") { // user has unstacked something
          project_node.slideUp(1000, function() {
            remaining_stack_size = project_node.siblings('tr').length;
            if (remaining_stack_size == 0) project_node.parents('tbody').remove();
            else project_node.remove();
          });
          StackShow.update_recommendations();
        } else { // user has stacked or skipped something
          project_node.css('background-color','#ddd').addClass('handled');
          if (action == "stack") {
            project_node.find(".stack_right").html("<span>In Use</span>");
            StackShow.add_stack_entry(json);
          } else {
            project_node.find(".stack_right").html("<span>Skipped</span>");
          }

        }
        StackShow.update_count(json);
        StackShow.reinit();
        StackShow.update_previews();
      }
    });
    return false;
  },
  add: function() { return StackShow.execute($(this),'/stacks/'+StackShow.stack_id()+'/stack_entries', "POST", "stack"); },
  skip: function() { return StackShow.execute($(this), '/stacks/'+StackShow.stack_id()+'/stack_ignores', "POST", "skip"); },
  remove: function() {
    stack_entry = $(this).parents('tr.stack_entry').attr('id').split("_")[2];
    return StackShow.execute($(this), '/stacks/'+StackShow.stack_id()+'/stack_entries/'+stack_entry, "DELETE", "remove");
  },


  // an array of the currently recommended projects
  visible_recommendations: function() {
    var projects = new Array();
    $(".recommendations .list li:not([class='handled']) a.ignore").each( function(i) {
      projects[projects.length] = $(this).attr('id').split("_")[1];
    });
    return projects;
  },
  fix_links: function(link) {
    if (link != null) {
      link.show();
    }
    $(".busy").remove();
    StackShow.enable_more_or_skip_link("skip");
  },

  busy_div: "<div class='busy' style='padding:0 8px 8px;float:right;'>&nbsp;</div>",

  // Navigation links
  clear_ignores: function() {
    var clear_link = $(this).html("&nbsp;");
    clear_link.before("<div class='busy' style='padding:0 8px 8px;float:left;'>&nbsp;</div>");
    $.ajax({
      url:'/stacks/' +StackShow.stack_id()+ '/stack_ignores/delete_all',
      type: "DELETE",
      success: function() {
        StackShow.get_more(null, null);
        return false;
      }
    });
    return false;
  },

  skip_all: function() { StackShow.get_more(StackShow.visible_recommendations(), $(this)) },
  more: function() { StackShow.get_more(null, $(this)) },
  update_recommendations: function() {
    StackShow.get_more(null, $("a:visible").filter("#skip_all, #more"));
  },

  getting_more: false,
  get_more_timer: null,
  get_more: function(skip_projects, link) {
    if ($("#recommendations:hidden").length > 0) {
      return;
    }
    if (StackShow.getting_more) {
      if (StackShow.get_more_timer != null) { clearTimeout(StackShow.get_more_timer); }
      StackShow.get_more_timer = setTimeout('StackShow.get_more('+skip_projects+',null)', 1000);
      return;
    } else {
      StackShow.getting_more = true;
    }
    if (link != null) {
      link.hide();
      if ($(".busy").length == 0) {
        link.after(StackShow.busy_div);
      }
    }
    if (skip_projects == null) {
      skip_projects = ""
    }
    $.getJSON(
      '/stacks/'+StackShow.stack_id()+'/builder.json',
      {ignore:String(skip_projects)},
      function(result) {
        var list = $(".recommendations .list");

        // we're going to slide up the new recommendations
        list.css('height', list.height()); // make height fixed, the larger div is overflow:hidde
        list.find("li").wrapAll("<div id='delete_me'></div>");
        list.children("ul").append(result.recommendations);
        list.find("#delete_me").slideUp(1000, function() {
          $(this).remove();
          list.css('height', 'auto');
          StackShow.getting_more = false;
        });

        StackShow.fix_links(link);
        StackShow.reinit();
      }
    );
  },

  update_count: function(json) {
    if (json.updated_count) {
      $(".listing_result").html(json.updated_count).ohloh_fade();
      if (json.updated_count.split(" ")[0] == "[0") {
        $("#empty_stack_text").fadeIn("slow");
      } else {
        $("#empty_stack_text").fadeOut("slow");
      }
    }
  },

  show_recommendations_panel: function() {
    $("a#show").before("<div class='busy' style='width:16px;float:right;'>&nbsp;</span>");
    $.getJSON('/stacks/'+StackShow.stack_id()+'/builder.json', function(response) {
      var show_div = $("a#show").parent().parent();
      $("a#show").siblings('.busy').remove();
      $(".recomendations").css('height', $("recommendations").height);
      show_div.hide();
      show_div.siblings('.clear').show();
      $(".recomendations").css('height', 'auto');

      $(".recommendations .controls").show();
      $(".recommendations a.clear_ignores").show();
      $(".recommendations .list ul").hide();
      $(".recommendations .list ul").html(response.recommendations).slideDown();
      StackShow.recommendations_init(true);
      StackShow.enable_more_or_skip_link("skip");
      return false;
    });
  },
  hide_recommendations_panel: function() {
    var hide_div = $("a#hide").parent().parent();
    $(".recommendations .controls").hide();
    $(".recommendations .list ul").slideUp().html("");

    //$(".recomendations").css('height', $("recommendations").height);
    hide_div.hide();
    hide_div.siblings('.clear').show();
    $(".recomendations").css('height', 'auto');
  }
}
