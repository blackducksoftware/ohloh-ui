class CommittersController < ApplicationController
  before_action :session_required, only: [:claim, :save_claim]
  before_action :find_committer, except: :index
  before_action :preload_projects_from_positions, only: :save_claim

  def index
    @unclaimed_people = Person.find_unclaimed(q: params[:query], find_by: params[:find_by])
    @unclaimed_people_count = Person::Count.unclaimed_by(params[:query], params[:find_by])
    preload_emails_from_unclaimed_people
  end

  def show
    @people = Person.where(name_id: @name.id)
              .includes([[project: [[best_analysis: :main_language], :logo]], :name, name_fact: :primary_language])
    preload_emails
  end

  def claim
    projects = Project.where(id: params[:project_ids])
    @positions = projects.map do |project|
      Position.new(project: project, name: @name)
    end
    preload_emails_and_name_facts_from_projects(projects)
  end

  def save_claim
    @positions = []
    create_positions

    if @positions.present?
      render_claim
    elsif current_user.claim_core.unclaimed_persons_count > 0
      redirect_to committers_path, notice: t('.notice')
    else
      redirect_to account_positions_url(current_user), success: t('.success')
    end
  end

  private

  def find_committer
    @name = Name.from_param(params[:id]).take
    fail ParamRecordNotFound unless @name

    redirect_to message_path, flash: { error: t('.error') } if @name.people.count.zero?
  end

  def render_claim
    projects = Project.where(id: @positions.map(&:project_id))
    preload_emails_and_name_facts_from_projects(projects)
    render :claim
  end

  def create_positions
    params[:positions].each do |position|
      begin
        current_user.position_core.ensure_position_or_alias!(@projects_map[position[:project_id].to_i], @name, true,
                                                             title: position[:title],
                                                             description: position[:description])
      rescue => exception
        capture_failed_positions(exception, position)
      end
    end
  end

  def capture_failed_positions(exception, position)
    position = Position.new(position.permit!)
    position.errors.add(:base, exception.to_s.gsub(/(Validation failed:|,)/, ',' => '<br/>'))
    @positions << position
  end

  def preload_emails_from_unclaimed_people
    email_ids = @unclaimed_people.map do |_name_id, people|
      people.first(12).map { |person| person.name_fact.email_address_ids }
    end.flatten

    find_emails(email_ids)
  end

  def preload_emails_and_name_facts_from_projects(projects)
    name_facts = NameFact.where(analysis_id: projects.map(&:best_analysis_id)).where(name_id: @name.id)
    @name_facts_map = name_facts.index_by(&:analysis_id)
    find_emails(name_facts.pluck(&:email_address_ids))
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
end
