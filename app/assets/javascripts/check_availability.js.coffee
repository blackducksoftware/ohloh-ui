class App.CheckAvailiability
  VALID_URL_REGEXP = /^[a-zA-Z][\w\-]{0,59}$/
  RESTRICTED_URLS = ['new', 'update', 'show', 'create', 'edit', 'destroy', 'index', 'unsubscribe_emails']

  constructor: ($input) ->
    return unless $input.length
    @$input = $input
    @$preview = $input.next('.availability-preview')
    @$preview = $input.parent().next('.availability-preview') unless @$preview.length
    throttledCheckAvailability = _(@checkAvailabilityForValidValue).throttle(500, leading: false)
    @$input.keyup(throttledCheckAvailability)
    @$input.trigger('keyup') if @$input.val().length # process value preloaded by soft refresh or back.

  appendClass: (className) ->
    $('span.add-on').addClass(className)
    $('.error.url_name').addClass('hidden')

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
        @appendClass('text-warning')

  setupPreviewSection: ->
    @$preview.removeClass('hidden')
    @$preview.find('.info').addClass('hidden')
    @$preview.find('.value').text("#{ @$input.data('previewBaseUrl') }/#{ @$input.val() }")

  displayAvailabilityPreview: (accountFound) =>
    @setupPreviewSection()
    if accountFound
      @$preview.find('.text-danger').removeClass('hidden')
      @appendClass('text-danger')
    else
      @$preview.find('.text-success').removeClass('hidden')
      @appendClass('text-success')

$ ->
  new App.CheckAvailiability($('input.check-availability'))
