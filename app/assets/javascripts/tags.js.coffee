JumpToTag =
  init: () ->
    $('form[rel=tag_jump]').submit () ->
      console.log 'here'
      if $('input#input_tag').val() != ''
        tag_value = encodeURIComponent $('input#input_tag').val().toLowerCase()
        window.location.href = "/tags?names=#{tag_value}"
      return false

    $('input.tag_autocomplete').autocomplete
      source: '/autocompletes/tags'
      select : (e, ui) ->
        $(this).val(ui.item.value)
        $('form[rel=tag_jump]').submit()

TagCloud =
  init: () ->
    $.fn.tagcloud.defaults =
      size:
        start: 10
        end: 18
        unit: 'pt'
      color:
        start: '#999'
        end: '#000'
    $('#tagcloud a').tagcloud()

TagNew =
  init: () ->
    project_id = $('form#edit_tags').attr('project_id')
    term = $('#input_tags').val()
    $('#input_tags').autocomplete
      source: "/autocompletes/tags?project_id=#{project_id}&term=#{term}"
      select : (evt, ui) ->
        tags_value = ui.item.value
        $('form[rel=tag_edit]').submit()
        $('#input_tags').val('')

TagEdit =
  init: () ->
    return if $('input#input_tags').length == 0
    $('form#edit_tags').submit(TagEdit.onSubmit)
    $('a.tag.add').click(TagEdit.onTagAddClick)
    $('a.tag.delete').click(TagEdit.onTagDeleteClick)

  onSubmit: () ->
    input = $('#input_tags')[0]
    value = $.trim(input.value)
    input.value = ''
    TagEdit.create(value) if value != ""
    return false

  create: (text) ->
    text = text.replace('.', '', 'g')
    taglinks = $("a.tag[tagname='#{text}']");
    taglinks.unbind('click', TagEdit.onTagAddClick).removeClass('add')
    $('.spinner').show()
    $('#error').hide()
    $('#submit').attr("disabled",'')
    project = $('form#edit_tags').attr('project')

    $.ajax
      type: 'POST'
      url: "/p/#{project}/tags"
      data:
        tag_name: text

      success: (data, textStatus) ->
        TagEdit.update_status(text)
        taglinks.click(TagEdit.onTagDeleteClick).addClass('delete')
        TagEdit.setTagArray(data.split('\n'))
        $('.spinner').hide()
        $('#submit').removeAttr('disabled')

      error: (resp) ->
        $('#error').html(resp.responseText).show()
        $('.spinner').hide()
        $('#submit').removeAttr('disabled')

  update_status: (text) ->
    taglinks = $("a.tag[tagname=#{text}']")
    project = $('form#edit_tags').attr('project')
    $.ajax
      type: 'GET'
      url: "/p/#{project}/tags/status"
      success: (data, textStatus) ->
        $('p.tags_left').html(data[1])
        $("#edit_tags").hide() if data[0] < 1

  destroy: (text) ->
    taglinks = $("a.tag[tagname=#{text}']")
    $("span[tagname='#{text}']").show()
    taglinks.fadeOut('slow');
    taglinks.unbind('click', TagEdit.onTagDeleteClick).removeClass('delete')
    $("span[tagname='#{text}']").show()
    project = $('form#edit_tags').attr('project')
    $("#error").hide()
    $.ajax
      type: 'DELETE'
      url: "/p/#{project}/tags#{text}"
      success: (data, textStatus) ->
        $('p.tags_left').html(data[1])
        $("#edit_tags").show() if data[0] > 0
        TagEdit.updateRelatedProjects()
        $("span[tagname='#{text}']").hide();

  setTagArray: (ary) ->
    $('span#current_tags').html('')
    for i in ary
      if ary[i].length > 0
        $('span#current_tags').append(TagEdit.tagLink(ary[i]));
        $("span#recommended_tags a.add[tagname='#{ary[i]}']").remove()
    $('span#current_tags a.tag').click(TagEdit.onTagDeleteClick).addClass('delete')
    TagEdit.updateRelatedProjects()

  tagLink: (text) ->
    "<a tagname='#{text}' class='tag delete tag_remove'>#{text}&nbsp;&nbsp;&nbsp;<i class='icon-remove'></i></a>" +
    "&nbsp;<span class='hidden' tagname='#{text}'><img src='/images/spinner.gif'></span>"

  onTagAddClick: () ->
    TagEdit.create $(this).attr('tagname')
    return false

  onTagDeleteClick: () ->
    TagEdit.destroy($(this).attr('tagname'))
    return false

  doAutoComplete: () ->
    text = $('input#input_tags')[0].value
    text = text.replace('.', '', 'g')
    project_id = $('form#edit_tags').attr('project_id')
    $('#recommended_tags').html('')
    $('#recommended_spinner').show()
    $.ajax
      url: "/p/#{project_id}/autocompletes/tags?term=#{encodeURIComponent(text)}"
      success: (data, textStatus) ->
        tags = JSON.parse(data)
        for i in tags
          if tags[i].length > 0
            $('#recommended_tags').append(TagEdit.tagLink(tags[i]))
            $("#recommended_tags a.tag.add[tagname='#{tags[i]}']").click(TagEdit.onTagAddClick)
      complete: () ->
        $('#recommended_spinner').hide()

  updateRelatedProjects: () ->
    $('#related_projects').html('')
    $('#related_spinner').show()
    project = $('form#edit_tags').attr('project')
    $.ajax
      url: "/p/#{project}/tags/related"
      success: (data, textStatus) ->
        $('#related_projects').html(data)
        $('#related_projects a.tag.add').click(TagEdit.onTagAddClick)
        $('#related_projects a.tag.delete').click(TagEdit.onTagDeleteClick)

      complete: () ->
        $('#related_spinner').hide()

$ ->
  JumpToTag.init()
