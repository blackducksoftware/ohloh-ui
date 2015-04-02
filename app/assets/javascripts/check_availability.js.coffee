class App.CheckAvailiability
  VALID_URL_REGEXP = /^[a-zA-Z][\w\-]{0,59}$/
  RESTRICTED_URLS = ['new', 'update', 'show', 'create', 'edit', 'destroy', 'index', 'unsubscribe_emails']

  constructor: ($input) ->
    return unless $input.length
    @$input = $input
    @$preview = $input.next('.availability-preview')
    throttledCheckAvailability = _(@checkAvailabilityForValidValue).throttle(500, leading: false)
    @$input.keyup(throttledCheckAvailability)
    @$input.trigger('keyup') # process value preloaded by soft refresh or back.

  checkAvailabilityForValidValue: =>
    inputValue = @$input.val()
    if inputValue == @$input.attr('value')
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

  setupPreviewSection: ->
    @$preview.removeClass('hidden')
    @$preview.find('.info').addClass('hidden')
    @$preview.find('.value').text("#{ @$input.data('previewBaseUrl') }/#{ @$input.val() }")

  displayAvailabilityPreview: (accountFound) =>
    @setupPreviewSection()
    if accountFound
      @$preview.find('.text-danger').removeClass('hidden')
    else
      @$preview.find('.text-success').removeClass('hidden')
