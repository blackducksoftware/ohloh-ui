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

  $('#collpase1').parent().click ->
    $('#collpase1').toggleClass('glyphicon-chevron-down glyphicon-chevron-up')
  $('#collpase2').parent().click ->
    $('#collpase2').toggleClass('glyphicon-chevron-down glyphicon-chevron-up')
  $('#collpase3').parent().click ->
    $('#collpase3').toggleClass('glyphicon-chevron-down glyphicon-chevron-up')
  $('#collpase4').parent().click ->
    $('#collpase4').toggleClass('glyphicon-chevron-down glyphicon-chevron-up')
  
