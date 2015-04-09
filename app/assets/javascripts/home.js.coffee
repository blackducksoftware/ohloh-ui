$(document).ready ->
  $('#text').focus ->
    $(this).val ''
    return
  $('#text').focusout ->
    $(this).val 'Search  Projects...'
    return
  divs = $('p[id^="content-"]').hide()
  i = 0
  do ->
    divs.eq(i).fadeIn(400).delay(6000).fadeOut 400, arguments.callee
    i = ++i % divs.length
    return
  return