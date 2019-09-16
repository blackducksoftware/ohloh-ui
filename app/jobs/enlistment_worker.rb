# frozen_string_literal: true

class EnlistmentWorker
  include Sidekiq::Worker

  def perform(github_username, current_user, project)
    githubuser = GithubUser.new(url: github_username)
    githubuser.save!
    githubuser.create_enlistment_for_project(current_user, project)
    Setting.complete_enlistment_job(project, github_username)
  end
end
