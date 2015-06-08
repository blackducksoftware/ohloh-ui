SessionProjects =
  init: ->
    # Back button causes random state to be visible. Ping server to clean it up.
    if $('#sp_menu').length
      timestamp = (new Date).getTime()

      # Avoid caching by appending 'random' number.
      $.ajax
        url: "/session_projects?#{ timestamp }"
        success: SessionProjects.success

  enable: ->
    # Update all checkboxes on page to match those in the menu.
    # This is primarily so that state will be cleaned up after back button.
    $('.sp_input').prop('checked', false)
    $('.sp_form.styled').removeClass('selected')
    $('#sp_menu .sp_input').each ->
      $(".sp_input[project_id='#{ $(this).attr('project_id') }']").prop('checked', true)
      $("#sp_form_#{ $(this).attr('project_id') }").addClass('selected')

    if $('#sp_menu .sp_input').length < 3
      # All checkboxes are enabled.
      $('.sp_input')
        .unbind('change')
        .bind('change', SessionProjects.change)
        .prop('disabled', false)
        .parent().removeClass('disabled')
    else
      # Project limit reached. Can only uncheck checkboxes.
      $('.sp_input')
        .filter(':checked')
        .unbind('change')
        .bind('change', SessionProjects.change)
        .prop('disabled', false)
        .parent().removeClass 'disabled'
      SessionProjects.disableUnchecked()

    # Activate the x icon.
    $('#sp_menu .sp_input')
      .unbind('click')
      .bind('click', SessionProjects.change)

    # Animate the appearance/disappearance of menu.
    height = '0'
    height = '2.6em' if $('#sp_menu .sp_input').length
    $('#sp_menu').animate { 'min-height': height }, duration: 300

  disableUnchecked: ->
    $('.sp_input')
      .not(':checked')
      .unbind('change')
      .prop('disabled', true)
      .parent().addClass('disabled')

  busy_span: "<span class='busy pull-left' style='padding: 0 18px 0;'>&nbsp;</span>"
  compare_span: "<span class='sp_label pull-left'>Compare</span>"

  change: ->
    checked = $(this).is(':checked')
    checked = false if $(this).hasClass('icon-remove-sign')
    # force false for remove-icons
    project_id = $(this).attr('project_id')
    sel = $('.sp_input[project_id="' + project_id + '"]')
    sel.siblings('span').replaceWith SessionProjects.busy_span
    sel.prop('checked', checked).prop 'disabled', true
    SessionProjects.disableUnchecked()
    if checked
      $.ajax
        type: 'POST'
        url: '/session_projects?project_id=' + project_id
        success: SessionProjects.success
    else
      $.ajax
        type: 'POST'
        url: '/session_projects/' + project_id
        data: '_method': 'delete'
        success: SessionProjects.success
    false

  success: (data, textStatus, jqXHR) ->
    $('#sp_menu').html(data)
    if _(data).isEmpty()
      $('#page').css('margin-top', '0px')
    else
      $('#page').css('margin-top', '52px')
    $('.busy').replaceWith(SessionProjects.compare_span)
    SessionProjects.enable()
    false

$(document).on 'page:change', ->
  SessionProjects.init()
