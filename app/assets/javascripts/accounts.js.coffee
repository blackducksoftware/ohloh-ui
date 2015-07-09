$(document).on 'page:change', ->
  if $('#account_affiliation_type').length
    new App.OrganizationSelector('account')
