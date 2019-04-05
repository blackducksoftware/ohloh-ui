class DuplicatesController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper TagsHelper

  before_action :session_required, :redirect_unverified_account
  before_action :admin_session_required, only: %i[index show resolve]
  before_action :set_project_or_fail, except: %i[index show resolve]
  before_action :find_duplicate, only: %i[edit update destroy]
  before_action :find_good_project, only: %i[create update]
  before_action :project_context, except: %i[index show resolve]
  before_action :must_own_duplicate, only: %i[edit update destroy]
  before_action :find_duplicate_without_project_id, only: %i[resolve show]

  def index
    @resolved_duplicates = Duplicate.where(resolved: true).order(id: :desc).paginate(per_page: 10, page: page_param)
    @unresolved_duplicates = Duplicate.where.not(resolved: true).order(id: :desc)
                                      .paginate(per_page: 10, page: page_param)
  end

  def new
    previous_dupe = @project.duplicates.unresolved.first
    if previous_dupe
      flash[:notice] = t('.cant_dupe_a_dupe', this: @project.name, that: previous_dupe.bad_project.name)
      return redirect_to project_path(@project)
    end
    @duplicate = Duplicate.new(bad_project: @project)
  end

  def create
    @duplicate = Duplicate.new(good_project: @good_project, bad_project: @project,
                               comment: duplicate_params[:comment], account: current_user)
    if @duplicate.save
      flash[:success] = t('.success')
      redirect_to project_path(@duplicate.bad_project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @duplicate.update(good_project: @good_project, comment: duplicate_params[:comment])
      flash[:success] = t('.success')
      redirect_to project_path(@duplicate.bad_project)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @duplicate.destroy
      flash[:success] = t('.success')
    else
      flash[:error] = t('.error')
    end
    redirect_to project_path(@duplicate.bad_project)
  end

  def resolve
    if params[:keep_id].to_i == @duplicate.bad_project_id
      @duplicate.update(bad_project: @duplicate.good_project, good_project: @duplicate.bad_project)
    end

    @duplicate.resolve!(current_user)
    redirect_to admin_duplicates_path, flash: { success: t('.success') }
  end

  def show; end

  def edit; end

  private

  def find_duplicate_without_project_id
    @duplicate = Duplicate.where(id: params[:id]).where.not(resolved: true).take
    raise ParamRecordNotFound if @duplicate.nil?
  end

  def find_duplicate
    @duplicate = Duplicate.where(bad_project_id: @project.id).where(id: params[:id]).take
    raise ParamRecordNotFound if @duplicate.nil?
  end

  def find_good_project
    @good_project = Project.from_param(duplicate_params[:good_project_id].downcase).take
  end

  def duplicate_params
    params.require(:duplicate).permit(%i[good_project_id bad_project_id comment])
  end

  def must_own_duplicate
    return if (@duplicate.account == current_user) || current_user_is_admin?

    flash[:error] = t('duplicates.edit.must_own_duplicate')
    redirect_to project_path(@duplicate.bad_project)
  end
end
