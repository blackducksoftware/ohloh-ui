$(document).ready ->
  divs = $('p[id^="content-"]').hide()
  i = 0
  do ->
    divs.eq(i).fadeIn(400).delay(6000).fadeOut 400, arguments.callee
    i = ++i % divs.length
    return
  $('#icon_text').click ->
    text_data = $('#text').val()
    if text_data != ''
      $('#search_form').submit()
    return
  return