class App.GithubAuth
  AUTH_URL = 'https://github.com/login/oauth/authorize'

  authenticate: ($githubButton) ->
    $githubButton.click ->
      $(this).attr 'disabled', 'disabled'
      github_url_params = [
        AUTH_URL
        '?client_id=', $(this).data('clientId')
        '&redirect_uri=', $(this).data('redirectUri')
        '&scope=', $(this).data('scope')
      ]
      window.location.href = github_url_params.join('')

$(document).on 'page:change', ->
  githubAuth = new App.GithubAuth()
  githubAuth.authenticate($('.github-oauth'))
