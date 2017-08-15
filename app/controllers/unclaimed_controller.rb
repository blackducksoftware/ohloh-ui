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
    project_ids = params[:positions].map { |position| position[:project_id] }
    @projects_map = Project.where(id: project_ids).index_by(&:id)
  end

  def find_emails(email_ids)
    @emails_map = EmailAddress.where(id: email_ids.flatten).index_by(&:id)
  end

  def unclaimed_people(query, find_by, per_page = nil)
    if query && Person.find_by_name_or_email(q: query).size > OBJECT_MEMORY_CAP
      unclaimed_people_with_limit(query, find_by)
    else
      Person.find_unclaimed(q: query, find_by: find_by, per_page: per_page)
    end
  end

  # NOTE: Since this approach avoids the *includes*, it takes 3x DB time. However this prevents memory hog.
  def unclaimed_people_with_limit(query, find_by)
    unclaimed_name_ids = Person.unclaimed_people(q: query, find_by: find_by).limit(10).pluck(:name_id)

    unclaimed_name_ids.map do |name_id|
      [name_id, Person.include_relations_and_order_by_kudo_position_and_name(name_id).limit(UNCLAIMED_TILE_LIMIT)]
    end
  end
end
