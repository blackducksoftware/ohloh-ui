$ ->
  download_widget_text = $('textarea.download_url.widget_text')

  new_link = (elem) ->
    chunk = download_widget_text.val().split('"')
    download_widget_text.val(chunk[0] + chunk[1] + chunk[2] + chunk[3] + "?package=" + elem + chunk[4])

  $('form select#package_select').change (e) ->
    new_link($(e.target).val())
