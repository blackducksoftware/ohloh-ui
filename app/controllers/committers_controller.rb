class CommittersController < UnclaimedController
  before_action :session_required, :redirect_unverified_account, only: [:claim, :save_claim]
  before_action :find_committer, except: :index
  before_action :preload_projects_from_positions, only: :save_claim

  def index
    @unclaimed_people = Person.find_unclaimed(q: query_param, find_by: params[:find_by])
    @unclaimed_people_count = Person::Count.unclaimed_by(query_param, params[:find_by])
    preload_emails_from_unclaimed_people
  end

  def show
    @people = Person.where(name_id: @name.id)
                    .includes({ project: [{ best_analysis: :main_language }, :logo] },
                              :name, name_fact: :primary_language)
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
    raise ParamRecordNotFound unless @name

    redirect_to root_path, flash: { error: t('.error') } if @name.people.count.zero?
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

  def query_param
    params[:query] || params[:q]
  end
end
