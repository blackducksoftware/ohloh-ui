class App.EnlistmentSelect
  constructor: ->
    addCallbacks()

  addCallbacks = ->
    $('#repository_type').change(->
      hideAllScmInfo()
      if githubUserSelected() then $('.default-url-tags').hide() else $('.default-url-tags').show()
      showRelevantScmInfo()
    ).change()

    $('.enlistment .submit').click(showSpinnerAndSubmit)

  showSpinnerAndSubmit = ->
    $(this).attr('disabled', 'disabled')
    $('.enlistment .spinner').show()
    $('.well.enlistment form').submit()

  hideAllScmInfo = ->
    $('.enlistment .scm_info').hide()
    $('.enlistment .scm_info input').attr('disabled', 'disabled')

  showRelevantScmInfo = ->
    repositoryType = $('#repository_type').val()
    repositoryClass = repositoryType.match(/^.[^A-Z]+/)[0].toLowerCase()
    $repositoryDiv = $(".enlistment .#{ repositoryClass }")
    $repositoryDiv.show()
    $repositoryDiv.find('input').removeAttr('disabled')

  githubUserSelected = ->
    $('#repository_type').val() == 'GithubUser'

$(document).on 'page:change', ->
  new App.EnlistmentSelect()
