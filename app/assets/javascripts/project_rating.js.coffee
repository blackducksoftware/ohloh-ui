App.ProjectRating =
  init:  ->
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
          read_only: $(this).attr('read_only') or false
          a_klass: if $(this).hasClass('needs_login') then 'needs_login' else ''
          success: (data) ->
            $('#rating_spinner').hide()
            App.ProjectRating.init()
            return
      return
    return
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
