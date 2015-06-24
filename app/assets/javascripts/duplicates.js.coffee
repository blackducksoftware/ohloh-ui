Duplicates =
  init: () ->
    $('.actions .keep-good').hover(
      ->
        $('.bad:not(:animated)').animate opacity: '0.25', duration: 500
        $('.message.keep-good').show()
      ->
        $('.bad:not(:animated)').animate opacity: '1', duration: 500
        $('.message.keep-good').hide()
    )

    $('.actions .keep-bad').hover(
      ->
        $('.good:not(:animated)').animate opacity: '0.25', duration: 500
        $('.message.keep-bad').show()
      ->
        $('.good:not(:animated)').animate opacity: '1', duration: 500
        $('.message.keep-bad').hide()
    )

$(document).on 'page:change', ->
  Duplicates.init()
