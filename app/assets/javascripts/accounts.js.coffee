$(document).on 'page:change', ->
  if $('#account_affiliation_type').length
    new App.OrganizationSelector('account')

  
  $('.show-more-2').click ->
    if $('.text-2').hasClass('show-more-height-2')
      $(this).text 'Show Less'
    else
      $(this).text 'Show More'
    $('.text-2').toggleClass 'show-more-height-2'

   $('.show-more-1').click ->
    if $('.text-1').hasClass('show-more-height-1')
      $(this).text 'Show Less'
    else
      $(this).text 'Show More'
    $('.text-1').toggleClass 'show-more-height-1'