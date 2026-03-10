SessionProjects =
  init: ->
    # Back button causes random state to be visible. Ping server to clean it up.
    if $('#sp_menu').length
      timestamp = (new Date).getTime()

      # Avoid caching by appending 'random' number.
      $.ajax
        url: "/session_projects?#{ timestamp }"
        success: SessionProjects.success

    # Initialize compare checkboxes
    SessionProjects.enable()

  enable: ->
    # Update all compare checkboxes on page to match those in the menu.
    # This is primarily so that state will be cleaned up after back button.
    $('.compare-checkbox').removeClass('selected')
    $('.compare-checkbox i').removeClass('fa-check-square-o').addClass('fa-square-o')

    # Mark selected projects from menu
    $('#sp_menu .remove-project').each ->
      project_id = $(this).data('project-id')
      $(".compare-checkbox[data-project-id='#{ project_id }']").addClass('selected')
      $(".compare-checkbox[data-project-id='#{ project_id }'] i").removeClass('fa-square-o').addClass('fa-check-square-o')

    if $('#sp_menu .remove-project').length < 3
      # All checkboxes are enabled.
      $('.compare-checkbox')
        .off('click')
        .on('click', SessionProjects.change)
        .removeClass('disabled')
    else
      # Project limit reached. Can only uncheck checkboxes.
      $('.compare-checkbox.selected')
        .off('click')
        .on('click', SessionProjects.change)
        .removeClass('disabled')
      SessionProjects.disableUnchecked()

    # Activate the remove icons in menu.
    $('#sp_menu .remove-project')
      .off('click')
      .on('click', SessionProjects.remove)

    # Activate toggle button
    $('#compare_toggle_btn')
      .off('click')
      .on('click', SessionProjects.toggleTray)

    # Show/hide the entire compare bar
    if $('#sp_menu .remove-project').length > 0
      $('#sp_menu').fadeIn(200)
      $('#projects_index_page').addClass('has-compare-tray')
    else
      $('#sp_menu').fadeOut(200)
      $('#projects_index_page').removeClass('has-compare-tray')

  disableUnchecked: ->
    $('.compare-checkbox')
      .not('.selected')
      .off('click')
      .addClass('disabled')

  toggleTray: ->
    $tray = $('.compare-tray-content')
    $icon = $('#compare_toggle_btn .toggle-icon')

    if $tray.hasClass('expanded')
      $tray.removeClass('expanded')
      $icon.removeClass('rotate')
    else
      $tray.addClass('expanded')
      $icon.addClass('rotate')
    false

  change: ->
    $checkbox = $(this)
    return false if $checkbox.hasClass('disabled')

    is_selected = $checkbox.hasClass('selected')
    project_id = $checkbox.data('project-id')

    # Show loading state
    $checkbox.addClass('disabled')

    if is_selected
      # Uncheck
      $.ajax
        type: 'POST'
        url: '/session_projects/' + project_id
        data: '_method': 'delete'
        success: SessionProjects.success
        error: -> $checkbox.removeClass('disabled')
    else
      # Check
      $.ajax
        type: 'POST'
        url: '/session_projects?project_id=' + project_id
        success: SessionProjects.success
        error: (xhr) ->
          if xhr.status == 403
            alert(xhr.responseText)
          $checkbox.removeClass('disabled')
    false

  remove: ->
    project_id = $(this).data('project-id')
    $.ajax
      type: 'POST'
      url: '/session_projects/' + project_id
      data: '_method': 'delete'
      success: SessionProjects.success
    false

  success: (data, textStatus, jqXHR) ->
    # Remember if the tray was expanded
    wasExpanded = $('.compare-tray-content').hasClass('expanded')

    # Replace the HTML
    $('#sp_menu').html(data)
    SessionProjects.enable()

    # Restore expanded state if it was open
    if wasExpanded
      $('.compare-tray-content').addClass('expanded')
      $('#compare_toggle_btn .toggle-icon').addClass('rotate')

    false

$(document).on 'page:change', ->
  SessionProjects.init()

# Also initialize on regular page load
$ ->
  SessionProjects.init()
