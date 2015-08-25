class App.CheckAvailiability
  VALID_URL_REGEXP = /^[a-zA-Z][\w\-]{0,59}$/
  RESTRICTED_URLS = ['new', 'update', 'show', 'create', 'edit', 'destroy', 'index', 'unsubscribe_emails']

  constructor: ($input) ->
    return unless $input.length
    @$input = $input
    @$preview = $input.parents('form').find('.availability-preview')
    throttledCheckAvailability = _(@checkAvailabilityForValidValue).throttle(500, leading: false)
    @$input.keyup(throttledCheckAvailability)
    @$input.trigger('keyup') if @$input.val().length # process value preloaded by soft refresh or back.

  appendClass: (className) ->
    $inputContainer = @$input.parents('.input-prepend').first()
    $inputContainer.find('span.add-on')
      .removeClass('text-danger text-success text-warning')
      .addClass(className)
    $inputContainer.find('.error').addClass('hidden')

  checkAvailabilityForValidValue: =>
    inputValue = @$input.val()
    if inputValue == @$input.data('originalValue')
      @$preview.addClass('hidden')
    else
      if inputValue.match(VALID_URL_REGEXP) && not _(RESTRICTED_URLS).contains(inputValue)
        $.ajax
          url: @$input.data('ajaxPath')
          data:
            query: inputValue
          success: @displayAvailabilityPreview
      else
        @setupPreviewSection()
        @$preview.find('.text-warning').removeClass('hidden')
        @appendClass('text-warning')

  setupPreviewSection: ->
    @$preview.removeClass('hidden')
    @$preview.find('.info').addClass('hidden')
    @$preview.find('.value').text("#{ @$input.data('previewBaseUrl') }/#{ @$input.val() }")

  displayAvailabilityPreview: (valueFound) =>
    @setupPreviewSection()
    if valueFound
      @$preview.find('.text-danger').removeClass('hidden')
      @appendClass('text-danger')
    else
      @$preview.find('.text-success').removeClass('hidden')
      @appendClass('')

$(document).on 'page:change', ->
  new App.CheckAvailiability($('input.check-availability'))
