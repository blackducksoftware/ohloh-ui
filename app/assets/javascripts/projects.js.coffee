App.ProjectForm = init: ->
    $(document).delegate 'a.remove_license', 'click', ->
      $(this).closest('.license').remove()
      if $('.chosen_licenses').html() == ''
        $('.chosen_licenses').html '<div class="license inset">[None]</div>'
      false
    licenseAutocomplete()
    return

  licenseAutocomplete = () ->
    $('#add_license').autocomplete(
      source: '/autocompletes/licenses'
      select: (event, ui) ->
        if $.trim($('.chosen_licenses div:first').html()) == '[None]'
          $('.chosen_licenses').html ''
        html = ('<div class="license col-md-5 no_margin_left">' + '<div class="col-md-6">#{name}</div>' + '<div class="col-md-5 pull-right" style="margin: 0 20px 20px 0">' + '<a href="#" class="btn btn-danger btn-mini remove_license col" data_id="#{id}">' + '<i class="icon-trash"></i> Remove</a>' + '</div>' + '</div>')._f(ui.item)
        $('.chosen_licenses').append html
        return
    ).autocomplete('instance')._renderItem = (ul, item) ->
      $('<li></li>').data('item.autocomplete', item).append('<p>' + item.name + '</p>').appendTo ul

    return
    
SimilarProjects = init: ->
  if $('#projects_show_page').length == 0
    return
  projectId = $('#similar_projects').data('project-id')
  $('#similar_projects').html ''
  $('#related_spinner').show()
  $.ajax
    url: '/p/' + projectId + '/similar_by_tags'
    success: (data, textStatus) ->
      $('#similar_projects').html data
      return
    complete: ->
      $('#related_spinner').hide()
      return
  return
$(document).on 'page:change', SimilarProjects.init()