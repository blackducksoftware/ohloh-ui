#= require enlistments

describe 'Enlistments', ->
  beforeEach ->
    @fixtures = fixture.preload('enlistments')[0]
    $('body').append($(@fixtures))
    App.Enlistment.init()

  describe 'submit', ->
    it 'shows spinner on submit', ->
      $('.enlistment').find('.submit').trigger('click')
      isSpinnerVisible = $('.enlistment').find('.spinner').is(':visible')
      expect(isSpinnerVisible).toBe(true)

  describe 'repository type change', ->
    it 'should show bzr repository details', ->
      $('#repository_type').val('BzrRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .bzr').is(':visible')
      expect(isDescription).toBe(true)

    it 'should show hg repository details', ->
      $('#repository_type').val('HgRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .hg').is(':visible')
      expect(isDescription).toBe(true)

    it 'should show Git repository details', ->
      $('#repository_type').val('GitRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .git').is(':visible')
      expect(isDescription).toBe(true)

    it 'should show cvs repository details', ->
      $('#repository_type').val('CVSRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .cvs').is(':visible')
      expect(isDescription).toBe(true)

    it 'should show svn repository details', ->
      $('#repository_type').val('SvnSyncRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .svn').is(':visible')
      expect(isDescription).toBe(true)
