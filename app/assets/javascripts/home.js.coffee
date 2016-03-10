$(document).on 'page:change', ->
  divs = $('p[id^="content-"]')
  i = 0
  do ->
    divs.eq(i).removeClass('hide').fadeIn(400).delay(6000).fadeOut 400, arguments.callee
    i = ++i % divs.length

  $('#icon_text').click ->
    text_data = $('#text').val()
    unless _(text_data).isEmpty()
      $('#search_form').submit()
