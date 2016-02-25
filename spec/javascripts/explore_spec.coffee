#= require explore

describe 'Explore', ->
  beforeEach ->
    @fixtures = fixture.preload('explore')[0]
    $('body').append($(@fixtures))
    App.Explore.handleMoreLessToggleContent()

  describe 'click on more/less toggle links', ->
    it 'should toggle content', ->
      $('a[id^=proj_more_desc_]').trigger('click')
      isFullDesciptionShown = $('#proj_desc_346315_lg').is(':visible')
      expect(isFullDesciptionShown).toBe(true)

      $('a[id^=proj_less_desc_]').trigger('click')
      isTruncatedContentShown = $('#proj_desc_346315_sm').is(':visible')
      expect(isTruncatedContentShown).toBe(true)

