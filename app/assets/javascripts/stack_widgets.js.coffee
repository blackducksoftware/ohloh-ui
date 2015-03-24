class stackWidget
  constructor: ->
    $('form.customized_stack_badge input[type=radio]').click(@activate)
    $('form.customized_stack_badge input[type=text]').change(@update).keyup(@update)
    $('form.customized_stack_badge input[name="icon_size"]').click(@update)
    @update() if $("form.customized_stack_badge").length > 0


  activate: ->
    $(this).parent().parent().find('input[type=text]').attr('disabled', 'disabled')
    $(this).siblings('input[type=text]').removeAttr('disabled')

  set_javascript: (icon_size, title, badge_width, projects_shown) ->
    script_tag = $('.embed.javascript pre')
    script_args = "?icon_width=#{icon_size}&icon_height=#{icon_size}&title=#{encodeURIComponent(title)}" +
                  "&width=#{@constrain_width(badge_width)}&projects_shown=#{projects_shown}&noclear=true"

    script_src = script_tag.attr('id') + script_args;
    new_html = "<script type='text/javascript' src='#{script_src}'></script>"
    script_tag.text(new_html)

    preview_src = "#{script_tag.attr('id')}#{script_args}"
    $.ajax
      url: preview_src
      success: (badge) ->
         $('.preview').html(badge)

  white_space: 4

  constrain_width: (input_width) ->
    one_widget_width = @icon_size() + @white_space
    Math.min(25*one_widget_width, Math.max(one_widget_width, input_width))

  recalc_width: ->
    specified_by_icons = $('#icons')[0].checked
    padding = 8
    border = 1
    extra_space = padding*2 + border*2
    one_widget_width = @icon_size() + @white_space
    $pixel_input = $('#pixels ~ input[type=text]')
    $icons_input = $('#icons ~ input[type=text]')

    if specified_by_icons
      badge_width = parseInt($icons_input.val()) * (@icon_size() + @white_space) + extra_space
      $pixel_input.val parseInt(@constrain_width(badge_width))
    else
      icons = parseInt($pixel_input.val() - extra_space) / (@icon_size() + @white_space)
      $icons_input.val parseInt(icons)

  icon_size: () ->
    parseInt $('input[name="icon_size"]:checked').val()

  update: () =>
    title = $('input.title').val()
    @recalc_width()
    badge_width = parseInt($('input#pixels ~ input[type=text]').val())
    max_projects_shown = 24
    columns = parseInt($('.icons').val())
    projects_shown = if columns < 4 then columns*8 else columns*2
    projects_shown = Math.min(projects_shown, max_projects_shown)
    @set_javascript @icon_size(), title, badge_width, projects_shown

$ ->
  new stackWidget
