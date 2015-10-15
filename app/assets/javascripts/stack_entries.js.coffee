class App.StackEntryModalGenerator
  constructor: ->
    $('.new-stack-entry').click ->
      projectId = $(this).data('projectId')
      $.ajax
        url: '/stack_entries/new'
        data: { project_id: projectId }

$(document).on 'page:change', ->
  new App.StackEntryModalGenerator()

App.StackEntryCheckboxes =
  setup: ($inputs) ->
    $inputs.each (index) ->
      $(this).prop('checked', true) if $(this).data('stackEntryId')

    $inputs.click ->
      $parent = $(this).parents('.stack-checkbox-container')
      $spinner = $parent.find('.spinner')
      $spinner.removeClass('hidden')
      stackId = $(this).data('stackId')

      if $(this).prop('checked')
        projectUrlName = $(this).data('projectUrlName')

        $.ajax "/stacks/#{ stackId }/stack_entries",  # stack_stack_entries_path
          type: 'POST'
          data: { stack_entry: { project_id: projectUrlName } }
          dataType: 'json'
          success: (data) ->
            $parent.find('input:checkbox').data('stackEntryId', data.stack_entry_id)
            $parent.find('.message').html "<span class='label label-primary'>stacked</span>"
          complete: ->
            $spinner.addClass('hidden')

      else
        stackEntryId = $(this).data('stackEntryId')

        $.ajax "/stacks/#{ stackId }/stack_entries/#{ stackEntryId }",  # stack_stack_entry_path
          type: 'DELETE'
          dataType: 'json'
          complete: =>
            $spinner.addClass('hidden')
            $parent.find('.message').html "<span class='label label-default'>unstacked</span>"
            $(this).data('stackEntryId', null)
