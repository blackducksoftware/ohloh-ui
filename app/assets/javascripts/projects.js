ProjectForm = {
  preview_url_name_label: 'label#preview_url_name',
  url_name_input: 'input#project_url_name',
  valid_url_name_re: /^[a-zA-Z][\w-]*$/,

  init: function() {
    $( document ).delegate( 'a.remove_license', 'click', function() {
      $(this).closest('.license').remove();
      $('input.license_id_' + $(this).attr('data_id')).remove();
      if( $('.chosen_licenses').html() === '' ) {
        $('.chosen_licenses').html('<div class="license inset">[None]</div>');
      }
      return false;
    });

    this.license_autocomplete();
  },

  license_autocomplete: function() {
    var licenses = [];
    var add_license = $('#add_license');
    if( add_license.size() === 0 ) return;
    add_license.autocomplete({
      source : '/autocompletes/licenses',
      focus: function(e, ui) {
        $( "#add_license" ).val( ui.item.name );
      },
      select: function(event, ui) {
        var $input = $("<input />", {
                        type: 'text',
                        style: 'display:none;',
                        name: 'project[project_licenses_attributes][][license_id]',
                        'class': 'license_id_' + ui.item.id,
                        value: ui.item.id });
        $input.insertAfter($('#add_license'));

        licenses.push(ui.item.name)

        if( $.trim($('.chosen_licenses div:first').html()) === '[None]' ) {
          $('.chosen_licenses').html('');
        }

        var html = (''+
        '<div class="license col-md-5 no_margin_left">'+
        '  <div class="col-md-6">#{name}</div>'+
        '  <div class="col-md-5 pull-right" style="margin: 0 20px 20px 0">'+
        '     <a href="#" class="btn btn-danger btn-mini remove_license col" data_id="#{id}">'+
        '        <i class="icon-trash"></i> Remove</a>'+
        '  </div>'+
        '</div>')._f(ui.item);
        $('.chosen_licenses').append(html);
      }
    })
    .autocomplete( "instance" )
    ._renderItem = function( ul, item ) {
      return $( "<li></li>" )
        .data( "item.autocomplete", item )
        .append( "<a>" + item.name + "</a>" )
        .appendTo( ul );
    };
  }
}

SimilarProjects = {
  init: function(){
    if($('#projects_show_page').length == 0) return;
    var project_id = $('#similar_projects').data('project-id');
    $('#similar_projects').html('');
    $('#related_spinner').show();
    $.ajax({
      url: '/p/' + project_id + '/similar_by_tags',
      success: function (data, textStatus) {
        $('#similar_projects').html( data );
      },
      complete: function() {
        $('#related_spinner').hide();
      }
    });
  }
}

$(document).on('page:change', SimilarProjects.init())

$(document).ready(function() {

  $("input[name='stacked']").each(function(index) {
    if ( $(this).attr("data-stackentry") ) {
      $(this).prop("checked",true);
    }
  });

  $("input[name='stacked']").click(function() {
    if ($(this).prop("checked") == true) {
      var target = $(this).attr("target");
      var message = ".message-position#message" + target;
      var $stackId = $(this).data("stack");
      var $projectUrlName = $(this).data("project");
      $('#related_spinner[target=' + '"' + target + '"' +']').removeClass("hidden");
      $.ajax("/stacks/" + $stackId + "/stack_entries",{
        type: "POST",
        data: "stack_entry[project_id]=" + $projectUrlName,
        dataType: 'json',
        success: function(data){
          if ($(".unstack-message").length) {
            $(".unstack-message").remove();
          }
          $(":checked").attr("data-stackentry", data.stack_entry_id);
          $(message).append("<p class=stack-message>stacked</p>");
        },
        complete: function(){
          $('#related_spinner[target=' + '"' + target + '"' +']').addClass("hidden");
        }
      });
    } else {
      var $inputElement = $(this);
      var target = $(this).attr("target");
      var message = ".message-position#message" + target;
      var $stackId = $(this).data("stack");
      var $stackEntryId = $(this).data("stackentry");
      $('#related_spinner[target=' + '"' + target + '"' +']').removeClass("hidden");
      $.ajax("/stacks/" + $stackId + "/stack_entries/" + $stackEntryId, {
        type: "DELETE",
        dataType: 'json',
        context: $inputElement,
        success: function() {
          $(".stack-message").remove();
        },
        complete: function(){
          $('#related_spinner[target=' + '"' + target + '"' +']').addClass("hidden");
        }
      }).done(function(){
        $(message).append("<p class=unstack-message>unstacked</p>");
        $inputElement.removeAttr("data-stackentry");
      });
    }
  });
});
