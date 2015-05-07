Privacy =
  init: () ->
    status = $("input[type=radio][name='account[email_master]']:checked").val()
    $('#account_email_master_false').click ->
      Privacy.toggleBoxes(false)
      $(this).next('span').addClass('email_opted_out')
      $(this).nextAll(':lt(4)').removeClass('email_opted_in')

    $('#account_email_master_true').click ->
      Privacy.toggleBoxes(true)
      $(this).next("span").addClass("email_opted_in")
      $(this).prevAll(':lt(2)').removeClass("email_opted_out")

    $('#account_email_posts, #account_email_kudos').change ->
        if $('#account_email_posts').val() == 'true' || $('#account_email_kudos').val() == 'true'
          $('#account_email_master_true').trigger('click')

    $("#account_email_master_#{status}").trigger('click')

  toggleBoxes: (true_or_false) ->
    color = if true_or_false then 'black' else 'lightgray'
    if true_or_false == false
      $('#account_email_posts').val(true_or_false.toString())
      $('#account_email_kudos').val(true_or_false.toString())
    $('#account_email_posts').css('color', color)
    $('#account_email_kudos').css('color', color)
    $('ul#email_status').css('color', color)

$ ->
  Privacy.init()
