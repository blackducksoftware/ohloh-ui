ProjectNewBadge =
  init: () ->
    this.initializeNewBadge(this)
    this.handleEvents(this)

  initializeNewBadge: (_klass) ->
    $("#add_badge_btn").on 'click', (event) ->
      $('#add_badge_btn, #add_new_badge_form').toggle()
      $('.chzn-select').chosen()

  handleEvents: (_klass) ->
    $('#project_badges_page').on 'change', '#select_project_badge', (event) ->
      $('.cii_badge_url, .travis_badge_url').addClass('hidden')
      if $(this).val()=="CiiBadge"
        $('.cii_badge_url').removeClass('hidden')
        $('.cii_badge_url .badge_url_holder').trigger('change')
      else
        $('.travis_badge_url').removeClass('hidden')
        $('.travis_badge_url .badge_url_holder').trigger('change')

    $('#project_badges_page').on 'change', '.badge_url_holder', (event) ->
      $(this).parents('tr #badge_url_input_container').find('.badge_url_field').val($(this).val())
      if $(this).parents('tr').find('.selected_badge_val').val() == ('TravisBadge' || 'Travis Badge')
        finalUrl = 'https://api.travis-ci.org/'+$(this).val()
      else
        finalUrl = 'https://bestpractices.coreinfrastructure.org/projects/'+$(this).val()+'/badge'
      i = document.createElement("img")
      i.src = finalUrl
      $(this).parents('tr').find('.badge_image_container').html(i)

    $('#project_badges_page').on 'click', '#save_badge', (event) ->
      $('#new_project_badge').submit()
      false

    $('#project_badges_page').on 'focus', '.edit_url_field', (event) ->
      $(this).addClass('hidden')
      $(this).siblings('.dirty_url_container').removeClass('hidden')
      $(this).siblings('.dirty_url_container').find('.dirty_url_field').focus()

    $('#project_badges_page').on 'click', '.edit_url_close_btn', (event) ->
      urlValObject = $(this).parents('.dirty_url_container').siblings('.edit_url_field.badge_url_holder')
      $(this).siblings('.dirty_url_field').val($(urlValObject).val())
      $(this).parents('.dirty_url_container').addClass('hidden')
      $(urlValObject).removeClass('hidden')

    $('#project_badges_page').on 'click', '.url_update_btn', (event) ->
      currentElement = $(this)
      urlFieldVal = $(this).siblings('.dirty_url_field').val()
      selectedBadge = $(this).parents('tr').find('.selected_badge_val').html()
      if urlFieldVal == ''
        alert("Url can't be empty")
        return
      debugger
      if (selectedBadge != 'Travis CI') && !Number.isInteger(parseInt(urlFieldVal))
        alert("Please enter a numeric value")
        return
      $.ajax
        method: 'PUT'
        data: project_badge:
                identifier: urlFieldVal
        url: $(this).parents('.col-xs-3').find('.edit_url_field').data('url')
        success: (data) ->
          if data.success==true
            parentContainer = $(currentElement).parents('.dirty_url_container')
            $(parentContainer).siblings('.edit_url_field').val(data.value)
            $(this).siblings('.dirty_url_field').val(data.value)
            $(parentContainer).addClass('hidden')
            $(parentContainer).siblings('.edit_url_field').removeClass('hidden')
            $(parentContainer).siblings('.edit_url_field').trigger('change')
          else
            alert(data.errors)

$(document).on 'page:change', ->
  ProjectNewBadge.init()
