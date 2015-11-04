#= require enlistments

describe 'Enlistments', ->
  beforeEach -> fixture.load('enlistments')

  it 'shows spinner on submit', ->
    $('.enlistment .submit').trigger('click')
    console.log @fx.find('.enlistment').find('.spinner').attr('class')
    isSpinnerVisible = $('.enlistment .spinner').is(':visible')
    expect(isSpinnerVisible).toBe(true)

  describe 'repository type change', ->
    beforeEach -> fixture.load('enlistments')

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
      $('#repository_type').trigger('change')
      $('#repository_type').val('GitRepository')
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
