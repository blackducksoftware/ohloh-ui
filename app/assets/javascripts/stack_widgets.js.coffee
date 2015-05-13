class StackWidget
  WHITE_SPACE = 4

  constructor: ->
    $('form.customized_stack_badge input[type=radio]').click(activate)
    $('form.customized_stack_badge input[type=text]').change(update).keyup(update)
    $('form.customized_stack_badge input[name="icon_size"]').click(update)
    update() if $("form.customized_stack_badge").length

  activate = ->
    $(this).parent().parent().find('input[type=text]').attr('disabled', 'disabled')
    $(this).siblings('input[type=text]').removeAttr('disabled')

  setJavascript = (iconSize, title, badgeWidth, projectsShown) ->
    scriptTag = $('.embed.javascript pre')
    scriptArgs = "?icon_width=#{ iconSize }&icon_height=#{ iconSize }&title=#{ encodeURIComponent(title) }" +
                  "&width=#{ constrainWidth(badgeWidth) }&projects_shown=#{ projectsShown }&noclear=true"

    scriptSrc = scriptTag.attr('id') + scriptArgs
    newHtml = "<script type='text/javascript' src='#{ scriptSrc }'></script>"
    scriptTag.text(newHtml)

    previewSrc = "#{ scriptTag.attr('id') }#{ scriptArgs }"
    $.ajax
      url: previewSrc
      success: (badge) ->
         $('.preview').html(badge)

  constrainWidth = (inputWidth) ->
    oneWidgetWidth = iconSize() + WHITE_SPACE
    Math.min(25*oneWidgetWidth, Math.max(oneWidgetWidth, inputWidth))

  recalcWidth = ->
    specifiedByIcons = $('#icons')[0].checked
    padding = 8
    border = 1
    extraSpace = padding*2 + border*2
    $pixelInput = $('#pixels ~ input[type=text]')
    $iconsInput = $('#icons ~ input[type=text]')

    if specifiedByIcons
      badgeWidth = parseInt($iconsInput.val()) * (iconSize() + WHITE_SPACE) + extraSpace
      $pixelInput.val parseInt(constrainWidth(badgeWidth))
    else
      icons = parseInt($pixelInput.val() - extraSpace) / (iconSize() + WHITE_SPACE)
      $iconsInput.val parseInt(icons)

  iconSize = ->
    parseInt $('input[name="icon_size"]:checked').val()

  update = ->
    title = $('input.title').val()
    recalcWidth()
    badgeWidth = parseInt($('input#pixels ~ input[type=text]').val())
    maxProjectsShown = 24
    columns = parseInt($('.icons').val())
    projectsShown = if columns < 4 then columns*8 else columns*2
    projectsShown = Math.min(projectsShown, maxProjectsShown)
    setJavascript(iconSize(), title, badgeWidth, projectsShown)

$(document).on 'page:change', ->
  new StackWidget
