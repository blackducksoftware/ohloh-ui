class App.OrganizationSelector
  constructor: (type) ->
    @$affiliationType = $("##{ type }_affiliation_type")
    @$organizationId = $("##{ type }_organization_id")
    @$organizationName = $("##{ type }_organization_name")

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
