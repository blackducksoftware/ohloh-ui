$(document).on 'page:change', ->
  if $('#handle-organization-selector').length
    new FillAffiliationAndToggleOrganization()

class FillAffiliationAndToggleOrganization
  constructor: ->
    @$affiliationType = $('#account_affiliation_type')
    @$organizationId = $('#account_organization_id')
    @$organizationName = $('#account_organization_name')

    @$organizationId.change(@fillAffiliationAndToggleOrganization)
    @fillAffiliationAndToggleOrganization()

  fillAffiliationAndToggleOrganization: =>
    @selectedText = @$organizationId.find('option:selected').text().toLowerCase()
    @setAffiliationType()
    @showOrHideOrganizationName()

  setAffiliationType: ->
    if @selectedText is 'unaffiliated' or @selectedText is 'other'
      @$affiliationType.val(@selectedText)
    else
      @$affiliationType.val('specified')

  showOrHideOrganizationName: ->
    if @selectedText is 'other'
      @$organizationName.removeClass('hidden')
    else
      @$organizationName.val('')
      @$organizationName.addClass('hidden')
