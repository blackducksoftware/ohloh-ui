App.Post =
  init: ->
    if $('textarea#post_body').length
      new SimpleMDE({
        element: $('textarea#post_body')[0],
        hideIcons: ["ordered-list"],
        spellChecker: false
      })

$(document).ready ->
  App.Post.init()
