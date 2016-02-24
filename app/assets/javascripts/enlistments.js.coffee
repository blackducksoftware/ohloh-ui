App.Enlistment = init: ->
  $('#repository_type').change(->
    select = $('#repository_type')[0]
    type = select.options[select.selectedIndex].text.substring(0, 3)
    $('.enlistment .svn_cvs').hide()
    $('.enlistment .cvs').hide()
    $('.enlistment .svn').hide()
    $('.enlistment .git').hide()
    $('.enlistment .hg').hide()
    $('.enlistment .bzr').hide()
    $('.svn_cvs input').attr('disabled', 'disabled')
    $('.cvs input').attr('disabled', 'disabled')
    $('.git input').attr('disabled', 'disabled')
    $('.hg input').attr('disabled', 'disabled')
    $('.bzr input').attr('disabled', 'disabled')
    switch type
      when 'CVS'
        $('.enlistment .svn_cvs').show()
        $('.enlistment .cvs').show()
        $('.svn_cvs input').removeAttr('disabled')
        $('.cvs input').removeAttr('disabled')
      when 'Sub'
        $('.enlistment .svn_cvs').show()
        $('.enlistment .svn').show()
        $('.svn_cvs input').removeAttr('disabled')
      when 'Git'
        $('.enlistment .git').show()
        $('.git input').removeAttr('disabled')
      when 'Mer'
        $('.enlistment .hg').show()
        $('.hg input').removeAttr('disabled')
      when 'Baz'
        $('.enlistment .bzr').show()
        $('.bzr input').removeAttr('disabled')
  ).change()

  $('.enlistment .submit').click ->
    $('.enlistment .spinner').show()
$(document).on 'page:change', ->
  App.Enlistment.init()
