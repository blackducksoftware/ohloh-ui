App.Enlistment = init: ->
  $('#repository_type').change(->
    $('.enlistment .scm_info').hide()
    $('.enlistment .scm_info input').attr('disabled', 'disabled')

    repositoryType = $('#repository_type').val()
    repositoryClass = repositoryType.match(/[A-Z][^A-Z]+/)[0].toLowerCase()
    repositoryDiv = $(".enlistment .#{ repositoryClass }")
    repositoryDiv.show()
    repositoryDiv.find('input').removeAttr('disabled')
  ).change()

  $('.enlistment .submit').click ->
    $(this).attr('disabled', 'disabled')
    $('.enlistment .spinner').show()
    $('.well.enlistment form').submit()

$(document).on 'page:change', ->
  App.Enlistment.init()
