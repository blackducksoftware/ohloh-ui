class App.ThickboxHelper
  constructor: (height, width) ->
    @height = height || 300
    @width = width ||370

  addParams: (url) ->
    url + @queryParameterize('height') + @queryParameterize('width')

  queryParameterize: (param_name) ->
    "&#{ param_name }=#{ this[param_name] }"
