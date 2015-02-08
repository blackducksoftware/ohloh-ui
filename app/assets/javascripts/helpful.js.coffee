$ ->
  App.Helpfuls =
    setupVoteLinks: ->
      $('.set-checkbox-and-submit-form').one 'click', ->
        $form = $(this).parent('form')
        value = $(this).data('checkBox')
        $form.find('input:checkbox').prop('checked', value)
        $form.submit()

  App.Helpfuls.setupVoteLinks()
