STAR_COLOR_FILLED = '#ffb91a'
STAR_COLOR_EMPTY  = '#d1d5db'

getCsrfToken = ->
  meta = document.querySelector('meta[name="csrf-token"]')
  if meta then meta.getAttribute('content') else ''

updateStarDisplay = (buttons, score) ->
  buttons.each ->
    svg = $(this).find('.star-svg')
    rating = parseInt($(this).data('rating'), 10)
    if rating <= score
      svg.attr('fill', STAR_COLOR_FILLED).attr('stroke', STAR_COLOR_FILLED)
    else
      svg.attr('fill', 'none').attr('stroke', STAR_COLOR_EMPTY)

ratingAjax = (method, url, ratingContent) ->
  $.ajax
    url: url
    type: method
    headers:
      'X-CSRF-Token': getCsrfToken()
    dataType: 'html'
    success: (html) ->
      if ratingContent.length
        ratingContent.replaceWith(html)
        initInteractiveStars()
    error: (xhr) ->
      console.error('Rating request failed:', xhr.status, xhr.statusText)

initInteractiveStars = ->
  $('.interactive-stars').each ->
    container = $(this)
    return if container.data('bound')
    container.data('bound', true)

    buttons   = container.find('.star-btn')
    rateUrl   = container.data('rate-url')
    unrateUrl = container.data('unrate-url')
    loggedIn  = container.data('logged-in') is true or container.data('logged-in') is 'true'
    userScore = parseInt(container.data('user-score'), 10) or 0
    showParam = encodeURIComponent(container.data('show') or 'projects/show/community_rating')

    updateStarDisplay(buttons, userScore)

    buttons.each ->
      btn = $(this)
      rating = parseInt(btn.data('rating'), 10)

      btn.on 'mouseenter', ->
        updateStarDisplay(buttons, rating)

      btn.on 'mouseleave', ->
        updateStarDisplay(buttons, userScore)

      btn.on 'click', (e) ->
        e.preventDefault()
        e.stopPropagation()

        unless loggedIn
          window.location.href = '/sessions/new?return_to=' + encodeURIComponent(window.location.href)
          return

        newScore = if rating is userScore then 0 else rating
        ratingContent = container.closest('.rating-content')

        if newScore is 0
          ratingAjax('DELETE', unrateUrl + '?show=' + showParam, ratingContent)
        else
          ratingAjax('POST', rateUrl + '?score=' + newScore + '&show=' + showParam, ratingContent)

  # Clear rating button
  $('.clear-rating-btn').each ->
    btn = $(this)
    return if btn.data('bound')
    btn.data('bound', true)

    btn.on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      url = btn.data('url')
      ratingContent = btn.closest('.rating-content')
      ratingAjax('DELETE', url, ratingContent)

# Old jrating-based rating system (used on non-redesigned pages)
App.ProjectRating =
  init: ->
    $("#rating_spinner").hide()
    $('ul.stack_list').change App.ProjectRating.hook_ratings
    @hook_ratings()
    @clear_ratings()
    return
  hook_ratings: ->
    $('.jrating').each (i) ->
      project_id = $(this).attr('id')
      star_style = $(this).attr('star_style') or 'small'
      show = $(this).attr('data-show')
      if $(this).children().length == 0
        $(this).rater '/p/' + project_id + '/rate?show='+show,
          style: star_style
          instantGratification: true
          curvalue: $(this).attr('score')
          read_only: $('.needs_login, .needs_verification, .needs_email_verification').length
          a_klass: if $(this).hasClass('needs_login') then 'needs_login' else ''
          success: (data) ->
            $('#rating_spinner').hide()
            App.ProjectRating.init()

  clear_ratings: ->
    $('#clear').click ->
      $.ajax
        url: $('#clear a').attr('data-url')
        type: 'DELETE'
        beforeSend: ->
          $('#clear').hide()
          $('#rating_spinner').show()
          return
        success: (data) ->
          $('#proj_rating').html data
          $('#rating_spinner').hide()
          App.ProjectRating.init()
          return
      false
    return

$(document).on 'page:change', ->
  App.ProjectRating.init()
  initInteractiveStars()
