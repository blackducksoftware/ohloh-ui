ProjectNewBadge =
  init: () ->
    this.initializeNewBadge(this)
    this.handleEvents(this)

  initializeNewBadge: (_klass) ->
    $("#add_badge_btn").on 'click', (event) ->
      $('#add_badge_btn, #add_new_badge_form').toggle()
    $('#project_badges_page').on 'click', (event) ->

  handleEvents: (_klass) ->
    $('#project_badges_page').on 'change', '#select_project_badge', (event) ->
      $('.cii_badge_url, .travis_badge_url').addClass('hidden')
      if $(this).val()=="CiiBadge"
        $('.cii_badge_url').removeClass('hidden')
      else
        $('.travis_badge_url').removeClass('hidden')

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
      $(this).siblings('.fa-check-circle').removeClass('hidden')

    $('#project_badges_page').on 'blur', '.edit_url_field', (event) ->

    $('#project_badges_page').on 'click', '.url_update_btn', (event) ->
      if $(this).siblings('.edit_url_field').val() == ''
        alert("Url can't be empty")
        false
      $.ajax
        method: 'PUT'
        data: project_badge:
                identifier: $(this).siblings('.edit_url_field').val()
        url: $(this).data('url')
        success: (data) ->
          alert(data.message)
          $(this).addClass('hidden')
        complete: ->
$(document).on 'page:change', ->
  ProjectNewBadge.init()
