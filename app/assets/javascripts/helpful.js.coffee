App.Helpfuls =
  setupVoteLinks: ->
    $('.set-checkbox-and-submit-form').one 'click', ->
      $form = $(this).parent('form')
      value = $(this).data('checkBox')
      $form.find('input:checkbox').prop('checked', value)
      $form.submit()
  setupChosenSelect: () ->
    $(".chzn-select").chosen();
    $('#sort_by .chzn-search').hide()
    $('.nav-select-container .chzn-search').show()
    $('.value-select').chosen()
$ ->
  App.Helpfuls.setupVoteLinks()
  App.Helpfuls.setupChosenSelect()
