class App.ProjectForm
  constructor: ->
    $('.chosen_licenses').on 'click', 'a.remove_license', ->
      $('input.license_id_' + $(this).attr('data_id')).remove()
      $(this).closest('.license-cell').remove()
      $('.no-license').show() unless $('.license-cell:visible').length

    @autocompleteLicense() if $('#add_license').length

  autocompleteLicense: ->
    $('#add_license').autocomplete(
      source: '/autocompletes/licenses'
      focus: (event, ui) ->
        $('#add_license').val(ui.item.name)
      select: (event, ui) ->
        $input = $('<input />',
                    type: 'hidden'
                    name: 'project[project_licenses_attributes][][license_id]'
                    class: 'license_id_' + ui.item.id
                    value: ui.item.id)
        $input.insertAfter($('#add_license'))

        $('.no-license').hide()
        $license = $('.license-template').clone()
        $license.removeClass('license-template')
        $license.find('.license_name').text(ui.item.name)
        $license.find('.remove_license').attr('data_id', ui.item.id)
        $('.chosen_licenses').append $license
      ).autocomplete('instance')._renderItem = (ul, item) ->
        $('<li></li>').data('item.autocomplete', item).append('<p>' + item.name + '</p>').appendTo ul

class App.SimilarProjects
  constructor: ->
    return unless $('#projects_show_page').length
    $('#similar_projects').html('')
    $('#related_spinner').removeClass('hidden')
    projectId = $('#similar_projects').data('projectId')
    $.ajax
      url: "/p/#{ projectId }/similar_by_tags.js"
      complete: ->
        $('#related_spinner').addClass('hidden')

$(document).on 'page:change', -> new App.SimilarProjects()
