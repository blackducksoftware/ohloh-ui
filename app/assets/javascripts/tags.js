JumpToTag = {
  init: function() {
    $('form[rel=tag_jump]').submit(function() {
      if ($('input#input_tag').val() != '') {
        tag_value = encodeURIComponent($('input#input_tag').val().toLowerCase());
        window.location.href = '/tags?names=' + tag_value;
        return false;
      }
      return false;
    });

    $('input.tag_autocomplete').autocomplete({ source : '/autocompletes/tags', select : function(e, ui){
      $(this).val(ui.item.value);
      $('form[rel=tag_jump]').submit();
    }});
  }
}

TagCloud = {
  init: function() {
    $.fn.tagcloud.defaults = {
      size: {start: 10, end: 18, unit: 'pt'},
      color: {start: '#999', end: '#000'}
    };
    $('#tagcloud a').tagcloud();
  }
}

TagNew = {
  init:function() {
    var project_id = $('form#edit_tags').attr('project_id');
    var term = $('#input_tags').val();
    $('#input_tags').autocomplete({source:'/autocompletes/tags?project_id='+project_id+'&term='+term, select : function (evt, ui) {
      tags_value = ui.item.value;
      $('form[rel=tag_edit]').submit();
      $('#input_tags').val('');
     }});
  }
}


TagEdit = {
  init: function() {
    if ($('input#input_tags').length == 0) return;
    $('form#edit_tags').submit(TagEdit.onSubmit);
    $('a.tag.add').click(TagEdit.onTagAddClick);
    $('a.tag.delete').click(TagEdit.onTagDeleteClick);
  },
  onSubmit: function() {
    input = $('#input_tags')[0];
    value = $.trim(input.value);
    input.value = '';
    if (value != "") {
      TagEdit.create(value);
    }
    return false;
  },
  create: function(text) {
    text = text.replace(".", "", "g");
    taglinks = $('a.tag[tagname=\'' + text + '\']');
    taglinks.unbind('click', TagEdit.onTagAddClick).removeClass('add');
    $(".spinner").show();
    $("#error").hide();
    $("#submit").attr("disabled",'');
    var project = $('form#edit_tags').attr('project');
    $.ajax({
      type: "POST",
      url: '/p/' + project + '/tags',
      data: {tag_name: text},
      success: function (data, textStatus) {
        TagEdit.update_status(text);
        taglinks.click(TagEdit.onTagDeleteClick).addClass('delete');
        TagEdit.setTagArray(data.split('\n'));
        $(".spinner").hide();
        $("#submit").removeAttr('disabled');
      },
      error: function(resp){
        $("#error").html(resp.responseText).show();
        $(".spinner").hide();
        $("#submit").removeAttr('disabled');
      }
    });
  },
  update_status: function(text) {
    taglinks = $('a.tag[tagname=\'' + text + '\']');
    var project = $('form#edit_tags').attr('project');
    $.ajax({
      type: "GET",
      url: '/p/' + project + '/tags/status',
      success: function (data, textStatus) {
        $('p.tags_left').html(data[1]);
        if(data[0] < 1) { $("#edit_tags").hide(); }
      }
    });
  },
  destroy: function(text) {
    taglinks = $('a.tag[tagname=\'' + text + '\']');
    $('span[tagname=\'' + text + '\']').show();
    taglinks.fadeOut("slow");
    taglinks.unbind('click', TagEdit.onTagDeleteClick).removeClass('delete');
    $('span[tagname=\'' + text + '\']').show();
    var project = $('form#edit_tags').attr('project');
    $("#error").hide();
    $.ajax({
      type: "DELETE",
      url: '/p/' + project + '/tags/' + text,
      success: function (data, textStatus) {
        $('p.tags_left').html(data[1]);
        if(data[0] > 0) { $("#edit_tags").show(); }
        TagEdit.updateRelatedProjects();
        $('span[tagname=\'' + text + '\']').hide();
      }
    });
  },
  setTagArray: function(ary) {
    $('span#current_tags').html('');
    for (var i in ary) {
      if (ary[i].length > 0) {
        $('span#current_tags').append(TagEdit.tagLink(ary[i]));
        $('span#recommended_tags a.add[tagname=\'' + ary[i] + '\']').remove();
      }
    }
    $('span#current_tags a.tag').click(TagEdit.onTagDeleteClick).addClass('delete');
    TagEdit.updateRelatedProjects();
    //TagEdit.doAutoComplete();
  },
  tagLink: function(text) {
    return('<a tagname="' + text + '" class="tag delete tag_remove">' + text + '&nbsp;&nbsp;&nbsp;<i class="icon-remove"></i></a>&nbsp;<span class="hidden" tagname="'+ text +'"><img src="/images/spinner.gif"></span>');
  },
  onTagAddClick: function() {
    TagEdit.create($(this).attr('tagname'));
    return false;
  },
  onTagDeleteClick: function() {
    TagEdit.destroy($(this).attr('tagname'));
    return false;
  },
  doAutoComplete: function() {
    var text = $('input#input_tags')[0].value;
    text = text.replace(".", "", "g");
    var project_id = $('form#edit_tags').attr('project_id');
    $('#recommended_tags').html('');
    $('#recommended_spinner').show();
    $.ajax({
      url: '/p/' + project_id + '/autocompletes/tags?term=' + encodeURIComponent(text),
      success: function (data, textStatus) {
        var tags = JSON.parse(data);
        for (var i in tags) {
          if (tags[i].length > 0) {
            $('#recommended_tags').append(TagEdit.tagLink(tags[i]));
            $('#recommended_tags a.tag.add[tagname=\'' + tags[i] + '\']').click(TagEdit.onTagAddClick);
          }
        }
      },
      complete: function() {
        $('#recommended_spinner').hide();
      }
    });
  },
  updateRelatedProjects: function() {
    $('#related_projects').html('');
    $('#related_spinner').show();
    var project = $('form#edit_tags').attr('project');
    $.ajax({
      url: '/p/' + project + '/tags/related',
      success: function (data, textStatus) {
        $('#related_projects').html( data );
        $('#related_projects a.tag.add').click(TagEdit.onTagAddClick);
        $('#related_projects a.tag.delete').click(TagEdit.onTagDeleteClick);
      },
      complete: function() {
        $('#related_spinner').hide();
      }
    });
  }
}
