#! /usr/bin/env ruby

require_relative '../config/environment'

class UpdateProjectCiiBadge
  def run!
    page = 1

    loop do
      cii_projects = fetch_cii_projects(page)
      break if cii_projects.blank?

      cii_projects.each do |project|
        next if cii_badges.include?(project['id'])
        create_cii_badge_for_existing_project(project)
      end
      page += 1
    end
  end

  private

  def create_cii_badge_for_existing_project(project)
    cii_project = cii_project_class.new(*project.values_at('id', 'name', 'homepage_url', 'repo_url'))
    find_enlistment_ids_by_forge(cii_project.repo_url).each do |enlistment_id|
      cii_badge = CiiBadge.new(identifier: cii_project.id, enlistment_id: enlistment_id)
      cii_badge.save if cii_badge.valid?
    end
  end

  def find_enlistment_ids_by_forge(url)
    match = Forge::Match.first(url)
    return [] if match.blank?

    Enlistment.where(id: Repository.matching(match)
                                   .joins(code_locations: :enlistments)
                                   .select('enlistments.id')).ids
  end

  def cii_project_class
    Struct.new(:id, :name, :homepage_url, :repo_url)
  end

  def fetch_cii_projects(page)
    JSON.parse Net::HTTP.get(URI("#{ENV['CII_API_BASE_URL']}projects.json?page=#{page}"))
  end

  def cii_badges
    @cii_badges ||= CiiBadge.pluck(:identifier)
  end
end

UpdateProjectCiiBadge.new.run!
