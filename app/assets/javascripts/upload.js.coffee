FileUpload =
  init: () ->
    return if $('.ace-file-input').length == 0

    $('.new_file_upload').ace_file_input
      no_file: 'No File ...'
      btn_choose: 'Choose'
      btn_change: 'Change'
      droppable: false
      onchange: null
      before_remove : () ->
        $('.max_size_exceeded').hide()
        $('input[type="submit"]').removeAttr('disabled')
        true

    $('.new_file_upload').on 'change', () ->
      if this.files[0].size > $(this).data('max_size')
        $('input[type="submit"]').attr('disabled', 'disabled')
        $('.max_size_exceeded').show()
      else
        $('input[type="submit"]').removeAttr('disabled')
        $('.max_size_exceeded').hide()

$(document).on 'page:change', ->
  FileUpload.init()
