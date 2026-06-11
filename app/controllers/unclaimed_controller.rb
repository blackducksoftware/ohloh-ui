# frozen_string_literal: true

class UnclaimedController < ApplicationController
  protected

  def capture_failed_positions(exception, position)
    position = Position.new(position.permit!)
    position.errors.add(:base, exception.to_s.gsub(/(Validation failed:|,)/, ',' => '<br/>'))
    @positions << position
  end

  def preload_emails_from_unclaimed_people
    email_ids = @unclaimed_people.map do |_name_id, people|
      people.first(12).map { |person| person.name_fact ? person.name_fact.email_address_ids : [] }
    end.flatten

    find_emails(email_ids)
  end

  def preload_emails_and_name_facts_from_projects(projects)
    name_facts = NameFact.where(analysis_id: projects.map(&:best_analysis_id)).where(name_id: @name.id)
    @name_facts_map = name_facts.index_by(&:analysis_id)
    find_emails(name_facts.pluck(:email_address_ids))
  end

  def preload_emails
    email_ids = @people.map { |person| person.name_fact.email_address_ids }.flatten
    find_emails(email_ids)
  end

  def preload_projects_from_positions
    project_ids = params[:positions].pluck(:project_id)
    @projects_map = Project.where(id: project_ids).index_by(&:id)
  end

  def find_emails(email_ids)
    @emails_map = EmailAddress.where(id: email_ids.flatten).index_by(&:id)
  end

  def unclaimed_people(query, find_by, per_page = 10)
    name_ids = Person.unclaimed_people(q: query, find_by: find_by)
                     .joins(:project)
                     .where.not(projects: { best_analysis_id: nil })
                     .limit(per_page).pluck(:name_id)
    unclaimed_people_with_limit(name_ids)
  end

  # NOTE: Fetches all name_ids in a single query then groups in Ruby to avoid N+1.
  def unclaimed_people_with_limit(unclaimed_name_ids)
    people = Person.include_relations_for_name_ids(unclaimed_name_ids).to_a
    grouped = people.group_by(&:name_id)
    unclaimed_name_ids.filter_map do |name_id|
      group = grouped[name_id]
      [name_id, group.first(UNCLAIMED_TILE_LIMIT)] if group
    end
  end
end
