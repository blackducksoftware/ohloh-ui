#= require enlistments

describe 'Enlistments', ->
  beforeEach ->
    @fixtures = fixture.preload('enlistments')[0]
    $('body').append($(@fixtures))
    @bzrUrl = $('.bzr input')
    @hgUrl = $('.hg input')
    @cvsUrl = $('.cvs input')
    @svnUrl = $('.svn input')
    @svncvsUrl = $('.svn_cvs input')
    @gitUrl = $('.git input')
    @githubUrl = $('.github input')
    new App.EnlistmentSelect()

  describe 'submit', ->
    it 'shows spinner on submit', ->
      $('.enlistment').find('.submit').trigger('click')
      isSpinnerVisible = $('.enlistment').find('.spinner').is(':visible')
      expect(isSpinnerVisible).toBe(true)

    it 'should disable submit button once after the first click', ->
      submitBtn = $('.enlistment .submit')
      submitBtn.click()
      expect(submitBtn.is(':disabled')).toBeTruthy()

  describe 'repository type change', ->
    it 'should show bzr repository details', ->
      $('#repository_type').val('BzrRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .bzr').is(':visible')
      isUrlDisabled = $('.bzr input').is(':disabled')
      expect(isDescription).toBeTruthy
      expect(@bzrUrl.is(':disabled')).toBeFalsy
      expect(@hgUrl.is(':disabled')).toBeTruthy

    it 'should show hg repository details', ->
      $('#repository_type').val('HgRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .hg').is(':visible')
      expect(isDescription).toBe(true)
      expect(@hgUrl.is(':disabled')).toBeFalsy
      expect(@svnUrl.is(':disabled')).toBeTruthy

    it 'should show Git repository details', ->
      $('#repository_type').val('GitRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .git').is(':visible')
      expect(isDescription).toBe(true)
      expect(@gitUrl.is(':disabled')).toBeFalsy
      expect(@svnUrl.is(':disabled')).toBeTruthy
      expect(@svncvsUrl.is(':disabled')).toBeTruthy

    it 'should show cvs repository details', ->
      $('#repository_type').val('CvsRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .cvs').is(':visible')
      expect(isDescription).toBe(true)
      expect(@cvsUrl.is(':disabled')).toBeFalsy
      expect(@svnUrl.is(':disabled')).toBeTruthy
      expect(@svncvsUrl.is(':disabled')).toBeFalsy

    it 'should show svn repository details', ->
      $('#repository_type').val('SvnSyncRepository')
      $('#repository_type').trigger('change')
      isDescription = $('.enlistment .svn').is(':visible')
      expect(isDescription).toBe(true)
      expect(@svnUrl.is(':disabled')).toBeFalsy
      expect(@cvsUrl.is(':disabled')).toBeTruthy
      expect(@svncvsUrl.is(':disabled')).toBeFalsy

    it 'should show github user details', ->
      $('#repository_type').val('GithubUser')
      $('#repository_type').trigger('change')
      expect($('.enlistment .github').is(':visible')).toBeTruthy()
      expect(@githubUrl.is(':disabled')).toBeFalsy()
      expect(@svnUrl.is(':disabled')).toBeTruthy()

    it 'should hide the default url field for github repositories', ->
      $('#repository_type').val('GithubUser')
      $('#repository_type').trigger('change')
      expect($('.enlistment .github').is(':visible')).toBeTruthy()
      expect($('.default-url-tags').is(':visible')).toBeFalsy()
