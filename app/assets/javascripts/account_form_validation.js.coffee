$(document).on 'page:change', ->
  urlField = document.querySelector('input[name="account[url]"]')
  form = document.querySelector('form[action*="/accounts/"]')

  return unless urlField && form

  validateUrl = (value) ->
    value = (value or '').trim()
    return true unless value.length
    /^https?:\/\//.test(value)

  updateError = ->
    isValid = validateUrl(urlField.value)
    urlField.classList.toggle('is-invalid', !isValid && urlField.value.trim())
    urlField.classList.toggle('is-valid', isValid && urlField.value.trim())

  urlField.addEventListener 'blur', updateError
  urlField.addEventListener 'input', updateError

  form.addEventListener 'submit', (e) ->
    unless validateUrl(urlField.value)
      e.preventDefault()
      urlField.focus()
      urlField.classList.add('is-invalid')
