#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

class UpdateProjectCiiBadge
  def run!
    page = 1

    loop do
      cii_projects = fetch_cii_projects(page)
      break if cii_projects.blank?

      create_cii_projects(cii_projects)
      page += 1
    end
  end

  private

  def create_cii_projects(cii_projects)
    cii_projects.each do |project|
      next if CiiBadge.find_by(identifier: project['id'])

      find_repo_enlistment_ids_and_create_badges(project)
      create_project(project['repo_url'], project['id'])
    end
  end

  def create_project(url, identifier)
    return if CiiBadge.find_by(identifier: project['id'])

    match = Forge::Match.first(url)
    return if match.blank?

    project = get_project_and_set_editor_account(match)
    return unless project.save

    enlistment_ids = project.enlistments.ids
    create_cii_badge_from_enlistments(enlistment_ids, identifier)
  rescue StandardError
    nil
  end

  def get_project_and_set_editor_account(match)
    project = match.project
    project.editor_account = Account.hamster
    project.assign_editor_account_to_associations
    project
  end

  def normalize_url(url)
    case url
    when /^https?:\/\/\w+@github.com\/(.+)\.git$/
      "git://github.com/#{$1}"
    when /^https?:\/\/github.com\/(.+)/
      "git://github.com/#{$1}"
    else
      url
    end
  end

  def url_probabilities(url)
    url = url.chomp('/')
    [
      "'#{normalize_url(url)}'",
      "'#{normalize_url(url)}.git'",
      "'#{remove_trailing_git(url)}'",
      "'#{remove_trailing_git(url)}.git'"
    ].join(',')
  end

  def remove_trailing_git(url)
    url.gsub(/.git$/, '')
  end

  def find_repo_enlistment_ids_and_create_badges(project)
    enlistments = get_enlistment_ids_by_repo_url(project['repo_url'])

    create_cii_badge_from_enlistments(enlistments, project['id'])
  end

  def get_enlistment_ids_by_repo_url(url)
    return [] unless url =~ /git/

    repositories = Repository.where("trim(trailing '/' from url) in (#{url_probabilities(url)})")

    get_enlistment_ids_by_repositories(repositories)
  end

  def create_cii_badge_from_enlistments(enlistments, identifier)
    enlistments.each do |enlistment_id|
      create_cii_badge(identifier, enlistment_id)
    end
  end

  def get_enlistment_ids_by_repositories(repositories)
    Enlistment.where(id: repositories.joins(code_locations: :enlistments)
                                     .select('enlistments.id')).ids
  end

  def create_cii_badge(identifier, enlistment_id)
    CiiBadge.create(identifier: identifier, enlistment_id: enlistment_id)
  end

  def fetch_cii_projects(page)
    JSON.parse Net::HTTP.get(URI("#{ENV['CII_API_BASE_URL']}projects.json?page=#{page}"))
  end
end

UpdateProjectCiiBadge.new.run!
