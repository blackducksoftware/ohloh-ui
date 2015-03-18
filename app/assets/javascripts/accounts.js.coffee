$(document).on 'page:change', ->
  if $('#handle-organization-selector').length
    new App.OrganizationSelector('account')
