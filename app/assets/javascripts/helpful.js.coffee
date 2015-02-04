(($) ->
  $ ->
    Helpfuls.init()
) jQuery

Helpfuls =
  init: ->
    Helpfuls.hook "a.helpful_yes, a.helpful_no"

  hook: (selector) ->
    $(selector).click ->
      $.ajax
        container_id: $(this).parents(".review_container")[0].id
        type: "POST"
        data:
          "helpful[yes]": ($(this).hasClass("helpful_yes"))

        dataType: "json"
        success: (json) ->
          if json.error?
            alert json.error
          else
            $("#" + @container_id + " .helpful_above").replaceWith json.helpful_count_status
            $("#" + @container_id + " .helpful_below").replaceWith json.helpful_yes_or_no_links
            Helpfuls.hook "a.helpful_yes, a.helpful_no"

        error: (request, textStatus, errorThrown) ->
          alert request.responseText

        url: $(this).attr("href")

      false
