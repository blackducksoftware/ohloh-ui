App.Enlistment = init: ->
  $('#repository_type').change(->
    select = $('#repository_type')[0]
    type = select.options[select.selectedIndex].text.substring(0, 3)
    $('.enlistment .cvs').hide()
    $('.enlistment .svn').hide()
    $('.enlistment .git').hide()
    $('.enlistment .hg').hide()
    $('.enlistment .bzr').hide()
    switch type
      when 'CVS'
        $('.enlistment .cvs').show()
      when 'Sub'
        $('.enlistment .svn').show()
      when 'Git'
        $('.enlistment .git').show()
      when 'Mer'
        $('.enlistment .hg').show()
      when 'Baz'
        $('.enlistment .bzr').show()
  ).change()
  $('.enlistment .submit').click ->
    $('.enlistment .spinner').show()
$(document).on 'page:change', ->
  App.Enlistment.init()
