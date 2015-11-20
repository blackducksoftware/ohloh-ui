class App.ProjectForm 
  constructor: ->
    $(document).delegate 'a.remove_license', 'click', ->
      $(this).closest('.license').remove()
      if $('.chosen_licenses').html() == ''
        $('.chosen_licenses').html '<div class="license inset">[None]</div>'
      false

    $('#add_license').autocomplete(
      source: '/autocompletes/licenses'
      select: (event, ui) ->
        if $.trim($('.chosen_licenses div:first').html()) == '[None]'
          $('.chosen_licenses').html ''
        $('#license_menu').clone().appendTo($('.chosen_licenses'))
        $('#license_menu').removeAttr('style')
        $('#license_name').text(ui.item.name)
        $('.remove_license').attr('data_id', ui.item.id)
        $('.chosen_licenses').append $('#license_menu')).autocomplete('instance')._renderItem = (ul, item) ->
        $('<li></li>').data('item.autocomplete', item).append('<p>' + item.name + '</p>').appendTo ul
    
class App.SimilarProjects
  constructor: ->
    return if $('#projects_show_page').length == 0
    projectId = $('#similar_projects').data('project-id')
    $('#similar_projects').html ''
    $('#related_spinner').show()
    $.ajax
      url: "/p/#{projectId}/similar_by_tags"
      success: (data, textStatus) ->
        $('#similar_projects').html data
      complete: ->
        $('#related_spinner').hide()
  
$(document).on 'page:change', -> new App.SimilarProjects()
