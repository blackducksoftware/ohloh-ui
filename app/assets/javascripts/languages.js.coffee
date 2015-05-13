App.Languages =
  init: ->
    $('.last_language').change @add_language

  add_language: ->
    $parent = $(this).parent('.language')
    $clone = $parent.clone(true)
    $clone.insertAfter($parent)
    $(this).removeClass('last_language')
    $(this).unbind('change')
    $parent.removeClass('language')

    $clone.find('.chzn-container').remove()
    $clone.find('select').removeClass('chzn-done').chosen()

$ ->
  App.Languages.init()

