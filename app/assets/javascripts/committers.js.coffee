App.Committers =
  init: ->
    return if $('.unclaimed_committers_box').length is 0

    $('.unclaimed_committers_box').hover (->
      App.Committers.enable_selection $(this).children().filter('.entire_commits_container')
    ), ->
      App.Committers.disable_selection $(this).children().filter('.entire_commits_container')
    $('.entire_commits_container').on 'click', 'i.tick_selected', ->
      $(this).removeClass 'icon-ok-sign tick_selected'
      $(this).addClass 'icon-ok-circle tick_unselected'
      $(this).parents('.inner').addClass 'unselected'
      $(this).closest('div').find(':checkbox').removeAttr 'checked'
    $('.entire_commits_container').on 'click', 'i.tick_unselected', ->
      $(this).addClass 'icon-ok-sign tick_selected'
      $(this).removeClass 'icon-ok-circle tick_unselected'
      $(this).parents('.inner').removeClass 'unselected'
      $(this).closest('div').find(':checkbox').attr 'checked', 'checked'
  enable_selection: (entire_commits_container) ->
    entire_commits_container.children('.inner').not('.more').prepend "<span class='selected_contribution'> <i id='selected' class='icon-ok-sign tick_selected'></i></span>"
    entire_commits_container.children('.unselected').children('.selected_contribution').remove()
    entire_commits_container.children('.unselected').prepend "<span class='selected_contribution'> <i class='icon-ok-circle tick_unselected'></i></span>"
  disable_selection: (entire_commits_container) ->
    entire_commits_container.children('.inner').not('.more').children('.selected_contribution').remove()

$ ->
  App.Committers.init()
