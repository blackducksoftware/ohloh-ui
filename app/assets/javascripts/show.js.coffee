PersonSummaryAccountAbout =
  init: ()->
    $('#more_about, #less_about').click ->
      $('#about_me_sm, #about_me_all').toggle()

PersonSummaryAdminPanel =
  init: () ->
    $('#close_admin_panel, #open_admin_panel').click ->
      $('#admin_actions_opened, #admin_actions_closed').toggleClass('hidden')

$ ->
  PersonSummaryAccountAbout.init()
  PersonSummaryAdminPanel.init()
