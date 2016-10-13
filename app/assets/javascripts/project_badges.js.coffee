ProjectNewBadge =
  init: () ->
    this.initializeNewBadge(this)
    this.handleEvents(this)

  initializeNewBadge: (_klass) ->


  handleEvents: (_klass) ->
    $('#project_badges_page').on 'change', '#select_project_badge', (event) ->
      $.ajax
        url: $(this).data('target-url') + '?badge_type=' + $(this).val()
        success: (html) ->
          $('#badge_url_input_container').empty().html(html.badge_template)

    $('#project_badges_page').on 'change', '#project_badge_url', (event) ->
      intermediaryUrl = $(this).parent().html()
      finalUrl = intermediaryUrl.replace('<input type="text" name="project_badge[url]" id="project_badge_url">', $(this).val())
      i = document.createElement("img")
      i.src = finalUrl
      $('#badge_image_container').empty()
      document.getElementById("badge_image_container").appendChild(i)
    $('#project_badges_page').on 'click', '#save_badge', (event) ->
      $.ajax
        type: 'POST'
        url: $('#new_project_badge').attr('action')
        data:
          { project_badge: {
              repository_id: $('#select_project_repo').val(),
              type: $('#select_project_badge').val(),
              url:  $('#project_badge_url').val()
            }
          }
        success: (data) ->
          if data.success
            $('.badge_table_container').html(data.content)
      return false
$(document).on 'page:change', ->
  ProjectNewBadge.init()
