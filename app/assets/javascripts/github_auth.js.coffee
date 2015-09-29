class App.GithubAuth
  AUTH_URL = 'https://github.com/login/oauth/authorize'

  authenticate: ($githubButton) ->
    $githubButton.click ->
      github_url_params = [
        AUTH_URL
        '?client_id=', $(this).data('clientId')
        '&redirect_uri=', $(this).data('redirectUri')
      ]
      window.location.href = github_url_params.join('')

$(document).on 'page:change', ->
  githubAuth = new App.GithubAuth()
  githubAuth.authenticate($('#github-verification'))
