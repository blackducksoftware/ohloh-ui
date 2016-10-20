ProjectNewBadge =
  init: () ->
    this.initializeNewBadge(this)
    this.handleEvents(this)

  initializeNewBadge: (_klass) ->
    $("#add_badge_btn").on 'click', (event) ->
      $('#add_badge_btn, #add_new_badge_form').toggle()

  handleEvents: (_klass) ->
    $('#project_badges_page').on 'change', '#select_project_badge', (event) ->
      $('.cii_badge_url, .travis_badge_url').addClass('hidden')
      if $(this).val()=="CiiBadge"
        $('.cii_badge_url').removeClass('hidden')
      else
        $('.travis_badge_url').removeClass('hidden')

    $('#project_badges_page').on 'change', '.badge_url_holder', (event) ->
      $('#project_badge_url').val($(this).val())
      if $("#select_project_badge").val() == 'CiiBadge'
        finalUrl = 'https://bestpractices.coreinfrastructure.org/projects/'+
                   $(this).val()+'/badge'
      else
        finalUrl = 'https://api.travis-ci.org/'+$(this).val()
      i = document.createElement("img")
      i.src = finalUrl
      $('#badge_image_container').empty()
      document.getElementById("badge_image_container").appendChild(i)

    $('#project_badges_page').on 'click', '#save_badge', (event) ->
      $('#new_project_badge').submit()
      false

$(document).on 'page:change', ->
  ProjectNewBadge.init()
