document.addEventListener 'DOMContentLoaded', ->
  urlField = document.querySelector('input[name="account[url]"]')
  form = document.querySelector('form[action*="/accounts/"]')

  return unless urlField && form

  validateUrl = (value) ->
    return true unless value
    /^(https?|ftp):\/\//.test(value)

  updateError = ->
    isValid = validateUrl(urlField.value)
    urlField.classList.toggle('is-invalid', !isValid && urlField.value)
    urlField.classList.toggle('is-valid', isValid && urlField.value)

  urlField.addEventListener 'blur', updateError
  urlField.addEventListener 'input', updateError

  form.addEventListener 'submit', (e) ->
    unless validateUrl(urlField.value)
      e.preventDefault()
      urlField.focus()
      urlField.classList.add('is-invalid')
